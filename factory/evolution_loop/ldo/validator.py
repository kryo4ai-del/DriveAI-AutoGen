"""LDO Validator — Schema validation for Loop Data Objects."""

from __future__ import annotations

from dataclasses import dataclass, field

from .schema import LoopDataObject, ScoreEntry


# ---------------------------------------------------------------------------
# Allowed values
# ---------------------------------------------------------------------------

VALID_PROJECT_TYPES = {"game", "business_app", "utility", "social"}
VALID_PRODUCTION_LINES = {"ios", "android", "web", "unity", "python"}
VALID_LOOP_MODES = {"sprint", "deep", "pivot"}
VALID_COMPILE_STATUSES = {"success", "failed", "not_built"}
VALID_GAP_CATEGORIES = {"bug", "feature", "performance", "ux", "structural"}
VALID_GAP_SEVERITIES = {"critical", "high", "medium", "low"}
VALID_TASK_TYPES = {"fix", "refactor", "implement", "remove"}
VALID_TASK_PRIORITIES = {"critical", "high", "medium", "low"}
VALID_CEO_CATEGORIES = {"bug", "ux", "performance", "content", "feel"}
VALID_CEO_SEVERITIES = {"blocker", "major", "minor"}
VALID_CEO_STATUSES = {"pending", "go", "no_go"}
VALID_TRENDS = {"improving", "stagnating", "declining"}
VALID_RECOMMENDATIONS = {"continue", "ceo_review", "stop"}


# ---------------------------------------------------------------------------
# Result
# ---------------------------------------------------------------------------

@dataclass
class ValidationResult:
    is_valid: bool = True
    errors: list = field(default_factory=list)


# ---------------------------------------------------------------------------
# Validator
# ---------------------------------------------------------------------------

class LDOValidator:
    """Validates a LoopDataObject for correctness."""

    def validate(self, ldo: LoopDataObject) -> ValidationResult:
        errors: list[str] = []

        # -- Meta -----------------------------------------------------------
        m = ldo.meta
        if not m.project_id:
            errors.append("meta.project_id is empty")
        if m.project_type and m.project_type not in VALID_PROJECT_TYPES:
            errors.append(f"meta.project_type '{m.project_type}' not in {sorted(VALID_PROJECT_TYPES)}")
        if m.production_line and m.production_line not in VALID_PRODUCTION_LINES:
            errors.append(f"meta.production_line '{m.production_line}' not in {sorted(VALID_PRODUCTION_LINES)}")
        if m.iteration < 0:
            errors.append(f"meta.iteration must be >= 0, got {m.iteration}")
        if m.loop_mode and m.loop_mode not in VALID_LOOP_MODES:
            errors.append(f"meta.loop_mode '{m.loop_mode}' not in {sorted(VALID_LOOP_MODES)}")

        # -- Build Artifacts ------------------------------------------------
        ba = ldo.build_artifacts
        if ba.compile_status and ba.compile_status not in VALID_COMPILE_STATUSES:
            errors.append(f"build_artifacts.compile_status '{ba.compile_status}' not in {sorted(VALID_COMPILE_STATUSES)}")

        # -- Scores ---------------------------------------------------------
        self._validate_score(ldo.scores.bug_score, "scores.bug_score", errors)
        self._validate_score(ldo.scores.roadbook_match_score, "scores.roadbook_match_score", errors)
        self._validate_score(ldo.scores.structural_health_score, "scores.structural_health_score", errors)
        self._validate_score(ldo.scores.performance_score, "scores.performance_score", errors)
        self._validate_score(ldo.scores.ux_score, "scores.ux_score", errors)

        for name, ps in ldo.scores.plugin_scores.items():
            if isinstance(ps, ScoreEntry):
                self._validate_score(ps, f"scores.plugin_scores[{name}]", errors)

        agg = ldo.scores.quality_score_aggregate
        if not (0.0 <= agg <= 100.0):
            errors.append(f"scores.quality_score_aggregate must be 0-100, got {agg}")

        # -- Gaps -----------------------------------------------------------
        for i, gap in enumerate(ldo.gaps):
            if gap.category and gap.category not in VALID_GAP_CATEGORIES:
                errors.append(f"gaps[{i}].category '{gap.category}' not in {sorted(VALID_GAP_CATEGORIES)}")
            if gap.severity and gap.severity not in VALID_GAP_SEVERITIES:
                errors.append(f"gaps[{i}].severity '{gap.severity}' not in {sorted(VALID_GAP_SEVERITIES)}")

        # -- Regression Data ------------------------------------------------
        rd = ldo.regression_data
        if rd.trend and rd.trend not in VALID_TRENDS:
            errors.append(f"regression_data.trend '{rd.trend}' not in {sorted(VALID_TRENDS)}")
        if rd.recommendation and rd.recommendation not in VALID_RECOMMENDATIONS:
            errors.append(f"regression_data.recommendation '{rd.recommendation}' not in {sorted(VALID_RECOMMENDATIONS)}")

        # -- Tasks ----------------------------------------------------------
        for i, task in enumerate(ldo.tasks):
            if task.type and task.type not in VALID_TASK_TYPES:
                errors.append(f"tasks[{i}].type '{task.type}' not in {sorted(VALID_TASK_TYPES)}")
            if task.priority and task.priority not in VALID_TASK_PRIORITIES:
                errors.append(f"tasks[{i}].priority '{task.priority}' not in {sorted(VALID_TASK_PRIORITIES)}")

        # -- CEO Feedback ---------------------------------------------------
        cf = ldo.ceo_feedback
        if cf.status and cf.status not in VALID_CEO_STATUSES:
            errors.append(f"ceo_feedback.status '{cf.status}' not in {sorted(VALID_CEO_STATUSES)}")
        for i, issue in enumerate(cf.issues):
            if issue.category and issue.category not in VALID_CEO_CATEGORIES:
                errors.append(f"ceo_feedback.issues[{i}].category '{issue.category}' not in {sorted(VALID_CEO_CATEGORIES)}")
            if issue.severity and issue.severity not in VALID_CEO_SEVERITIES:
                errors.append(f"ceo_feedback.issues[{i}].severity '{issue.severity}' not in {sorted(VALID_CEO_SEVERITIES)}")

        return ValidationResult(is_valid=len(errors) == 0, errors=errors)

    @staticmethod
    def _validate_score(entry: ScoreEntry, path: str, errors: list[str]) -> None:
        if not (0.0 <= entry.value <= 100.0):
            errors.append(f"{path}.value must be 0-100, got {entry.value}")
        if not (0.0 <= entry.confidence <= 100.0):
            errors.append(f"{path}.confidence must be 0-100, got {entry.confidence}")
