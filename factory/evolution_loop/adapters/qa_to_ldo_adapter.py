"""QA-to-LDO Adapter — Transforms QA outputs into LDO-compatible fields.

Reads outputs from:
  1. QA Department (qa_coordinator.py → QAResult / QAReport JSON)
  2. QA Forge (qa_forge_orchestrator.py → QAForgeResult / JSON report)

Produces partial dicts that can be merged into a LoopDataObject.
Each partial follows the LDO schema structure (see ldo/schema.py).
"""

from __future__ import annotations

import json
import logging
from dataclasses import asdict
from pathlib import Path

logger = logging.getLogger(__name__)

_FACTORY_ROOT = Path(__file__).resolve().parent.parent.parent


# ---------------------------------------------------------------------------
# Module-level helpers
# ---------------------------------------------------------------------------

def _to_dict(obj) -> dict:
    """Convert a dataclass, object, or dict to a plain dict."""
    if isinstance(obj, dict):
        return obj
    if hasattr(obj, "__dataclass_fields__"):
        return asdict(obj)
    if hasattr(obj, "__dict__"):
        return obj.__dict__
    return {}


def _map_compile_status(phase_status: str) -> str:
    """Map QA phase status string to LDO compile_status enum value."""
    return {"PASSED": "success", "SKIPPED": "not_built"}.get(phase_status, "failed")


def _make_gap(gap_id: str, category: str, severity: str,
              description: str, component: str) -> dict:
    """Create a Gap-compatible dict."""
    return {
        "id": gap_id,
        "category": category,
        "severity": severity,
        "description": description,
        "affected_component": component,
        "is_regression": False,
        "first_seen_iteration": 0,
    }


_GATE_CHECK_CATEGORIES: dict[str, str] = {
    "build_ok": "bug",
    "tests_exist": "bug",
    "failure_rate": "bug",
    "no_crashes": "bug",
    "operations_clean": "structural",
}


# ---------------------------------------------------------------------------
# Adapter
# ---------------------------------------------------------------------------

