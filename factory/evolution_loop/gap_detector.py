"""Gap Detector — Identifies gaps between Soll (Roadbook) and Ist (Scores/Build).

Compares quality scores against targets, checks for compile errors,
test failures, and missing features.  Also detects regressions by
comparing with the previous iteration.

All logic is deterministic (no LLM).
"""

from __future__ import annotations

from factory.evolution_loop.config.config_loader import EvolutionConfig
from factory.evolution_loop.ldo.schema import Gap, LoopDataObject
from factory.evolution_loop.ldo.storage import LDOStorage

_PREFIX = "[EVO-GAP]"

_SEVERITY_ORDER = {"critical": 0, "high": 1, "medium": 2, "low": 3}

# Maps config target key → (score attribute on ldo.scores, gap category, severity)
_SCORE_GAP_MAP = [
    ("bug_score_min", "bug_score", "bug", "critical"),
    ("roadbook_match_min", "roadbook_match_score", "feature", "high"),
    ("structural_health_min", "structural_health_score", "structural", "high"),
    ("performance_score_min", "performance_score", "performance", "medium"),
    ("ux_score_min", "ux_score", "ux", "medium"),
]


class GapDetector:
    """Identifies gaps between Soll (Roadbook) and Ist (Scores/Build)."""

    AGENT_ID = "evo_gap_detector"

    def __init__(self) -> None:
        pass

    # ------------------------------------------------------------------
    # Main entry point
    # ------------------------------------------------------------------

    def detect_gaps(
        self, ldo: LoopDataObject, config: EvolutionConfig,
    ) -> LoopDataObject:
        """Find all gaps and write them into the LDO.

        Steps:
        1. Score-based gaps (scores below quality targets)
        2. Compile error gaps
        3. Test failure gaps
        4. Feature coverage gaps
        5. Regression check (compare with previous iteration)
        6. Assign IDs, sort, write into ldo.gaps
        """
        iteration = ldo.meta.iteration
        targets = config.get_quality_targets()
        gaps: list[Gap] = []

        # 1. Score-based gaps
        for target_key, score_attr, category, severity in _SCORE_GAP_MAP:
            target_val = targets.get(target_key)
            if target_val is None:
                continue
            score_entry = getattr(ldo.scores, score_attr, None)
            if score_entry is None:
                continue
            if score_entry.value < target_val:
                gaps.append(self._create_gap(
                    iteration=iteration,
                    gap_number=0,  # assigned later
                    category=category,
                    severity=severity,
                    description=(
                        f"{score_attr} ({score_entry.value:.0f}) "
                        f"below target ({target_val})"
                    ),
                    affected_component=score_attr,
                ))

        # 2. Compile error gaps
        for err in (ldo.qa_results.compile_errors or []):
            desc = str(err)[:200] if err else "Compile error"
            gaps.append(self._create_gap(
                iteration=iteration,
                gap_number=0,
                category="bug",
                severity="critical",
                description=f"Compile error: {desc}",
                affected_component="build",
            ))

        # 3. Test failure gaps
        failed = ldo.qa_results.tests_failed or 0
        if failed > 0:
            gaps.append(self._create_gap(
                iteration=iteration,
                gap_number=0,
                category="bug",
                severity="high",
                description=f"{failed} tests failed",
                affected_component="tests",
            ))

        # 4. Feature coverage gaps
        gaps.extend(self._detect_feature_gaps(ldo, iteration))

        # 5. Regression check
        gaps = self._try_regression_check(gaps, ldo)

        # 6. Assign IDs, sort, write
        gaps = self._sort_gaps(gaps)
        for i, gap in enumerate(gaps, start=1):
            gap.id = f"GAP-{iteration}-{i:03d}"
            if not gap.is_regression:
                gap.first_seen_iteration = iteration

        ldo.gaps = gaps

        # Log summary
        counts = {}
        for g in gaps:
            counts[g.severity] = counts.get(g.severity, 0) + 1
        parts = [f"{counts.get(s, 0)} {s}" for s in ("critical", "high", "medium", "low") if counts.get(s, 0) > 0]
        summary = ", ".join(parts) if parts else "none"
        print(f"{_PREFIX} Found {len(gaps)} gaps: {summary}")

        return ldo

    # ------------------------------------------------------------------
    # Helpers
    # ------------------------------------------------------------------

    @staticmethod
    def _create_gap(
        iteration: int,
        gap_number: int,
        category: str,
        severity: str,
        description: str,
        affected_component: str = "",
        is_regression: bool = False,
        first_seen: int = 0,
    ) -> Gap:
        """Factory method for Gap objects."""
        return Gap(
            id=f"GAP-{iteration}-{gap_number:03d}" if gap_number > 0 else "",
            category=category,
            severity=severity,
            description=description,
            affected_component=affected_component,
            is_regression=is_regression,
            first_seen_iteration=first_seen if is_regression else iteration,
        )

    def _detect_feature_gaps(
        self, ldo: LoopDataObject, iteration: int,
    ) -> list[Gap]:
        """Check roadbook features against simulation coverage."""
        gaps: list[Gap] = []
        features = ldo.roadbook_targets.features or []
        if not features:
            return gaps

        coverage = ldo.simulation_results.roadbook_coverage or {}
        covered = set(coverage.get("features_covered", []) or [])

        for feat in features:
            if feat not in covered:
                gaps.append(self._create_gap(
                    iteration=iteration,
                    gap_number=0,
                    category="feature",
                    severity="high",
                    description=f"Feature not implemented: {feat}",
                    affected_component=feat,
                ))

        return gaps

    def _try_regression_check(
        self, current_gaps: list[Gap], ldo: LoopDataObject,
    ) -> list[Gap]:
        """Try to load previous iteration and check regressions."""
        iteration = ldo.meta.iteration
        if iteration <= 1:
            return current_gaps

        try:
            storage = LDOStorage(ldo.meta.project_id)
            previous_ldo = storage.load(iteration - 1)
            return self._check_regressions(current_gaps, previous_ldo)
        except (FileNotFoundError, Exception):
            return current_gaps

    def _check_regressions(
        self, current_gaps: list[Gap], previous_ldo: LoopDataObject,
    ) -> list[Gap]:
        """Compare current gaps with previous iteration.

        Matching: same category + same affected_component.
        """
        prev_lookup: dict[tuple[str, str], Gap] = {}
        for pg in (previous_ldo.gaps or []):
            key = (pg.category, pg.affected_component)
            prev_lookup[key] = pg

        for gap in current_gaps:
            key = (gap.category, gap.affected_component)
            prev = prev_lookup.get(key)
            if prev is not None:
                gap.is_regression = True
                gap.first_seen_iteration = (
                    prev.first_seen_iteration
                    if prev.first_seen_iteration > 0
                    else previous_ldo.meta.iteration
                )

        return current_gaps

    @staticmethod
    def _sort_gaps(gaps: list[Gap]) -> list[Gap]:
        """Sort gaps by severity: critical > high > medium > low."""
        return sorted(gaps, key=lambda g: _SEVERITY_ORDER.get(g.severity, 99))
