"""Score Aggregator — Weighted quality score with veto logic.

Combines individual scores into a single quality_score_aggregate,
applying project-type-specific weights and hard-score veto rules.

Veto Rules:
  - Bug Score below threshold → aggregate capped at 50
  - Roadbook Match or Structural Health below threshold → aggregate capped at 60

All logic is deterministic — no LLM calls.
"""

from __future__ import annotations


# Mapping from quality_targets keys to score dict keys
_TARGET_TO_SCORE = {
    "bug_score_min": "bug_score",
    "roadbook_match_min": "roadbook_match",
    "structural_health_min": "structural_health",
    "performance_score_min": "performance_score",
    "ux_score_min": "ux_score",
}


def _get_value(entry) -> float:
    """Extract value from ScoreEntry, dict, or float."""
    if isinstance(entry, dict):
        return entry.get("value", 0.0)
    if hasattr(entry, "value"):
        return entry.value
    return float(entry) if entry else 0.0


def _get_confidence(entry) -> float:
    """Extract confidence from ScoreEntry or dict."""
    if isinstance(entry, dict):
        return entry.get("confidence", 0.0)
    if hasattr(entry, "confidence"):
        return entry.confidence
    return 0.0


class ScoreAggregator:
    """Calculates weighted Quality Score with veto logic."""

    def aggregate(
        self,
        scores: dict,
        weights: dict,
        quality_targets: dict,
    ) -> dict:
        """Calculate weighted quality score with veto checks.

        Args:
            scores: Score name → ScoreEntry or ``{"value": float, "confidence": float}``.
            weights: Score name → weight (0.0-1.0), should sum to ~1.0.
            quality_targets: ``{"bug_score_min": 90, "roadbook_match_min": 95, ...}``.

        Returns:
            ``{"quality_score_aggregate", "veto_active", "veto_reason", "weighted_scores"}``.
        """
        # 1. Weighted average
        weighted_scores: dict[str, float] = {}
        total = 0.0
        total_weight = 0.0

        for score_name, weight in weights.items():
            if weight <= 0:
                continue

            # Try both exact name and common suffixed variants
            entry = scores.get(score_name)
            if entry is None:
                # Try adding _score suffix or removing it
                for alt in (f"{score_name}_score", score_name.replace("_score", "")):
                    entry = scores.get(alt)
                    if entry is not None:
                        break

            val = _get_value(entry) if entry is not None else 0.0
            contribution = val * weight
            weighted_scores[score_name] = round(contribution, 2)
            total += contribution
            total_weight += weight

        # Normalize if weights don't sum to 1.0
        if total_weight > 0 and abs(total_weight - 1.0) > 0.01:
            total = total / total_weight

        aggregate = round(max(0.0, min(100.0, total)), 1)

        # 2. Veto checks
        veto_active = False
        veto_reason = ""

        # Bug score veto: if below bug_score_min → cap at 50
        bug_min = quality_targets.get("bug_score_min", 0)
        bug_val = _get_value(
            scores.get("bug_score") or scores.get("bug") or {}
        )
        if bug_min > 0 and bug_val < bug_min:
            veto_active = True
            veto_reason = f"bug_score {bug_val:.0f} < min {bug_min}"
            aggregate = min(aggregate, 50.0)

        # Roadbook / Structural veto: cap at 60
        for target_key, score_key in [
            ("roadbook_match_min", "roadbook_match"),
            ("structural_health_min", "structural_health"),
        ]:
            threshold = quality_targets.get(target_key, 0)
            val = _get_value(
                scores.get(score_key)
                or scores.get(f"{score_key}_score")
                or {}
            )
            if threshold > 0 and val < threshold:
                if not veto_active:
                    veto_active = True
                    veto_reason = f"{score_key} {val:.0f} < min {threshold}"
                else:
                    veto_reason += f"; {score_key} {val:.0f} < min {threshold}"
                aggregate = min(aggregate, 60.0 if not bug_min or bug_val >= bug_min else 50.0)

        return {
            "quality_score_aggregate": aggregate,
            "veto_active": veto_active,
            "veto_reason": veto_reason,
            "weighted_scores": weighted_scores,
        }

    def check_targets_met(
        self,
        scores: dict,
        quality_targets: dict,
    ) -> dict:
        """Check whether all quality targets are met.

        Compares each score value against its corresponding ``*_min`` target.

        Returns:
            ``{"all_met", "met": [...], "not_met": [...], "details": {...}}``.
        """
        met: list[str] = []
        not_met: list[str] = []
        details: dict[str, dict] = {}

        for target_key, score_key in _TARGET_TO_SCORE.items():
            threshold = quality_targets.get(target_key)
            if threshold is None:
                continue

            # Find the score value
            entry = scores.get(score_key) or scores.get(f"{score_key}_score")
            val = _get_value(entry) if entry is not None else 0.0

            is_met = val >= threshold
            if is_met:
                met.append(score_key)
            else:
                not_met.append(score_key)

            details[score_key] = {
                "value": round(val, 1),
                "target": threshold,
                "met": is_met,
            }

        # Also check aggregate if present
        agg_min = quality_targets.get("quality_score_aggregate_min")
        if agg_min is not None:
            agg_val = _get_value(scores.get("quality_score_aggregate", 0))
            is_met = agg_val >= agg_min
            if is_met:
                met.append("quality_score_aggregate")
            else:
                not_met.append("quality_score_aggregate")
            details["quality_score_aggregate"] = {
                "value": round(agg_val, 1),
                "target": agg_min,
                "met": is_met,
            }

        return {
            "all_met": len(not_met) == 0,
            "met": met,
            "not_met": not_met,
            "details": details,
        }
