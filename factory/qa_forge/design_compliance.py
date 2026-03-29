"""Design Compliance -- evaluates QA results against CD Roadbook design requirements.

12 automatic checks (DC-001 to DC-012) aggregate QA checker results.
5 manual checks (DC-M01 to DC-M05) generate a CEO checklist.
"""

import json
import logging
from dataclasses import dataclass, field
from pathlib import Path
from typing import Optional

from .config import QA_CONFIG

logger = logging.getLogger(__name__)


@dataclass
class ComplianceCheck:
    """Single compliance check result."""
    check_id: str
    name: str
    category: str  # "visual", "audio", "animation", "scene", "cross"
    passed: bool
    severity: str = "error"  # "error", "warning", "info"
    details: str = ""
    auto: bool = True  # False for manual CEO checks


@dataclass
class ComplianceReport:
    """Aggregated design compliance report."""
    project: str
    checks: list = field(default_factory=list)
    manual_checklist: list = field(default_factory=list)
    score_percent: float = 0.0
    verdict: str = "PENDING"  # PASS, CONDITIONAL_PASS, FAIL
    fixes_required: list = field(default_factory=list)
    recommendations: list = field(default_factory=list)

    def summary(self) -> str:
        """Human-readable summary."""
        auto_checks = [c for c in self.checks if c.auto]
        passed = sum(1 for c in auto_checks if c.passed)
        failed = sum(1 for c in auto_checks if not c.passed)

        lines = [
            f"Design Compliance: {self.project}",
            f"  Score: {self.score_percent:.1f}% | Verdict: {self.verdict}",
            f"  Auto Checks: {passed} passed, {failed} failed "
            f"(of {len(auto_checks)})",
        ]

        if self.fixes_required:
            lines.append(f"  Required Fixes ({len(self.fixes_required)}):")
            for fix in self.fixes_required:
                lines.append(f"    - {fix}")

        if self.recommendations:
            lines.append(f"  Recommendations ({len(self.recommendations)}):")
            for rec in self.recommendations:
                lines.append(f"    - {rec}")

        if self.manual_checklist:
            lines.append(f"  CEO Manual Checklist ({len(self.manual_checklist)}):")
            for item in self.manual_checklist:
                lines.append(f"    [ ] {item.check_id}: {item.name} "
                             f"-- {item.details}")

        return "\n".join(lines)


# --- Standard Checks ---

STANDARD_CHECKS = [
    # Visual
    {"id": "DC-001", "name": "Color Palette Compliance",
     "category": "visual", "qa_key": "color_palette",
     "desc": "All assets use approved CD palette"},
    {"id": "DC-002", "name": "Brightness / Theme Consistency",
     "category": "visual", "qa_key": "brightness",
     "desc": "Dark/light theme brightness within range"},
    {"id": "DC-003", "name": "Resolution Minimums",
     "category": "visual", "qa_key": "resolution",
     "desc": "Icons ≥512px, sprites ≥256px"},
    {"id": "DC-004", "name": "Alpha Channel Correctness",
     "category": "visual", "qa_key": "transparency",
     "desc": "Sprites/icons have alpha, backgrounds do not"},

    # Audio
    {"id": "DC-005", "name": "Audio Loudness Standard",
     "category": "audio", "qa_key": "loudness",
     "desc": "Peak within target ±tolerance, no clipping"},
    {"id": "DC-006", "name": "Sound Duration Ranges",
     "category": "audio", "qa_key": "duration",
     "desc": "SFX/UI/ambient/music within category range"},
    {"id": "DC-007", "name": "Audio Format & Platform",
     "category": "audio", "qa_key": "format",
     "desc": "Correct format per target platform"},

    # Animation
    {"id": "DC-008", "name": "Animation Timing Ranges",
     "category": "animation", "qa_key": "timing",
     "desc": "Duration within category timing range"},
    {"id": "DC-009", "name": "Ease Curve Quality",
     "category": "animation", "qa_key": "ease_curves",
     "desc": "No all-linear keyframes (robotic feel)"},
    {"id": "DC-010", "name": "Lottie Structure Valid",
     "category": "animation", "qa_key": "lottie_structure",
     "desc": "Required fields, valid framerate, layers present"},

    # Scene
    {"id": "DC-011", "name": "Level Reachability",
     "category": "scene", "qa_key": "reachability",
     "desc": "All cells reachable via BFS from start"},
    {"id": "DC-012", "name": "Difficulty Curve Monotonic",
     "category": "scene", "qa_key": "difficulty_curve",
     "desc": "No large jumps (>0.25), tutorial levels easy"},
]

MANUAL_CHECKS = [
    {"id": "DC-M01", "name": "Brand Identity Match",
     "category": "cross",
     "desc": "Visual style matches brand guidelines and mood board"},
    {"id": "DC-M02", "name": "Audio-Visual Sync",
     "category": "cross",
     "desc": "Sound effects match animation timing and context"},
    {"id": "DC-M03", "name": "Accessibility Review",
     "category": "cross",
     "desc": "Color contrast, font sizes, screen reader support"},
    {"id": "DC-M04", "name": "Platform Feel Test",
     "category": "cross",
     "desc": "iOS/Android/Web feel native on each platform"},
    {"id": "DC-M05", "name": "Emotional Response",
     "category": "cross",
     "desc": "First-impression test: does the app feel premium?"},
]


