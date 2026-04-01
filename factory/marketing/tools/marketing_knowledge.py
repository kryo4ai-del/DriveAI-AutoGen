"""Marketing Knowledge Base — Persistentes Lern-System.

Nutzt Knowledge-Writeback-Pattern (wie SWF-07 Memory Agent).
hypothesis → confirmed (2+ Beobachtungen) → established (5+) → deprecated
"""

import json
import logging
import os
from datetime import datetime
from pathlib import Path

from factory.marketing.tools.ranking_database import RankingDatabase
from factory.marketing.config import OUTPUT_PATH, REPORTS_PATH

logger = logging.getLogger("factory.marketing.tools.marketing_knowledge")


class MarketingKnowledgeBase:
    """Persistente Marketing-Wissensdatenbank mit Auto-Promotion."""

    CATEGORIES = [
        "content_insights",       # Was funktioniert bei Content
        "audience_insights",      # Was wir ueber Zielgruppen wissen
        "competitive_insights",   # Was wir ueber Wettbewerber wissen
        "technical_insights",     # Was wir ueber Tools/Plattformen wissen
        "cost_insights",          # Was wir ueber Kosten/ROI wissen
    ]

    # Welcher Agent bekommt welche Kategorie
    AGENT_KNOWLEDGE_MAP = {
        "MKT-02": ["content_insights", "audience_insights", "competitive_insights"],
        "MKT-03": ["content_insights", "audience_insights"],
        "MKT-05": ["audience_insights", "competitive_insights"],
        "MKT-06": ["content_insights"],
        "MKT-07": ["content_insights"],
        "MKT-09": ["cost_insights", "audience_insights"],
        "MKT-12": ["content_insights", "cost_insights"],
        "MKT-14": ["cost_insights", "audience_insights", "competitive_insights"],
    }

    CONFIDENCE_ORDER = {"deprecated": -1, "hypothesis": 0, "confirmed": 1, "established": 2}

    def __init__(self):
        self.db = RankingDatabase()

    def add_knowledge(self, category: str, insight: str, evidence: str = None,
                      confidence: str = "hypothesis", source_agent: str = None,
                      tags: str = None) -> int:
        """Fuegt neues Wissen hinzu.

        Prueft erst ob aehnliches Wissen existiert (gleiche Kategorie + aehnlicher Text).
        Wenn ja: confirm_knowledge statt neuer Eintrag.

        Returns: knowledge_id
        """
        if category not in self.CATEGORIES:
            logger.warning("Unknown category: %s (valid: %s)", category, self.CATEGORIES)

        # Prüfe auf aehnliches bestehendes Wissen
        existing = self.db.search_knowledge(
            keywords=insight[:50],  # Erste 50 Zeichen als Suchbegriff
            category=category,
            limit=5,
        )
        for entry in existing:
            # Einfacher Vergleich: wenn insight-Text stark aehnlich
            if self._text_similarity(entry.get("insight", ""), insight) > 0.7:
                logger.info("Similar knowledge found (id=%d), confirming instead", entry["id"])
                result = self.confirm_knowledge(entry["id"], new_evidence=evidence)
                return entry["id"]

        # Neuer Eintrag
        knowledge_id = self.db.store_knowledge(
            category=category,
            insight=insight,
            evidence=evidence,
            confidence=confidence,
            source_agent=source_agent,
            tags=tags,
        )
        logger.info("New knowledge added: id=%d, category=%s, confidence=%s",
                     knowledge_id, category, confidence)
        return knowledge_id

    def _text_similarity(self, text_a: str, text_b: str) -> float:
        """Einfache Wort-basierte Aehnlichkeit (Jaccard)."""
        words_a = set(text_a.lower().split())
        words_b = set(text_b.lower().split())
        if not words_a or not words_b:
            return 0.0
        intersection = words_a & words_b
        union = words_a | words_b
        return len(intersection) / len(union)

    def confirm_knowledge(self, knowledge_id: int, new_evidence: str = None) -> dict:
        """Bestaetigt bestehendes Wissen.

        observations_count + 1
        Auto-Promotion:
        - count >= 2: confidence = "confirmed"
        - count >= 5: confidence = "established"

        Returns: {"id": int, "confidence": str, "observations_count": int}
        """
        if new_evidence:
            # Append evidence
            existing = self.db.get_knowledge(limit=9999)
            for entry in existing:
                if entry["id"] == knowledge_id:
                    old_evidence = entry.get("evidence") or ""
                    combined = f"{old_evidence}\n---\n{new_evidence}" if old_evidence else new_evidence
                    self.db.update_knowledge(knowledge_id, evidence=combined)
                    break

        result = self.db.confirm_knowledge(knowledge_id)
        logger.info("Knowledge confirmed: id=%d → confidence=%s, count=%d",
                     knowledge_id, result.get("confidence"), result.get("observations_count", 0))
        return result

    def query_knowledge(self, category: str = None, keywords: str = None,
                        min_confidence: str = "hypothesis",
                        limit: int = 20) -> list[dict]:
        """Suche nach relevantem Wissen.

        keywords: Sucht in insight + evidence + tags
        min_confidence: "hypothesis" (alles), "confirmed", "established"
        """
        return self.db.search_knowledge(
            keywords=keywords,
            category=category,
            min_confidence=min_confidence,
            limit=limit,
        )

    def get_knowledge_for_agent(self, agent_id: str) -> list[dict]:
        """Gibt alle relevanten Insights fuer einen Agent zurueck.

        Nutzt AGENT_KNOWLEDGE_MAP um Kategorien zu filtern.
        Sortiert nach confidence (established > confirmed > hypothesis).
        Limit: 10 Insights pro Agent (nicht ueberfluten).
        """
        categories = self.AGENT_KNOWLEDGE_MAP.get(agent_id, [])
        if not categories:
            return []

        all_insights = []
        for cat in categories:
            results = self.db.get_knowledge(category=cat, limit=20)
            # Filter out deprecated
            results = [r for r in results if r.get("confidence") != "deprecated"]
            all_insights.extend(results)

        # Sortiere: established > confirmed > hypothesis
        all_insights.sort(
            key=lambda x: self.CONFIDENCE_ORDER.get(x.get("confidence", "hypothesis"), 0),
            reverse=True,
        )

        # Deduplizieren nach ID
        seen = set()
        unique = []
        for item in all_insights:
            if item["id"] not in seen:
                seen.add(item["id"])
                unique.append(item)

        return unique[:10]

    def deprecate_knowledge(self, knowledge_id: int, reason: str) -> bool:
        """Markiert Wissen als veraltet."""
        success = self.db.update_knowledge(knowledge_id, confidence="deprecated")
        if success:
            # Append reason to evidence
            existing = self.db.get_knowledge(limit=9999)
            for entry in existing:
                if entry["id"] == knowledge_id:
                    old_evidence = entry.get("evidence") or ""
                    combined = f"{old_evidence}\n--- DEPRECATED: {reason}"
                    self.db.update_knowledge(knowledge_id, evidence=combined)
                    break
            logger.info("Knowledge deprecated: id=%d, reason=%s", knowledge_id, reason)
        return success

    def create_knowledge_report(self) -> str:
        """Gesamtueberblick als Markdown.
        Output: factory/marketing/reports/knowledge/knowledge_report_{date}.md
        """
        stats = self.get_knowledge_stats()
        all_knowledge = self.db.get_knowledge(limit=9999)

        now = datetime.now()
        date_str = now.strftime("%Y%m%d")

        report_dir = Path(REPORTS_PATH) / "knowledge"
        report_dir.mkdir(parents=True, exist_ok=True)
        report_path = report_dir / f"knowledge_report_{date_str}.md"

        lines = [
            "# Marketing Knowledge Base Report",
            f"\nGeneriert: {now.strftime('%Y-%m-%d %H:%M')}",
            f"\n## Statistik",
            f"\n- **Gesamt-Eintraege:** {stats['total']}",
        ]
        for cat, count in stats.get("by_category", {}).items():
            lines.append(f"  - {cat}: {count}")

        lines.append(f"\n### Nach Confidence:")
        for conf, count in stats.get("by_confidence", {}).items():
            lines.append(f"  - {conf}: {count}")

        # Top Insights (established + confirmed)
        top = [k for k in all_knowledge
               if k.get("confidence") in ("established", "confirmed")]
        if top:
            lines.append("\n## Top Insights (Bestaetigt)")
            for k in top[:20]:
                lines.append(f"\n### [{k['confidence'].upper()}] {k['category']}")
                lines.append(f"**Insight:** {k['insight']}")
                if k.get("evidence"):
                    lines.append(f"**Evidence:** {k['evidence'][:200]}")
                lines.append(f"*Beobachtungen: {k.get('observations_count', 1)}*")

        content = "\n".join(lines)
        report_path.write_text(content, encoding="utf-8")
        logger.info("Knowledge report: %s", report_path)
        return str(report_path)

    def seed_initial_knowledge(self) -> int:
        """Initiales Wissen aus Phase-1-bis-7-Erkenntnissen."""
        seeds = [
            ("technical_insights",
             "TikTok Scraping liefert 137 Hashtags live — Stufe 1 funktioniert",
             "Phase 2 TikTok Scraper Tests", "confirmed", "MKT-system"),
            ("technical_insights",
             "o3-mini versagt bei langen Outputs -- get_model_for_agent nutzen",
             "Phase 1 Tests: Modell-Routing", "established", "MKT-system"),
            ("cost_insights",
             "Factory vs Market Costs: mehr als 99% Ersparnis bei Marketing-Produktion",
             "Phase 7 Cost Analysis: $3.50 vs $163,000", "confirmed", "MKT-system"),
            ("content_insights",
             "Frage-Hooks performen auf TikTok besser als Fakten-Hooks",
             "Phase 2 Hook-Library Analyse", "hypothesis", "MKT-03"),
            ("audience_insights",
             "EchoMatch Zielgruppe: 18-34, Casual Gamer, DACH + US",
             "Market Strategy Phase Analyse", "confirmed", "MKT-02"),
            ("technical_insights",
             "FFmpeg Video-Pipeline erzeugt 720p/1080p Videos lokal ohne API-Kosten",
             "Phase 1 Video Pipeline Tests", "established", "MKT-07"),
            ("content_insights",
             "Behind-the-Scenes Content ueber die Factory generiert hohes Engagement",
             "Phase 5 Storytelling Agent", "hypothesis", "MKT-12"),
            ("competitive_insights",
             "Competitor Tracker erkennt Listing-Aenderungen via Hash-Vergleich",
             "Phase 3 Competitor Tracker", "confirmed", "MKT-system"),
            ("cost_insights",
             "LLM-Kosten pro Marketing-Run: ~$0.08 durch TheBrain-Routing",
             "Phase 4 TheBrain Integration", "established", "MKT-system"),
            ("technical_insights",
             "A/B Tests nutzen Z-Test mit scipy Fallback auf manuelle Berechnung",
             "Phase 7 A/B Test Tool", "established", "MKT-system"),
        ]

        count = 0
        for category, insight, evidence, confidence, source in seeds:
            self.add_knowledge(
                category=category,
                insight=insight,
                evidence=evidence,
                confidence=confidence,
                source_agent=source,
            )
            count += 1

        logger.info("Seeded %d initial knowledge entries", count)
        return count

    def get_knowledge_stats(self) -> dict:
        """Statistik: Eintraege pro Kategorie und Confidence."""
        all_knowledge = self.db.get_knowledge(limit=9999)

        by_category: dict[str, int] = {}
        by_confidence: dict[str, int] = {}

        for k in all_knowledge:
            cat = k.get("category", "unknown")
            conf = k.get("confidence", "hypothesis")
            by_category[cat] = by_category.get(cat, 0) + 1
            by_confidence[conf] = by_confidence.get(conf, 0) + 1

        return {
            "total": len(all_knowledge),
            "by_category": by_category,
            "by_confidence": by_confidence,
        }
