"""Regression Tracker — Analyzes iteration history, detects trends and stagnation.

Compares consecutive iterations to find improving, stagnating, or declining
trends.  Recommends whether the loop should continue, switch mode, or stop.

All logic is deterministic (no LLM).
"""

from __future__ import annotations

from factory.evolution_loop.config.config_loader import EvolutionConfig
from factory.evolution_loop.ldo.schema import LoopDataObject

_PREFIX = "[EVO-REGRESSION]"

_SCORE_NAMES = [
    "bug_score", "roadbook_match_score", "structural_health_score",
    "performance_score", "ux_score",
]

_MODE_ORDER = {"sprint": 0, "deep": 1, "pivot": 2}


def _extract_scores(ldo: LoopDataObject) -> dict[str, float]:
    """Extract score values from an LDO into a flat dict."""
    result: dict[str, float] = {}
    for name in _SCORE_NAMES:
        entry = getattr(ldo.scores, name, None)
        if entry is not None:
            result[name] = entry.value
    result["quality_score_aggregate"] = ldo.scores.quality_score_aggregate
    return result


class RegressionTracker:
    """Analyzes iteration history, detects trends and recommends loop steering."""

    AGENT_ID = "evo_regression_tracker"

    def __init__(self, config: EvolutionConfig) -> None:
        limits = config.get_loop_limits()
        self._stagnation_threshold = limits.get("stagnation_threshold_percent", 2)
        self._regression_threshold = limits.get("regression_threshold_percent", 5)
        self._stagnation_iterations = limits.get("stagnation_iterations", 2)
        self._deep_max_iterations = limits.get("deep_max_iterations", 5)

        # Track iterations without improvement across calls
        self._iterations_without_improvement: int = 0

    # ------------------------------------------------------------------
    # Main entry point
    # ------------------------------------------------------------------

    def analyze(
        self, ldo: LoopDataObject, history: list[LoopDataObject],
    ) -> LoopDataObject:
        """Analyze trend and write recommendation into ldo.regression_data."""
        iteration = ldo.meta.iteration

        # First iteration — no history
        if not history:
            ldo.regression_data.trend = "improving"
            ldo.regression_data.recommendation = "continue"
            ldo.regression_data.iterations_without_improvement = 0
            self._iterations_without_improvement = 0
            print(f"{_PREFIX} Iteration {iteration}: no history, starting fresh")
            return ldo

        # Compare with previous
        previous = history[-1]
        current_scores = _extract_scores(ldo)
        previous_scores = _extract_scores(previous)

        agg_delta = (
            current_scores.get("quality_score_aggregate", 0)
            - previous_scores.get("quality_score_aggregate", 0)
        )

        # Build comparison dict
        comparison: dict[str, float] = {}
        for name in list(current_scores.keys()):
            if name in previous_scores:
                comparison[name] = current_scores[name] - previous_scores[name]

        # Determine trend
        if agg_delta > self._stagnation_threshold:
            trend = "improving"
            self._iterations_without_improvement = 0
        elif agg_delta < -self._regression_threshold:
            trend = "declining"
            self._iterations_without_improvement = 0
        else:
            # Stagnation zone
            self._iterations_without_improvement += 1
            if self._iterations_without_improvement >= self._stagnation_iterations:
                trend = "stagnating"
            else:
                trend = "improving"  # give another chance

        # Find regressions
        regressions = self.find_regressions(current_scores, previous_scores)

        # Generate recommendation
        if trend == "declining":
            recommendation = "stop"
        elif trend == "stagnating":
            recommendation = "ceo_review"
        else:
            recommendation = "continue"

        # Write into LDO
        ldo.regression_data.trend = trend
        ldo.regression_data.iterations_without_improvement = self._iterations_without_improvement
        ldo.regression_data.regressions_detected = [
            f"{r['score_name']}: {r['previous']:.1f} -> {r['current']:.1f} ({r['delta']:+.1f})"
            for r in regressions
        ]
        ldo.regression_data.recommendation = recommendation
        ldo.regression_data.comparison_to_previous = comparison

        print(
            f"{_PREFIX} Iteration {iteration}: trend={trend}, "
            f"delta={agg_delta:+.1f}, recommendation={recommendation}"
        )

        return ldo

    # ------------------------------------------------------------------
    # Loop mode detection
    # ------------------------------------------------------------------

    def detect_loop_mode(
        self, ldo: LoopDataObject, history: list[LoopDataObject],
    ) -> str:
        """Detect appropriate loop mode: sprint, deep, or pivot.

        Mode can only escalate: sprint -> deep -> pivot (never back).
        """
        current_mode = ldo.meta.loop_mode or "sprint"
        trend = ldo.regression_data.trend

        new_mode = current_mode

        # Sprint -> Deep: stagnating while in sprint, or persistent gap (3+ iterations)
        if current_mode == "sprint" and trend == "stagnating":
            new_mode = "deep"

        # Sprint -> Deep: same gap in 3+ consecutive iterations
        if current_mode == "sprint" and self._has_persistent_gap(ldo, history, threshold=3):
            new_mode = "deep"

        # Deep -> Pivot: declining while in deep, or deep exhausted
        if current_mode == "deep":
            if trend == "declining":
                new_mode = "pivot"
            # Deep exhausted: count consecutive deep iterations (from end of history)
            deep_consecutive = self._count_iterations_in_mode(history, "deep")
            if deep_consecutive >= self._deep_max_iterations:
                new_mode = "pivot"

        # Enforce escalation only
        if _MODE_ORDER.get(new_mode, 0) < _MODE_ORDER.get(current_mode, 0):
            new_mode = current_mode

        return new_mode

    # ------------------------------------------------------------------
    # Regression detection
    # ------------------------------------------------------------------

    @staticmethod
    def find_regressions(
        current_scores: dict[str, float],
        previous_scores: dict[str, float],
    ) -> list[dict]:
        """Find scores that decreased between iterations."""
        regressions = []
        for name, current_val in current_scores.items():
            prev_val = previous_scores.get(name)
            if prev_val is None:
                continue
            delta = current_val - prev_val
            if delta < 0:
                regressions.append({
                    "score_name": name,
                    "previous": prev_val,
                    "current": current_val,
                    "delta": delta,
                })
        return regressions

    # ------------------------------------------------------------------
    # Trend summary
    # ------------------------------------------------------------------

    @staticmethod
    def get_trend_summary(history: list[LoopDataObject]) -> str:
        """Return a short textual summary of the aggregate trend."""
        if not history:
            return "No history available"

        aggregates = [h.scores.quality_score_aggregate for h in history]
        n = len(aggregates)
        first_iter = history[0].meta.iteration
        last_iter = history[-1].meta.iteration

        score_str = "->".join(f"{a:.1f}" for a in aggregates)

        if n >= 2:
            total_change = aggregates[-1] - aggregates[0]
            avg_change = total_change / (n - 1)
            if total_change > 2:
                trend_word = "improving"
            elif total_change < -2:
                trend_word = "declining"
            else:
                trend_word = "stable"
        else:
            avg_change = 0.0
            trend_word = "n/a"

        return (
            f"Iterations {first_iter}->{last_iter}: "
            f"Aggregate {score_str} "
            f"({trend_word}, avg change: {avg_change:+.1f}/iteration)"
        )

    # ------------------------------------------------------------------
    # Helpers
    # ------------------------------------------------------------------

    @staticmethod
    def _has_persistent_gap(
        ldo: LoopDataObject, history: list[LoopDataObject], threshold: int = 3,
    ) -> bool:
        """Check if any gap has persisted for threshold consecutive iterations."""
        if len(history) < threshold - 1:
            return False

        current_gaps = {(g.category, g.affected_component) for g in (ldo.gaps or [])}
        if not current_gaps:
            return False

        # Check last (threshold-1) history entries
        recent = history[-(threshold - 1):]
        for gap_key in current_gaps:
            found_in_all = True
            for h in recent:
                h_gaps = {(g.category, g.affected_component) for g in (h.gaps or [])}
                if gap_key not in h_gaps:
                    found_in_all = False
                    break
            if found_in_all:
                return True

        return False

    @staticmethod
    def _declining_streak(history: list[LoopDataObject]) -> int:
        """Count consecutive declining iterations from the end of history."""
        streak = 0
        for h in reversed(history):
            if h.regression_data.trend == "declining":
                streak += 1
            else:
                break
        return streak

    @staticmethod
    def _count_mode_iterations(history: list[LoopDataObject], mode: str) -> int:
        """Count how many iterations were in a specific mode."""
        return sum(1 for h in history if h.meta.loop_mode == mode)

    @staticmethod
    def _count_iterations_in_mode(history: list[LoopDataObject], mode: str) -> int:
        """Count consecutive iterations in *mode* from the end of history."""
        count = 0
        for h in reversed(history):
            if h.meta.loop_mode == mode:
                count += 1
            else:
                break
        return count

    @staticmethod
    def _count_recurring_gaps(history: list[LoopDataObject]) -> list[str]:
        """Find gaps that appear in 3+ consecutive iterations (from end).

        Compares gaps by (category, affected_component).
        Returns list of recurring gap descriptions.
        """
        if len(history) < 3:
            return []

        # Build gap key sets for each history entry (last 3+)
        recent = history[-3:]
        gap_sets = []
        for h in recent:
            keys = {
                (g.category, g.affected_component): g.description
                for g in (h.gaps or [])
            }
            gap_sets.append(keys)

        # Find intersection of keys across all recent entries
        common_keys = set(gap_sets[0].keys())
        for gs in gap_sets[1:]:
            common_keys &= set(gs.keys())

        # Return descriptions for recurring gaps
        return [gap_sets[0][k] for k in common_keys]