class DesignCompliance:
    """Evaluates QA checker results against CD Roadbook design requirements."""

    def run_compliance(self, qa_results: dict,
                       project: str = "unknown",
                       roadbook: Optional[dict] = None) -> ComplianceReport:
        """Run all compliance checks against QA results.

        Args:
            qa_results: Dict with keys "visual", "audio", "animation", "scene"
                        each containing a list of checker results.
            project: Project name for the report.
            roadbook: Optional CD Roadbook dict with design requirements.

        Returns:
            ComplianceReport with verdict, fixes, recommendations.
        """
        report = ComplianceReport(project=project)

        # Run automatic checks
        for check_def in STANDARD_CHECKS:
            result = self._evaluate_check(check_def, qa_results)
            report.checks.append(result)

        # Add manual checklist
        for manual in MANUAL_CHECKS:
            report.manual_checklist.append(ComplianceCheck(
                check_id=manual["id"],
                name=manual["name"],
                category=manual["category"],
                passed=False,  # CEO must verify
                severity="info",
                details=manual["desc"],
                auto=False,
            ))

        # Calculate score + verdict
        auto_checks = [c for c in report.checks if c.auto]
        passed_count = sum(1 for c in auto_checks if c.passed)
        total = len(auto_checks)
        report.score_percent = (passed_count / total * 100) if total > 0 else 0

        # Collect errors and warnings
        errors = [c for c in auto_checks
                  if not c.passed and c.severity == "error"]
        warnings = [c for c in auto_checks
                    if not c.passed and c.severity == "warning"]

        # Determine verdict using config thresholds
        thresholds = QA_CONFIG["verdict_thresholds"]
        pass_t = thresholds["pass"]
        cond_t = thresholds["conditional_pass"]

        if (len(errors) <= pass_t["max_errors"]
                and len(warnings) <= pass_t["max_warnings"]
                and report.score_percent >= pass_t["min_pass_rate"] * 100):
            report.verdict = "PASS"
        elif (len(errors) <= cond_t["max_errors"]
              and len(warnings) <= cond_t["max_warnings"]
              and report.score_percent >= cond_t["min_pass_rate"] * 100):
            report.verdict = "CONDITIONAL_PASS"
        else:
            report.verdict = "FAIL"

        # Generate fixes for errors
        for check in errors:
            report.fixes_required.append(
                f"[{check.check_id}] {check.name}: {check.details}")

        # Generate recommendations for warnings
        for check in warnings:
            report.recommendations.append(
                f"[{check.check_id}] {check.name}: {check.details}")

        return report

    def _evaluate_check(self, check_def: dict,
                        qa_results: dict) -> ComplianceCheck:
        """Evaluate one standard check against QA results."""
        check_id = check_def["id"]
        category = check_def["category"]
        qa_key = check_def["qa_key"]

        # Map category to QA result list
        category_map = {
            "visual": "visual",
            "audio": "audio",
            "animation": "animation",
            "scene": "scene",
        }
        result_key = category_map.get(category)

        if not result_key or result_key not in qa_results:
            return ComplianceCheck(
                check_id=check_id,
                name=check_def["name"],
                category=category,
                passed=True,
                severity="warning",
                details=f"No {category} results available (skipped)",
            )

        results = qa_results[result_key]
        if not results:
            return ComplianceCheck(
                check_id=check_id,
                name=check_def["name"],
                category=category,
                passed=True,
                severity="info",
                details="No assets to check",
            )

        # Count pass/fail for this specific check across all results
        pass_count = 0
        fail_count = 0
        warn_count = 0
        fail_details = []

        for r in results:
            checks = r.get("checks", {})
            if qa_key in checks:
                check_result = checks[qa_key]
                status = check_result.get("pass")
                if status is True:
                    pass_count += 1
                elif status is False:
                    fail_count += 1
                    detail = check_result.get("details", "")
                    asset_id = (r.get("asset_id") or r.get("sound_id")
                                or r.get("anim_id") or r.get("item_id")
                                or r.get("level_id") or "unknown")
                    fail_details.append(f"{asset_id}: {detail}")
                elif status == "warn":
                    warn_count += 1

        total = pass_count + fail_count + warn_count
        if total == 0:
            return ComplianceCheck(
                check_id=check_id,
                name=check_def["name"],
                category=category,
                passed=True,
                severity="info",
                details=f"Check '{qa_key}' not found in results",
            )

        passed = fail_count == 0
        severity = "error" if fail_count > 0 else ("warning" if warn_count > 0
                                                    else "info")

        details_str = (f"{pass_count}/{total} passed"
                       if passed else
                       f"{fail_count}/{total} failed: "
                       + "; ".join(fail_details[:3]))

        return ComplianceCheck(
            check_id=check_id,
            name=check_def["name"],
            category=category,
            passed=passed,
            severity=severity,
            details=details_str,
        )

    def save_report(self, report: ComplianceReport,
                    output_dir: str = None) -> str:
        """Save compliance report as JSON."""
        if output_dir is None:
            output_dir = str(Path(__file__).parent / "reports")

        Path(output_dir).mkdir(parents=True, exist_ok=True)
        path = Path(output_dir) / f"{report.project}_compliance.json"

        data = {
            "project": report.project,
            "score_percent": report.score_percent,
            "verdict": report.verdict,
            "checks": [
                {"id": c.check_id, "name": c.name, "category": c.category,
                 "passed": c.passed, "severity": c.severity,
                 "details": c.details, "auto": c.auto}
                for c in report.checks
            ],
            "manual_checklist": [
                {"id": c.check_id, "name": c.name, "details": c.details}
                for c in report.manual_checklist
            ],
            "fixes_required": report.fixes_required,
            "recommendations": report.recommendations,
        }

        path.write_text(json.dumps(data, indent=2, ensure_ascii=False),
                        encoding="utf-8")
        logger.info("Compliance report saved: %s", path)
        return str(path)
