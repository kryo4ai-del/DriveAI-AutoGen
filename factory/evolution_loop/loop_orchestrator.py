"""Loop Orchestrator — The conductor of the Evolution Loop.

Calls agents sequentially, steers the cycle, checks stop conditions,
and tracks costs.  This is the ONLY component allowed to call other
Loop agents — no agent may invoke another agent directly.

All logic is deterministic (no LLM).
"""

from __future__ import annotations

import logging
from datetime import datetime, timezone

from factory.evolution_loop.config.config_loader import EvolutionConfig
from factory.evolution_loop.decision_agent import DecisionAgent
from factory.evolution_loop.evaluation_agent import EvaluationAgent
from factory.evolution_loop.gap_detector import GapDetector
from factory.evolution_loop.ldo.schema import LoopDataObject
from factory.evolution_loop.regression_tracker import RegressionTracker
from factory.evolution_loop.simulation_agent import SimulationAgent
from factory.evolution_loop.ldo.storage import LDOStorage
from factory.evolution_loop.ldo.validator import LDOValidator
from factory.evolution_loop.scoring.aggregator import ScoreAggregator
from factory.evolution_loop.tracking.cost_tracker import CostTracker
from factory.evolution_loop.tracking.git_tagger import GitTagger

logger = logging.getLogger(__name__)

_PREFIX = "[EVO-LOOP]"
_MAX_SAFETY_ITERATIONS = 100


