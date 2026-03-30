"""Cohort Analysis -- gruppiert Nutzer nach Akquisitions-Zeitpunkt und vergleicht."""

from datetime import datetime, timezone
from typing import Optional


class CohortAnalyzer:
    """Analysiert Kohorten und erkennt Update-Impact."""

    def __init__(self) -> None:
        pass

    def analyze_cohorts(self, metrics_history: list[dict],
                        release_history: list[dict] = None) -> dict:
        """Kohorten-Analyse basierend auf Metriken-History."""
        if not metrics_history:
            return {"cohorts": {}, "cohort_comparison": {}, "update_impact": []}

        cohorts = self._build_cohorts(metrics_history)
        comparison = self._compare_cohorts(cohorts)
        update_impact = []
        if release_history:
            update_impact = self._detect_update_impact(cohorts, release_history)

        return {
            "cohorts": cohorts,
            "cohort_comparison": comparison,
            "update_impact": update_impact,
        }

    def _build_cohorts(self, metrics_history: list[dict], period: str = "weekly") -> dict:
        """Gruppiert Metriken nach Wochen-Kohorten."""
        cohorts = {}

        for i, entry in enumerate(metrics_history):
            collected = entry.get("collected_at", "")
            if not collected:
                week_label = f"Week-{i // 7 + 1}"
            else:
                try:
                    dt = datetime.fromisoformat(collected.replace("Z", "+00:00"))
                    year, week, _ = dt.isocalendar()
                    week_label = f"{year}-W{week:02d}"
                except (ValueError, AttributeError):
                    week_label = f"Week-{i // 7 + 1}"

            if week_label not in cohorts:
                cohorts[week_label] = {
                    "period": week_label,
                    "data_points": [],
                    "new_users": 0,
                }

            firebase = entry.get("firebase_metrics", {})
            store = entry.get("store_metrics", {})

            cohorts[week_label]["data_points"].append(entry)
            cohorts[week_label]["new_users"] += store.get("downloads_period", 0)

        # Aggregieren pro Kohorte
        result = {}
        for label, cohort in cohorts.items():
            points = cohort["data_points"]
            if not points:
                continue

            ret_d1_vals = [p.get("firebase_metrics", {}).get("retention_day1", 0) for p in points]
            ret_d7_vals = [p.get("firebase_metrics", {}).get("retention_day7", 0) for p in points]
            ret_d30_vals = [p.get("firebase_metrics", {}).get("retention_day30", 0) for p in points]

            result[label] = {
                "period": label,
                "new_users": cohort["new_users"],
                "retention_day1": round(sum(ret_d1_vals) / len(ret_d1_vals), 3) if ret_d1_vals else 0,
                "retention_day7": round(sum(ret_d7_vals) / len(ret_d7_vals), 3) if ret_d7_vals else 0,
                "retention_day30": round(sum(ret_d30_vals) / len(ret_d30_vals), 3) if ret_d30_vals else 0,
            }

        return result

    def _compare_cohorts(self, cohorts: dict) -> dict:
        """Vergleich zwischen Kohorten."""
        if len(cohorts) < 2:
            return {"trend": "insufficient_data", "best_cohort": "", "worst_cohort": ""}

        sorted_labels = sorted(cohorts.keys())
        best = max(sorted_labels, key=lambda k: cohorts[k].get("retention_day7", 0))
        worst = min(sorted_labels, key=lambda k: cohorts[k].get("retention_day7", 0))

        # Trend: Vergleiche erste und letzte Kohorte
        first = cohorts[sorted_labels[0]]
        last = cohorts[sorted_labels[-1]]

        ret7_change = last.get("retention_day7", 0) - first.get("retention_day7", 0)
        if ret7_change > 0.02:
            trend = "improving"
        elif ret7_change < -0.02:
            trend = "declining"
        else:
            trend = "stable"

        return {
            "trend": trend,
            "best_cohort": best,
            "worst_cohort": worst,
            "avg_retention_day7_change": round(ret7_change, 3),
        }

    def _detect_update_impact(self, cohorts: dict, release_history: list[dict]) -> list[dict]:
        """Erkennt ob ein Update die Retention veraendert hat."""
        impacts = []
        sorted_labels = sorted(cohorts.keys())

        if len(sorted_labels) < 2:
            return impacts

        for release in release_history:
            version = release.get("version", "?")
            release_date = release.get("release_date", "")

            # Finde Kohorte vor und nach dem Release
            try:
                dt = datetime.fromisoformat(release_date.replace("Z", "+00:00"))
                year, week, _ = dt.isocalendar()
                release_week = f"{year}-W{week:02d}"
            except (ValueError, AttributeError):
                continue

            # Kohorte vor Release
            before_labels = [l for l in sorted_labels if l < release_week]
            after_labels = [l for l in sorted_labels if l >= release_week]

            if not before_labels or not after_labels:
                continue

            before = cohorts[before_labels[-1]]
            after = cohorts[after_labels[0]]

            ret7_before = before.get("retention_day7", 0)
            ret7_after = after.get("retention_day7", 0)
            change = ret7_after - ret7_before

            if abs(change) < 0.01:
                impact_label = "neutral"
            elif change > 0:
                impact_label = "positive"
            else:
                impact_label = "negative"

            impact_pct = round((change / ret7_before * 100), 1) if ret7_before > 0 else 0

            impacts.append({
                "version": version,
                "release_date": release_date,
                "cohort_before": before_labels[-1],
                "cohort_after": after_labels[0],
                "retention_day7_before": ret7_before,
                "retention_day7_after": ret7_after,
                "impact": impact_label,
                "impact_score": impact_pct,
                "message": f"Update {version} had {impact_label} impact on Day-7 Retention ({impact_pct:+.1f}%)",
            })

        return impacts
