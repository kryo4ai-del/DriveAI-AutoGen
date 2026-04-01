"""QA Checker — pre-release validation gate.

Deterministic checks before a release can proceed.
"""

from . import config as cfg


class QAChecker:
    """Validates whether a release is safe to proceed."""

    def check(self, release_context: dict) -> dict:
        """Run all QA checks on a release context.

        Args:
            release_context: Dict with keys:
                - app_id, action_type, target_version
                - health_score (current)
                - active_anomalies (count)
                - has_briefing (bool)
                - has_submission (bool)
                - cooling_active (bool)

        Returns:
            Dict with passed (bool), checks (list of check results), blockers (list).
        """
        checks = []
        blockers = []

        # 1. Health Score Check
        score = release_context.get("health_score", 0)
        health_ok = score >= cfg.QA_MIN_HEALTH_SCORE
        checks.append({
            "name": "health_score",
            "passed": health_ok,
            "detail": f"Score {score:.1f} (min: {cfg.QA_MIN_HEALTH_SCORE})",
        })
        if not health_ok:
            blockers.append(f"Health Score zu niedrig: {score:.1f} < {cfg.QA_MIN_HEALTH_SCORE}")

        # 2. Anomaly Check
        anomalies = release_context.get("active_anomalies", 0)
        anomaly_ok = anomalies <= cfg.QA_MAX_ACTIVE_ANOMALIES
        checks.append({
            "name": "active_anomalies",
            "passed": anomaly_ok,
            "detail": f"{anomalies} aktive Anomalien (max: {cfg.QA_MAX_ACTIVE_ANOMALIES})",
        })
        if not anomaly_ok:
            blockers.append(f"Zu viele aktive Anomalien: {anomalies} > {cfg.QA_MAX_ACTIVE_ANOMALIES}")

        # 3. Cooling Check
        cooling = release_context.get("cooling_active", False)
        cooling_ok = not cooling
        checks.append({
            "name": "cooling_active",
            "passed": cooling_ok,
            "detail": "Kein Cooling aktiv" if cooling_ok else "Cooling-Periode aktiv",
        })
        if not cooling_ok:
            blockers.append("App befindet sich in Cooling-Periode")

        # 4. Briefing Check (optional)
        if cfg.QA_REQUIRE_BRIEFING:
            has_briefing = release_context.get("has_briefing", False)
            checks.append({
                "name": "briefing_exists",
                "passed": has_briefing,
                "detail": "Briefing vorhanden" if has_briefing else "Kein Briefing",
            })
            if not has_briefing:
                blockers.append("Kein Briefing Document vorhanden")

        # 5. Submission Check (optional)
        if cfg.QA_REQUIRE_SUBMISSION:
            has_sub = release_context.get("has_submission", False)
            checks.append({
                "name": "submission_exists",
                "passed": has_sub,
                "detail": "Factory Submission vorhanden" if has_sub else "Keine Submission",
            })
            if not has_sub:
                blockers.append("Keine Factory Submission vorhanden")

        return {
            "passed": len(blockers) == 0,
            "checks": checks,
            "blockers": blockers,
            "total_checks": len(checks),
            "passed_checks": sum(1 for c in checks if c["passed"]),
        }
