"""Review Analyzer -- analysiert Store-Reviews fuer Live Operations Insights.

NICHT zu verwechseln mit Marketing MKT-10 (factory/marketing/agents/review_manager.py).
MKT-10: "Wie antworten wir auf dieses Review?"
Live Ops ReviewAnalyzer: "Was sagen die Reviews ueber den Zustand der App?"
"""

from collections import Counter
from datetime import datetime, timezone
from typing import Optional

from ...app_registry.database import AppRegistryDB
from . import config


class ReviewAnalyzer:
    """Analysiert Store-Reviews fuer Live Operations Insights."""

    def __init__(self, registry_db: Optional[AppRegistryDB] = None) -> None:
        self.db = registry_db or AppRegistryDB()

    def analyze_reviews(self, app_id: str, reviews: list[dict]) -> dict:
        """Analysiert eine Liste von Reviews."""
        if not reviews:
            print(f"[Review Analyzer] No reviews for {app_id}")
            return self._empty_result(app_id)

        print(f"[Review Analyzer] Analyzing {len(reviews)} reviews for {app_id}")

        categorized = [self._categorize_review(r) for r in reviews]
        sentiments = [self._extract_sentiment(r) for r in reviews]
        patterns = self._detect_patterns(reviews)
        rating_health = self._calculate_rating_health(reviews)
        insights = self._generate_review_insights(categorized, sentiments, patterns, rating_health)

        # Category breakdown
        cat_counts = Counter(c["category"] for c in categorized)
        sent_counts = Counter(sentiments)

        return {
            "app_id": app_id,
            "analyzed_at": datetime.now(timezone.utc).isoformat(),
            "period_days": config.PATTERN_WINDOW_DAYS,
            "total_reviews": len(reviews),
            "rating_health": rating_health,
            "category_breakdown": dict(cat_counts),
            "sentiment_breakdown": dict(sent_counts),
            "patterns": patterns,
            "insights": insights,
        }

    def get_review_summary(self, app_id: str) -> dict:
        """Zusammenfassung fuer Dashboard."""
        # In der Stub-Phase returnen wir leeres Ergebnis
        return self._empty_result(app_id)

    # ------------------------------------------------------------------
    # Categorization
    # ------------------------------------------------------------------

    def _categorize_review(self, review: dict) -> dict:
        """Kategorisiert ein Review via Keyword-Matching."""
        text = f"{review.get('title', '')} {review.get('body', '')}".lower()

        best_cat = "other"
        best_score = 0

        for category, keywords in config.KEYWORD_CATEGORIES.items():
            score = sum(1 for kw in keywords if kw in text)
            if score > best_score:
                best_score = score
                best_cat = category

        # Deutsche Keywords pruefen
        for category, keywords in config.KEYWORD_CATEGORIES_DE.items():
            score = sum(1 for kw in keywords if kw in text)
            if score > best_score:
                best_score = score
                best_cat = category

        return {
            "review_id": review.get("review_id", ""),
            "category": best_cat,
            "confidence": min(best_score / 3.0, 1.0),
            "rating": review.get("rating", 0),
        }

    def _extract_sentiment(self, review: dict) -> str:
        """Bestimmt Sentiment: positive/negative/neutral/mixed."""
        text = f"{review.get('title', '')} {review.get('body', '')}".lower()
        rating = review.get("rating", 3)

        pos_count = sum(1 for kw in config.SENTIMENT_POSITIVE if kw in text)
        neg_count = sum(1 for kw in config.SENTIMENT_NEGATIVE if kw in text)

        # Rating als starkes Signal
        if rating >= 4:
            pos_count += 2
        elif rating <= 2:
            neg_count += 2

        if pos_count > 0 and neg_count > 0:
            return "mixed"
        elif pos_count > neg_count:
            return "positive"
        elif neg_count > pos_count:
            return "negative"
        return "neutral"

    # ------------------------------------------------------------------
    # Pattern Detection
    # ------------------------------------------------------------------

    def _detect_patterns(self, reviews: list[dict]) -> list[dict]:
        """Erkennt wiederkehrende Themen in Reviews."""
        # Sammle alle Keywords aus Reviews
        keyword_reviews = {}  # keyword -> list of review texts

        all_keywords = []
        for cat_keywords in config.KEYWORD_CATEGORIES.values():
            all_keywords.extend(cat_keywords)
        for cat_keywords in config.KEYWORD_CATEGORIES_DE.values():
            all_keywords.extend(cat_keywords)

        for review in reviews:
            text = f"{review.get('title', '')} {review.get('body', '')}".lower()
            for kw in all_keywords:
                if kw in text:
                    if kw not in keyword_reviews:
                        keyword_reviews[kw] = []
                    keyword_reviews[kw].append(text[:100])

        # Patterns: Keywords mit >= PATTERN_MIN_MENTIONS
        patterns = []
        for kw, texts in keyword_reviews.items():
            if len(texts) >= config.PATTERN_MIN_MENTIONS:
                # Bestimme Severity basierend auf Keyword-Kategorie
                severity = "medium"
                for cat, keywords in config.KEYWORD_CATEGORIES.items():
                    if kw in keywords:
                        if cat == "bug_report":
                            severity = "high"
                        elif cat == "complaint":
                            severity = "medium"
                        break

                patterns.append({
                    "theme": kw,
                    "mentions": len(texts),
                    "severity": severity,
                    "sample_reviews": texts[:3],
                    "suggested_action": self._suggest_action_for_pattern(kw, severity),
                })

        # Sortiere nach Mentions (haeufigste zuerst)
        patterns.sort(key=lambda p: p["mentions"], reverse=True)
        return patterns

    def _suggest_action_for_pattern(self, keyword: str, severity: str) -> str:
        """Generiert Action-Vorschlag fuer ein Pattern."""
        if keyword in ("crash", "freeze", "force close", "absturz", "einfrieren"):
            return "Prioritize crash investigation -- potential hotfix candidate"
        if keyword in ("bug", "error", "broken", "fehler", "kaputt"):
            return "Investigate reported bug and schedule patch"
        if keyword in ("slow", "lag", "loading"):
            return "Performance profiling needed"
        if severity == "high":
            return f"Investigate '{keyword}' reports urgently"
        return f"Monitor '{keyword}' reports for escalation"

    # ------------------------------------------------------------------
    # Rating Health
    # ------------------------------------------------------------------

    def _calculate_rating_health(self, reviews: list[dict]) -> dict:
        """Berechnet Rating-Trend und Gesundheit."""
        ratings = [r.get("rating", 0) for r in reviews if r.get("rating")]
        if not ratings:
            return {"current_average": 0, "previous_average": 0, "trend": "unknown",
                    "below_target": True, "target": config.RATING_TARGET}

        n = len(ratings)
        mid = n // 2

        current_avg = sum(ratings[mid:]) / len(ratings[mid:]) if ratings[mid:] else 0
        previous_avg = sum(ratings[:mid]) / len(ratings[:mid]) if ratings[:mid] and mid > 0 else current_avg

        if current_avg > previous_avg + 0.1:
            trend = "improving"
        elif current_avg < previous_avg - 0.1:
            trend = "declining"
        else:
            trend = "stable"

        return {
            "current_average": round(current_avg, 2),
            "previous_average": round(previous_avg, 2),
            "trend": trend,
            "below_target": current_avg < config.RATING_TARGET,
            "target": config.RATING_TARGET,
        }

    # ------------------------------------------------------------------
    # Insights Generation
    # ------------------------------------------------------------------

    def _generate_review_insights(self, categorized: list, sentiments: list,
                                  patterns: list, rating_health: dict) -> list[dict]:
        """Generiert Insights fuer Decision Engine."""
        insights = []

        # Rating Trend
        if rating_health.get("trend") == "declining":
            insights.append({
                "type": "warning",
                "message": f"Rating declining: {rating_health['previous_average']:.1f} -> {rating_health['current_average']:.1f}",
                "data": rating_health,
            })

        if rating_health.get("below_target"):
            insights.append({
                "type": "warning",
                "message": f"Rating {rating_health['current_average']:.1f} below target {rating_health['target']}",
                "data": rating_health,
            })

        # Patterns
        for pattern in patterns:
            if pattern["severity"] == "high":
                insights.append({
                    "type": "critical",
                    "message": f"{pattern['mentions']} reports about '{pattern['theme']}' -- hotfix candidate",
                    "pattern": pattern["theme"],
                })
            elif pattern["mentions"] >= 5:
                insights.append({
                    "type": "warning",
                    "message": f"Recurring theme: '{pattern['theme']}' ({pattern['mentions']} mentions)",
                    "pattern": pattern["theme"],
                })

        # Sentiment ratio
        neg_count = sentiments.count("negative")
        total = len(sentiments) if sentiments else 1
        neg_ratio = neg_count / total
        if neg_ratio > 0.4:
            insights.append({
                "type": "warning",
                "message": f"High negative sentiment ratio: {neg_ratio:.0%} of reviews are negative",
                "data": {"negative_ratio": neg_ratio},
            })

        return insights

    def _empty_result(self, app_id: str) -> dict:
        return {
            "app_id": app_id,
            "analyzed_at": datetime.now(timezone.utc).isoformat(),
            "total_reviews": 0,
            "rating_health": {},
            "category_breakdown": {},
            "sentiment_breakdown": {},
            "patterns": [],
            "insights": [],
        }
