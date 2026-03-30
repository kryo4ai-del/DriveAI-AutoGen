"""Analytics Agent -- Core Framework.

Verwandelt Rohdaten in Insights: Trends, Funnels, Kohorten, Feature Usage.
Wird in Prompts 10+11 um weitere Analysen erweitert.
"""

import json
import os
from datetime import datetime, timezone
from typing import Optional

from ...app_registry.database import AppRegistryDB
from . import config
from .trend_detector import TrendDetector
from .funnel_analyzer import FunnelAnalyzer
from .cohort_analyzer import CohortAnalyzer
from .feature_tracker import FeatureTracker


class AnalyticsAgent:
    """Analytisches Gehirn des Live Operations Layers."""

    def __init__(self, registry_db: Optional[AppRegistryDB] = None) -> None:
        self.db = registry_db or AppRegistryDB()
        self.trend_detector = TrendDetector()
        self.funnel_analyzer = FunnelAnalyzer()
        self.cohort_analyzer = CohortAnalyzer()
        self.feature_tracker = FeatureTracker()

    def analyze_app(self, app_id: str, metrics_history: list[dict]) -> dict:
        """Vollstaendige Analyse einer App."""
        print(f"[Analytics Agent] Analysiere App {app_id} ({len(metrics_history)} Datenpunkte)")

        result = {
            "app_id": app_id,
            "analyzed_at": datetime.now(timezone.utc).isoformat(),
            "trend_analysis": {},
            "funnel_analysis": {},
            "cohort_analysis": {},
            "feature_usage": {},
            "recommendations": [],
        }

        # Trend Detection
        if metrics_history:
            result["trend_analysis"] = self.trend_detector.detect_trends(metrics_history)
            result["recommendations"].extend(
                self._trend_recommendations(result["trend_analysis"])
            )

        # Funnel Analysis
        if metrics_history:
            result["funnel_analysis"] = self.funnel_analyzer.analyze_funnels(metrics_history)
            for finding in result["funnel_analysis"].get("critical_findings", []):
                result["recommendations"].append({
                    "type": finding.get("severity", "warning"),
                    "category": "funnel",
                    "message": finding.get("message", ""),
                    "data_points": {"funnel": finding.get("funnel", "")},
                    "suggested_action": finding.get("suggested_action", ""),
                })

        # Cohort Analysis
        if metrics_history:
            release_hist = []
            app = self.db.get_app(app_id)
            if app:
                release_hist = self.db.get_release_history(app_id)
            result["cohort_analysis"] = self.cohort_analyzer.analyze_cohorts(
                metrics_history, release_hist
            )
            for impact in result["cohort_analysis"].get("update_impact", []):
                if impact.get("impact") == "negative":
                    result["recommendations"].append({
                        "type": "warning",
                        "category": "cohort",
                        "message": impact.get("message", ""),
                        "data_points": {"version": impact.get("version"), "score": impact.get("impact_score")},
                        "suggested_action": "Investigate what changed in this update",
                    })

        # Feature Usage
        if metrics_history:
            result["feature_usage"] = self.feature_tracker.analyze_feature_usage(metrics_history)
            for rec in result["feature_usage"].get("recommendations", []):
                result["recommendations"].append({
                    "type": "opportunity" if rec.get("type") == "rising" else "warning",
                    "category": "feature_usage",
                    "message": rec.get("message", ""),
                    "data_points": {"feature": rec.get("feature", "")},
                    "suggested_action": rec.get("suggested_action", ""),
                })

        # Insights speichern
        self._save_insights(app_id, result)

        return result

    def analyze_all(self) -> dict:
        """Analyse aller Apps."""
        apps = self.db.get_all_apps()
        if not apps:
            print("[Analytics Agent] Keine Apps in der Registry.")
            return {}

        results = {}
        for app in apps:
            history = self._load_metrics_history(app["app_id"])
            results[app["app_id"]] = self.analyze_app(app["app_id"], history)

        print(f"[Analytics Agent] {len(results)} Apps analysiert.")
        return results

    def get_insights_summary(self, app_id: str) -> dict:
        """Aggregierte Zusammenfassung aller Insights fuer Decision Engine."""
        insights_path = os.path.join(
            config.INSIGHTS_OUTPUT_DIR, f"{app_id}_latest.json"
        )
        if os.path.isfile(insights_path):
            with open(insights_path, "r", encoding="utf-8") as f:
                return json.load(f)
        return {}

    def _load_metrics_history(self, app_id: str, days: int = 30) -> list[dict]:
        """Laedt historische Metriken aus dem Data-Verzeichnis."""
        data_dir = os.path.join("factory", "live_operations", "data")
        history = []

        if not os.path.isdir(data_dir):
            return history

        for fname in sorted(os.listdir(data_dir)):
            if not fname.endswith(".json") or fname.startswith("."):
                continue
            fpath = os.path.join(data_dir, fname)
            try:
                with open(fpath, "r", encoding="utf-8") as f:
                    data = json.load(f)
                # Kann ein Dict mit app_id-Keys sein oder ein einzelner Eintrag
                if isinstance(data, dict):
                    if app_id in data:
                        history.append(data[app_id])
                    elif data.get("app_id") == app_id:
                        history.append(data)
            except (json.JSONDecodeError, OSError):
                continue

        return history[-days:]  # Letzte N Tage

    def _save_insights(self, app_id: str, insights: dict) -> None:
        """Speichert Insights als JSON."""
        os.makedirs(config.INSIGHTS_OUTPUT_DIR, exist_ok=True)

        # Timestamped file
        ts = datetime.now(timezone.utc).strftime("%Y%m%d_%H%M%S")
        path = os.path.join(config.INSIGHTS_OUTPUT_DIR, f"{app_id}_{ts}.json")
        with open(path, "w", encoding="utf-8") as f:
            json.dump(insights, f, indent=2, default=str)

        # Latest file (ueberschrieben)
        latest = os.path.join(config.INSIGHTS_OUTPUT_DIR, f"{app_id}_latest.json")
        with open(latest, "w", encoding="utf-8") as f:
            json.dump(insights, f, indent=2, default=str)

        print(f"[Analytics Agent] Insights gespeichert: {path}")

    def _trend_recommendations(self, trend_data: dict) -> list[dict]:
        """Generiert Empfehlungen aus Trend-Analyse."""
        recs = []
        trends = trend_data.get("trends", {})

        for key, info in trends.items():
            direction = info.get("direction", "stable")
            strength = info.get("strength", 0)
            anomalies = info.get("anomalies", [])

            # Fallende kritische Metriken
            if direction == "falling" and key in ("retention_day7", "retention_day30", "dau", "dau_mau_ratio"):
                severity = "critical" if strength > 0.6 else "warning"
                recs.append({
                    "type": severity,
                    "category": "engagement",
                    "message": f"{key} is {direction} (strength: {strength:.0%})",
                    "data_points": {"current": info["current_value"], "change": info["change_percent"]},
                    "suggested_action": f"Investigate {key} decline and consider re-engagement measures",
                })

            if direction == "rising" and key == "crash_rate":
                recs.append({
                    "type": "critical",
                    "category": "stability",
                    "message": f"Crash rate rising (strength: {strength:.0%})",
                    "data_points": {"current": info["current_value"], "change": info["change_percent"]},
                    "suggested_action": "Prioritize crash investigation and hotfix",
                })

            if direction == "falling" and key in ("revenue_period", "arpu"):
                recs.append({
                    "type": "warning",
                    "category": "revenue",
                    "message": f"{key} is declining (strength: {strength:.0%})",
                    "data_points": {"current": info["current_value"], "change": info["change_percent"]},
                    "suggested_action": "Review monetization strategy and conversion funnel",
                })

            # Anomalien
            for anomaly in anomalies:
                recs.append({
                    "type": "warning",
                    "category": "anomaly",
                    "message": f"Anomaly detected in {key}: {anomaly['type']} at index {anomaly['index']} ({anomaly['deviation_sigma']:.1f} sigma)",
                    "data_points": {"value": anomaly["value"], "expected": anomaly["expected"]},
                    "suggested_action": f"Investigate {anomaly['type']} in {key}",
                })

        return recs
