"""Content-Trend-Analyse + Hook-Bibliothek — Lernt was funktioniert.

Verbindet eigene Performance-Daten mit externen Trends.
Hook-Bibliothek nutzt Knowledge-Writeback-Pattern (hypothesis -> proven -> deprecated).
"""

import json
import logging
import os
from datetime import datetime
from pathlib import Path

logger = logging.getLogger("factory.marketing.tools.content_trend_analyzer")


class ContentTrendAnalyzer:
    """Analysiert Content-Performance und pflegt die Hook-Bibliothek."""

    def __init__(self):
        from factory.marketing.tools.ranking_database import RankingDatabase

        self.db = RankingDatabase()

    # ── Internal Helpers ──────────────────────────────────

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

    # ── Own Performance ───────────────────────────────────

    def analyze_own_performance(self, days: int = 30) -> dict:
        """Analysiert eigene Content-Performance aus der DB."""
        posts = self.db.get_top_posts(limit=50, days=days)

        result = {
            "period_days": days,
            "total_posts": len(posts),
            "best_platform": None,
            "best_format": None,
            "avg_engagement_rate": 0.0,
            "top_posts": [],
            "data_quality": "mock",
        }

        if not posts:
            result["top_posts"] = [
                {"platform": "tiktok", "note": "Keine echten Post-Daten vorhanden"},
            ]
            return result

        # Aggregate by platform
        platform_engagement = {}
        format_engagement = {}
        total_engagement = 0

        for p in posts:
            plat = p.get("platform", "unknown")
            fmt = p.get("content_type", "unknown")
            eng = (p.get("likes", 0) + p.get("shares", 0) + p.get("comments", 0))
            total_engagement += eng

            platform_engagement.setdefault(plat, []).append(eng)
            format_engagement.setdefault(fmt, []).append(eng)

        # Best platform
        if platform_engagement:
            result["best_platform"] = max(
                platform_engagement,
                key=lambda k: sum(platform_engagement[k]) / len(platform_engagement[k]),
            )

        # Best format
        if format_engagement:
            result["best_format"] = max(
                format_engagement,
                key=lambda k: sum(format_engagement[k]) / len(format_engagement[k]),
            )

        result["avg_engagement_rate"] = round(total_engagement / max(len(posts), 1), 2)
        result["top_posts"] = posts[:5]
        result["data_quality"] = "real" if len(posts) >= 10 else "limited"
        return result

    # ── Hook Extraction ───────────────────────────────────

    def extract_hooks_from_top_content(self, limit: int = 10) -> list[dict]:
        """Extrahiert Hooks aus den best-performenden Posts."""
        posts = self.db.get_top_posts(limit=limit, days=90)

        if posts:
            # Real data path
            text_block = "\n".join(
                f"[{p.get('platform', '?')}] {p.get('post_id', '')}"
                for p in posts[:10]
            )
            prompt = (
                f"Analysiere diese Top-performenden Social-Media-Posts:\n{text_block}\n\n"
                "Extrahiere 5 wiederkehrende Hook-Muster. "
                "Antworte NUR als JSON-Array: "
                '[{"hook_text": "...", "platform": "...", "category": "question|shocking_fact|controversy|tutorial|behind_the_scenes", "reason": "..."}]'
            )
            response = self._call_llm(prompt, max_tokens=1024)
            hooks = self._parse_json(response)
            if isinstance(hooks, list) and hooks:
                for h in hooks:
                    self.db.store_hook(
                        hook_text=h.get("hook_text", ""),
                        platform=h.get("platform", "tiktok"),
                        topic="content_analysis",
                        category=h.get("category", "question"),
                    )
                return hooks

        # Fallback: Generate hypothesis hooks from Factory knowledge
        return self._generate_hypothesis_hooks()

    def _generate_hypothesis_hooks(self) -> list[dict]:
        """Generiert Hypothese-Hooks aus Factory-Knowledge."""
        # Read narratives if available
        narrative_text = ""
        narrative_dir = Path(__file__).resolve().parents[1] / "brand" / "narratives"
        if narrative_dir.exists():
            for f in narrative_dir.glob("*.md"):
                try:
                    narrative_text += f.read_text(encoding="utf-8")[:500] + "\n"
                except Exception:
                    pass

        if not narrative_text:
            narrative_text = (
                "DriveAI Factory: Autonome KI-App-Fabrik. "
                "108 Agents bauen Apps. Kein menschlicher Entwickler noetig. "
                "Von Idee zu fertigem App in Stunden."
            )

        prompt = (
            f"Du bist Social-Media-Experte. Basierend auf dieser Factory-Info:\n"
            f"{narrative_text[:1000]}\n\n"
            "Generiere 5 Hook-Texte fuer TikTok/YouTube Shorts. "
            "Kategorien: question, shocking_fact, controversy, tutorial, behind_the_scenes. "
            "Antworte NUR als JSON-Array: "
            '[{"hook_text": "...", "platform": "tiktok", "category": "...", "reason": "..."}]'
        )
        response = self._call_llm(prompt, max_tokens=1024)
        hooks = self._parse_json(response)

        if isinstance(hooks, list) and hooks:
            for h in hooks:
                self.db.store_hook(
                    hook_text=h.get("hook_text", ""),
                    platform=h.get("platform", "tiktok"),
                    topic="factory",
                    category=h.get("category", "question"),
                )
            return hooks

        # Ultimate fallback
        fallback_hooks = [
            {"hook_text": "Eine KI hat 108 Agenten und baut Apps alleine", "platform": "tiktok", "category": "shocking_fact", "reason": "Factory unique selling point"},
            {"hook_text": "Kannst du erraten welche App NICHT von einem Menschen gebaut wurde?", "platform": "tiktok", "category": "question", "reason": "Engagement through mystery"},
            {"hook_text": "Ich zeige dir wie 108 KI-Agenten eine App bauen", "platform": "youtube", "category": "tutorial", "reason": "Educational hook"},
        ]
        for h in fallback_hooks:
            self.db.store_hook(
                hook_text=h["hook_text"], platform=h["platform"],
                topic="factory", category=h["category"],
            )
        return fallback_hooks

    # ── Hook Management ───────────────────────────────────

    def save_hook(self, hook_text: str, platform: str,
                  topic: str = None, category: str = None) -> int:
        """Speichert einen Hook. Status: hypothesis."""
        return self.db.store_hook(hook_text, platform, topic, category)

    def record_hook_usage(self, hook_id: int, successful: bool) -> None:
        """Markiert Hook als verwendet. Auto-Promotion/Deprecation in DB."""
        self.db.update_hook_usage(hook_id, successful)

    def get_recommended_hooks(self, platform: str, topic: str = None,
                              limit: int = 5) -> list[dict]:
        """Empfiehlt Hooks. Proven > Hypothesis, deprecated ausgeschlossen."""
        results = []

        # 1. Proven for platform + topic
        if topic:
            proven = self.db.get_hooks(platform=platform, topic=topic, status="proven", limit=limit)
            results.extend(proven)

        # 2. Proven for platform (any topic)
        if len(results) < limit:
            proven_all = self.db.get_hooks(platform=platform, status="proven", limit=limit - len(results))
            for h in proven_all:
                if h["id"] not in {r["id"] for r in results}:
                    results.append(h)

        # 3. Hypothesis hooks
        if len(results) < limit:
            hypo = self.db.get_hooks(platform=platform, status="hypothesis", limit=limit - len(results))
            for h in hypo:
                if h["id"] not in {r["id"] for r in results}:
                    results.append(h)

        return results[:limit]

    # ── Format Performance ────────────────────────────────

    def get_format_performance_matrix(self) -> dict:
        """Welches Format auf welcher Plattform wie gut performt."""
        data = self.db.get_format_performance(days=90)

        platforms = set()
        formats = set()
        matrix = {}

        for row in data:
            plat = row.get("platform", "unknown")
            fmt = row.get("format_type", "unknown")
            eng = row.get("avg_engagement", 0)
            platforms.add(plat)
            formats.add(fmt)
            matrix.setdefault(plat, {})
            existing = matrix[plat].get(fmt, [])
            existing.append(eng)
            matrix[plat][fmt] = existing

        # Average
        avg_matrix = {}
        best_combo = ("", "", 0)
        for plat, fmts in matrix.items():
            avg_matrix[plat] = {}
            for fmt, vals in fmts.items():
                avg = sum(vals) / len(vals) if vals else 0
                avg_matrix[plat][fmt] = round(avg, 4)
                if avg > best_combo[2]:
                    best_combo = (fmt, plat, avg)

        recommendation = (
            f"{best_combo[0]} on {best_combo[1]}" if best_combo[2] > 0
            else "Keine Daten vorhanden"
        )

        return {
            "platforms": sorted(platforms),
            "formats": sorted(formats),
            "matrix": avg_matrix,
            "recommendation": recommendation,
        }

    # ── Seed ──────────────────────────────────────────────

    def seed_initial_hooks(self) -> int:
        """Erstellt initiale Hooks basierend auf Factory-Knowledge."""
        hooks = self.extract_hooks_from_top_content(limit=5)
        return len(hooks)

    # ── Report ────────────────────────────────────────────

    def create_content_trend_report(self, days: int = 30) -> str:
        """Content-Trend-Report."""
        perf = self.analyze_own_performance(days)
        hooks = self.db.get_hooks(limit=50)
        matrix = self.get_format_performance_matrix()

        # Hook stats
        proven = sum(1 for h in hooks if h.get("status") == "proven")
        hypo = sum(1 for h in hooks if h.get("status") == "hypothesis")
        dep = sum(1 for h in hooks if h.get("status") == "deprecated")

        # Build report
        text_parts = [
            f"Performance: {perf['total_posts']} Posts, Quality={perf['data_quality']}, "
            f"Best Platform={perf['best_platform']}, Best Format={perf['best_format']}. "
            f"Hook Library: {proven} proven, {hypo} hypothesis, {dep} deprecated. "
            f"Format Matrix: {matrix.get('recommendation', 'N/A')}."
        ]

        prompt = (
            "Erstelle einen kurzen Content-Trend-Report basierend auf diesen Daten:\n"
            + "\n".join(text_parts) + "\n\n"
            "Formatiere als Markdown mit Sektionen: Performance, Hooks, Formate, Empfehlung. "
            "Halte es auf 1 Seite."
        )

        report_text = self._call_llm(prompt, max_tokens=2048)
        if not report_text:
            report_text = "\n".join([
                f"# Content Trend Report ({days}d)\n",
                f"Datum: {datetime.now().strftime('%Y-%m-%d')}\n",
                "## Performance",
                f"- Posts: {perf['total_posts']}, Data Quality: {perf['data_quality']}",
                f"- Best Platform: {perf['best_platform']}",
                f"- Best Format: {perf['best_format']}\n",
                "## Hook Library",
                f"- Proven: {proven}, Hypothesis: {hypo}, Deprecated: {dep}\n",
                "## Format Matrix",
                f"- Recommendation: {matrix.get('recommendation', 'N/A')}\n",
            ])

        report_dir = Path(__file__).resolve().parents[1] / "reports" / "content_trends"
        report_dir.mkdir(parents=True, exist_ok=True)
        date_str = datetime.now().strftime("%Y-%m-%d")
        path = report_dir / f"content_trend_report_{date_str}.md"
        path.write_text(report_text, encoding="utf-8")
        logger.info("Content trend report: %s", path)
        return str(path)
