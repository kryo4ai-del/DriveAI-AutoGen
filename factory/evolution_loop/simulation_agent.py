"""Simulation Agent — Static code analysis without execution.

Analyzes build artifacts deterministically: static analysis, roadbook coverage
matching, and synthetic user flow checks.  No LLM calls — pure Python.

This replaces the last stub in the Loop Orchestrator (P-EVO-014).
"""

from __future__ import annotations

import os
import re
from pathlib import Path

from factory.evolution_loop.ldo.schema import LoopDataObject

_PREFIX = "[EVO-SIM]"

_MAX_FILES = 1000

_LANGUAGE_MAP = {
    ".swift": "swift",
    ".kt": "kotlin",
    ".ts": "typescript",
    ".tsx": "typescript",
    ".cs": "csharp",
    ".py": "python",
    ".js": "javascript",
    ".jsx": "javascript",
    ".java": "java",
    ".dart": "dart",
    ".go": "go",
    ".rs": "rust",
    ".cpp": "cpp",
    ".c": "c",
    ".h": "c",
    ".m": "objc",
    ".rb": "ruby",
    ".php": "php",
}

_BINARY_EXTENSIONS = frozenset({
    ".png", ".jpg", ".jpeg", ".gif", ".bmp", ".ico", ".svg", ".webp",
    ".mp3", ".mp4", ".wav", ".ogg", ".avi", ".mov",
    ".zip", ".tar", ".gz", ".rar", ".7z",
    ".pdf", ".doc", ".docx", ".xls", ".xlsx",
    ".xcassets", ".pbxproj", ".xcworkspace",
    ".ttf", ".otf", ".woff", ".woff2",
    ".so", ".dylib", ".dll", ".exe", ".o", ".a",
    ".pyc", ".pyo", ".class", ".jar",
    ".db", ".sqlite", ".sqlite3",
})

# Patterns for stub detection
_STUB_PATTERNS = [
    re.compile(r"^\s*pass\s*$"),
    re.compile(r"^\s*\.\.\.s*$"),
    re.compile(r"throw\s+NotImplementedError", re.IGNORECASE),
    re.compile(r"fatalError\s*\(", re.IGNORECASE),
    re.compile(r"return\s+nil\s*//\s*stub", re.IGNORECASE),
    re.compile(r"TODO\s*:\s*implement", re.IGNORECASE),
    re.compile(r"FIXME\s*:\s*implement", re.IGNORECASE),
    re.compile(r"raise\s+NotImplementedError"),
]

# Patterns for hardcoded values
_HARDCODED_PATTERNS = [
    re.compile(r'["\']https?://[^"\']+["\']'),           # hardcoded URLs
    re.compile(r'\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b'),  # hardcoded IPs
    re.compile(r'["\'][A-Za-z0-9]{20,}["\']'),           # potential API keys (20+ chars)
]

# Navigation patterns for flow detection
_NAV_PATTERNS = [
    re.compile(r"NavigationLink", re.IGNORECASE),
    re.compile(r"\.navigate\s*\(", re.IGNORECASE),
    re.compile(r"\.push\s*\(", re.IGNORECASE),
    re.compile(r"\.present\s*\(", re.IGNORECASE),
    re.compile(r"Intent\s*\(", re.IGNORECASE),
    re.compile(r"startActivity\s*\(", re.IGNORECASE),
    re.compile(r"router\.", re.IGNORECASE),
    re.compile(r"performSegue", re.IGNORECASE),
    re.compile(r"Navigator\.", re.IGNORECASE),
]

# Error handling patterns
_ERROR_HANDLING_PATTERNS = [
    re.compile(r"\btry\b"),
    re.compile(r"\bcatch\b"),
    re.compile(r"\bguard\b"),
    re.compile(r"\bthrows\b"),
    re.compile(r"\bexcept\b"),
    re.compile(r"\braise\b"),
    re.compile(r"\bfinally\b"),
    re.compile(r"\bdo\s*\{"),  # Swift do-catch
]


