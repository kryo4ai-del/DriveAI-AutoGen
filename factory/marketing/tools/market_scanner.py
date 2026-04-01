"""App-Markt-Scanner — Findet Marktluecken und generiert App-Ideen.

Der ultimative Kreislauf:
Scanner -> Idee -> CEO-Gate -> Pre-Production -> Factory baut -> Marketing vermarktet -> Scanner lernt.
"""

import json
import logging
import os
import re
import time
from datetime import datetime
from pathlib import Path

logger = logging.getLogger("factory.marketing.tools.market_scanner")


class AppMarketScanner:
    """Systematische Marktluecken-Erkennung und App-Ideen-Generierung."""

    CATEGORIES = ["games", "productivity", "education", "health", "finance", "entertainment"]

    def __init__(self):
        from factory.marketing.tools.ranking_database import RankingDatabase
        from factory.marketing.alerts.alert_manager import MarketingAlertManager

        self.db = RankingDatabase()
        self.alerts = MarketingAlertManager()
        self._serpapi_available = bool(os.getenv("SERPAPI_API_KEY"))

    # ── Internal Helpers ──────────────────────────────────

    def _serpapi_search(self, query: str) -> dict | None:
        """SerpAPI-Suche."""
        if not self._serpapi_available:
            return None
        try:
            import requests

            params = {
                "engine": "google",
                "q": query,
                "api_key": os.getenv("SERPAPI_API_KEY"),
                "num": 10,
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

    def _call_llm(self, prompt: str, max_tokens: int = 2048) -> str:
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

    def _parse_json(self, text: str) -> list | dict:
        """Parst JSON aus LLM-Response."""
        if not text:
            return []
        text = text.strip()
        if "```json" in text:
            text = text.split("```json")[1].split("```")[0].strip()
        elif "```" in text:
            text = text.split("```")[1].split("```")[0].strip()
        try:
            return json.loads(text)
        except json.JSONDecodeError:
            return []

    # ── Category Trends ───────────────────────────────────

    def scan_category_trends(self, categories: list[str] = None) -> dict:
        """Scannt App-Store-Kategorien nach Trends."""
        if categories is None:
            categories = self.CATEGORIES

        result = {"categories_scanned": 0, "results": {}}

        for cat in categories:
            cat_result = {"top_apps": [], "growing_trends": [], "saturation": "medium"}

            # SerpAPI: top apps
            data = self._serpapi_search(f"top {cat} apps 2026")
            if data:
                for r in data.get("organic_results", [])[:5]:
                    cat_result["top_apps"].append(r.get("title", "")[:80])

            # SerpAPI: trending
            data2 = self._serpapi_search(f"trending {cat} app new 2026")
            if data2:
                for r in data2.get("organic_results", [])[:3]:
                    cat_result["growing_trends"].append(r.get("title", "")[:80])

            # Saturation estimate
            if len(cat_result["top_apps"]) >= 5:
                cat_result["saturation"] = "high"
            elif len(cat_result["top_apps"]) == 0:
                cat_result["saturation"] = "low"

            # LLM analysis if we have data
            if cat_result["top_apps"] or cat_result["growing_trends"]:
                prompt = (
                    f"Kategorie: {cat}. Top Apps: {cat_result['top_apps'][:5]}. "
                    f"Trends: {cat_result['growing_trends'][:3]}. "
                    "Ist diese Kategorie ueber- oder unterversorgt? "
                    "Antworte NUR: 'high', 'medium' oder 'low'."
                )
                response = self._call_llm(prompt, max_tokens=64)
                if response:
                    resp_lower = response.strip().lower().strip("'\".")
                    if resp_lower in ("high", "medium", "low"):
                        cat_result["saturation"] = resp_lower

            result["results"][cat] = cat_result
            result["categories_scanned"] += 1

        return result

    # ── Market Gaps ───────────────────────────────────────

    def find_market_gaps(self, category: str) -> list[dict]:
        """Identifiziert Marktluecken in einer Kategorie."""
        # Scan if not already done
        trends = self.scan_category_trends([category])
        cat_data = trends.get("results", {}).get(category, {})

        # Factory capabilities summary
        factory_caps = (
            "Die DriveAI Factory kann bauen: "
            "iOS Apps (Swift/SwiftUI), Android Apps (Kotlin), Web Apps (React/TypeScript), "
            "Unity Games. Staerken: Puzzle Games, Casual Games, Productivity Tools, "
            "Finance Dashboards, Education Apps. "
            "Einschraenkungen: Kein Backend/Server, kein AR/VR, keine Hardware-Integration."
        )

        prompt = (
            f"Kategorie: {category}\n"
            f"Markt-Daten: {json.dumps(cat_data, ensure_ascii=False, default=str)}\n"
            f"Factory-Capabilities: {factory_caps}\n\n"
            "Identifiziere 3 Marktluecken die die Factory fuellen koennte. "
            "Antworte NUR als JSON-Array:\n"
            '[{"gap_description": "...", "category": "...", "target_audience": "...", '
            '"estimated_potential": "high|medium|low", "factory_feasibility": "high|medium|low", '
            '"reasoning": "..."}]'
        )

        response = self._call_llm(prompt, max_tokens=2048)
        gaps = self._parse_json(response)

        if isinstance(gaps, list) and gaps:
            return gaps

        # Fallback
        return [{
            "gap_description": f"Innovative {category} App mit KI-Features",
            "category": category,
            "target_audience": "18-35 Tech-Enthusiasten",
            "estimated_potential": "medium",
            "factory_feasibility": "high",
            "reasoning": f"Wenig KI-native Apps in der {category}-Kategorie",
        }]

    # ── App Idea ──────────────────────────────────────────

    def create_app_idea(self, gap: dict) -> dict:
        """Aus einer Marktluecke eine konkrete App-Idee formulieren."""
        prompt = (
            f"Marktluecke: {json.dumps(gap, ensure_ascii=False, default=str)}\n\n"
            "Erstelle eine konkrete App-Idee. Antworte NUR als JSON:\n"
            '{"app_name": "...", "one_liner": "...", "target_audience": "...", '
            '"core_features": ["...", "...", "..."], '
            '"monetization": "...", "estimated_potential": "high|medium|low", '
            '"why_factory_should_build": "..."}'
        )

        response = self._call_llm(prompt, max_tokens=1024)
        idea = self._parse_json(response)

        if isinstance(idea, dict) and idea.get("app_name"):
            return idea

        # Fallback
        return {
            "app_name": f"{gap.get('category', 'New').title()}AI",
            "one_liner": gap.get("gap_description", "Innovative App"),
            "target_audience": gap.get("target_audience", "18-35"),
            "core_features": ["KI-gestuetzte Interaktion", "Personalisierung", "Offline-Modus"],
            "monetization": "Freemium + In-App-Kaeufe",
            "estimated_potential": gap.get("estimated_potential", "medium"),
            "why_factory_should_build": "Passt perfekt zur Factory-Architektur",
        }

    # ── Pipeline Integration ──────────────────────────────

    def submit_idea_to_pipeline(self, idea: dict, project_slug: str = None) -> dict:
        """Schreibt Idee als Dokument und erstellt CEO-Gate."""
        # Generate slug
        if not project_slug:
            name = idea.get("app_name", "new_app")
            project_slug = re.sub(r"[^a-z0-9]+", "_", name.lower()).strip("_")

        # Write idea document
        idea_md = self.get_pipeline_compatible_idea(idea)
        ideas_dir = Path(__file__).resolve().parents[1] / "output" / "ideas"
        ideas_dir.mkdir(parents=True, exist_ok=True)
        idea_path = ideas_dir / f"{project_slug}_idea.md"
        idea_path.write_text(idea_md, encoding="utf-8")

        # Create CEO Gate
        gate_id = self.alerts.create_gate_request(
            source_agent="AppMarketScanner",
            title=f"Neue App-Idee: {idea.get('app_name', project_slug)}",
            description=(
                f"Der Market Scanner hat eine Marktluecke identifiziert.\n"
                f"App: {idea.get('app_name', '?')}\n"
                f"Konzept: {idea.get('one_liner', '?')}\n"
                f"Potenzial: {idea.get('estimated_potential', '?')}"
            ),
            options=[
                {"label": "In Pre-Production aufnehmen", "description": "Projekt starten"},
                {"label": "Auf Wiedervorlage", "description": "Spaeter nochmal pruefen"},
                {"label": "Ablehnen", "description": "Idee verwerfen"},
            ],
        )

        logger.info("Idea submitted: %s (gate: %s)", project_slug, gate_id)
        return {"idea_path": str(idea_path), "gate_id": gate_id}

    def get_pipeline_compatible_idea(self, idea: dict) -> str:
        """Formatiert eine Idee als Pre-Production-kompatibles Markdown."""
        name = idea.get("app_name", "Neue App")
        one_liner = idea.get("one_liner", "")
        audience = idea.get("target_audience", "")
        features = idea.get("core_features", [])
        monetization = idea.get("monetization", "")
        why = idea.get("why_factory_should_build", "")

        features_md = "\n".join(f"- {f}" for f in features)

        return (
            f"# App-Idee: {name}\n\n"
            f"## Konzept\n{one_liner}\n\n"
            f"## Zielgruppe\n{audience}\n\n"
            f"## Kernfeatures\n{features_md}\n\n"
            f"## Monetarisierung\n{monetization}\n\n"
            f"## Warum jetzt\n{why}\n"
        )

    # ── Market Report ─────────────────────────────────────

    def create_market_report(self, period: str = "quarterly") -> str:
        """Quartals-Marktbericht."""
        trends = self.scan_category_trends()

        lines = [
            f"# App Market Report ({period})\n",
            f"Datum: {datetime.now().strftime('%Y-%m-%d')}\n",
            f"## Kategorien gescannt: {trends['categories_scanned']}\n",
        ]

        for cat, data in trends.get("results", {}).items():
            lines.append(f"### {cat.title()}")
            lines.append(f"- Saturation: {data.get('saturation', '?')}")
            if data.get("top_apps"):
                lines.append(f"- Top Apps: {', '.join(data['top_apps'][:3])}")
            if data.get("growing_trends"):
                lines.append(f"- Trends: {', '.join(data['growing_trends'][:3])}")
            lines.append("")

        report_dir = Path(__file__).resolve().parents[1] / "reports" / "market"
        report_dir.mkdir(parents=True, exist_ok=True)
        date_str = datetime.now().strftime("%Y-%m-%d")
        path = report_dir / f"market_report_{date_str}.md"
        path.write_text("\n".join(lines), encoding="utf-8")
        logger.info("Market report: %s", path)
        return str(path)
