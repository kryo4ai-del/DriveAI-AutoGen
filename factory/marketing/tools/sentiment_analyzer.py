"""Sentiment-Analyse — Misst oeffentliche Stimmung zu KI-Apps/Factory.

Datensammlung: deterministisch (SerpAPI + Adapter).
Analyse: LLM.
"""

import json
import logging
import os
import time
from datetime import datetime
from pathlib import Path

logger = logging.getLogger("factory.marketing.tools.sentiment_analyzer")


class SentimentAnalyzer:
    """Analysiert oeffentliche Stimmung auf drei Ebenen."""

    TOPICS = {
        "ai_apps": {
            "queries": ["AI generated app", "KI-generierte App", "AI mobile app quality"],
            "description": "Oeffentliche Meinung zu KI-generierten Apps",
        },
        "autonomous_ai": {
            "queries": ["autonomous AI system", "multi-agent AI", "AI replacing developers"],
            "description": "Stimmung gegenueber autonomen KI-Systemen",
        },
        "driveai": {
            "queries": ['"DriveAI Factory"', '"DriveAI" AI factory', '"DriveAI" app'],
            "description": "Spezifische Erwaehnung der DriveAI Factory",
        },
    }

    LABELS = {
        (-1.0, -0.6): "very_negative",
        (-0.6, -0.2): "negative",
        (-0.2, 0.2): "neutral",
        (0.2, 0.6): "positive",
        (0.6, 1.01): "very_positive",
    }

    def __init__(self):
        from factory.marketing.tools.ranking_database import RankingDatabase
        from factory.marketing.alerts.alert_manager import MarketingAlertManager

        self.db = RankingDatabase()
        self.alerts = MarketingAlertManager()
        self._serpapi_available = bool(os.getenv("SERPAPI_API_KEY"))

    # ── Internal Helpers ──────────────────────────────────

    def _serpapi_search(self, query: str, engine: str = "google", **kwargs) -> dict | None:
        """SerpAPI-Suche."""
        if not self._serpapi_available:
            return None
        try:
            import requests

            params = {
                "engine": engine,
                "q": query,
                "api_key": os.getenv("SERPAPI_API_KEY"),
                "num": 10,
                **kwargs,
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

    @staticmethod
    def _score_to_label(score: float) -> str:
        """Konvertiert Score zu Label."""
        for (low, high), label in SentimentAnalyzer.LABELS.items():
            if low <= score < high:
                return label
        return "neutral"

    # ── Scan ──────────────────────────────────────────────

    def scan_sentiment(self, topic: str, sources: list[str] = None,
                       days: int = 7) -> dict:
        """Sammelt Texte zum Thema aus verschiedenen Quellen."""
        if sources is None:
            sources = ["news", "reddit", "x"]

        topic_config = self.TOPICS.get(topic, {"queries": [topic], "description": topic})
        queries = topic_config["queries"]

        result = {
            "topic": topic,
            "sources_scanned": 0,
            "texts_collected": 0,
            "texts": [],
            "scan_date": datetime.now().isoformat(),
        }

        for source in sources:
            texts = self._scan_source(source, queries)
            if texts:
                result["texts"].extend(texts)
                result["sources_scanned"] += 1

        result["texts_collected"] = len(result["texts"])
        return result

    def _scan_source(self, source: str, queries: list[str]) -> list[dict]:
        """Scannt eine einzelne Quelle."""
        texts = []

        if source == "news":
            for q in queries[:2]:
                data = self._serpapi_search(q, tbm="nws")
                if data:
                    for r in data.get("news_results", data.get("organic_results", []))[:5]:
                        texts.append({
                            "source": "news",
                            "text": f"{r.get('title', '')} — {r.get('snippet', '')}",
                            "url": r.get("link"),
                            "date": r.get("date"),
                        })

        elif source == "reddit":
            for q in queries[:1]:
                data = self._serpapi_search(f"site:reddit.com {q}")
                if data:
                    for r in data.get("organic_results", [])[:5]:
                        texts.append({
                            "source": "reddit",
                            "text": f"{r.get('title', '')} — {r.get('snippet', '')}",
                            "url": r.get("link"),
                            "date": None,
                        })

        elif source == "x":
            for q in queries[:1]:
                data = self._serpapi_search(f"site:x.com {q}")
                if data:
                    for r in data.get("organic_results", [])[:5]:
                        texts.append({
                            "source": "x",
                            "text": f"{r.get('title', '')} — {r.get('snippet', '')}",
                            "url": r.get("link"),
                            "date": None,
                        })

        return texts

    # ── Analyze ───────────────────────────────────────────

    def analyze_sentiment(self, scan_result: dict) -> dict:
        """LLM analysiert gesammelte Texte."""
        topic = scan_result.get("topic", "unknown")
        texts = scan_result.get("texts", [])

        if not texts:
            # No data — return neutral with low confidence
            result = {
                "topic": topic,
                "sentiment_score": 0.0,
                "sentiment_label": "neutral",
                "dominant_narratives": ["Keine Daten verfuegbar"],
                "sample_count": 0,
                "confidence": 0.0,
                "summary": "Keine Texte zum Analysieren gefunden.",
            }
            self._store_result(result)
            return result

        # Build LLM prompt with max 20 texts, each max 500 chars
        text_block = "\n".join(
            f"[{t['source']}] {t['text'][:500]}"
            for t in texts[:20]
        )

        prompt = f"""Analysiere die folgende Sammlung von Texten zum Thema "{topic}".

Texte:
{text_block}

Antworte NUR als JSON (kein anderer Text):
{{
  "sentiment_score": float zwischen -1.0 (sehr negativ) und 1.0 (sehr positiv),
  "dominant_narratives": ["Narrative 1", "Narrative 2", "Narrative 3"],
  "summary": "2-3 Saetze Zusammenfassung der Stimmung"
}}"""

        response = self._call_llm(prompt, max_tokens=1024)
        parsed = self._parse_json(response)

        score = float(parsed.get("sentiment_score", 0.0))
        score = max(-1.0, min(1.0, score))
        sample_count = len(texts)
        confidence = min(1.0, sample_count / 20.0)

        result = {
            "topic": topic,
            "sentiment_score": round(score, 3),
            "sentiment_label": self._score_to_label(score),
            "dominant_narratives": parsed.get("dominant_narratives", []),
            "sample_count": sample_count,
            "confidence": round(confidence, 2),
            "summary": parsed.get("summary", ""),
        }

        self._store_result(result)
        return result

    def _store_result(self, result: dict) -> None:
        """Speichert Sentiment-Ergebnis in DB."""
        try:
            self.db.store_sentiment(
                topic=result["topic"],
                source="combined",
                sentiment_score=result["sentiment_score"],
                sentiment_label=result["sentiment_label"],
                dominant_narratives=result.get("dominant_narratives"),
                sample_count=result.get("sample_count", 0),
                confidence=result.get("confidence", 0),
                summary=result.get("summary", ""),
            )
        except Exception as e:
            logger.warning("Failed to store sentiment: %s", e)

    def _parse_json(self, text: str) -> dict:
        """Parst JSON aus LLM-Response."""
        if not text:
            return {}
        text = text.strip()
        if "```json" in text:
            text = text.split("```json")[1].split("```")[0].strip()
        elif "```" in text:
            text = text.split("```")[1].split("```")[0].strip()
        try:
            return json.loads(text)
        except json.JSONDecodeError:
            return {}

    # ── Narrative Shift ───────────────────────────────────

    def detect_narrative_shift(self, topic: str, current_period: int = 7,
                               previous_period: int = 30) -> dict:
        """Vergleicht aktuelle vs. vorherige Stimmung."""
        current = self.db.get_sentiment_trend(topic, days=current_period)
        previous = self.db.get_sentiment_trend(topic, days=previous_period)

        if not current:
            return {
                "shifted": False, "direction": "stable",
                "current_score": 0, "previous_score": 0, "delta": 0,
                "new_narratives": [], "fading_narratives": [],
            }

        cur_scores = [r.get("sentiment_score", 0) for r in current if r.get("sentiment_score") is not None]
        prev_scores = [r.get("sentiment_score", 0) for r in previous if r.get("sentiment_score") is not None]

        cur_avg = sum(cur_scores) / max(len(cur_scores), 1)
        prev_avg = sum(prev_scores) / max(len(prev_scores), 1)
        delta = cur_avg - prev_avg

        direction = "stable"
        if delta > 0.15:
            direction = "improving"
        elif delta < -0.15:
            direction = "declining"

        return {
            "shifted": abs(delta) > 0.15,
            "direction": direction,
            "current_score": round(cur_avg, 3),
            "previous_score": round(prev_avg, 3),
            "delta": round(delta, 3),
            "new_narratives": [],
            "fading_narratives": [],
        }

    # ── Factory Mentions ──────────────────────────────────

    def check_factory_mentions(self) -> dict:
        """Sucht gezielt nach DriveAI Factory Erwaehungen im Web."""
        result = {
            "mentions_found": 0,
            "mentions": [],
            "overall_sentiment": "neutral",
        }

        queries = ['"DriveAI Factory"', '"DriveAI" AI app factory']
        for q in queries:
            data = self._serpapi_search(q)
            if not data:
                continue
            for r in data.get("organic_results", [])[:5]:
                mention = {
                    "source": r.get("source", "web"),
                    "url": r.get("link", ""),
                    "context": f"{r.get('title', '')} — {r.get('snippet', '')}",
                    "sentiment": "neutral",
                }
                result["mentions"].append(mention)

                # Store in DB
                try:
                    self.db.store_factory_mention(
                        source=mention["source"],
                        url=mention["url"],
                        context=mention["context"],
                        sentiment=mention["sentiment"],
                    )
                except Exception:
                    pass

        result["mentions_found"] = len(result["mentions"])

        # Create alerts for mentions
        if result["mentions_found"] > 0:
            # Check if any negative
            neg_count = sum(1 for m in result["mentions"] if m.get("sentiment") == "negative")
            if neg_count > 0:
                try:
                    self.alerts.create_alert(
                        type="alert", priority="high", category="sentiment",
                        source_agent="SentimentAnalyzer",
                        title=f"DriveAI negativ erwaehnt ({neg_count}x)",
                        description=f"{neg_count} negative Erwaehungen gefunden.",
                    )
                except Exception:
                    pass

        return result

    # ── Reports ───────────────────────────────────────────

    def create_sentiment_report(self, period: str = "weekly") -> str:
        """Woechentlicher Sentiment-Report ueber alle drei Ebenen."""
        days = 7 if period == "weekly" else 30
        all_results = []

        for topic_key in self.TOPICS:
            scan = self.scan_sentiment(topic_key, days=days)
            analysis = self.analyze_sentiment(scan)
            all_results.append(analysis)

        # Build report
        lines = [f"# Sentiment Report ({period})\n",
                 f"Datum: {datetime.now().strftime('%Y-%m-%d')}\n"]

        for r in all_results:
            label_emoji = {"very_positive": "++++", "positive": "++",
                           "neutral": "~", "negative": "--", "very_negative": "----"}
            emoji = label_emoji.get(r["sentiment_label"], "?")
            lines.append(f"## {r['topic']} [{emoji}]")
            lines.append(f"- Score: {r['sentiment_score']} ({r['sentiment_label']})")
            lines.append(f"- Confidence: {r['confidence']}")
            lines.append(f"- Samples: {r['sample_count']}")
            if r.get("dominant_narratives"):
                lines.append("- Narratives: " + ", ".join(r["dominant_narratives"]))
            if r.get("summary"):
                lines.append(f"- {r['summary']}")
            lines.append("")

        report_dir = Path(__file__).resolve().parents[1] / "reports" / "sentiment"
        report_dir.mkdir(parents=True, exist_ok=True)
        date_str = datetime.now().strftime("%Y-%m-%d")
        path = report_dir / f"sentiment_report_{date_str}.md"
        path.write_text("\n".join(lines), encoding="utf-8")
        logger.info("Sentiment report created: %s", path)
        return str(path)

    # ── Quick Check ───────────────────────────────────────

    def run_quick_check(self, topic_key: str = "driveai") -> dict:
        """Schneller Sentiment-Check fuer ein einzelnes Topic."""
        scan = self.scan_sentiment(topic_key)
        return self.analyze_sentiment(scan)