def _normalize_name(name: str) -> str:
    """Normalize a feature/screen name for matching: lowercase, strip separators."""
    return re.sub(r"[-_\s]+", "", name.lower())


def _empty_static_analysis() -> dict:
    """Return a default empty static analysis dict."""
    return {
        "total_files": 0,
        "total_loc": 0,
        "language_distribution": {},
        "todos": 0,
        "fixmes": 0,
        "stubs": 0,
        "hardcoded_values": 0,
        "deep_nesting": 0,
        "error_handling_ratio": 0.0,
        "dead_code_indicators": 0,
        "dead_code_ratio": 0.0,
        "files_analyzed": 0,
        "files_skipped": 0,
    }


def _empty_coverage() -> dict:
    """Return a default empty coverage dict."""
    return {
        "features_covered": [],
        "features_missing": [],
        "screens_covered": [],
        "screens_missing": [],
        "flows_covered": [],
        "coverage_percent": 0.0,
    }


class SimulationAgent:
    """Analyzes build artifacts through static code analysis."""

    AGENT_ID = "evo_simulation"

    def __init__(self) -> None:
        pass

    # ------------------------------------------------------------------
    # Main entry point
    # ------------------------------------------------------------------

    def simulate(self, ldo: LoopDataObject) -> LoopDataObject:
        """Analyze build artifacts and write results into LDO."""
        paths = ldo.build_artifacts.paths or []

        # Filter to existing files
        existing = [p for p in paths[:_MAX_FILES] if os.path.isfile(p)]

        if not existing:
            print(f"{_PREFIX} No existing build files found ({len(paths)} paths given)")
            # Only set defaults if no pre-populated data exists
            if not ldo.simulation_results.static_analysis:
                ldo.simulation_results.static_analysis = _empty_static_analysis()
            if not ldo.simulation_results.roadbook_coverage:
                ldo.simulation_results.roadbook_coverage = _empty_coverage()
            if not ldo.simulation_results.synthetic_flows:
                ldo.simulation_results.synthetic_flows = []
            return ldo

        # 1. Static analysis
        ldo.simulation_results.static_analysis = self._static_analysis(existing)

        # 2. Roadbook coverage
        ldo.simulation_results.roadbook_coverage = self._roadbook_coverage(ldo)

        # 3. Synthetic flow check
        ldo.simulation_results.synthetic_flows = self._synthetic_flow_check(ldo)

        coverage_pct = ldo.simulation_results.roadbook_coverage.get("coverage_percent", 0)
        print(
            f"{_PREFIX} Analysis complete: {len(existing)} files, "
            f"{coverage_pct:.0f}% roadbook coverage"
        )

        return ldo

    # ------------------------------------------------------------------
    # Static analysis
    # ------------------------------------------------------------------

    def _static_analysis(self, file_paths: list) -> dict:
        """Analyze code files without LLM."""
        result = _empty_static_analysis()
        lang_dist: dict[str, int] = {}
        files_with_error_handling = 0

        for fpath in file_paths[:_MAX_FILES]:
            if not self._is_text_file(fpath):
                result["files_skipped"] += 1
                continue

            content = self._read_file(fpath)
            if content is None:
                result["files_skipped"] += 1
                continue

            result["files_analyzed"] += 1
            result["total_files"] += 1

            # Language
            lang = self._detect_language(fpath)
            lang_dist[lang] = lang_dist.get(lang, 0) + 1

            lines = content.split("\n")

            # LOC (non-empty, non-comment)
            loc = 0
            for line in lines:
                stripped = line.strip()
                if stripped and not stripped.startswith("//") and not stripped.startswith("#"):
                    loc += 1
            result["total_loc"] += loc

            # TODOs and FIXMEs
            for line in lines:
                upper = line.upper()
                if "TODO" in upper:
                    result["todos"] += 1
                if "FIXME" in upper or "HACK" in upper or "XXX" in upper:
                    result["fixmes"] += 1

            # Stubs
            file_has_stub = False
            for line in lines:
                for pat in _STUB_PATTERNS:
                    if pat.search(line):
                        file_has_stub = True
                        result["stubs"] += 1
                        break
            # Also check empty function bodies: { } on same or next line
            for i, line in enumerate(lines):
                stripped = line.strip()
                if stripped == "{ }" or stripped == "{}":
                    # Check if preceded by func/def
                    if i > 0:
                        prev = lines[i - 1].strip()
                        if any(kw in prev for kw in ("func ", "def ", "fun ", "function ")):
                            result["stubs"] += 1

            # Hardcoded values
            for line in lines:
                for pat in _HARDCODED_PATTERNS:
                    if pat.search(line):
                        result["hardcoded_values"] += 1
                        break  # one per line max

            # Deep nesting (indentation depth > 3 levels)
            for line in lines:
                if not line.strip():
                    continue
                # Count leading spaces/tabs
                leading = len(line) - len(line.lstrip())
                # Normalize: 1 tab = 4 spaces
                depth = leading // 4 if "\t" not in line else line.count("\t", 0, leading)
                if depth > 3:
                    result["deep_nesting"] += 1

            # Error handling
            has_error_handling = False
            for line in lines:
                for pat in _ERROR_HANDLING_PATTERNS:
                    if pat.search(line):
                        has_error_handling = True
                        break
                if has_error_handling:
                    break
            if has_error_handling:
                files_with_error_handling += 1

            # Dead code indicators: code after return/break/continue at same indent
            for i in range(len(lines) - 1):
                stripped = lines[i].strip()
                if stripped in ("return", "break", "continue") or stripped.startswith("return "):
                    # Check next non-empty line at same or deeper indent
                    current_indent = len(lines[i]) - len(lines[i].lstrip())
                    for j in range(i + 1, min(i + 3, len(lines))):
                        next_line = lines[j]
                        if not next_line.strip():
                            continue
                        next_indent = len(next_line) - len(next_line.lstrip())
                        if next_indent >= current_indent and next_line.strip() not in ("}", ")", "]", ""):
                            # Check it's not a closing brace
                            if not next_line.strip().startswith(("}", ")", "]", "case ", "default:", "else", "catch", "except", "finally")):
                                result["dead_code_indicators"] += 1
                        break

        result["language_distribution"] = lang_dist

        # Error handling ratio
        if result["total_files"] > 0:
            result["error_handling_ratio"] = round(
                files_with_error_handling / result["total_files"], 2
            )

        # Dead code ratio (rough estimate based on indicators / total LOC)
        if result["total_loc"] > 0:
            result["dead_code_ratio"] = round(
                min(result["dead_code_indicators"] / max(result["total_loc"], 1), 0.5), 4
            )

        return result

    # ------------------------------------------------------------------
    # Roadbook coverage
    # ------------------------------------------------------------------

    def _roadbook_coverage(self, ldo: LoopDataObject) -> dict:
        """Check roadbook coverage through string matching in code."""
        targets = ldo.roadbook_targets
        features = targets.features or []
        screens = targets.screens or []
        paths = ldo.build_artifacts.paths or []

        if not features and not screens:
            return _empty_coverage()

        # Build lookup: normalized filename -> path, and cache file contents
        file_names: list[str] = []
        file_contents: dict[str, str] = {}
        for p in paths[:_MAX_FILES]:
            basename = os.path.basename(p)
            file_names.append(basename)
            if os.path.isfile(p) and self._is_text_file(p):
                content = self._read_file(p)
                if content:
                    file_contents[p] = content

        # Normalize all filenames for matching
        normalized_filenames = [_normalize_name(Path(fn).stem) for fn in file_names]
        # Also normalize all file content for searching
        normalized_contents = {
            p: content.lower() for p, content in file_contents.items()
        }

        # Feature coverage
        features_covered = []
        features_missing = []
        for feat in features:
            norm_feat = _normalize_name(feat)
            found = False
            # Check filename match
            for nfn in normalized_filenames:
                if norm_feat in nfn or nfn in norm_feat:
                    found = True
                    break
            # Check content match if not found by filename
            if not found:
                for content in normalized_contents.values():
                    if norm_feat in content:
                        found = True
                        break
            if found:
                features_covered.append(feat)
            else:
                features_missing.append(feat)

        # Screen coverage
        screens_covered = []
        screens_missing = []
        for screen in screens:
            norm_screen = _normalize_name(screen)
            found = False
            for nfn in normalized_filenames:
                if norm_screen in nfn or nfn in norm_screen:
                    found = True
                    break
            if not found:
                for content in normalized_contents.values():
                    if norm_screen in content:
                        found = True
                        break
            if found:
                screens_covered.append(screen)
            else:
                screens_missing.append(screen)

        # Coverage percent
        total = len(features) + len(screens)
        covered = len(features_covered) + len(screens_covered)
        coverage_pct = (covered / total * 100) if total > 0 else 0.0

        return {
            "features_covered": features_covered,
            "features_missing": features_missing,
            "screens_covered": screens_covered,
            "screens_missing": screens_missing,
            "coverage_percent": round(coverage_pct, 1),
        }

    # ------------------------------------------------------------------
    # Synthetic flow check
    # ------------------------------------------------------------------

    def _synthetic_flow_check(self, ldo: LoopDataObject) -> list:
        """Check whether user flows are logically possible."""
        flows = ldo.roadbook_targets.user_flows or []
        paths = ldo.build_artifacts.paths or []

        if not flows:
            return []

        # Cache file contents
        all_content = ""
        for p in paths[:_MAX_FILES]:
            if os.path.isfile(p) and self._is_text_file(p):
                content = self._read_file(p)
                if content:
                    all_content += content + "\n"

        all_content_lower = all_content.lower()

        # Count total navigation patterns
        results = []
        for flow_name in flows:
            norm_flow = _normalize_name(flow_name)

            # Check if flow is referenced in code
            screens_referenced = 0
            if norm_flow in all_content_lower:
                screens_referenced += 1
            # Also check parts of the flow name (e.g. "start_game" -> "start", "game")
            parts = re.split(r"[-_\s]+", flow_name.lower())
            for part in parts:
                if len(part) > 3 and part in all_content_lower:
                    screens_referenced += 1

            # Count navigation patterns
            nav_count = 0
            for pat in _NAV_PATTERNS:
                nav_count += len(pat.findall(all_content))

            results.append({
                "flow_name": flow_name,
                "screens_referenced": screens_referenced,
                "navigation_patterns_found": nav_count,
                "is_complete": screens_referenced > 0,
            })

        return results

    # ------------------------------------------------------------------
    # Helpers
    # ------------------------------------------------------------------

    @staticmethod
    def _detect_language(filepath: str) -> str:
        """Detect programming language from file extension."""
        ext = Path(filepath).suffix.lower()
        return _LANGUAGE_MAP.get(ext, "unknown")

    @staticmethod
    def _is_text_file(filepath: str) -> bool:
        """Check if a file is a text file (not binary)."""
        ext = Path(filepath).suffix.lower()
        if ext in _BINARY_EXTENSIONS:
            return False
        # If extension is in our language map, it's text
        if ext in _LANGUAGE_MAP:
            return True
        # For unknown extensions, check by reading a small chunk
        try:
            with open(filepath, "rb") as f:
                chunk = f.read(1024)
            # If null bytes present, it's likely binary
            if b"\x00" in chunk:
                return False
            return True
        except (OSError, IOError):
            return False

    @staticmethod
    def _read_file(filepath: str) -> str | None:
        """Read a file with encoding fallback. Returns None on failure."""
        for encoding in ("utf-8", "latin-1"):
            try:
                with open(filepath, "r", encoding=encoding) as f:
                    return f.read()
            except (UnicodeDecodeError, UnicodeError):
                continue
            except (OSError, IOError):
                return None
        return None
