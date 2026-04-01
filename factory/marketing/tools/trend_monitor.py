"""Trend-Monitoring-System — Erkennt Trends und bewertet Relevanz fuer die Factory.

Datensammlung: deterministisch (Adapter + SerpAPI).
Relevanz-Bewertung: LLM (mid tier).
"""

import json
import logging
import os
import time
from datetime import datetime
from pathlib import Path

logger = logging.getLogger("factory.marketing.tools.trend_monitor")


class TrendMonitor:
    """Erkennt und bewertet Trends aus verschiedenen Quellen."""

    def __init__(self):
        from factory.marketing.tools.ranking_database import RankingDatabase
        from factory.marketing.alerts.alert_manager import MarketingAlertManager

        self.db = RankingDatabase()
        self.alerts = MarketingAlertManager()

        # Adapter laden (Dry-Run)
        self._adapters = {}
        try:
            from factory.marketing.adapters import get_adapter

            for platform in ["youtube", "tiktok", "x"]:
                try:
                    self._adapters[platform] = get_adapter(platform, dry_run=True)
                except Exception:
                    pass
        except Exception:
            pass

        # SerpAPI pruefen
        self._serpapi_available = bool(os.getenv("SERPAPI_API_KEY"))

    # ── SerpAPI Helper ────────────────────────────────────

    def _serpapi_search(self, query: str, engine: str = "google", **kwargs) -> dict | None:
        """SerpAPI-Suche mit Fehlerbehandlung.

        engine: "google", "google_news", "google_trends"
        Returns: Suchergebnisse oder None bei Fehler/kein Key.
        """
        if not self._serpapi_available:
            logger.info("SerpAPI not available — skipping web search")
            return None

        try:
            import requests

            params = {
                "engine": engine,
                "q": query,
                "api_key": os.getenv("SERPAPI_API_KEY"),
                **kwargs,
            }
            time.sleep(1)  # Rate limiting
            response = requests.get("https://serpapi.com/search", params=params, timeout=15)
            if response.status_code == 429:
                logger.warning("SerpAPI rate limited")
                return None
            response.raise_for_status()
            return response.json()
        except Exception as e:
            logger.warning("SerpAPI search failed: %s", e)
            return None

    # ── LLM Helper ────────────────────────────────────────

    def _call_llm(self, prompt: str, max_tokens: int = 4096) -> str:
        """LLM-Call fuer Relevanz-Bewertung. Tool-Level (kein Agent-ID)."""
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

    # ── Scan Sources ──────────────────────────────────────

    def scan_all_sources(self) -> dict:
        """Scannt alle verfuegbaren Quellen nach Trends.

        Quellen:
        1. X Trending Topics (ueber XAdapter)
        2. YouTube Trending (ueber YouTubeAdapter)
        3. Google News (ueber SerpAPI)
        4. Google Trends (ueber SerpAPI)
        """
        result = {
            "x": [],
            "youtube": [],
            "google_news": [],
            "google_trends": [],
            "sources_scanned": 0,
            "sources_failed": 0,
            "timestamp": datetime.now().isoformat(),
        }

        # 1. X Trending
        try:
            x_adapter = self._adapters.get("x")
            if x_adapter and hasattr(x_adapter, "get_trending_topics"):
                x_data = x_adapter.get_trending_topics()
                if isinstance(x_data, dict):
                    result["x"] = x_data.get("topics", x_data.get("trends", []))
                elif isinstance(x_data, list):
                    result["x"] = x_data
                result["sources_scanned"] += 1
            else:
                result["sources_failed"] += 1
        except Exception as e:
            logger.warning("X trending scan failed: %s", e)
            result["sources_failed"] += 1

        # 2. YouTube Trending
        try:
            yt_adapter = self._adapters.get("youtube")
            if yt_adapter and hasattr(yt_adapter, "get_trending"):
                yt_data = yt_adapter.get_trending()
                if isinstance(yt_data, dict):
                    result["youtube"] = yt_data.get("videos", yt_data.get("trending", []))
                elif isinstance(yt_data, list):
                    result["youtube"] = yt_data
                result["sources_scanned"] += 1
            else:
                result["sources_failed"] += 1
        except Exception as e:
            logger.warning("YouTube trending scan failed: %s", e)
            result["sources_failed"] += 1

        # 3. Google News
        try:
            news = self._serpapi_search(
                "AI app development OR autonomous AI factory OR multi-agent system",
                engine="google",
                tbm="nws",
                num=10,
            )
            if news and "news_results" in news:
                result["google_news"] = [
                    {"title": n.get("title", ""), "source": n.get("source", ""),
                     "link": n.get("link", ""), "snippet": n.get("snippet", "")}
                    for n in news["news_results"][:10]
                ]
                result["sources_scanned"] += 1
            elif news and "organic_results" in news:
                result["google_news"] = [
                    {"title": r.get("title", ""), "source": r.get("source", ""),
                     "link": r.get("link", ""), "snippet": r.get("snippet", "")}
                    for r in news["organic_results"][:10]
                ]
                result["sources_scanned"] += 1
            else:
                result["sources_failed"] += 1
        except Exception as e:
            logger.warning("Google News scan failed: %s", e)
            result["sources_failed"] += 1

        # 4. Google Trends
        try:
            trends = self._serpapi_search(
                "AI factory OR multi-agent OR autonomous app",
                engine="google_trends",
            )
            if trends and "interest_over_time" in trends:
                timeline = trends["interest_over_time"].get("timeline_data", [])
                result["google_trends"] = [
                    {"query": t.get("query", ""), "interest": t.get("values", [{}])[0].get("extracted_value", 0)}
                    for t in timeline[-10:]
                ]
                result["sources_scanned"] += 1
            elif trends and "related_queries" in trends:
                rising = trends["related_queries"].get("rising", [])
                result["google_trends"] = [
                    {"query": q.get("query", ""), "interest": q.get("value", 0)}
                    for q in rising[:10]
                ]
                result["sources_scanned"] += 1
            else:
                result["sources_failed"] += 1
        except Exception as e:
            logger.warning("Google Trends scan failed: %s", e)
            result["sources_failed"] += 1

        return result

    # ── Relevanz-Bewertung ────────────────────────────────

    def evaluate_relevance(self, trends_raw: dict) -> list[dict]:
        """LLM bewertet Relevanz jedes Trends fuer die DriveAI Factory."""
        # Flatten all trends into one list
        all_trends = []
        for source, items in trends_raw.items():
            if source in ("sources_scanned", "sources_failed", "timestamp"):
                continue
            if not isinstance(items, list):
                continue
            for item in items:
                if isinstance(item, dict):
                    topic = item.get("topic") or item.get("title") or item.get("query") or str(item)
                    all_trends.append({"topic": topic, "source": source, "raw": item})
                elif isinstance(item, str):
                    all_trends.append({"topic": item, "source": source, "raw": item})

        if not all_trends:
            return []

        # Build LLM prompt
        trend_list = "\n".join(
            f"- [{t['source']}] {t['topic']}" for t in all_trends[:30]
        )

        prompt = f"""Du bist ein Trend-Analyst fuer die DriveAI Factory — eine autonome KI-App-Fabrik mit 108 Agents, 18 Departments, die Apps komplett autonom produziert (iOS, Android, Web, Unity).

Bewerte jeden der folgenden Trends nach Relevanz fuer diese Factory:

{trend_list}

Antworte NUR als JSON-Array. Kein anderer Text. Fuer jeden Trend:
{{
  "topic": "...",
  "source": "...",
  "relevance_score": 0.0 bis 10.0,
  "urgency": "immediate" | "this_week" | "monitor",
  "content_suggestion": "Kurze Empfehlung was die Factory damit machen soll"
}}

Sortiere nach relevance_score absteigend."""

        response = self._call_llm(prompt, max_tokens=4096)
        if not response:
            # Fallback: Simple keyword scoring
            return self._keyword_fallback(all_trends)

        # Parse LLM response
        try:
            # Extract JSON from response
            text = response.strip()
            if "```json" in text:
                text = text.split("```json")[1].split("```")[0].strip()
            elif "```" in text:
                text = text.split("```")[1].split("```")[0].strip()

            evaluated = json.loads(text)
            if not isinstance(evaluated, list):
                evaluated = [evaluated]
        except (json.JSONDecodeError, IndexError):
            logger.warning("Failed to parse LLM trend evaluation — using keyword fallback")
            return self._keyword_fallback(all_trends)

        # Store in DB
        for t in evaluated:
            try:
                self.db.store_trend(
                    source=t.get("source", "unknown"),
                    topic=t.get("topic", ""),
                    description=t.get("content_suggestion", ""),
                    relevance_score=float(t.get("relevance_score", 0)),
                    urgency=t.get("urgency", "monitor"),
                    content_suggestion=t.get("content_suggestion", ""),
                )
            except Exception as e:
                logger.warning("Failed to store trend: %s", e)

        evaluated.sort(key=lambda x: float(x.get("relevance_score", 0)), reverse=True)
        return evaluated

    def _keyword_fallback(self, trends: list[dict]) -> list[dict]:
        """Deterministisches Keyword-Scoring als LLM-Fallback."""
        HIGH_KEYWORDS = {"ai", "autonomous", "agent", "factory", "multi-agent", "app", "llm",
                         "gpt", "claude", "gemini", "automation", "code generation"}
        MID_KEYWORDS = {"tech", "startup", "gaming", "mobile", "ios", "android", "unity"}

        results = []
        for t in trends:
            topic_lower = t["topic"].lower()
            score = 0.0
            for kw in HIGH_KEYWORDS:
                if kw in topic_lower:
                    score += 2.0
            for kw in MID_KEYWORDS:
                if kw in topic_lower:
                    score += 1.0
            score = min(score, 10.0)

            urgency = "monitor"
            if score >= 7:
                urgency = "immediate"
            elif score >= 4:
                urgency = "this_week"

            entry = {
                "topic": t["topic"],
                "source": t["source"],
                "relevance_score": score,
                "urgency": urgency,
                "content_suggestion": "Keyword-basierte Bewertung (kein LLM verfuegbar)",
            }
            results.append(entry)

            self.db.store_trend(
                source=entry["source"], topic=entry["topic"],
                relevance_score=score, urgency=urgency,
                content_suggestion=entry["content_suggestion"],
            )

        results.sort(key=lambda x: x["relevance_score"], reverse=True)
        return results

    # ── Alerts ────────────────────────────────────────────

    def create_trend_alert(self, trend: dict) -> str | None:
        """Erstellt Alert bei hoher Relevanz (>= 7)."""
        score = float(trend.get("relevance_score", 0))
        if score < 7:
            return None

        priority = "high" if score >= 9 else "medium"
        # "system" is a valid ALERT_CATEGORY
        return self.alerts.create_alert(
            type="alert",
            priority=priority,
            category="system",
            source_agent="TrendMonitor",
            title=f"Trend: {trend.get('topic', 'Unknown')[:80]}",
            description=(
                f"Relevanz: {score}/10 | Urgency: {trend.get('urgency', '?')}\n"
                f"Quelle: {trend.get('source', '?')}\n"
                f"Empfehlung: {trend.get('content_suggestion', '-')}"
            ),
            data={"trend": trend},
        )

    # ── Reports ───────────────────────────────────────────

    def create_trend_report(self, period: str = "weekly") -> str:
        """Erstellt Trend-Report aus DB-Daten."""
        days = 7 if period == "weekly" else 30
        trends = self.db.get_trend_history(days=days)

        if not trends:
            # Create minimal report
            report_dir = Path(__file__).resolve().parents[1] / "reports" / "trends"
            report_dir.mkdir(parents=True, exist_ok=True)
            date_str = datetime.now().strftime("%Y-%m-%d")
            path = report_dir / f"trend_report_{date_str}.md"
            path.write_text(f"# Trend Report ({period})\n\nKeine Trends im Zeitraum.\n",
                            encoding="utf-8")
            return str(path)

        # Build context for LLM
        trend_summary = "\n".join(
            f"- [{t['source']}] {t['topic']} (Score: {t.get('relevance_score', '?')}, "
            f"Urgency: {t.get('urgency', '?')})"
            for t in trends[:50]
        )

        prompt = f"""Erstelle einen Trend-Report fuer die DriveAI Factory (autonome KI-App-Fabrik).

Zeitraum: letzte {days} Tage
Anzahl Trends: {len(trends)}

Trends:
{trend_summary}

Format: Markdown mit Sections:
## Executive Summary
## Top Trends (Top 5 nach Relevanz)
## Empfehlungen fuer die Factory
## Ausblick
"""

        report_text = self._call_llm(prompt, max_tokens=4096)
        if not report_text:
            # Fallback: Static report
            lines = [f"# Trend Report ({period})\n",
                     f"Zeitraum: {days} Tage | Trends: {len(trends)}\n"]
            for t in trends[:10]:
                lines.append(f"- **{t['topic']}** (Score: {t.get('relevance_score', '?')}, "
                             f"Quelle: {t['source']})")
            report_text = "\n".join(lines)

        report_dir = Path(__file__).resolve().parents[1] / "reports" / "trends"
        report_dir.mkdir(parents=True, exist_ok=True)
        date_str = datetime.now().strftime("%Y-%m-%d")
        path = report_dir / f"trend_report_{date_str}.md"
        path.write_text(report_text, encoding="utf-8")
        logger.info("Trend report created: %s", path)
        return str(path)

    # ── Query ─────────────────────────────────────────────

    def get_trend_history(self, days: int = 30, min_relevance: float = None) -> list[dict]:
        """Trend-Verlauf aus DB."""
        return self.db.get_trend_history(days=days, min_relevance=min_relevance)
