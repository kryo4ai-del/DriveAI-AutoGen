"""App Health Scorer Agent — berechnet Health Scores (0-100) pro App.

Nimmt normalisierte Metriken vom metrics_collector und berechnet den Health Score,
gewichtet nach App-Kategorie-Profil. Rein deterministisch — kein LLM-Call.
"""

from datetime import datetime, timezone
from typing import Optional

from factory.live_operations.app_registry.database import AppRegistryDB
from factory.live_operations.agents.health_scorer.profiles import (
    PROFILES,
    DEFAULT_PROFILE,
)

_PREFIX = "[Health Scorer]"


def _now_iso() -> str:
    return datetime.now(timezone.utc).isoformat()


def _clamp(value: float, low: float = 0.0, high: float = 100.0) -> float:
    return max(low, min(high, value))


def _linear_score(value: float, min_val: float, max_val: float) -> float:
    """Linear interpolation: min_val -> 0, max_val -> 100."""
    if max_val == min_val:
        return 50.0
    score = ((value - min_val) / (max_val - min_val)) * 100.0
    return _clamp(score)


def _inverse_linear_score(value: float, zero_at: float) -> float:
    """Inverse: 0 -> 100, zero_at -> 0."""
    if zero_at <= 0:
        return 100.0
    return _clamp(100.0 - (value / zero_at) * 100.0)


