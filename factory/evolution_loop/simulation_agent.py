"""Simulation Agent — Static code analysis + optional LLM-powered deep analysis.

Analyzes build artifacts deterministically: static analysis, roadbook coverage
matching, and synthetic user flow checks.  Optionally enriches results with
LLM-powered deep flow analysis and code quality assessment.

This replaces the last stub in the Loop Orchestrator (P-EVO-014).
LLM extension added in P-EVO-019.
"""

from __future__ import annotations

import logging
import os
import re
from pathlib import Path

from factory.evolution_loop.ldo.schema import LoopDataObject
from factory.evolution_loop.plugins.plugin_loader import PluginLoader

logger = logging.getLogger(__name__)

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
    """Analyzes build artifacts through static + optional LLM-powered analysis."""

    AGENT_ID = "evo_simulation"

    def __init__(self) -> None:
        self._plugin_loader = PluginLoader()
        self._llm_cost: float = 0.0

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

        # 4. Evaluation Plugins (per project_type)
        ldo = self._run_plugins(ldo)

        # 5. LLM-powered deep analysis (optional, non-critical)
        self._llm_cost = 0.0
        try:
            deep_flow = self._deep_flow_analysis(ldo)
            if deep_flow:
                ldo.simulation_results.static_analysis["deep_flow_analysis"] = deep_flow
        except Exception as e:
            logger.warning("%s Deep flow analysis failed (non-critical): %s", _PREFIX, e)

        try:
            code_quality = self._code_quality_analysis(existing[:5])
            if code_quality:
                ldo.simulation_results.static_analysis["code_quality_analysis"] = code_quality
        except Exception as e:
            logger.warning("%s Code quality analysis failed (non-critical): %s", _PREFIX, e)

        if self._llm_cost > 0:
            ldo.simulation_results.static_analysis["llm_cost_usd"] = round(self._llm_cost, 6)

        coverage_pct = ldo.simulation_results.roadbook_coverage.get("coverage_percent", 0)
        cost_str = f", LLM cost: ${self._llm_cost:.4f}" if self._llm_cost > 0 else ""
        print(
            f"{_PREFIX} Analysis complete: {len(existing)} files, "
            f"{coverage_pct:.0f}% roadbook coverage{cost_str}"
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
    # Evaluation Plugins
    # ------------------------------------------------------------------

    def _run_plugins(self, ldo: LoopDataObject) -> LoopDataObject:
        """Load and run evaluation plugins for the project type."""
        project_type = ldo.meta.project_type or ""
        plugins = self._plugin_loader.load_plugins(project_type)

        if not plugins:
            return ldo

        for plugin in plugins:
            try:
                result = plugin.evaluate(ldo)
                score_entry = result.get("score")
                issues = result.get("issues", [])

                # Store as dict for EvaluationAgent compatibility
                ldo.simulation_results.plugin_results[plugin.name] = {
                    "value": score_entry.value if score_entry else 0,
                    "confidence": score_entry.confidence if score_entry else 10,
                    "issues": issues,
                }
            except Exception as e:
                print(f"{_PREFIX} Plugin '{plugin.name}' failed: {e}")
                ldo.simulation_results.plugin_results[plugin.name] = {
                    "value": 0,
                    "confidence": 0,
                    "issues": [f"Plugin error: {e}"],
                }

        return ldo

    # ------------------------------------------------------------------
    # LLM helper (P-EVO-019)
    # ------------------------------------------------------------------

    def _call_llm(self, prompt: str, system_msg: str | None = None, max_tokens: int = 2048) -> str:
        """LLM call via TheBrain ProviderRouter with Anthropic fallback.

        Returns the response text, or empty string on failure.
        Tracks cost in self._llm_cost.

        Note: O-series models consume reasoning tokens from max_tokens budget.
        A floor of 1024 is enforced to ensure visible output.
        """
        # O-series models (o3-mini) need headroom for reasoning tokens
        max_tokens = max(max_tokens, 1024)

        if system_msg is None:
            system_msg = (
                "Du bist der Simulation Agent der DriveAI Factory. "
                "Analysiere Code-Artefakte praezise und sachlich. "
                "Antworte immer auf Deutsch."
            )

        messages = [
            {"role": "system", "content": system_msg},
            {"role": "user", "content": prompt},
        ]

        # --- Primary path: TheBrain + ProviderRouter ---
        try:
            from factory.brain.model_provider import get_model, get_router

            selection = get_model(
                agent_name="SimulationAgent",
                task_type="analysis",
                profile="standard",
                expected_output_tokens=max_tokens,
            )
            router = get_router()
            response = router.call(
                model_id=selection["model"],
                provider=selection["provider"],
                messages=messages,
                max_tokens=max_tokens,
                temperature=1.0,  # O-series models only support 1.0
            )
            if response.error:
                raise RuntimeError(response.error)

            self._llm_cost += response.cost_usd or 0.0
            cost_str = f", ${response.cost_usd:.4f}" if response.cost_usd else ""
            logger.info(
                "%s LLM: %s (%s)%s",
                _PREFIX, selection["model"], selection["provider"], cost_str,
            )
            return response.content

        except Exception as primary_err:
            logger.warning("%s Primary LLM failed: %s — trying fallback", _PREFIX, primary_err)

        # --- Fallback: Direct Anthropic SDK ---
        try:
            import anthropic

            client = anthropic.Anthropic()
            resp = client.messages.create(
                model="claude-sonnet-4-6",
                max_tokens=max_tokens,
                system=system_msg,
                messages=[{"role": "user", "content": prompt}],
            )
            text = resp.content[0].text if resp.content else ""
            # Estimate cost (Sonnet input ~$3/M, output ~$15/M)
            in_tok = getattr(resp.usage, "input_tokens", 0)
            out_tok = getattr(resp.usage, "output_tokens", 0)
            est_cost = (in_tok * 3.0 + out_tok * 15.0) / 1_000_000
            self._llm_cost += est_cost
            logger.info("%s LLM fallback: claude-sonnet-4-6, ~$%.4f", _PREFIX, est_cost)
            return text

        except Exception as fallback_err:
            logger.error("%s LLM fallback also failed: %s", _PREFIX, fallback_err)
            return ""

    # ------------------------------------------------------------------
    # Deep flow analysis (LLM) — max 3 calls
    # ------------------------------------------------------------------

    def _deep_flow_analysis(self, ldo: LoopDataObject) -> dict | None:
        """Analyze user flows for missing connections, dead ends, error states.

        Makes at most 3 LLM calls. Returns analysis dict or None.
        """
        flows = ldo.roadbook_targets.user_flows or []
        paths = ldo.build_artifacts.paths or []

        if not flows:
            return None

        # Collect navigation-relevant code snippets (max 8000 chars)
        nav_snippets: list[str] = []
        total_chars = 0
        for p in paths[:_MAX_FILES]:
            if total_chars > 8000:
                break
            if not os.path.isfile(p) or not self._is_text_file(p):
                continue
            content = self._read_file(p)
            if not content:
                continue
            # Only include files with navigation patterns
            has_nav = any(pat.search(content) for pat in _NAV_PATTERNS)
            if has_nav:
                basename = os.path.basename(p)
                snippet = f"--- {basename} ---\n{content[:2000]}"
                nav_snippets.append(snippet)
                total_chars += len(snippet)

        if not nav_snippets:
            return None

        code_context = "\n".join(nav_snippets[:10])

        # --- LLM Call 1: Flow completeness ---
        flow_list = ", ".join(flows[:10])
        prompt_1 = (
            f"Analysiere diese Code-Snippets auf User-Flow-Vollstaendigkeit.\n\n"
            f"Erwartete Flows: {flow_list}\n\n"
            f"Code:\n```\n{code_context}\n```\n\n"
            f"Pruefe fuer jeden Flow:\n"
            f"1. Ist der Flow im Code referenziert?\n"
            f"2. Gibt es Sackgassen (Screens ohne Weiter-Navigation)?\n"
            f"3. Fehlen Error-States oder Loading-States?\n\n"
            f"Antworte strukturiert: pro Flow eine Zeile mit "
            f"'FLOW: <name> | STATUS: complete/incomplete/missing | ISSUES: <kurz>'"
        )
        result_1 = self._call_llm(prompt_1, max_tokens=2048)

        # --- LLM Call 2: Dead-end detection ---
        prompt_2 = (
            f"Finde Sackgassen und fehlende Verbindungen in diesen Navigations-Snippets.\n\n"
            f"Code:\n```\n{code_context}\n```\n\n"
            f"Liste alle Screens/Views die:\n"
            f"- Keine ausgehende Navigation haben (Sackgassen)\n"
            f"- Nur eingehende aber keine ausgehende Navigation haben\n"
            f"- Error-Handling fehlt (kein catch/guard nach Navigation)\n\n"
            f"Format: 'DEADEND: <screen> | REASON: <grund>'"
        )
        result_2 = self._call_llm(prompt_2, max_tokens=1024)

        # --- LLM Call 3: Recommendations ---
        prompt_3 = (
            f"Basierend auf dieser Analyse:\n\n"
            f"Flow-Check:\n{result_1[:1500]}\n\n"
            f"Sackgassen:\n{result_2[:1000]}\n\n"
            f"Gib max 5 konkrete Empfehlungen zur Verbesserung der User-Flows. "
            f"Format: nummerierte Liste, jeweils eine Zeile."
        )
        result_3 = self._call_llm(prompt_3, max_tokens=1024)

        return {
            "flow_completeness": result_1,
            "dead_ends": result_2,
            "recommendations": result_3,
            "flows_analyzed": len(flows),
            "nav_files_found": len(nav_snippets),
            "llm_calls": 3,
        }

    # ------------------------------------------------------------------
    # Code quality analysis (LLM) — max 5 calls
    # ------------------------------------------------------------------

    def _code_quality_analysis(self, file_paths: list[str]) -> dict | None:
        """Evaluate code quality per file via LLM. Max 5 files, 1 call each.

        Returns quality analysis dict or None.
        """
        if not file_paths:
            return None

        # Pick up to 5 largest text files
        candidates = []
        for p in file_paths:
            if not os.path.isfile(p) or not self._is_text_file(p):
                continue
            content = self._read_file(p)
            if content and len(content) > 50:
                candidates.append((p, content))
        candidates.sort(key=lambda x: len(x[1]), reverse=True)
        candidates = candidates[:5]

        if not candidates:
            return None

        file_results = []
        for fpath, content in candidates:
            basename = os.path.basename(fpath)
            lang = self._detect_language(fpath)
            # Truncate to 4000 chars for prompt budget
            code_snippet = content[:4000]

            prompt = (
                f"Bewerte die Code-Qualitaet dieser Datei ({lang}):\n\n"
                f"Datei: {basename}\n"
                f"```{lang}\n{code_snippet}\n```\n\n"
                f"Bewerte auf einer Skala 1-10 in diesen Kategorien:\n"
                f"- readability: Lesbarkeit und Benennung\n"
                f"- structure: Modularitaet und Aufbau\n"
                f"- error_handling: Fehlerbehandlung\n"
                f"- maintainability: Wartbarkeit\n\n"
                f"Format (exakt eine Zeile pro Kategorie):\n"
                f"readability: <1-10>\n"
                f"structure: <1-10>\n"
                f"error_handling: <1-10>\n"
                f"maintainability: <1-10>\n"
                f"summary: <ein Satz Zusammenfassung>"
            )
            result = self._call_llm(prompt, max_tokens=512)

            # Parse scores from response
            scores = {}
            for category in ("readability", "structure", "error_handling", "maintainability"):
                match = re.search(rf"{category}\s*:\s*(\d+)", result, re.IGNORECASE)
                if match:
                    scores[category] = min(int(match.group(1)), 10)

            summary_match = re.search(r"summary\s*:\s*(.+)", result, re.IGNORECASE)
            summary = summary_match.group(1).strip() if summary_match else ""

            avg_score = round(sum(scores.values()) / max(len(scores), 1), 1)

            file_results.append({
                "file": basename,
                "language": lang,
                "scores": scores,
                "average": avg_score,
                "summary": summary,
            })

        # Aggregate
        all_avgs = [r["average"] for r in file_results if r["average"] > 0]
        overall = round(sum(all_avgs) / max(len(all_avgs), 1), 1) if all_avgs else 0.0

        return {
            "files": file_results,
            "overall_quality": overall,
            "files_analyzed": len(file_results),
            "llm_calls": len(file_results),
        }

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
