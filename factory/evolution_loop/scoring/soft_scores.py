"""Soft Score Calculator — Heuristic-based quality scores.

Soft Scores use static heuristics (no LLM) and have lower confidence
(35-55%) compared to Hard Scores (85-95%).  They improve as more data
becomes available through simulation and plugin results.

Two soft scores:
  1. Performance Score — code size, anti-patterns, stubs, error handling
  2. UX Score — screen coverage, flow completeness, nav depth, consistency
"""

from __future__ import annotations

import re

from factory.evolution_loop.ldo.schema import ScoreEntry


def _clamp(value: float, lo: float = 0.0, hi: float = 100.0) -> float:
    return max(lo, min(hi, value))


class SoftScoreCalculator:
    """Calculates heuristic-based quality scores (no LLM)."""

    # ------------------------------------------------------------------
    # Performance Score
    # ------------------------------------------------------------------

    def calculate_performance_score(
        self,
        build_artifacts: dict | None,
        simulation_results: dict | None = None,
    ) -> ScoreEntry:
        """Performance Score (0-100) based on static heuristics.

        4 criteria, each worth 25 points:
          1. Code size ratio (file count)
          2. Anti-pattern indicators (deep nesting, hardcoded values)
          3. Stub/TODO ratio
          4. Error handling coverage

        Confidence: 45-55 with data, 15 without.
        """
        ba = build_artifacts or {}
        sim = simulation_results or {}
        sa = sim.get("static_analysis", {}) or {}

        paths = ba.get("paths", []) or []
        has_sa = bool(sa)

        if not paths and not has_sa:
            return ScoreEntry(value=50.0, confidence=15.0)

        # 1. Code size ratio (25 pts)
        n_files = len(paths)
        if n_files == 0 and has_sa:
            n_files = sa.get("total_files", 0) or 0

        if n_files <= 0:
            size_pts = 20.0  # neutral if unknown
        elif n_files < 50:
            size_pts = 25.0
        elif n_files <= 200:
            size_pts = 20.0
        elif n_files <= 500:
            size_pts = 15.0
        else:
            size_pts = 10.0

        # 2. Anti-pattern indicators (25 pts)
        deep_nesting = sa.get("deep_nesting", 0) or 0
        hardcoded = sa.get("hardcoded_values", 0) or 0
        pattern_pts = _clamp(25.0 - deep_nesting * 3.0 - hardcoded * 1.0, 0.0, 25.0)
        if not has_sa:
            pattern_pts = 12.5  # neutral

        # 3. Stub/TODO ratio (25 pts)
        stubs = sa.get("stubs", sa.get("stubs_count", 0)) or 0
        todos = sa.get("todos", sa.get("todos_count", 0)) or 0
        total_files = sa.get("total_files", max(n_files, 1)) or 1
        stub_ratio = (stubs + todos) / total_files if total_files > 0 else 0.0

        if not has_sa:
            stub_pts = 12.5  # neutral
        elif stub_ratio == 0:
            stub_pts = 25.0
        elif stub_ratio < 0.05:
            stub_pts = 20.0
        elif stub_ratio < 0.20:
            stub_pts = 10.0
        else:
            stub_pts = 0.0

        # 4. Error handling (25 pts)
        err_ratio = sa.get("error_handling_ratio", 0.0) or 0.0
        if not has_sa:
            err_pts = 12.5  # neutral
        elif err_ratio > 0.7:
            err_pts = 25.0
        elif err_ratio >= 0.3:
            err_pts = 15.0
        else:
            err_pts = 5.0

        score = size_pts + pattern_pts + stub_pts + err_pts
        confidence = 50.0 if has_sa else (35.0 if paths else 15.0)

        return ScoreEntry(value=_clamp(round(score, 1)), confidence=confidence)

    # ------------------------------------------------------------------
    # UX Score
    # ------------------------------------------------------------------

    def calculate_ux_score(
        self,
        roadbook_targets: dict | None,
        simulation_results: dict | None = None,
    ) -> ScoreEntry:
        """UX Score (0-100) based on static heuristics.

        4 criteria, each worth 25 points:
          1. Screen coverage (planned vs. covered)
          2. Flow completeness (synthetic flows)
          3. Navigation depth estimate (# of screens)
          4. Naming consistency of screens

        Confidence: 35-45 with data, 15 without.
        """
        targets = roadbook_targets or {}
        sim = simulation_results or {}
        coverage = sim.get("roadbook_coverage", {}) or {}
        flows = sim.get("synthetic_flows", []) or []

        screens = targets.get("screens", []) or []
        user_flows = targets.get("user_flows", []) or []
        total_screens = len(screens)
        total_flows = len(user_flows)

        has_sim = bool(coverage or flows)

        if not screens and not user_flows and not has_sim:
            return ScoreEntry(value=50.0, confidence=15.0)

        # 1. Screen coverage (25 pts)
        if total_screens > 0:
            covered = len(coverage.get("screens_covered", []) or [])
            ratio = covered / total_screens
            screen_pts = ratio * 25.0
        else:
            screen_pts = 12.5  # neutral

        # 2. Flow completeness (25 pts)
        if total_flows > 0:
            # Count complete flows from synthetic_flows
            flows_covered = coverage.get("flows_covered", None)
            if flows_covered is not None:
                complete = len(flows_covered)
            else:
                complete = sum(
                    1 for f in flows
                    if isinstance(f, dict) and f.get("is_complete", False)
                )
            flow_pts = (complete / total_flows) * 25.0
        else:
            flow_pts = 12.5  # neutral

        # 3. Navigation depth estimate (25 pts)
        if total_screens > 0:
            if 3 <= total_screens <= 8:
                nav_pts = 25.0
            elif total_screens <= 2:
                nav_pts = 15.0
            elif total_screens <= 15:
                nav_pts = 20.0
            else:
                nav_pts = 10.0
        else:
            nav_pts = 12.5  # neutral

        # 4. Naming consistency (25 pts)
        if total_screens >= 2:
            consistency_pts = self._check_naming_consistency(screens)
        else:
            consistency_pts = 12.5  # neutral

        score = screen_pts + flow_pts + nav_pts + consistency_pts
        confidence = 40.0 if has_sim else (30.0 if screens else 15.0)

        return ScoreEntry(value=_clamp(round(score, 1)), confidence=confidence)

    # ------------------------------------------------------------------
    # Helpers
    # ------------------------------------------------------------------

    @staticmethod
    def _check_naming_consistency(screens: list) -> float:
        """Check if screen names follow a consistent pattern (25 pts max)."""
        if not screens:
            return 12.5

        suffixes = ("View", "Screen", "Page", "Scene", "Panel", "Controller")
        suffix_counts: dict[str, int] = {}
        no_suffix = 0

        for name in screens:
            if not isinstance(name, str):
                no_suffix += 1
                continue
            matched = False
            for sfx in suffixes:
                if name.endswith(sfx):
                    suffix_counts[sfx] = suffix_counts.get(sfx, 0) + 1
                    matched = True
                    break
            if not matched:
                no_suffix += 1

        total = len(screens)
        if not suffix_counts:
            return 12.5  # no recognizable pattern

        # Find dominant suffix
        dominant = max(suffix_counts.values())
        ratio = dominant / total

        if ratio >= 0.8:
            return 25.0  # very consistent
        elif ratio >= 0.5:
            return 20.0  # mostly consistent
        else:
            return 15.0  # mixed
