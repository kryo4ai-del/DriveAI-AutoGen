"""QA Coordinator — Main orchestrator for the QA Department.

Runs 4 sequential phases:
  Phase A: Build Verification  (BuildVerifier + RepairCoordinator retry)
  Phase B: Operations Layer    (CompileHygieneValidator + auto-fixes)
  Phase C: Test Execution      (TestRunner)
  Phase D: Quality Gate        (QualityCriteria evaluation)

On failure: bounce back to Assembly (up to max_bounces) or escalate to CEO.

All external factory imports are lazy to avoid circular dependencies.
All external calls are wrapped in try/except — QA never crashes the pipeline.
"""

import time
from dataclasses import dataclass, field
from pathlib import Path

from factory.qa.config import QAConfig
from factory.qa.bounce_tracker import BounceTracker
from factory.qa.qa_report import QAReport
from factory.qa.test_runner import BuildVerifier, TestRunner, BuildResult, TestResult
from factory.qa.quality_criteria import QualityCriteria, QualityGateResult

_PROJECT_ROOT = Path(__file__).resolve().parent.parent.parent


# ---------------------------------------------------------------------------
# Result dataclass
# ---------------------------------------------------------------------------

@dataclass
class QAResult:
    """Final result of a full QA run."""
    status: str = "PENDING"       # PASSED, FAILED, BOUNCED, ESCALATED, ERROR
    build_result: BuildResult | None = None
    ops_result: dict = field(default_factory=dict)
    test_result: TestResult | None = None
    gate_result: QualityGateResult | None = None
    bounce_count: int = 0
    report_path: str | None = None
    recommendation: str = ""
    duration_seconds: float = 0.0


# ---------------------------------------------------------------------------
# QACoordinator
# ---------------------------------------------------------------------------

