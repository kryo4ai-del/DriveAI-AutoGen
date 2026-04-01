"""Anomaly Detector -- erkennt dramatische Abweichungen.

Laeuft alle 30 Minuten. Bewusst SIMPEL — nur Ausreisser-Erkennung,
keine Trendanalyse. Geschwindigkeit > Genauigkeit.
"""

from datetime import datetime, timezone, timedelta
from typing import Optional

from ...app_registry.database import AppRegistryDB
from . import config


class AnomalyDetector:
    """Erkennt dramatische Abweichungen ausserhalb des 6h-Zyklus."""

    def __init__(self, registry_db: Optional[AppRegistryDB] = None) -> None:
        self.db = registry_db or AppRegistryDB()

    # ------------------------------------------------------------------
    # Public API
    # ------------------------------------------------------------------

    def scan_all(self) -> list:
        """Scannt alle Apps auf Anomalien."""
        print("[Anomaly Detector] Scanning all apps")
        anomalies = []

        try:
            apps = self.db.get_all_apps()
        except Exception:
            apps = []

        for app in apps:
            app_id = app.get("app_id", "")
            if not app_id:
                continue
            try:
                anomaly = self.scan_app(app_id)
                if anomaly:
                    anomalies.append(anomaly)
            except Exception as e:
                print(f"[Anomaly Detector] Error scanning {app_id}: {e}")

        found = len(anomalies)
        print(f"[Anomaly Detector] Scan complete: {found} anomalies in {len(apps)} apps")
        return anomalies

    def scan_app(self, app_id: str, current: dict = None, baseline: dict = None) -> Optional[dict]:
        """Scannt eine App auf Anomalien. Returned Anomalie oder None."""
        if current is None:
            current = self._get_current_metrics(app_id)
        if baseline is None:
            baseline = self._get_baseline(app_id)

        # Get current health score and previous
        current_score = current.get("health_score", 0)
        previous_score = baseline.get("health_score", current_score)

        # Check each anomaly type
        # post_update_regression FIRST -- if a recent update caused the issue,
        # auto-rollback is more useful than generic escalation
        checks = [
            self._check_post_update_regression(app_id, current, baseline),
            self._check_crash_explosion(app_id, current, baseline),
            self._check_revenue_collapse(app_id, current, baseline),
            self._check_health_score_freefall(app_id, current_score, previous_score),
        ]

        # Return first anomaly found
        for anomaly in checks:
            if anomaly:
                print(f"[Anomaly Detector] {app_id}: {anomaly['anomaly_type']} "
                      f"({anomaly['severity']})")
                return anomaly

        return None

    # ------------------------------------------------------------------
    # Anomaly Checks
    # ------------------------------------------------------------------

    def _check_crash_explosion(self, app_id: str, current: dict, baseline: dict) -> Optional[dict]:
        """Crash Rate verdoppelt sich innerhalb eines Intervalls."""
        current_crash = current.get("crash_rate", 0)
        baseline_crash = baseline.get("crash_rate", 0)

        if baseline_crash <= 0:
            return None

        multiplier = current_crash / baseline_crash
        if multiplier < config.CRASH_EXPLOSION_MULTIPLIER:
            return None

        return {
            "app_id": app_id,
            "detected_at": datetime.now(timezone.utc).isoformat(),
            "anomaly_type": "crash_explosion",
            "severity": "critical",
            "detail": f"Crash Rate von {baseline_crash:.1%} auf {current_crash:.1%} "
                      f"gestiegen ({multiplier:.1f}x Baseline)",
            "baseline_value": baseline_crash,
            "current_value": current_crash,
            "affected_metric": "crash_rate",
            "can_auto_rollback": False,  # Crash alone doesn't warrant rollback
            "recommended_action": "escalate",
            "escalation_level": 3,
        }

    def _check_revenue_collapse(self, app_id: str, current: dict, baseline: dict) -> Optional[dict]:
        """Revenue faellt auf unter 20% des Baselines."""
        current_rev = current.get("revenue", 0)
        baseline_rev = baseline.get("revenue", 0)

        if baseline_rev <= 0:
            return None

        ratio = current_rev / baseline_rev
        if ratio >= config.REVENUE_COLLAPSE_THRESHOLD:
            return None

        return {
            "app_id": app_id,
            "detected_at": datetime.now(timezone.utc).isoformat(),
            "anomaly_type": "revenue_collapse",
            "severity": "critical",
            "detail": f"Revenue auf {ratio:.0%} des Baselines gefallen "
                      f"({current_rev:.2f} vs {baseline_rev:.2f})",
            "baseline_value": baseline_rev,
            "current_value": current_rev,
            "affected_metric": "revenue",
            "can_auto_rollback": False,
            "recommended_action": "escalate",
            "escalation_level": 3,
        }

    def _check_health_score_freefall(self, app_id: str, current_score: float,
                                     previous_score: float) -> Optional[dict]:
        """Health Score faellt um >20 Punkte in einem Zyklus."""
        drop = previous_score - current_score
        if drop < config.HEALTH_FREEFALL_THRESHOLD:
            return None

        return {
            "app_id": app_id,
            "detected_at": datetime.now(timezone.utc).isoformat(),
            "anomaly_type": "health_score_freefall",
            "severity": "critical",
            "detail": f"Health Score von {previous_score:.1f} auf {current_score:.1f} "
                      f"gefallen (-{drop:.1f} Punkte)",
            "baseline_value": previous_score,
            "current_value": current_score,
            "affected_metric": "health_score",
            "can_auto_rollback": False,
            "recommended_action": "escalate",
            "escalation_level": 3,
        }

    def _check_post_update_regression(self, app_id: str, current: dict,
                                      baseline: dict) -> Optional[dict]:
        """Nach einem Update: Key-Metriken schlechter als vor dem Update.

        Nur geprueft in den ersten 48h nach einem Release.
        Dies ist der EINZIGE Fall in dem auto_rollback = True sein kann.
        """
        last_release = current.get("last_release_date")
        if not last_release:
            return None

        try:
            release_dt = datetime.fromisoformat(last_release.replace("Z", "+00:00"))
        except (ValueError, AttributeError):
            return None

        # Only check within 48h window
        hours_since = (datetime.now(timezone.utc) - release_dt).total_seconds() / 3600
        if hours_since > config.POST_UPDATE_WINDOW_HOURS:
            return None

        # Check if key metrics are significantly worse
        regressions = []
        for metric in ["crash_rate", "dau", "retention_day7"]:
            curr_val = current.get(metric, 0)
            base_val = baseline.get(metric, 0)
            if base_val == 0:
                continue

            if metric == "crash_rate":
                # Higher is worse
                if curr_val > base_val * 1.5:
                    regressions.append(f"{metric}: {base_val:.2%} -> {curr_val:.2%}")
            else:
                # Lower is worse
                if curr_val < base_val * 0.7:
                    regressions.append(f"{metric}: {base_val:.0f} -> {curr_val:.0f}")

        if not regressions:
            return None

        # Check if rollback is possible
        has_stable = bool(current.get("last_stable_version"))

        return {
            "app_id": app_id,
            "detected_at": datetime.now(timezone.utc).isoformat(),
            "anomaly_type": "post_update_regression",
            "severity": "high",
            "detail": f"Post-Update Regression ({hours_since:.0f}h nach Release): "
                      + ", ".join(regressions),
            "baseline_value": baseline,
            "current_value": current,
            "affected_metric": "multiple",
            "can_auto_rollback": has_stable,
            "recommended_action": "rollback" if has_stable else "escalate",
            "escalation_level": 2 if has_stable else 3,
            "regressions": regressions,
            "hours_since_release": round(hours_since, 1),
        }

    # ------------------------------------------------------------------
    # Data Access
    # ------------------------------------------------------------------

    def _get_current_metrics(self, app_id: str) -> dict:
        """Aktuelle Metriken aus der Registry."""
        result = {"app_id": app_id}
        try:
            app = self.db.get_app(app_id)
            if app:
                result["health_score"] = app.get("health_score", 0)
                result["current_version"] = app.get("current_version")
                result["last_stable_version"] = app.get("last_stable_version")

                # Last release date from release_history
                releases = self.db.get_release_history(app_id)
                if releases:
                    result["last_release_date"] = releases[0].get("release_date")
        except Exception:
            pass
        return result

    def _get_baseline(self, app_id: str) -> dict:
        """Letzte bekannte 'normale' Metriken (Durchschnitt letzte Zyklen)."""
        result = {"app_id": app_id, "health_score": 75, "crash_rate": 0.01,
                  "revenue": 100, "dau": 1000, "retention_day7": 0.35}

        try:
            history = self.db.get_health_history(app_id, limit=config.BASELINE_CYCLES)
            if history:
                scores = [h.get("overall_score", 0) for h in history]
                if scores:
                    result["health_score"] = sum(scores) / len(scores)
        except Exception:
            pass

        return result
