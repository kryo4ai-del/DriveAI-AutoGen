"""Evaluation Agent — Calculates all Quality Scores for the LDO.

Combines Hard Scores (deterministic, high confidence) and Soft Scores
(heuristic, lower confidence) into a single quality assessment.
The aggregate score uses project-type-specific weights and veto logic.

This agent is called by the Loop Orchestrator — it never runs standalone.
"""

from __future__ import annotations

from dataclasses import asdict

from factory.evolution_loop.config.config_loader import EvolutionConfig
from factory.evolution_loop.ldo.schema import (
    LoopDataObject,
    ScoreEntry,
)
from factory.evolution_loop.scoring.aggregator import ScoreAggregator
from factory.evolution_loop.scoring.hard_scores import HardScoreCalculator
from factory.evolution_loop.scoring.soft_scores import SoftScoreCalculator

_PREFIX = "[EVO-EVAL]"


class EvaluationAgent:
    """Calculates all Quality Scores for the LDO."""

    AGENT_ID = "evo_evaluation"

    def __init__(self) -> None:
        self._hard = HardScoreCalculator()
        self._soft = SoftScoreCalculator()
        self._agg = ScoreAggregator()

    def evaluate(self, ldo: LoopDataObject, config: EvolutionConfig) -> LoopDataObject:
        """Calculate all scores and write them into the LDO.

        1. Convert LDO fields to dicts for the calculators.
        2. Compute Hard Scores (bug, roadbook, structural).
        3. Compute Soft Scores (performance, ux).
        4. Collect plugin scores from simulation results.
        5. Aggregate with project-type weights and veto logic.
        6. Write everything back into ``ldo.scores``.
        """
        # 1. Convert to dicts
        qa_dict = asdict(ldo.qa_results)
        sim_dict = asdict(ldo.simulation_results)
        roadbook_dict = asdict(ldo.roadbook_targets)
        build_dict = asdict(ldo.build_artifacts)

        # 2. Hard Scores
        bug = self._hard.calculate_bug_score(qa_dict, sim_dict)
        roadbook = self._hard.calculate_roadbook_match(roadbook_dict, sim_dict)
        structural = self._hard.calculate_structural_health(sim_dict)

        ldo.scores.bug_score = bug
        ldo.scores.roadbook_match_score = roadbook
        ldo.scores.structural_health_score = structural

        # 3. Soft Scores
        perf = self._soft.calculate_performance_score(build_dict, sim_dict)
        ux = self._soft.calculate_ux_score(roadbook_dict, sim_dict, build_dict)

        ldo.scores.performance_score = perf
        ldo.scores.ux_score = ux

        # 3b. Maintainability Score → stored in plugin_scores
        maint = self._soft.calculate_maintainability_score(build_dict, sim_dict)
        ldo.scores.plugin_scores["maintainability"] = maint

        # 4. Plugin Scores
        plugin_results = ldo.simulation_results.plugin_results
        if plugin_results:
            for key, val in plugin_results.items():
                if isinstance(val, dict) and "value" in val:
                    ldo.scores.plugin_scores[key] = ScoreEntry(
                        value=float(val.get("value", 0)),
                        confidence=float(val.get("confidence", 30)),
                    )

        # 5. Aggregate
        weights = config.get_score_weights(ldo.meta.project_type)
        targets = config.get_quality_targets()

        scores_for_agg = {
            "bug_score": {"value": bug.value, "confidence": bug.confidence},
            "roadbook_match": {"value": roadbook.value, "confidence": roadbook.confidence},
            "structural_health": {"value": structural.value, "confidence": structural.confidence},
            "performance_score": {"value": perf.value, "confidence": perf.confidence},
            "ux_score": {"value": ux.value, "confidence": ux.confidence},
        }

        agg_result = self._agg.aggregate(scores_for_agg, weights, targets)
        ldo.scores.quality_score_aggregate = agg_result["quality_score_aggregate"]

        # 6. Log
        veto = f" VETO: {agg_result['veto_reason']}" if agg_result["veto_active"] else ""
        print(
            f"{_PREFIX} Scores: Bug={bug.value:.0f} Roadbook={roadbook.value:.0f} "
            f"Structural={structural.value:.0f} Performance={perf.value:.0f} "
            f"UX={ux.value:.0f} Maint={maint.value:.0f} "
            f"-> Aggregate={agg_result['quality_score_aggregate']:.1f}"
            f"{veto}"
        )

        return ldo