class QACoordinator:
    """Orchestrates the full QA pipeline for a project+platform."""

    def __init__(
        self,
        project_name: str,
        platform: str,
        project_dir: str | None = None,
        config: QAConfig | None = None,
    ) -> None:
        self.project_name = project_name
        self.platform = platform
        self.config = config or QAConfig()
        self.bounce = BounceTracker(project_name, platform)

        # Resolve project dir
        if project_dir:
            self.project_dir = Path(project_dir)
        else:
            self.project_dir = _PROJECT_ROOT / "projects" / project_name

        self._report = QAReport(project_name, platform)

    # ------------------------------------------------------------------
    # Main entry point
    # ------------------------------------------------------------------

    def run_qa(self) -> QAResult:
        """Run the full QA pipeline. Returns QAResult."""
        start = time.time()
        result = QAResult()
        result.bounce_count = self.bounce.get_count()

        print(f"\n{'='*60}")
        print(f"[QA] Starting QA for {self.project_name}/{self.platform}")
        print(f"[QA] Bounce count: {result.bounce_count}/{self.config.max_bounces}")
        print(f"{'='*60}\n")

        try:
            # Phase A: Build Verification
            build_result = self._phase_a_build()
            result.build_result = build_result
            if not build_result.success:
                result.status = self._handle_failure("build", build_result.status, result)
                result.duration_seconds = time.time() - start
                return self._finalize(result)

            # Phase B: Operations Layer
            ops_result = self._phase_b_operations()
            result.ops_result = ops_result
            blocking = ops_result.get("blocking_count", 0)
            if blocking > 0:
                result.status = self._handle_failure(
                    "operations", f"{blocking} blocking issues", result)
                result.duration_seconds = time.time() - start
                return self._finalize(result)

            # Phase C: Test Execution
            test_result = self._phase_c_tests()
            result.test_result = test_result

            # Phase D: Quality Gate
            gate_result = self._phase_d_quality_gate(build_result, ops_result, test_result)
            result.gate_result = gate_result

            if gate_result.passed:
                result.status = "PASSED"
                result.recommendation = "Ship it."
                self.bounce.reset()
                print(f"\n[QA] PASSED — All required checks passed")
            else:
                result.status = self._handle_failure(
                    "quality_gate", gate_result.summary, result)

        except Exception as e:
            print(f"\n[QA] ERROR: Unhandled exception: {e}")
            result.status = "ERROR"
            result.recommendation = f"QA crashed: {e}"
            self._report.add_warning("qa_crash", str(e))

        result.duration_seconds = time.time() - start
        return self._finalize(result)

    # ------------------------------------------------------------------
    # Phase A: Build Verification
    # ------------------------------------------------------------------

    def _phase_a_build(self) -> BuildResult:
        """Phase A: Build verification with optional repair retry."""
        print("[QA Phase A] Build Verification")
        start = time.time()

        verifier = BuildVerifier(
            self.project_name, self.platform,
            str(self.project_dir), self.config,
        )
        build_result = verifier.verify()

        if build_result.success:
            elapsed = time.time() - start
            self._report.add_phase("build", "PASSED", elapsed)
            print(f"[QA Phase A] Build PASSED ({elapsed:.0f}s)")
            return build_result

        # Build failed — try RepairCoordinator if available
        if build_result.status == "SKIPPED":
            elapsed = time.time() - start
            self._report.add_phase("build", "SKIPPED", elapsed,
                                   {"reason": build_result.reason})
            print(f"[QA Phase A] Build SKIPPED: {build_result.reason}")
            # Treat SKIPPED as success (toolchain not available)
            build_result.success = True
            return build_result

        # Try repair
        repaired = self._try_repair(build_result)
        if repaired is not None:
            build_result = repaired

        elapsed = time.time() - start
        status = "PASSED" if build_result.success else "FAILED"
        self._report.add_phase("build", status, elapsed, {
            "compiler_errors": len(build_result.error_lines),
            "repaired": repaired is not None,
        })
        return build_result

    def _try_repair(self, build_result: BuildResult) -> BuildResult | None:
        """Attempt repair via RepairCoordinator. Returns new BuildResult or None."""
        if not build_result.compiler_output:
            return None

        try:
            from factory.assembly.repair.repair_coordinator import RepairCoordinator
        except ImportError:
            print("[QA Phase A] RepairCoordinator not available — skipping repair")
            self._report.add_warning("repair_unavailable",
                                     "factory.assembly.repair.repair_coordinator not found")
            return None

        print("[QA Phase A] Attempting repair via RepairCoordinator...")
        try:
            language = "swift" if self.platform == "ios" else \
                       "kotlin" if self.platform == "android" else \
                       "typescript" if self.platform == "web" else "csharp"

            coordinator = RepairCoordinator(
                project_dir=str(self.project_dir),
                language=language,
                enable_llm=True,
                max_llm_files=10,
            )
            repair_report = coordinator.full_repair(build_result.compiler_output)

            if repair_report.status in ("clean", "improved") and repair_report.final_errors == 0:
                print(f"[QA Phase A] Repair successful: {repair_report.tier1_fixes} fixes applied")
                self._report.add_warning("repair_applied",
                                         f"Tier1: {repair_report.tier1_fixes} fixes")
                # Re-verify build after repair
                verifier = BuildVerifier(
                    self.project_name, self.platform,
                    str(self.project_dir), self.config,
                )
                return verifier.verify()
            else:
                print(f"[QA Phase A] Repair incomplete: {repair_report.final_errors} errors remain")
                self._report.add_warning("repair_incomplete",
                                         repair_report.escalation or
                                         f"{repair_report.final_errors} errors remain")
                return None

        except Exception as e:
            print(f"[QA Phase A] Repair failed: {e}")
            self._report.add_warning("repair_error", str(e))
            return None

    # ------------------------------------------------------------------
    # Phase B: Operations Layer
    # ------------------------------------------------------------------

    def _phase_b_operations(self) -> dict:
        """Phase B: Run CompileHygieneValidator and count blocking issues."""
        print("[QA Phase B] Operations Layer (Compile Hygiene)")
        start = time.time()

        ops_result = {
            "blocking_count": 0,
            "warning_count": 0,
            "total_issues": 0,
            "status": "SKIPPED",
        }

        try:
            from factory.operations.compile_hygiene_validator import CompileHygieneValidator
        except ImportError:
            print("[QA Phase B] CompileHygieneValidator not available — skipping")
            self._report.add_phase("operations", "SKIPPED", time.time() - start,
                                   {"reason": "CompileHygieneValidator not found"})
            return ops_result

        try:
            validator = CompileHygieneValidator(self.project_name)
            report = validator.validate()

            blocking = getattr(report, "blocking_count", 0)
            warning = getattr(report, "warning_count", 0)
            total = getattr(report, "total_issues", blocking + warning)
            status_str = getattr(report, "status", "unknown")

            ops_result = {
                "blocking_count": blocking,
                "warning_count": warning,
                "total_issues": total,
                "status": status_str,
            }

            elapsed = time.time() - start

            if blocking > 0:
                # Try auto-fix via quality_gate_loop
                ops_result = self._try_ops_autofix(ops_result)

            elapsed = time.time() - start
            phase_status = "PASSED" if ops_result["blocking_count"] == 0 else "FAILED"
            self._report.add_phase("operations", phase_status, elapsed, ops_result)

            print(f"[QA Phase B] {phase_status}: "
                  f"{ops_result['blocking_count']} blocking, "
                  f"{ops_result['warning_count']} warnings")

        except Exception as e:
            elapsed = time.time() - start
            print(f"[QA Phase B] Error: {e}")
            self._report.add_phase("operations", "ERROR", elapsed, {"error": str(e)})
            self._report.add_warning("operations_error", str(e))

        return ops_result

    def _try_ops_autofix(self, ops_result: dict) -> dict:
        """Try auto-fix via quality_gate_loop for blocking issues."""
        try:
            from factory.operations.quality_gate_loop import run_quality_gate_loop
        except ImportError:
            print("[QA Phase B] quality_gate_loop not available — skipping auto-fix")
            return ops_result

        print(f"[QA Phase B] {ops_result['blocking_count']} blocking issues — running auto-fix...")
        try:
            language = "swift" if self.platform == "ios" else \
                       "kotlin" if self.platform == "android" else \
                       "typescript" if self.platform == "web" else "csharp"

            loop_result = run_quality_gate_loop(
                project_name=self.project_name,
                language=language,
                line=self.platform,
                max_iterations=self.config.max_auto_fixes_per_run,
            )

            if loop_result.status == "pass":
                print(f"[QA Phase B] Auto-fix successful: "
                      f"{loop_result.tier1_fixes} T1, {loop_result.tier2_fixes} T2 fixes")
                ops_result["blocking_count"] = loop_result.final_blocking
                ops_result["status"] = "fixed"
                self._report.add_warning("ops_autofix_applied",
                                         f"T1={loop_result.tier1_fixes}, T2={loop_result.tier2_fixes}")
            else:
                print(f"[QA Phase B] Auto-fix escalated: "
                      f"{loop_result.final_blocking} blocking remain")
                ops_result["blocking_count"] = loop_result.final_blocking
                ops_result["status"] = "escalation"

        except Exception as e:
            print(f"[QA Phase B] Auto-fix error: {e}")
            self._report.add_warning("ops_autofix_error", str(e))

        return ops_result

    # ------------------------------------------------------------------
    # Phase C: Test Execution
    # ------------------------------------------------------------------

    def _phase_c_tests(self) -> TestResult:
        """Phase C: Run platform-specific tests."""
        print("[QA Phase C] Test Execution")
        start = time.time()

        runner = TestRunner(
            platform=self.platform,
            project_dir=str(self.project_dir),
            project_name=self.project_name,
            config=self.config,
        )
        test_result = runner.run()
        elapsed = time.time() - start

        self._report.add_phase("tests", test_result.status, elapsed, {
            "total": test_result.tests_total,
            "passed": test_result.tests_passed,
            "failed": test_result.tests_failed,
            "failure_rate": test_result.failure_rate,
            "has_crashes": test_result.has_crashes,
        })

        print(f"[QA Phase C] {test_result.status}: "
              f"{test_result.tests_passed}/{test_result.tests_total} passed "
              f"(failure rate: {test_result.failure_rate:.1%})")
        return test_result

    # ------------------------------------------------------------------
    # Phase D: Quality Gate
    # ------------------------------------------------------------------

    def _phase_d_quality_gate(
        self,
        build_result: BuildResult,
        ops_result: dict,
        test_result: TestResult,
    ) -> QualityGateResult:
        """Phase D: Evaluate all results against quality criteria."""
        print("[QA Phase D] Quality Gate Evaluation")
        start = time.time()

        criteria = QualityCriteria.from_project(self.project_name, self.platform)
        gate_result = criteria.evaluate(build_result, ops_result, test_result)

        elapsed = time.time() - start
        status = "PASSED" if gate_result.passed else "FAILED"
        check_details = {c.name: {"passed": c.passed, "required": c.required, "detail": c.detail}
                         for c in gate_result.checks}

        self._report.add_phase("quality_gate", status, elapsed, check_details)

        print(f"[QA Phase D] {status}: {gate_result.summary}")
        return gate_result

    # ------------------------------------------------------------------
    # Failure handling
    # ------------------------------------------------------------------

    def _handle_failure(self, phase: str, reason: str, result: QAResult) -> str:
        """Handle a phase failure: bounce or escalate.

        Returns the QAResult status string.
        """
        print(f"\n[QA] FAILURE in {phase}: {reason}")

        if self.bounce.is_limit_reached(self.config.max_bounces):
            # Escalate to CEO
            print(f"[QA] Bounce limit reached ({self.config.max_bounces}) — ESCALATING to CEO")
            result.recommendation = (
                f"QA failed at {phase}: {reason}. "
                f"Bounced {self.bounce.get_count()} times. Escalating to CEO."
            )
            self._escalate_to_ceo(phase, reason)
            return "ESCALATED"
        else:
            # Bounce back to Assembly
            count = self.bounce.increment()
            print(f"[QA] BOUNCING back to Assembly (bounce {count}/{self.config.max_bounces})")
            result.recommendation = (
                f"Bounce #{count}: Fix {phase} issue — {reason}. "
                f"Then re-submit to QA."
            )
            result.bounce_count = count
            return "BOUNCED"

    def _escalate_to_ceo(self, phase: str, reason: str) -> None:
        """Create a CEO escalation gate via gate_api (if available)."""
        try:
            from factory.hq.gate_api import create_gate
        except ImportError:
            print("[QA] gate_api not available — escalation logged but no gate created")
            self._report.add_warning("escalation_no_gate",
                                     "factory.hq.gate_api not found")
            return

        try:
            gate_id = create_gate(
                project=self.project_name,
                gate_type="qa_escalation",
                category="qa",
                title=f"QA Escalation: {self.project_name}/{self.platform}",
                description=(
                    f"QA failed at phase '{phase}' after "
                    f"{self.config.max_bounces} bounces.\n\n"
                    f"Reason: {reason}\n\n"
                    f"Options: Fix manually, kill the product, or override QA."
                ),
                severity="blocking",
                options=[
                    {"id": "fix", "label": "Fix & Retry", "color": "yellow"},
                    {"id": "override", "label": "Override QA", "color": "orange"},
                    {"id": "kill", "label": "Kill Product", "color": "red"},
                ],
                source_department="qa",
                source_agent="qa_coordinator",
                platform=self.platform,
                context={
                    "phase": phase,
                    "reason": reason,
                    "bounce_count": self.bounce.get_count(),
                },
            )
            print(f"[QA] CEO Gate created: {gate_id}")
            self._report.add_warning("ceo_gate_created", f"Gate ID: {gate_id}")

        except Exception as e:
            print(f"[QA] Failed to create CEO gate: {e}")
            self._report.add_warning("escalation_error", str(e))

    # ------------------------------------------------------------------
    # Finalize
    # ------------------------------------------------------------------

    def _finalize(self, result: QAResult) -> QAResult:
        """Finalize the report, save it, and return the result."""
        self._report.set_bounce_count(result.bounce_count)
        self._report.set_recommendation(result.recommendation)
        self._report.finalize(result.status)

        try:
            path = self._report.save(self.config)
            result.report_path = path
            print(f"\n[QA] Report saved: {path}")
        except Exception as e:
            print(f"[QA] Failed to save report: {e}")

        print(f"\n{'='*60}")
        print(f"[QA] RESULT: {result.status}")
        print(f"[QA] Duration: {result.duration_seconds:.0f}s")
        print(f"[QA] Recommendation: {result.recommendation}")
        print(f"{'='*60}\n")

        return result
