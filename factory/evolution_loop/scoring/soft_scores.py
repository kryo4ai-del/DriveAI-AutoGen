"""Soft Score Calculator — Heuristic-based quality scores.

Soft Scores use static heuristics (no LLM) and have lower confidence
(40-70%) compared to Hard Scores (85-95%).  They improve as more data
becomes available through simulation and plugin results.

Three soft scores:
  1. Performance Score — code size, anti-patterns, async, memory, stubs
  2. UX Score — screen coverage, flow completeness, nav depth, error/loading states, naming
  3. Maintainability Score — duplication, file size distribution, naming, test coverage
"""

from __future__ import annotations

import os
import re
import statistics
from pathlib import Path

from factory.evolution_loop.ldo.schema import ScoreEntry


def _clamp(value: float, lo: float = 0.0, hi: float = 100.0) -> float:
    return max(lo, min(hi, value))


def _safe_read(path: str, max_bytes: int = 64_000) -> str:
    """Read file content safely. Returns empty string on failure."""
    try:
        with open(path, "r", encoding="utf-8", errors="replace") as f:
            return f.read(max_bytes)
    except Exception:
        return ""


def _count_loc(content: str) -> int:
    """Count non-empty lines."""
    return sum(1 for line in content.splitlines() if line.strip())


class SoftScoreCalculator:
    """Calculates heuristic-based quality scores (no LLM)."""

    # ------------------------------------------------------------------
    # Performance Score (Enhanced — 5 criteria, 20 pts each)
    # ------------------------------------------------------------------

    def calculate_performance_score(
        self,
        build_artifacts: dict | None,
        simulation_results: dict | None = None,
    ) -> ScoreEntry:
        """Enhanced Performance Score (0-100).

        5 criteria, each worth 20 points:
          1. Code Size Efficiency (avg LOC/file)
          2. Anti-Pattern Density (deep_nesting / total_files)
          3. Async/Concurrency Patterns
          4. Memory Pattern Indicators
          5. Stub/TODO Ratio Impact

        Confidence: 50-60 with data, 15 without.
        """
        ba = build_artifacts or {}
        sim = simulation_results or {}
        sa = sim.get("static_analysis", {}) or {}

        paths = ba.get("paths", []) or []
        has_sa = bool(sa)

        if not paths and not has_sa:
            return ScoreEntry(value=50.0, confidence=15.0)

        n_files = len(paths)
        if n_files == 0 and has_sa:
            n_files = sa.get("total_files", 0) or 0

        total_loc = sa.get("total_loc", 0) or 0

        # Read file contents for pattern detection (max 50 files)
        file_contents = {}
        for p in paths[:50]:
            if isinstance(p, str) and os.path.isfile(p):
                file_contents[p] = _safe_read(p)

        # 1. Code Size Efficiency (20 pts) — avg LOC per file
        if total_loc > 0 and n_files > 0:
            avg_loc = total_loc / n_files
        elif file_contents:
            locs = [_count_loc(c) for c in file_contents.values() if c]
            avg_loc = statistics.mean(locs) if locs else 0
        else:
            avg_loc = 0

        if avg_loc <= 0:
            size_pts = 15.0  # neutral
        elif avg_loc < 200:
            size_pts = 20.0
        elif avg_loc < 400:
            size_pts = 15.0
        elif avg_loc < 800:
            size_pts = 10.0
        else:
            size_pts = 5.0

        # 2. Anti-Pattern Density (20 pts) — deep_nesting / total_files
        deep_nesting = sa.get("deep_nesting", 0) or 0
        effective_files = sa.get("total_files", max(n_files, 1)) or 1

        if not has_sa:
            pattern_pts = 10.0  # neutral
        else:
            ratio = deep_nesting / effective_files if effective_files > 0 else 0
            if ratio < 0.1:
                pattern_pts = 20.0
            elif ratio < 0.3:
                pattern_pts = 15.0
            elif ratio < 0.5:
                pattern_pts = 10.0
            else:
                pattern_pts = 5.0

        # 3. Async/Concurrency Patterns (20 pts)
        async_patterns = re.compile(
            r"\b(async|await|DispatchQueue|Task\s*\{|coroutine|Promise|"
            r"CompletableFuture|Observable|asyncio|threading|concurrent)\b",
            re.IGNORECASE,
        )
        error_in_async = re.compile(
            r"\b(try|catch|except|throws|do\s*\{|\.catch|onError|"
            r"Result<|completionHandler|defer)\b",
            re.IGNORECASE,
        )

        has_async = False
        has_async_error = False
        for content in file_contents.values():
            if not content:
                continue
            if async_patterns.search(content):
                has_async = True
                if error_in_async.search(content):
                    has_async_error = True
                    break

        if has_async and has_async_error:
            async_pts = 20.0
        elif has_async:
            async_pts = 12.0
        else:
            async_pts = 15.0  # OK for simple apps

        # 4. Memory Pattern Indicators (20 pts)
        memory_patterns = re.compile(
            r"\b(weak\s+self|\[weak|unowned|@autoreleasepool|"
            r"dispose|cleanup|deinit|onDestroy|useEffect\s*\(\s*\(\s*\)\s*=>|"
            r"componentWillUnmount|onCleared|WeakReference)\b",
            re.IGNORECASE,
        )

        has_memory = any(
            memory_patterns.search(c) for c in file_contents.values() if c
        )

        if has_memory:
            memory_pts = 20.0
        elif n_files > 20:
            memory_pts = 8.0  # large project without memory management
        else:
            memory_pts = 15.0  # OK for small projects

        # 5. Stub/TODO Ratio Impact (20 pts)
        stubs = sa.get("stubs", sa.get("stubs_count", 0)) or 0
        todos = sa.get("todos", sa.get("todos_count", 0)) or 0
        total_loc_eff = total_loc if total_loc > 0 else max(n_files * 50, 1)

        if not has_sa and not file_contents:
            stub_pts = 10.0  # neutral
        else:
            stub_count = stubs + todos
            if stub_count == 0:
                stub_pts = 20.0
            else:
                stub_pct = stub_count / total_loc_eff * 100
                if stub_pct < 3:
                    stub_pts = 16.0
                elif stub_pct < 10:
                    stub_pts = 10.0
                else:
                    stub_pts = 4.0

        score = size_pts + pattern_pts + async_pts + memory_pts + stub_pts

        # Confidence: higher when we have both static_analysis AND file content
        if has_sa and file_contents:
            confidence = 60.0
        elif has_sa:
            confidence = 55.0
        elif file_contents:
            confidence = 50.0
        else:
            confidence = 15.0

        return ScoreEntry(value=_clamp(round(score, 1)), confidence=confidence)

    # ------------------------------------------------------------------
    # UX Score (Enhanced — 5 criteria, 20 pts each)
    # ------------------------------------------------------------------

    def calculate_ux_score(
        self,
        roadbook_targets: dict | None,
        simulation_results: dict | None = None,
        build_artifacts: dict | None = None,
    ) -> ScoreEntry:
        """Enhanced UX Score (0-100).

        5 criteria, each worth 20 points:
          1. Screen Coverage (planned vs. covered)
          2. Flow Completeness (synthetic flows)
          3. Navigation Depth (optimal 3-7 screens)
          4. Error/Loading State Coverage [NEW]
          5. Naming Consistency [ENHANCED]

        Confidence: 40-50 with data, 15 without.
        """
        targets = roadbook_targets or {}
        sim = simulation_results or {}
        ba = build_artifacts or {}
        coverage = sim.get("roadbook_coverage", {}) or {}
        flows = sim.get("synthetic_flows", []) or []

        screens = targets.get("screens", []) or []
        user_flows = targets.get("user_flows", []) or []
        total_screens = len(screens)
        total_flows = len(user_flows)
        paths = ba.get("paths", []) or []

        has_sim = bool(coverage or flows)

        if not screens and not user_flows and not has_sim:
            return ScoreEntry(value=50.0, confidence=15.0)

        # 1. Screen Coverage (20 pts)
        if total_screens > 0:
            covered = len(coverage.get("screens_covered", []) or [])
            ratio = covered / total_screens
            screen_pts = ratio * 20.0
        else:
            screen_pts = 10.0  # neutral

        # 2. Flow Completeness (20 pts)
        if total_flows > 0:
            flows_covered = coverage.get("flows_covered", None)
            if flows_covered is not None:
                complete = len(flows_covered)
            else:
                complete = sum(
                    1 for f in flows
                    if isinstance(f, dict) and f.get("is_complete", False)
                )
            flow_pts = (complete / total_flows) * 20.0
        else:
            flow_pts = 10.0  # neutral

        # 3. Navigation Depth (20 pts) — optimal 3-7
        if total_screens > 0:
            if 3 <= total_screens <= 7:
                nav_pts = 20.0
            elif total_screens <= 2:
                nav_pts = 12.0
            elif total_screens <= 12:
                nav_pts = 15.0
            elif total_screens <= 20:
                nav_pts = 10.0
            else:
                nav_pts = 5.0
        else:
            nav_pts = 10.0  # neutral

        # 4. Error/Loading State Coverage (20 pts) [NEW]
        error_state_re = re.compile(
            r"\b(ErrorView|error_state|\.alert|showError|ErrorMessage|"
            r"EmptyView|empty_state|NoDataView|placeholder|ErrorBoundary|"
            r"error_screen|ErrorScreen|FailureView)\b",
            re.IGNORECASE,
        )
        loading_state_re = re.compile(
            r"\b(LoadingView|ProgressView|spinner|isLoading|ActivityIndicator|"
            r"loading_state|Skeleton|shimmer|CircularProgressIndicator|"
            r"LoadingScreen|ProgressBar)\b",
            re.IGNORECASE,
        )

        has_error_states = False
        has_loading_states = False
        for p in paths[:50]:
            if isinstance(p, str) and os.path.isfile(p):
                content = _safe_read(p)
                if content:
                    if error_state_re.search(content):
                        has_error_states = True
                    if loading_state_re.search(content):
                        has_loading_states = True
                    if has_error_states and has_loading_states:
                        break

        if has_error_states and has_loading_states:
            state_pts = 20.0
        elif has_error_states:
            state_pts = 12.0
        elif has_loading_states:
            state_pts = 12.0
        elif not paths:
            state_pts = 10.0  # neutral — no files to check
        else:
            state_pts = 4.0

        # 5. Naming Consistency (20 pts) [ENHANCED]
        # Use both screen names AND filenames
        all_names = list(screens)
        for p in paths:
            if isinstance(p, str):
                fname = Path(p).stem
                if any(kw in fname.lower() for kw in ("view", "screen", "page", "activity", "fragment", "controller")):
                    all_names.append(fname)

        if len(all_names) >= 2:
            consistency_pts = self._check_naming_consistency(all_names, max_pts=20.0)
        elif len(all_names) == 1:
            consistency_pts = 10.0  # neutral
        else:
            consistency_pts = 10.0  # neutral

        score = screen_pts + flow_pts + nav_pts + state_pts + consistency_pts

        # Confidence
        if has_sim and paths:
            confidence = 50.0
        elif has_sim:
            confidence = 45.0
        elif screens:
            confidence = 35.0
        else:
            confidence = 15.0

        return ScoreEntry(value=_clamp(round(score, 1)), confidence=confidence)

    # ------------------------------------------------------------------
    # Maintainability Score (NEW — 4 criteria, 25 pts each)
    # ------------------------------------------------------------------

    def calculate_maintainability_score(
        self,
        build_artifacts: dict | None,
        simulation_results: dict | None = None,
    ) -> ScoreEntry:
        """Maintainability Score (0-100) — how maintainable is the code?

        4 criteria, each worth 25 points:
          1. Code Duplication Indicators
          2. File Size Distribution (stddev of LOC)
          3. Naming Consistency (PascalCase classes, camelCase functions)
          4. Test Coverage Indicator (test files / source files ratio)

        Confidence: 60-70 with file data, 15 without.
        """
        ba = build_artifacts or {}
        sim = simulation_results or {}
        sa = sim.get("static_analysis", {}) or {}

        paths = ba.get("paths", []) or []

        if not paths and not sa:
            return ScoreEntry(value=50.0, confidence=15.0)

        # Read files for analysis (max 50)
        file_data: list[tuple[str, str, int]] = []  # (filename, content, loc)
        for p in paths[:50]:
            if isinstance(p, str) and os.path.isfile(p):
                content = _safe_read(p)
                if content:
                    loc = _count_loc(content)
                    file_data.append((Path(p).name, content, loc))

        if not file_data and not sa:
            return ScoreEntry(value=50.0, confidence=15.0)

        # 1. Code Duplication Indicators (25 pts)
        dup_pts = self._check_duplication(file_data)

        # 2. File Size Distribution (25 pts)
        dist_pts = self._check_file_size_distribution(file_data, sa)

        # 3. Naming Consistency (25 pts)
        naming_pts = self._check_code_naming_consistency(file_data)

        # 4. Test Coverage Indicator (25 pts)
        test_pts = self._check_test_coverage(paths, file_data)

        score = dup_pts + dist_pts + naming_pts + test_pts

        # Confidence
        if file_data:
            confidence = 65.0 if len(file_data) >= 5 else 55.0
        elif sa:
            confidence = 40.0
        else:
            confidence = 15.0

        return ScoreEntry(value=_clamp(round(score, 1)), confidence=confidence)

    # ------------------------------------------------------------------
    # Helpers
    # ------------------------------------------------------------------

    @staticmethod
    def _check_naming_consistency(names: list, max_pts: float = 25.0) -> float:
        """Check if names follow a consistent suffix pattern."""
        if not names:
            return max_pts * 0.5

        suffixes = ("View", "Screen", "Page", "Scene", "Panel", "Controller",
                     "Activity", "Fragment", "Component")
        suffix_counts: dict[str, int] = {}
        no_suffix = 0

        for name in names:
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

        total = len(names)
        if not suffix_counts:
            return max_pts * 0.5  # no recognizable pattern

        dominant = max(suffix_counts.values())
        ratio = dominant / total

        if ratio >= 0.8:
            return max_pts  # very consistent
        elif ratio >= 0.5:
            return max_pts * 0.7  # mostly consistent
        else:
            return max_pts * 0.3  # chaotic

    @staticmethod
    def _check_duplication(file_data: list[tuple[str, str, int]]) -> float:
        """Check for code duplication indicators (25 pts max)."""
        if not file_data:
            return 12.5  # neutral

        # Extract function/method names across files
        func_re = re.compile(r"\b(?:func|def|function|fun)\s+(\w+)")
        func_files: dict[str, list[str]] = {}  # func_name → [filenames]

        for fname, content, _ in file_data:
            for m in func_re.finditer(content):
                fn = m.group(1)
                if len(fn) > 3:  # skip very short names
                    func_files.setdefault(fn, []).append(fname)

        # Count functions that appear in multiple different files
        duplicated_funcs = sum(
            1 for fn, files in func_files.items()
            if len(set(files)) > 1
        )

        total_funcs = len(func_files)
        if total_funcs == 0:
            return 15.0  # not enough data

        dup_ratio = duplicated_funcs / total_funcs
        if dup_ratio < 0.05:
            return 25.0  # minimal duplication
        elif dup_ratio < 0.15:
            return 18.0  # moderate
        elif dup_ratio < 0.3:
            return 10.0  # high
        else:
            return 5.0  # very high

    @staticmethod
    def _check_file_size_distribution(
        file_data: list[tuple[str, str, int]],
        sa: dict,
    ) -> float:
        """Check file size distribution (25 pts max)."""
        locs = [loc for _, _, loc in file_data if loc > 0]

        if not locs:
            total_loc = sa.get("total_loc", 0) or 0
            total_files = sa.get("total_files", 0) or 0
            if total_files > 0 and total_loc > 0:
                avg = total_loc / total_files
                # Without per-file data, assume moderate distribution
                return 15.0 if avg < 300 else 10.0
            return 12.5  # neutral

        if len(locs) < 2:
            return 18.0  # single file, can't measure distribution

        stddev = statistics.stdev(locs)
        if stddev < 100:
            return 25.0  # very uniform
        elif stddev < 200:
            return 18.0  # moderate
        elif stddev < 400:
            return 12.0  # uneven
        else:
            return 8.0  # God Files present

    @staticmethod
    def _check_code_naming_consistency(file_data: list[tuple[str, str, int]]) -> float:
        """Check naming conventions consistency (25 pts max)."""
        if not file_data:
            return 12.5  # neutral

        class_re = re.compile(r"\b(?:class|struct|enum|interface)\s+(\w+)")
        func_re = re.compile(r"\b(?:func|def|function|fun)\s+(\w+)")

        pascal_classes = 0
        non_pascal_classes = 0
        camel_funcs = 0
        non_camel_funcs = 0

        for _, content, _ in file_data:
            for m in class_re.finditer(content):
                name = m.group(1)
                if name[0].isupper():
                    pascal_classes += 1
                else:
                    non_pascal_classes += 1

            for m in func_re.finditer(content):
                name = m.group(1)
                # Skip __dunder__ and test_ prefixed
                if name.startswith("__") or name.startswith("test"):
                    continue
                if name[0].islower() or name.startswith("_"):
                    camel_funcs += 1
                else:
                    non_camel_funcs += 1

        total_names = pascal_classes + non_pascal_classes + camel_funcs + non_camel_funcs
        if total_names == 0:
            return 12.5  # not enough data

        consistent = pascal_classes + camel_funcs
        ratio = consistent / total_names

        if ratio >= 0.9:
            return 25.0  # very consistent
        elif ratio >= 0.7:
            return 18.0  # mostly consistent
        elif ratio >= 0.5:
            return 12.0  # mixed
        else:
            return 8.0  # inconsistent

    @staticmethod
    def _check_test_coverage(paths: list, file_data: list[tuple[str, str, int]]) -> float:
        """Check test file ratio (25 pts max)."""
        test_re = re.compile(r"(test_|_test\.|Tests?/|Spec/|spec_)", re.IGNORECASE)

        # Check all paths (not just read files)
        all_names = [Path(p).name if isinstance(p, str) else str(p) for p in paths]
        total = len(all_names)

        if total == 0:
            # Fallback to file_data
            all_names = [fn for fn, _, _ in file_data]
            total = len(all_names)

        if total == 0:
            return 12.5  # neutral

        test_count = sum(1 for n in all_names if test_re.search(n))
        source_count = total - test_count
        if source_count <= 0:
            return 18.0  # all tests, unusual

        ratio = test_count / source_count
        if ratio > 0.5:
            return 25.0
        elif ratio >= 0.2:
            return 18.0
        elif ratio >= 0.05:
            return 10.0
        else:
            return 3.0
