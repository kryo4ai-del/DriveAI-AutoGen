"""Hard Score Calculator — Objective, deterministic quality scores.

Hard Scores are measurable, reproducible, and have high confidence (85-95%).
They form the foundation of the Evolution Loop quality system and hold
veto power over the aggregate score.

Three hard scores:
  1. Bug Score — based on test failures, compile errors, warnings
  2. Roadbook Match — feature/screen/flow coverage vs. targets
  3. Structural Health — static analysis (dead code, nesting, error handling)

All formulas are pure math — no LLM calls.
"""

from __future__ import annotations

from factory.evolution_loop.ldo.schema import ScoreEntry


def _clamp(value: float, lo: float = 0.0, hi: float = 100.0) -> float:
    """Clamp a value between lo and hi."""
    return max(lo, min(hi, value))


class HardScoreCalculator:
    """Calculates objective, deterministic quality scores."""

    # ------------------------------------------------------------------
    # Bug Score
    # ------------------------------------------------------------------

    def calculate_bug_score(
        self,
        qa_results: dict | None,
        simulation_results: dict | None = None,
    ) -> ScoreEntry:
        """Bug Score (0-100, higher = fewer bugs).

        Formula::

            score = 100
                  - (tests_failed * 5)
                  - (len(compile_errors) * 15)
                  - (len(warnings) * 1)
                  - (stubs * 3)       # from static_analysis if available
                  - (todos * 1)       # from static_analysis if available

        Confidence: 95 when test data exists, 10 when empty.
        """
        qa = qa_results or {}

        tests_failed = qa.get("tests_failed", 0) or 0
        compile_errors = qa.get("compile_errors", []) or []
        warnings = qa.get("warnings", []) or []

        # Check if we have any data at all
        has_data = (
            tests_failed > 0
            or qa.get("tests_passed", 0)
            or len(compile_errors) > 0
            or len(warnings) > 0
        )

        if not has_data and not qa:
            return ScoreEntry(value=50.0, confidence=10.0)

        score = 100.0
        score -= tests_failed * 5
        score -= len(compile_errors) * 15
        score -= len(warnings) * 1

        # Optional: static analysis extras
        if simulation_results and isinstance(simulation_results, dict):
            sa = simulation_results.get("static_analysis", {})
            if isinstance(sa, dict):
                score -= sa.get("stubs_count", 0) * 3
                score -= sa.get("todos_count", 0) * 1

        confidence = 95.0 if has_data else 10.0
        return ScoreEntry(value=_clamp(score), confidence=confidence)

    # ------------------------------------------------------------------
    # Roadbook Match
    # ------------------------------------------------------------------

    def calculate_roadbook_match(
        self,
        roadbook_targets: dict | None,
        simulation_results: dict | None = None,
    ) -> ScoreEntry:
        """Roadbook Match Score (0-100, higher = more features implemented).

        Formula::

            features_ratio = features_covered / features_total   (weight 40)
            screens_ratio  = screens_covered  / screens_total    (weight 30)
            flows_ratio    = flows_covered    / flows_total      (weight 30)
            score = features_ratio * 40 + screens_ratio * 30 + flows_ratio * 30

        Confidence: 90 with simulation data, 30 without.
        """
        targets = roadbook_targets or {}

        features = targets.get("features", []) or []
        screens = targets.get("screens", []) or []
        user_flows = targets.get("user_flows", []) or []

        total_features = len(features)
        total_screens = len(screens)
        total_flows = len(user_flows)

        # Nothing to match against
        if total_features == 0 and total_screens == 0 and total_flows == 0:
            return ScoreEntry(value=0.0, confidence=0.0)

        # Extract coverage from simulation results
        sim = simulation_results or {}
        coverage = sim.get("roadbook_coverage", {}) or {}
        synthetic_flows = sim.get("synthetic_flows", []) or []

        features_covered = len(coverage.get("features_covered", []) or [])
        screens_covered = len(coverage.get("screens_covered", []) or [])

        # Flows: count from synthetic_flows where is_complete=True,
        # or from roadbook_coverage["flows_covered"]
        flows_covered_list = coverage.get("flows_covered", None)
        if flows_covered_list is not None:
            flows_covered = len(flows_covered_list)
        else:
            flows_covered = sum(
                1 for f in synthetic_flows
                if isinstance(f, dict) and f.get("is_complete", False)
            )

        has_sim = bool(coverage or synthetic_flows)

        # Ratios (guard against division by zero)
        feat_ratio = (features_covered / total_features) if total_features > 0 else 0.0
        screen_ratio = (screens_covered / total_screens) if total_screens > 0 else 0.0
        flow_ratio = (flows_covered / total_flows) if total_flows > 0 else 0.0

        # Weighted score — only count dimensions that have targets
        weight_feat = 40 if total_features > 0 else 0
        weight_screen = 30 if total_screens > 0 else 0
        weight_flow = 30 if total_flows > 0 else 0
        total_weight = weight_feat + weight_screen + weight_flow

        if total_weight == 0:
            return ScoreEntry(value=0.0, confidence=0.0)

        # Normalize weights so they sum to 100
        score = (
            feat_ratio * (weight_feat / total_weight * 100)
            + screen_ratio * (weight_screen / total_weight * 100)
            + flow_ratio * (weight_flow / total_weight * 100)
        )

        confidence = 90.0 if has_sim else 30.0
        return ScoreEntry(value=_clamp(round(score, 1)), confidence=confidence)

    # ------------------------------------------------------------------
    # Structural Health
    # ------------------------------------------------------------------

    def calculate_structural_health(
        self,
        simulation_results: dict | None = None,
    ) -> ScoreEntry:
        """Structural Health Score (0-100).

        4 criteria, each worth 25 points:

        1. **dead_code_ratio** (25 pts):
           0% → 25, ≥20% → 0, linear in between.

        2. **dependency_health** (25 pts):
           25 - (hardcoded_values * 2), clamped to [0, 25].

        3. **pattern_compliance** (25 pts):
           25 - (deep_nesting * 5), clamped to [0, 25].

        4. **error_handling_coverage** (25 pts):
           error_handling_ratio * 25 (ratio 0.8+ → 20-25 pts).

        Confidence: 85 with static analysis data, 20 without.
        """
        sim = simulation_results or {}
        sa = sim.get("static_analysis", {}) or {}

        if not sa:
            return ScoreEntry(value=50.0, confidence=20.0)

        # 1. Dead code (25 pts)
        dead_ratio = sa.get("dead_code_ratio", 0.0) or 0.0
        dead_pts = _clamp(25.0 * (1.0 - dead_ratio / 0.20), 0.0, 25.0)

        # 2. Dependency health (25 pts)
        hardcoded = sa.get("hardcoded_values", 0) or 0
        dep_pts = _clamp(25.0 - hardcoded * 2.0, 0.0, 25.0)

        # 3. Pattern compliance (25 pts)
        deep_nesting = sa.get("deep_nesting", 0) or 0
        pattern_pts = _clamp(25.0 - deep_nesting * 5.0, 0.0, 25.0)

        # 4. Error handling coverage (25 pts)
        err_ratio = sa.get("error_handling_ratio", 0.0) or 0.0
        err_pts = _clamp(err_ratio * 25.0, 0.0, 25.0)

        score = dead_pts + dep_pts + pattern_pts + err_pts
        return ScoreEntry(value=_clamp(round(score, 1)), confidence=85.0)