class QAToLDOAdapter:
    """Transforms QA Department + QA Forge outputs into LDO-compatible dicts.

    Each ``transform_*`` method returns a *partial* dict matching LDO schema
    fields.  ``merge_results`` combines two partials, and
    ``extract_from_project`` loads reports from the filesystem.
    """

    # ------------------------------------------------------------------
    # QA Forge → LDO
    # ------------------------------------------------------------------

    def transform_qa_forge_results(self, forge_data) -> dict:
        """Transform QA Forge output into partial LDO fields.

        Accepts a ``QAForgeResult`` dataclass **or** a saved-JSON dict.

        Returns a dict with keys: ``qa_results``, ``scores``, ``gaps``,
        ``_forge_meta`` (internal metadata, stripped during LDO population).
        """
        data = _to_dict(forge_data)
        verdict = data.get("verdict", "unknown")
        errors = data.get("errors", [])

        # Full result lists (from dataclass) vs. counts only (saved JSON)
        visual = data.get("visual_results", [])
        audio = data.get("audio_results", [])
        animation = data.get("animation_results", [])
        scene = data.get("scene_results", [])
        all_results = [r for r in visual + audio + animation + scene if isinstance(r, dict)]

        compliance_score = data.get("compliance_score", 0)
        if isinstance(data.get("compliance"), dict):
            compliance_score = data["compliance"].get("score", compliance_score)

        # Count outcomes
        if all_results:
            pass_count = sum(1 for r in all_results if r.get("overall") == "pass")
            warn_count = sum(1 for r in all_results if r.get("overall") == "warn")
            fail_count = sum(1 for r in all_results if r.get("overall") == "fail")
            total = len(all_results)
        else:
            total = (data.get("visual_count", 0) + data.get("audio_count", 0) +
                     data.get("animation_count", 0) + data.get("scene_count", 0))
            pass_count, warn_count, fail_count = self._estimate_from_verdict(verdict, total)

        # Test details
        test_details = [
            {"source": "qa_forge",
             "name": r.get("name", r.get("check", "unknown")),
             "result": r.get("overall", "unknown")}
            for r in all_results
        ]

        # Derive UX score (visual + scene)
        ux_checks = [r for r in visual + scene if isinstance(r, dict)]
        if ux_checks:
            ux_pass = sum(1 for r in ux_checks if r.get("overall") == "pass")
            ux_value = (ux_pass / len(ux_checks)) * 100
        else:
            ux_value = self._verdict_to_score(verdict)

        # Derive performance score (animation + audio)
        perf_checks = [r for r in animation + audio if isinstance(r, dict)]
        if perf_checks:
            perf_pass = sum(1 for r in perf_checks if r.get("overall") == "pass")
            perf_value = (perf_pass / len(perf_checks)) * 100
        else:
            perf_value = self._verdict_to_score(verdict)

        confidence = (min(90.0, compliance_score) if compliance_score > 0
                      else 70.0 if total > 5 else 50.0)

        # Gaps from failures
        gaps: list[dict] = []
        for r in all_results:
            if r.get("overall") == "fail":
                cat = "ux" if r in (visual + scene) else "performance"
                desc = r.get("message", r.get("detail",
                             f"QA Forge check failed: {r.get('name', 'unknown')}"))
                gaps.append(_make_gap(f"QAF-{len(gaps) + 1}", cat, "high",
                                      desc, r.get("file", r.get("component", ""))))

        for err in errors:
            gaps.append(_make_gap(f"QAF-ERR-{len(gaps) + 1}", "bug", "critical",
                                  str(err), ""))

        return {
            "qa_results": {
                "tests_passed": pass_count,
                "tests_failed": fail_count,
                "test_details": test_details,
                "compile_errors": [],
                "warnings": [f"QA Forge warnings: {warn_count}"] if warn_count else [],
            },
            "scores": {
                "ux_score": {"value": round(ux_value, 1), "confidence": round(confidence, 1)},
                "performance_score": {"value": round(perf_value, 1), "confidence": round(confidence, 1)},
            },
            "gaps": gaps,
            "_forge_meta": {
                "verdict": verdict,
                "compliance_score": compliance_score,
                "total_checks": total,
            },
        }

    # ------------------------------------------------------------------
    # QA Department → LDO
    # ------------------------------------------------------------------

    def transform_qa_department_results(self, qa_data) -> dict:
        """Transform QA Department output into partial LDO fields.

        Accepts a ``QAResult`` dataclass **or** a ``QAReport.to_dict()`` JSON.
        Auto-detects the format via the presence of a ``"phases"`` key.

        Returns a dict with keys: ``build_artifacts``, ``qa_results``,
        ``scores``, ``gaps``, ``_dept_meta``.
        """
        data = _to_dict(qa_data)
        if "phases" in data:
            return self._from_report_json(data)
        return self._from_qa_result(data)

    # ---- QAReport JSON format -----------------------------------------

    def _from_report_json(self, report: dict) -> dict:
        phases = report.get("phases", {})
        status = report.get("status", "PENDING")

        # Build phase
        build_phase = phases.get("build", {})
        build_details = build_phase.get("details", {})
        compile_status = _map_compile_status(build_phase.get("status", "SKIPPED"))

        # Test phase
        test_details = phases.get("tests", {}).get("details", {})
        tests_total = test_details.get("total", 0)
        tests_passed = test_details.get("passed", 0)
        tests_failed = test_details.get("failed", 0)
        failure_rate = test_details.get("failure_rate", 0.0)

        # Operations phase
        ops_details = phases.get("operations", {}).get("details", {})
        blocking = ops_details.get("blocking_count", 0)
        warning_count = ops_details.get("warning_count", 0)

        # Quality gate → gaps
        gate_details = phases.get("quality_gate", {}).get("details", {})
        gaps = self._gaps_from_report(compile_status, blocking, gate_details)

        # Scores
        bug_value = max(0.0, 100.0 - (failure_rate * 500))
        structural_value = max(0.0, 100.0 - (blocking * 25) - (warning_count * 5))
        confidence = 80.0 if tests_total >= 10 else (60.0 if tests_total >= 5 else 40.0)

        compile_errors = ([f"{build_details['compiler_errors']} compiler errors"]
                          if build_details.get("compiler_errors", 0) > 0 else [])
        warnings = [f"{w.get('title', '')}: {w.get('detail', '')}"
                    for w in report.get("warnings", [])]

        return {
            "build_artifacts": {
                "compile_status": compile_status,
                "platform_details": {
                    "platform": report.get("platform", ""),
                    "build_duration": build_phase.get("duration_seconds", 0),
                },
            },
            "qa_results": {
                "tests_passed": tests_passed,
                "tests_failed": tests_failed,
                "test_details": [],
                "compile_errors": compile_errors,
                "warnings": warnings,
            },
            "scores": {
                "bug_score": {"value": round(bug_value, 1), "confidence": round(confidence, 1)},
                "structural_health_score": {"value": round(structural_value, 1),
                                            "confidence": round(confidence, 1)},
            },
            "gaps": gaps,
            "_dept_meta": {
                "status": status,
                "bounce_count": report.get("bounce_count", 0),
                "recommendation": report.get("recommendation", ""),
                "duration_seconds": report.get("duration_seconds", 0),
            },
        }

    # ---- QAResult dataclass format ------------------------------------

    def _from_qa_result(self, data: dict) -> dict:
        status = data.get("status", "PENDING")
        build = _to_dict(data.get("build_result") or {})
        test = _to_dict(data.get("test_result") or {})
        ops = data.get("ops_result") or {}

        compile_status = ("success" if build.get("success")
                          else "not_built" if build.get("status") == "SKIPPED"
                          else "failed")

        tests_total = test.get("tests_total", 0)
        tests_passed = test.get("tests_passed", 0)
        tests_failed = test.get("tests_failed", 0)
        failure_rate = test.get("failure_rate", 0.0)
        failures = test.get("failures", [])
        blocking = ops.get("blocking_count", 0)
        warning_count = ops.get("warning_count", 0)

        bug_value = max(0.0, 100.0 - (failure_rate * 500))
        structural_value = max(0.0, 100.0 - (blocking * 25) - (warning_count * 5))
        confidence = 80.0 if tests_total >= 10 else (60.0 if tests_total >= 5 else 40.0)

        # Gaps
        gaps: list[dict] = []
        if compile_status == "failed":
            gaps.append(_make_gap("QAD-BUILD-1", "bug", "critical",
                                  f"Build failed: {build.get('reason', 'unknown')}",
                                  "build_system"))
        for i, f in enumerate(failures):
            gaps.append(_make_gap(
                f"QAD-TEST-{i + 1}", "bug", "high",
                f"Test failed: {f.get('test_name', '?')} — {f.get('error_message', '')}",
                f.get("test_name", "")))
        if blocking > 0:
            gaps.append(_make_gap("QAD-OPS-1", "structural", "high",
                                  f"{blocking} blocking operations issues", "operations"))

        compile_errors = build.get("error_lines", [])
        warnings = ([f"build warnings: {build.get('warnings_count', 0)}"]
                    if build.get("warnings_count", 0) > 0 else [])

        return {
            "build_artifacts": {
                "compile_status": compile_status,
                "platform_details": {
                    "build_status": build.get("status", ""),
                    "build_duration": build.get("duration_seconds", 0),
                },
            },
            "qa_results": {
                "tests_passed": tests_passed,
                "tests_failed": tests_failed,
                "test_details": [
                    {"source": "qa_department",
                     "test_name": f.get("test_name", ""),
                     "error_message": f.get("error_message", "")}
                    for f in failures
                ],
                "compile_errors": compile_errors,
                "warnings": warnings,
            },
            "scores": {
                "bug_score": {"value": round(bug_value, 1), "confidence": round(confidence, 1)},
                "structural_health_score": {"value": round(structural_value, 1),
                                            "confidence": round(confidence, 1)},
            },
            "gaps": gaps,
            "_dept_meta": {
                "status": status,
                "bounce_count": data.get("bounce_count", 0),
                "recommendation": data.get("recommendation", ""),
                "duration_seconds": data.get("duration_seconds", 0),
            },
        }

    # ------------------------------------------------------------------
    # Merge
    # ------------------------------------------------------------------

    def merge_results(self, forge_partial: dict | None,
                      dept_partial: dict | None) -> dict:
        """Merge QA Forge + Department partials into one LDO-compatible dict.

        - ``build_artifacts``: from department only (Forge has none).
        - ``qa_results``: summed / concatenated.
        - ``scores``: confidence-weighted average for overlapping keys.
        - ``gaps``: concatenated.
        """
        if not forge_partial and not dept_partial:
            return {}
        if not forge_partial:
            return dept_partial
        if not dept_partial:
            return forge_partial

        merged: dict = {"build_artifacts": dept_partial.get("build_artifacts", {})}

        # qa_results
        dq = dept_partial.get("qa_results", {})
        fq = forge_partial.get("qa_results", {})
        merged["qa_results"] = {
            "tests_passed": dq.get("tests_passed", 0) + fq.get("tests_passed", 0),
            "tests_failed": dq.get("tests_failed", 0) + fq.get("tests_failed", 0),
            "test_details": dq.get("test_details", []) + fq.get("test_details", []),
            "compile_errors": dq.get("compile_errors", []) + fq.get("compile_errors", []),
            "warnings": dq.get("warnings", []) + fq.get("warnings", []),
        }

        # scores
        ds = dept_partial.get("scores", {})
        fs = forge_partial.get("scores", {})
        merged["scores"] = {}
        for key in set(list(ds.keys()) + list(fs.keys())):
            if key in ds and key in fs:
                d, f = ds[key], fs[key]
                dc = d.get("confidence", 50)
                fc = f.get("confidence", 50)
                total_conf = dc + fc
                if total_conf > 0:
                    val = (d.get("value", 0) * dc + f.get("value", 0) * fc) / total_conf
                    merged["scores"][key] = {"value": round(val, 1),
                                             "confidence": round(max(dc, fc), 1)}
                else:
                    merged["scores"][key] = d
            else:
                merged["scores"][key] = ds.get(key) or fs.get(key)

        # gaps
        merged["gaps"] = dept_partial.get("gaps", []) + forge_partial.get("gaps", [])

        return merged

    # ------------------------------------------------------------------
    # Extract from filesystem
    # ------------------------------------------------------------------

    def extract_from_project(self, project_slug: str,
                             platform: str = "web") -> dict:
        """Load QA outputs from the filesystem and return merged LDO partial.

        Looks for:
          - ``factory/qa_forge/reports/{slug}_qa_forge.json``
          - ``factory/qa/reports/{slug}_{platform}_*.json``  (latest)
        """
        forge_partial = None
        dept_partial = None

        # QA Forge report
        forge_path = _FACTORY_ROOT / "qa_forge" / "reports" / f"{project_slug}_qa_forge.json"
        if forge_path.exists():
            try:
                raw = json.loads(forge_path.read_text(encoding="utf-8"))
                forge_partial = self.transform_qa_forge_results(raw)
                logger.info("Loaded QA Forge report: %s", forge_path)
            except Exception as e:
                logger.warning("Failed to load QA Forge report %s: %s", forge_path, e)

        # QA Department report (latest by filename sort)
        dept_dir = _FACTORY_ROOT / "qa" / "reports"
        if dept_dir.exists():
            reports = sorted(dept_dir.glob(f"{project_slug}_{platform}_*.json"))
            if reports:
                try:
                    raw = json.loads(reports[-1].read_text(encoding="utf-8"))
                    dept_partial = self.transform_qa_department_results(raw)
                    logger.info("Loaded QA Department report: %s", reports[-1])
                except Exception as e:
                    logger.warning("Failed to load QA Dept report %s: %s", reports[-1], e)

        return self.merge_results(forge_partial, dept_partial)

    # ------------------------------------------------------------------
    # Internal helpers
    # ------------------------------------------------------------------

    @staticmethod
    def _gaps_from_report(compile_status: str, blocking: int,
                          gate_details: dict) -> list[dict]:
        gaps: list[dict] = []
        if compile_status == "failed":
            gaps.append(_make_gap("QAD-BUILD-1", "bug", "critical",
                                  "Build failed", "build_system"))
        if blocking > 0:
            gaps.append(_make_gap("QAD-OPS-1", "structural", "high",
                                  f"{blocking} blocking operations issues", "operations"))
        for name, check in gate_details.items():
            if isinstance(check, dict) and not check.get("passed", True):
                gaps.append(_make_gap(
                    f"QAD-GATE-{name}",
                    _GATE_CHECK_CATEGORIES.get(name, "bug"),
                    "high" if check.get("required") else "medium",
                    check.get("detail", f"Quality gate failed: {name}"),
                    name))
        return gaps

    @staticmethod
    def _estimate_from_verdict(verdict: str, total: int) -> tuple[int, int, int]:
        """Estimate pass/warn/fail counts when only verdict + total are known."""
        if verdict == "pass":
            return total, 0, 0
        elif verdict == "warn":
            w = max(1, int(total * 0.3))
            return total - w, w, 0
        else:
            f = max(1, int(total * 0.5))
            return total - f, 0, f

    @staticmethod
    def _verdict_to_score(verdict: str) -> float:
        """Map verdict string to estimated score (0-100)."""
        return {"pass": 90.0, "warn": 65.0, "fail": 30.0}.get(verdict, 50.0)