class AppHealthScorer:
    """Berechnet Health Scores fuer Apps basierend auf normalisierten Metriken."""

    def __init__(self, registry_db: Optional[AppRegistryDB] = None) -> None:
        self._db = registry_db or AppRegistryDB()

    # ------------------------------------------------------------------
    # Public API
    # ------------------------------------------------------------------

    def score_app(self, app_id: str, metrics: dict) -> dict:
        """Berechnet Score fuer eine App."""
        app = self._db.get_app(app_id)
        if not app:
            print(f"{_PREFIX} App {app_id} nicht gefunden.")
            return {}

        profile = app.get("app_profile", DEFAULT_PROFILE)
        if profile not in PROFILES:
            print(f"{_PREFIX} Unbekanntes Profil '{profile}', fallback auf '{DEFAULT_PROFILE}'.")
            profile = DEFAULT_PROFILE

        store = metrics.get("store_metrics", {})
        firebase = metrics.get("firebase_metrics", {})

        # Calculate category scores
        stability = self._calculate_stability_score(store, firebase)
        satisfaction = self._calculate_satisfaction_score(store)
        engagement = self._calculate_engagement_score(firebase, profile)
        revenue = self._calculate_revenue_score(store, firebase)
        growth = self._calculate_growth_score(store, firebase)

        category_scores = {
            "stability": stability,
            "satisfaction": satisfaction,
            "engagement": engagement,
            "revenue": revenue,
            "growth": growth,
        }

        # Apply weights
        overall = self._apply_weights(category_scores, profile)
        zone = self._determine_zone(overall)

        # Build alerts
        alerts = []
        for cat, score in category_scores.items():
            if score < 50.0:
                alerts.append({
                    "category": cat,
                    "message": f"{cat.title()} in roter Zone ({score:.0f}) — Analyse empfohlen",
                })

        weights = PROFILES[profile]["weights"]
        result = {
            "app_id": app_id,
            "app_name": app.get("app_name", "Unknown"),
            "scored_at": _now_iso(),
            "profile": profile,
            "overall_score": round(overall, 1),
            "zone": zone,
            "category_scores": {
                cat: {
                    "score": round(score, 1),
                    "weight": weights[cat],
                    "weighted": round(score * weights[cat], 2),
                }
                for cat, score in category_scores.items()
            },
            "alerts": alerts,
        }

        # Persist to DB
        self._persist_score(app_id, overall, zone, category_scores)

        print(f"{_PREFIX} {app.get('app_name', app_id)}: Score={overall:.1f} Zone={zone}")
        return result

    def score_all(self, all_metrics: dict) -> dict:
        """Berechnet Scores fuer alle Apps."""
        results = {}
        apps_data = all_metrics.get("apps", {})

        if not apps_data:
            print(f"{_PREFIX} Keine Metriken vorhanden.")
            return {"scored_at": _now_iso(), "results": {}, "total": 0}

        for app_id, metrics in apps_data.items():
            try:
                results[app_id] = self.score_app(app_id, metrics)
            except Exception as e:
                print(f"{_PREFIX} Fehler bei Scoring von {app_id}: {e}")
                results[app_id] = {"app_id": app_id, "error": str(e)}

        return {
            "scored_at": _now_iso(),
            "results": results,
            "total": len(results),
        }

    # ------------------------------------------------------------------
    # Scoring — Category Calculators
    # ------------------------------------------------------------------

    def _calculate_stability_score(self, store: dict, firebase: dict) -> float:
        """Stability: Crash Rate + ANR Rate -> 0-100."""
        crash_rate = store.get("crash_rate", 0.0)
        anr_rate = store.get("anr_rate", 0.0)

        # Also consider Firebase crashlytics data
        crash_free_pct = firebase.get("crash_free_sessions_pct", 100.0)
        # Convert crash_free percentage to crash_rate if store data unavailable
        if crash_rate == 0.0 and crash_free_pct < 100.0:
            crash_rate = 100.0 - crash_free_pct

        # Crash Rate: 0% -> 100, >5% -> 0
        crash_score = _inverse_linear_score(crash_rate, 5.0)

        # ANR Rate: 0% -> 100, >2% -> 0
        anr_score = _inverse_linear_score(anr_rate, 2.0)

        # Combined: 70% Crash + 30% ANR
        if anr_rate > 0:
            return _clamp(crash_score * 0.7 + anr_score * 0.3)
        return crash_score

    def _calculate_satisfaction_score(self, store: dict) -> float:
        """User Satisfaction: Rating + Rating Trend -> 0-100."""
        rating = store.get("rating_average", 3.0)
        rating_trend = store.get("rating_trend", 0.0)

        # Rating 5.0 -> 100, <=1.0 -> 0
        rating_score = _linear_score(rating, 1.0, 5.0)

        # Trend bonus/malus
        if rating_trend > 0:
            rating_score += 5.0
        elif rating_trend < 0:
            rating_score -= 10.0

        return _clamp(rating_score)

    def _calculate_engagement_score(self, firebase: dict, profile: str) -> float:
        """Engagement: DAU/MAU + Retention + Session Length -> 0-100 (profilabhaengig)."""
        dau_mau = firebase.get("dau_mau_ratio", 0.0)
        retention_d7 = firebase.get("retention_day7", 0.0)
        session_length = firebase.get("avg_session_length_seconds", 0.0)

        # DAU/MAU Ratio: 0.5+ -> 100, 0 -> 0
        dau_mau_score = _linear_score(dau_mau, 0.0, 0.5)

        # Retention Day 7: 50%+ -> 100, 0% -> 0
        retention_score = _linear_score(retention_d7, 0.0, 50.0)

        # Session Length: profile-dependent
        if profile in ("gaming", "content"):
            # Longer is better: 600s+ -> 100, 0 -> 0
            session_score = _linear_score(session_length, 0.0, 600.0)
            return _clamp((dau_mau_score * 0.35 + retention_score * 0.35 + session_score * 0.30))
        elif profile == "utility":
            # Session length irrelevant for utility
            return _clamp((dau_mau_score * 0.50 + retention_score * 0.50))
        else:
            # Moderate sessions: 300s sweet spot
            session_score = _linear_score(session_length, 0.0, 300.0)
            return _clamp((dau_mau_score * 0.40 + retention_score * 0.40 + session_score * 0.20))

    def _calculate_revenue_score(self, store: dict, firebase: dict) -> float:
        """Revenue: ARPU + Conversion Rate + Revenue Trend -> 0-100."""
        arpu = firebase.get("arpu", 0.0)
        conversion = firebase.get("conversion_rate", 0.0)
        revenue_trend = store.get("revenue_trend", 0.0)

        # ARPU: $5+ -> 100, 0 -> 0
        arpu_score = _linear_score(arpu, 0.0, 5.0)

        # Conversion: 10%+ -> 100, 0% -> 0
        conversion_score = _linear_score(conversion, 0.0, 10.0)

        # Revenue Trend bonus/malus
        base = (arpu_score * 0.5 + conversion_score * 0.5)
        if revenue_trend > 0:
            base += 5.0
        elif revenue_trend < 0:
            base -= 10.0

        return _clamp(base)

    def _calculate_growth_score(self, store: dict, firebase: dict) -> float:
        """Growth: Download Trend -> 0-100."""
        downloads = store.get("downloads_period", 0)
        downloads_total = store.get("downloads_total", 1)
        retention_d1 = firebase.get("retention_day1", 0.0)

        # Downloads period relative to total (growth velocity)
        if downloads_total > 0:
            growth_ratio = downloads / max(downloads_total, 1)
            # Good growth: >5% of total in 7 days -> 100
            growth_score = _linear_score(growth_ratio, 0.0, 0.05)
        else:
            growth_score = 50.0

        # Retention Day 1 as organic quality indicator
        retention_score = _linear_score(retention_d1, 0.0, 60.0)

        return _clamp(growth_score * 0.6 + retention_score * 0.4)

    # ------------------------------------------------------------------
    # Scoring — Helpers
    # ------------------------------------------------------------------

    def _apply_weights(self, category_scores: dict, profile: str) -> float:
        """Gewichtete Summe basierend auf Profil."""
        weights = PROFILES[profile]["weights"]
        total = sum(
            category_scores[cat] * weights[cat]
            for cat in category_scores
        )
        return _clamp(total)

    @staticmethod
    def _determine_zone(score: float) -> str:
        """Health Zone: green (80-100), yellow (50-79), red (0-49)."""
        if score >= 80.0:
            return "green"
        elif score >= 50.0:
            return "yellow"
        return "red"

    # ------------------------------------------------------------------
    # Persistence
    # ------------------------------------------------------------------

    def _persist_score(
        self, app_id: str, overall: float, zone: str, categories: dict
    ) -> None:
        """Speichert Score in DB: Health Record + App Update."""
        # Update app record
        self._db.update_app(app_id, {
            "health_score": round(overall, 1),
            "health_zone": zone,
        })

        # Add health history record
        self._db.add_health_record(app_id, {
            "overall_score": round(overall, 1),
            "stability_score": round(categories["stability"], 1),
            "satisfaction_score": round(categories["satisfaction"], 1),
            "engagement_score": round(categories["engagement"], 1),
            "revenue_score": round(categories["revenue"], 1),
            "growth_score": round(categories["growth"], 1),
        })
