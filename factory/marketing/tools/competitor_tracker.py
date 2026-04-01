"""Wettbewerber-Tracker — Beobachtet Konkurrenz auf App- und Factory-Ebene.

Datensammlung: deterministisch (SerpAPI + Store-Adapter).
Analyse + Reports: LLM.
"""

import json
import logging
import os
import time
from datetime import datetime
from pathlib import Path

logger = logging.getLogger("factory.marketing.tools.competitor_tracker")


class CompetitorTracker:
    """Systematische Wettbewerber-Beobachtung."""

    # Standard-Wettbewerber auf Factory-Ebene
    DEFAULT_FACTORY_COMPETITORS = [
        {"name": "Cursor", "type": "indirect", "url": "cursor.com"},
        {"name": "Devin", "type": "direct", "url": "devin.ai"},
        {"name": "Replit Agent", "type": "indirect", "url": "replit.com"},
        {"name": "GitHub Copilot Workspace", "type": "indirect", "url": "github.com"},
        {"name": "Lovable", "type": "indirect", "url": "lovable.dev"},
        {"name": "Bolt.new", "type": "indirect", "url": "bolt.new"},
    ]

    # App-Level Wettbewerber pro Projekt
    DEFAULT_APP_COMPETITORS = {
        "echomatch": [
            {"name": "Royal Match", "store_id": "com.dreamgames.royalmatch"},
            {"name": "Candy Crush Saga", "store_id": "com.king.candycrushsaga"},
            {"name": "Puzzle & Dragons", "store_id": "jp.gungho.padEN"},
        ],
    }

    def __init__(self):
        from factory.marketing.tools.ranking_database import RankingDatabase
        from factory.marketing.alerts.alert_manager import MarketingAlertManager

        self.db = RankingDatabase()
        self.alerts = MarketingAlertManager()
        self._serpapi_available = bool(os.getenv("SERPAPI_API_KEY"))

    # ── Internal Helpers ──────────────────────────────────

    def _serpapi_search(self, query: str) -> dict | None:
        """SerpAPI-Suche mit Fehlerbehandlung."""
        if not self._serpapi_available:
            return None
        try:
            import requests

            params = {
                "engine": "google",
                "q": query,
                "api_key": os.getenv("SERPAPI_API_KEY"),
                "num": 5,
            }
            time.sleep(1)
            response = requests.get("https://serpapi.com/search", params=params, timeout=15)
            if response.status_code == 429:
                logger.warning("SerpAPI rate limited")
                return None
            response.raise_for_status()
            return response.json()
        except Exception as e:
            logger.warning("SerpAPI search failed: %s", e)
            return None

    def _call_llm(self, prompt: str, max_tokens: int = 4096) -> str:
        """LLM-Call. Tool-Level."""
        from dotenv import load_dotenv

        load_dotenv(Path(__file__).resolve().parents[3] / ".env")
        try:
            from factory.brain.model_provider import get_model, get_router

            selection = get_model(profile="standard", expected_output_tokens=max_tokens)
            router = get_router()
            response = router.call(
                model_id=selection["model"],
                provider=selection["provider"],
                messages=[{"role": "user", "content": prompt}],
                max_tokens=max_tokens,
                temperature=1.0,
            )
            if response.error:
                raise RuntimeError(response.error)
            return response.content
        except Exception as e:
            logger.error("LLM call failed: %s", e)
            return ""

    def _mock_app_data(self, name: str) -> dict:
        """Mock-Daten als Fallback wenn keine externen Quellen verfuegbar."""
        import hashlib
        import random

        seed = int(hashlib.md5(name.encode()).hexdigest()[:8], 16)
        rng = random.Random(seed)
        return {
            "rating": round(rng.uniform(3.5, 4.8), 1),
            "review_count": rng.randint(5000, 500000),
            "version": f"{rng.randint(1, 5)}.{rng.randint(0, 20)}.{rng.randint(0, 9)}",
            "source": "mock",
        }

    def _mock_factory_data(self, name: str) -> dict:
        """Mock-Daten fuer Factory-Wettbewerber."""
        return {
            "latest_news": f"{name} continues development (mock data)",
            "features": ["AI code generation", "Multi-file editing"],
            "source": "mock",
        }

    # ── App-Level Tracking ────────────────────────────────

    def track_app_competitors(self, project_slug: str,
                              competitors: list[dict] = None) -> dict:
        """Trackt App-Level-Wettbewerber."""
        if competitors is None:
            competitors = self.DEFAULT_APP_COMPETITORS.get(project_slug, [])

        result = {
            "competitors_tracked": 0,
            "changes_detected": 0,
            "alerts_created": 0,
            "details": [],
        }

        for comp in competitors:
            name = comp["name"]
            store_id = comp.get("store_id", "")

            # Daten sammeln: SerpAPI oder Mock
            app_data = self._fetch_app_data(name, store_id)

            # In DB speichern
            self.db.store_competitor(
                level="app",
                competitor_name=name,
                category="gaming",
                store="ios",
                store_rating=app_data.get("rating"),
                review_count=app_data.get("review_count"),
                notes=f"source: {app_data.get('source', 'unknown')}",
            )

            # Snapshot speichern
            import hashlib

            listing_hash = hashlib.md5(
                json.dumps(app_data, sort_keys=True).encode()
            ).hexdigest()

            self.db.store_competitor_snapshot(
                competitor_name=name,
                listing_text_hash=listing_hash,
                rating=app_data.get("rating"),
                review_count=app_data.get("review_count"),
                version=app_data.get("version"),
                metadata=app_data,
            )

            # Change Detection
            changes = self.detect_changes(name)
            detail = {
                "name": name,
                "rating": app_data.get("rating"),
                "review_count": app_data.get("review_count"),
                "changed": changes["changed"],
                "source": app_data.get("source", "unknown"),
            }

            if changes["changed"]:
                result["changes_detected"] += 1
                alerts = self._create_competitor_alerts(name, changes)
                result["alerts_created"] += len(alerts)

            result["details"].append(detail)
            result["competitors_tracked"] += 1

        return result

    def _fetch_app_data(self, name: str, store_id: str) -> dict:
        """Holt App-Daten via SerpAPI oder Mock."""
        if self._serpapi_available:
            data = self._serpapi_search(f"{name} app store rating reviews {store_id}")
            if data:
                # Extract rating/reviews from search results
                snippet_text = ""
                for r in data.get("organic_results", [])[:3]:
                    snippet_text += f" {r.get('snippet', '')} {r.get('title', '')}"

                rating = self._extract_rating(snippet_text)
                reviews = self._extract_review_count(snippet_text)

                if rating or reviews:
                    return {
                        "rating": rating or 4.0,
                        "review_count": reviews or 10000,
                        "version": None,
                        "source": "serpapi",
                    }

        return self._mock_app_data(name)

    # ── Factory-Level Tracking ────────────────────────────

    def track_factory_competitors(self, competitors: list[dict] = None) -> dict:
        """Trackt Factory-Level-Wettbewerber (andere KI-Projekte)."""
        if competitors is None:
            competitors = self.DEFAULT_FACTORY_COMPETITORS

        result = {
            "competitors_tracked": 0,
            "direct": 0,
            "indirect": 0,
            "changes_detected": 0,
            "details": [],
        }

        for comp in competitors:
            name = comp["name"]
            comp_type = comp.get("type", "indirect")

            # Daten sammeln
            factory_data = self._fetch_factory_data(name, comp.get("url", ""))

            # In DB speichern
            self.db.store_competitor(
                level="factory",
                competitor_name=name,
                category=comp_type,
                notes=f"source: {factory_data.get('source', 'unknown')}",
            )

            # Snapshot
            import hashlib

            listing_hash = hashlib.md5(
                json.dumps(factory_data, sort_keys=True).encode()
            ).hexdigest()

            self.db.store_competitor_snapshot(
                competitor_name=name,
                listing_text_hash=listing_hash,
                metadata=factory_data,
            )

            # Change Detection
            changes = self.detect_changes(name)

            detail = {
                "name": name,
                "type": comp_type,
                "changed": changes["changed"],
                "source": factory_data.get("source", "unknown"),
            }

            if changes["changed"]:
                result["changes_detected"] += 1

            result["details"].append(detail)
            result["competitors_tracked"] += 1

            if comp_type == "direct":
                result["direct"] += 1
            else:
                result["indirect"] += 1

        return result

    def _fetch_factory_data(self, name: str, url: str) -> dict:
        """Holt Factory-Competitor-Daten via SerpAPI oder Mock."""
        if self._serpapi_available:
            data = self._serpapi_search(f"{name} AI latest features news 2026")
            if data:
                news_items = []
                for r in data.get("organic_results", [])[:3]:
                    news_items.append({
                        "title": r.get("title", ""),
                        "snippet": r.get("snippet", ""),
                        "link": r.get("link", ""),
                    })
                if news_items:
                    return {
                        "latest_news": news_items[0].get("title", ""),
                        "news_items": news_items,
                        "source": "serpapi",
                    }

        return self._mock_factory_data(name)

    # ── Change Detection ──────────────────────────────────

    def detect_changes(self, competitor_name: str) -> dict:
        """Vergleicht aktuellen gegen vorherigen Snapshot."""
        base = self.db.detect_competitor_changes(competitor_name)
        changes = base.get("changes", {})

        # Determine significance
        significance = "none"
        if not changes:
            return {"changed": False, "changes": {}, "significance": "none"}

        if "rating" in changes:
            old, new = changes["rating"]
            try:
                diff = abs(float(new) - float(old))
                if diff > 0.5:
                    significance = "critical"
                elif diff > 0.3:
                    significance = "major"
                else:
                    significance = "minor"
            except (ValueError, TypeError):
                significance = "minor"

        if "review_count" in changes and significance != "critical":
            old, new = changes["review_count"]
            try:
                if int(new) > int(old) * 2:
                    significance = "major"
                elif significance == "none":
                    significance = "minor"
            except (ValueError, TypeError):
                pass

        if "version" in changes and significance == "none":
            significance = "minor"

        if "listing_text_hash" in changes and significance == "none":
            significance = "minor"

        return {"changed": True, "changes": changes, "significance": significance}

    # ── Alerts ────────────────────────────────────────────

    def _create_competitor_alerts(self, competitor_name: str,
                                  changes: dict) -> list[str]:
        """Erstellt Alerts basierend auf Aenderungen."""
        alert_ids = []
        significance = changes.get("significance", "none")

        if significance in ("major", "critical"):
            priority = "high" if significance == "critical" else "medium"
            change_details = json.dumps(changes.get("changes", {}), default=str)

            try:
                aid = self.alerts.create_alert(
                    type="alert",
                    priority=priority,
                    category="ranking",
                    source_agent="CompetitorTracker",
                    title=f"Competitor Change: {competitor_name} ({significance})",
                    description=(
                        f"Wettbewerber {competitor_name} hat signifikante Aenderungen.\n"
                        f"Details: {change_details}"
                    ),
                    data={"competitor": competitor_name, "changes": changes},
                )
                alert_ids.append(aid)
            except Exception as e:
                logger.warning("Failed to create competitor alert: %s", e)

        return alert_ids

    # ── Reports ───────────────────────────────────────────

    def create_competitor_report(self, level: str = "app",
                                 project_slug: str = None) -> str:
        """Erstellt Wettbewerber-Report via LLM."""
        # Get data from DB
        conn = self.db._connect()
        try:
            rows = conn.execute(
                "SELECT * FROM competitors WHERE level = ? ORDER BY date DESC LIMIT 50",
                (level,),
            ).fetchall()
            competitors = [dict(r) for r in rows]
        finally:
            conn.close()

        if not competitors:
            # Minimal report
            report_dir = Path(__file__).resolve().parents[1] / "reports" / "competitors"
            report_dir.mkdir(parents=True, exist_ok=True)
            date_str = datetime.now().strftime("%Y-%m-%d")
            path = report_dir / f"competitor_report_{level}_{date_str}.md"
            path.write_text(
                f"# Competitor Report ({level})\n\nKeine Wettbewerberdaten vorhanden.\n",
                encoding="utf-8",
            )
            return str(path)

        comp_summary = "\n".join(
            f"- {c['competitor_name']} (Rating: {c.get('store_rating', 'N/A')}, "
            f"Reviews: {c.get('review_count', 'N/A')}, Category: {c.get('category', '?')})"
            for c in competitors[:20]
        )

        prompt = (
            f"Erstelle einen Wettbewerber-Report fuer die DriveAI Factory.\n"
            f"Level: {level}\n"
            f"Wettbewerber:\n{comp_summary}\n\n"
            f"Format: Markdown mit:\n"
            f"## Uebersicht\n## Staerken/Schwaechen Analyse\n"
            f"## Empfehlungen fuer DriveAI\n## Risiken"
        )

        report_text = self._call_llm(prompt, max_tokens=4096)
        if not report_text:
            lines = [f"# Competitor Report ({level})\n"]
            for c in competitors[:10]:
                lines.append(f"- **{c['competitor_name']}**: "
                             f"Rating {c.get('store_rating', '?')}, "
                             f"{c.get('review_count', '?')} Reviews")
            report_text = "\n".join(lines)

        report_dir = Path(__file__).resolve().parents[1] / "reports" / "competitors"
        report_dir.mkdir(parents=True, exist_ok=True)
        date_str = datetime.now().strftime("%Y-%m-%d")
        path = report_dir / f"competitor_report_{level}_{date_str}.md"
        path.write_text(report_text, encoding="utf-8")
        logger.info("Competitor report created: %s", path)
        return str(path)

    def create_differentiator_matrix(self, project_slug: str) -> str:
        """Was kann die Factory/App was die Konkurrenz nicht kann."""
        # Get competitor data
        conn = self.db._connect()
        try:
            rows = conn.execute(
                "SELECT * FROM competitors ORDER BY date DESC LIMIT 30",
            ).fetchall()
            competitors = [dict(r) for r in rows]
        finally:
            conn.close()

        comp_list = ", ".join(set(c["competitor_name"] for c in competitors)) or "keine Daten"

        prompt = (
            f"Erstelle eine Differentiator-Matrix fuer das DriveAI-Projekt '{project_slug}'.\n\n"
            f"DriveAI Factory: 108 Agents, 18 Departments, autonome App-Produktion "
            f"(iOS, Android, Web, Unity), $0.08 pro Run, End-to-End Pipeline.\n\n"
            f"Wettbewerber: {comp_list}\n\n"
            f"Format: Markdown-Tabelle mit:\n"
            f"| Feature | DriveAI | Wettbewerber | Vorteil |\n"
            f"Dann: ## Unique Selling Points\n## Luecken\n## Empfehlungen"
        )

        report_text = self._call_llm(prompt, max_tokens=4096)
        if not report_text:
            report_text = f"# Differentiator Matrix — {project_slug}\n\nKein LLM verfuegbar.\n"

        report_dir = Path(__file__).resolve().parents[1] / "reports" / "competitors"
        report_dir.mkdir(parents=True, exist_ok=True)
        date_str = datetime.now().strftime("%Y-%m-%d")
        path = report_dir / f"differentiators_{project_slug}_{date_str}.md"
        path.write_text(report_text, encoding="utf-8")
        logger.info("Differentiator matrix created: %s", path)
        return str(path)

    # ── Util ──────────────────────────────────────────────

    @staticmethod
    def _extract_rating(text: str) -> float | None:
        """Extrahiert Rating aus Text (z.B. '4.5 out of 5', '4.7★')."""
        import re

        patterns = [
            r"(\d\.\d)\s*(?:out of|/)\s*5",
            r"(\d\.\d)\s*(?:stars?|★|⭐)",
            r"rating[:\s]*(\d\.\d)",
        ]
        for p in patterns:
            m = re.search(p, text, re.IGNORECASE)
            if m:
                val = float(m.group(1))
                if 0 <= val <= 5:
                    return val
        return None

    @staticmethod
    def _extract_review_count(text: str) -> int | None:
        """Extrahiert Review-Count aus Text (z.B. '1.2M reviews', '500K ratings')."""
        import re

        patterns = [
            r"([\d,.]+)\s*[Mm]\s*(?:reviews?|ratings?)",
            r"([\d,.]+)\s*[Kk]\s*(?:reviews?|ratings?)",
            r"([\d,.]+)\s*(?:reviews?|ratings?)",
        ]
        for i, p in enumerate(patterns):
            m = re.search(p, text)
            if m:
                num_str = m.group(1).replace(",", "")
                try:
                    val = float(num_str)
                    if i == 0:
                        return int(val * 1_000_000)
                    elif i == 1:
                        return int(val * 1_000)
                    return int(val)
                except ValueError:
                    pass
        return None
