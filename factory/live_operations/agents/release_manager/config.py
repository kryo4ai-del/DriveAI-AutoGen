"""ReleaseManager configuration."""

# ── Release Statuses ──────────────────────────────────────────────
STATUS_PENDING = "pending"
STATUS_QA_CHECK = "qa_check"
STATUS_QA_PASSED = "qa_passed"
STATUS_QA_FAILED = "qa_failed"
STATUS_UPLOADING = "uploading"
STATUS_UPLOADED = "uploaded"
STATUS_RELEASED = "released"
STATUS_FAILED = "failed"

# ── QA Thresholds ─────────────────────────────────────────────────
QA_MIN_HEALTH_SCORE = 30.0          # Minimum health score to proceed
QA_MAX_ACTIVE_ANOMALIES = 2         # Max anomalies before blocking
QA_REQUIRE_BRIEFING = True          # Must have briefing reference
QA_REQUIRE_SUBMISSION = True        # Must have factory submission

# ── Cooling Periods (hours) after release ─────────────────────────
COOLING_AFTER_RELEASE = {
    "hotfix": 48,
    "patch": 168,          # 1 week
    "feature_update": 336,  # 2 weeks
    "rollback": 24,
}

# ── Release Storage ──────────────────────────────────────────────
RELEASES_DIR_NAME = "releases"