class LoopOrchestrator:
    """Conductor of the Evolution Loop.  Steers the iterative quality cycle."""

    AGENT_ID = "evo_loop_orchestrator"

    def __init__(
        self,
        project_id: str,
        project_type: str,
        production_line: str,
        config: EvolutionConfig | None = None,
    ) -> None:
        self.project_id = project_id
        self.project_type = project_type
        self.production_line = production_line

        self._config = config or EvolutionConfig()
        self._config_limits = self._config.get_loop_limits()
        self._config_targets = self._config.get_quality_targets()
        self._config_weights = self._config.get_score_weights(project_type)

        self._storage = LDOStorage(project_id)
        self._validator = LDOValidator()
        self._evaluation_agent = EvaluationAgent()
        self._gap_detector = GapDetector()
        self._decision_agent = DecisionAgent()
        self._regression_tracker = RegressionTracker(self._config)
        self._simulation_agent = SimulationAgent()
        self._aggregator = ScoreAggregator()
        self._cost_tracker = CostTracker()
        self._git_tagger = GitTagger(project_id)

        self.iteration: int = 0
        self.loop_mode: str = "sprint"

        # Cache last scores for status report
        self._last_scores: dict[str, float] = {}
        self._last_aggregate: float = 0.0
        self._last_recommendation: str = ""

    # ------------------------------------------------------------------
    # Main loop
    # ------------------------------------------------------------------

    def run_loop(self, initial_ldo: LoopDataObject) -> LoopDataObject:
        """Run the iterative Evolution Loop.

        Returns the final LDO after the loop stops.
        """
        # Validate initial LDO
        vr = self._validator.validate(initial_ldo)
        if not vr.is_valid:
            print(f"{_PREFIX} WARNING: Initial LDO validation errors: {vr.errors}")

        ldo = initial_ldo

        print(f"{_PREFIX} Starting Evolution Loop for '{self.project_id}' "
              f"(type={self.project_type}, line={self.production_line})")

        max_total = self._config_limits.get("total_max_iterations", 20)

        while self.iteration < _MAX_SAFETY_ITERATIONS:
            self.iteration += 1

            # Update LDO meta
            ldo.meta.iteration = self.iteration
            ldo.meta.timestamp = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
            ldo.meta.loop_mode = self.loop_mode
            ldo.meta.git_tag = f"evolution/{self.project_id}/iteration-{self.iteration}"
            ldo.meta.accumulated_cost = self._cost_tracker.get_total()

            print(f"\n{_PREFIX} === Iteration {self.iteration} (mode: {self.loop_mode}) ===")

            # Run single iteration
            ldo = self.run_single_iteration(ldo)

            # Save LDO
            try:
                path = self._storage.save(ldo)
                print(f"{_PREFIX} LDO saved: {path}")
            except Exception as e:
                print(f"{_PREFIX} WARNING: Failed to save LDO: {e}")

            # Git tag this iteration
            tag_msg = f"Iteration {self.iteration} (mode: {self.loop_mode}, aggregate: {ldo.scores.quality_score_aggregate:.1f})"
            self._git_tagger.tag_iteration(self.iteration, tag_msg)

            # Check stop conditions
            result = self.check_stop_conditions(ldo)
            print(f"{_PREFIX} Stop check: {result}")

            if result == "stop":
                print(f"{_PREFIX} Loop stopped after {self.iteration} iterations")
                self._last_recommendation = "stop"
                return ldo

            if result == "ceo_review":
                print(f"{_PREFIX} CEO Review triggered after {self.iteration} iterations")
                ldo.regression_data.recommendation = "ceo_review"
                self._last_recommendation = "ceo_review"
                return ldo

            # result == "continue" → next iteration

        # Safety fallback
        print(f"{_PREFIX} SAFETY: Force stop after {_MAX_SAFETY_ITERATIONS} iterations")
        return ldo

    # ------------------------------------------------------------------
    # Single iteration — sequential agent calls
    # ------------------------------------------------------------------

    def run_single_iteration(self, ldo: LoopDataObject) -> LoopDataObject:
        """Execute one full iteration: 5 sequential agent steps."""

        steps = [
            ("Simulation", self.simulation_step),
            ("Evaluation", self.evaluation_step),
            ("Gap Detection", self.gap_detection_step),
            ("Regression", self.regression_step),
            ("Decision", self.decision_step),
        ]

        for name, step_fn in steps:
            try:
                ldo = step_fn(ldo)
            except Exception as e:
                print(f"{_PREFIX} ERROR in {name}: {e}")
                logger.exception("Error in %s step", name)

        return ldo

    # ------------------------------------------------------------------
    # Agent steps
    # ------------------------------------------------------------------

    def simulation_step(self, ldo: LoopDataObject) -> LoopDataObject:
        """Delegate to SimulationAgent for static analysis."""
        print(f"{_PREFIX} Simulation: running...")
        ldo = self._simulation_agent.simulate(ldo)
        return ldo

    def evaluation_step(self, ldo: LoopDataObject) -> LoopDataObject:
        """Delegate to EvaluationAgent for all score calculations."""
        ldo = self._evaluation_agent.evaluate(ldo, self._config)

        # Cache for status report
        self._last_scores = {
            "bug": ldo.scores.bug_score.value,
            "roadbook": ldo.scores.roadbook_match_score.value,
            "structural": ldo.scores.structural_health_score.value,
        }
        self._last_aggregate = ldo.scores.quality_score_aggregate

        return ldo

    def gap_detection_step(self, ldo: LoopDataObject) -> LoopDataObject:
        """Delegate to GapDetector for gap identification."""
        ldo = self._gap_detector.detect_gaps(ldo, self._config)
        return ldo

    def regression_step(self, ldo: LoopDataObject) -> LoopDataObject:
        """Delegate to RegressionTracker for trend analysis and mode detection."""
        history = self._storage.get_history()
        ldo = self._regression_tracker.analyze(ldo, history)
        new_mode = self._regression_tracker.detect_loop_mode(ldo, history)
        if new_mode != self.loop_mode:
            print(f"{_PREFIX} Mode switch: {self.loop_mode} -> {new_mode}")
            self.loop_mode = new_mode
            ldo.meta.loop_mode = new_mode
        return ldo

    def decision_step(self, ldo: LoopDataObject) -> LoopDataObject:
        """Delegate to DecisionAgent for task generation."""
        if ldo.meta.loop_mode == "deep":
            print(f"{_PREFIX} Deep Mode: Decision Agent will prioritize refactoring")
        ldo = self._decision_agent.generate_tasks(ldo, self._config)
        return ldo

    # ------------------------------------------------------------------
    # Stop conditions
    # ------------------------------------------------------------------

    def check_stop_conditions(self, ldo: LoopDataObject) -> str:
        """Check whether the loop should continue.

        Returns ``"continue"``, ``"stop"``, or ``"ceo_review"``.
        First matching condition wins.
        """
        max_total = self._config_limits.get("total_max_iterations", 20)
        sprint_max = self._config_limits.get("sprint_max_iterations", 10)
        deep_max = self._config_limits.get("deep_max_iterations", 5)
        budget = self._config_limits.get("budget_threshold_usd", 5.0)

        # 1. Pivot mode → immediate CEO review
        if ldo.meta.loop_mode == "pivot":
            return "ceo_review"

        # 2. Total max iterations reached
        if self.iteration >= max_total:
            return "stop"

        # 3. Budget exceeded
        if self._cost_tracker.get_total() >= budget:
            return "ceo_review"

        # 4. Mode-specific max iterations
        mode_iters = self._count_mode_iterations(ldo.meta.loop_mode)
        if ldo.meta.loop_mode == "sprint" and mode_iters > sprint_max:
            return "ceo_review"
        if ldo.meta.loop_mode == "deep" and mode_iters > deep_max:
            return "ceo_review"

        # 5. Regression recommends stop
        if ldo.regression_data.recommendation == "stop":
            return "stop"

        # 6. Regression recommends CEO review
        if ldo.regression_data.recommendation == "ceo_review":
            return "ceo_review"

        # 7. All quality targets met → CEO must review before store
        check = self._aggregator.check_targets_met(
            {
                "bug_score": {"value": ldo.scores.bug_score.value},
                "roadbook_match": {"value": ldo.scores.roadbook_match_score.value},
                "structural_health": {"value": ldo.scores.structural_health_score.value},
                "performance_score": {"value": ldo.scores.performance_score.value},
                "ux_score": {"value": ldo.scores.ux_score.value},
                "quality_score_aggregate": ldo.scores.quality_score_aggregate,
            },
            self._config_targets,
        )
        if check["all_met"]:
            return "ceo_review"

        # 8. Default
        return "continue"

    def _count_mode_iterations(self, mode: str) -> int:
        """Count how many iterations have run in the given mode (from storage)."""
        history = self._storage.get_history()
        return sum(1 for h in history if h.meta.loop_mode == mode)

    # ------------------------------------------------------------------
    # Status report
    # ------------------------------------------------------------------

    @property
    def accumulated_cost(self) -> float:
        """Return accumulated cost from the CostTracker."""
        return self._cost_tracker.get_total()

    def get_status_report(self) -> str:
        """Return a human-readable loop status string."""
        max_total = self._config_limits.get("total_max_iterations", 20)
        budget = self._config_limits.get("budget_threshold_usd", 5.0)
        total_cost = self._cost_tracker.get_total()

        bug = self._last_scores.get("bug", 0)
        roadbook = self._last_scores.get("roadbook", 0)
        structural = self._last_scores.get("structural", 0)

        lines = [
            "",
            "=== Evolution Loop Status ===",
            f"Project: {self.project_id} ({self.project_type}, {self.production_line})",
            f"Iteration: {self.iteration} / {max_total}",
            f"Mode: {self.loop_mode}",
            f"Cost: ${total_cost:.4f} / ${budget:.2f}",
            f"Last Scores: Bug={bug:.0f} Roadbook={roadbook:.0f} "
            f"Structural={structural:.0f} Aggregate={self._last_aggregate:.1f}",
            f"Recommendation: {self._last_recommendation or 'n/a'}",
            "=============================",
        ]
        return "\n".join(lines)
