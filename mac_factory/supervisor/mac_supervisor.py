"""
DriveAI Mac Factory — Mac Supervisor

The autonomous iOS build orchestrator. Receives a project, runs it through
pre-build cleanup -> compile -> repair loop -> archive. No human intervention.

Flow:
1. Pre-Build Cleanup (5 rules, $0)
2. xcodegen
3. First Compile
4. Import Mapping (post-compile, $0)
5. Compile + Repair Loop
6. Archive (if 0 errors)
7. Report
"""

import os
import re
import time
import subprocess
import json
from pathlib import Path
from dataclasses import dataclass, field

from mac_factory.supervisor.safety_guard import SafetyGuard
from mac_factory.supervisor.pre_build_cleanup import PreBuildCleanup
from mac_factory.supervisor.error_analyzer import ErrorAnalyzer
from mac_factory.supervisor.error_auditor import ErrorAuditor
from mac_factory.supervisor.repair_executor import RepairExecutor
from mac_factory.supervisor.learning_db import LearningDB
from mac_factory.supervisor.progress_tracker import ProgressTracker


@dataclass
class SupervisorResult:
    status: str = "PENDING"
    build_succeeded: bool = False
    archive_succeeded: bool = False
    archive_path: str = ""
    start_errors: int = 0
    end_errors: int = 0
    pre_build_fixed: int = 0
    import_mapping_fixed: int = 0
    compile_repair_fixed: int = 0
    cycles_used: int = 0
    total_cost: float = 0.0
    duration_seconds: float = 0.0
    reason: str = ""
    error_trend: list = field(default_factory=list)

    def to_dict(self) -> dict:
        return {k: v for k, v in self.__dict__.items()}


class MacSupervisor:
    def __init__(self, project_dir: str, project_name: str, config: dict = None):
        self.project_dir = project_dir
        self.project_name = project_name
        self.config = config or {}

        self.guard = None
        self.cleanup = None
        self.analyzer = None
        self.auditor = None
        self.executor = None
        self.learning = None
        self.tracker = None

    def run(self, max_cycles: int = 10, budget_limit: float = 2.00,
            timeout_minutes: int = 30, archive_on_success: bool = True,
            job_id: str = "", external_guard=None) -> SupervisorResult:
        start_time = time.time()
        result = SupervisorResult()

        if not job_id:
            job_id = f"supervised_{self.project_name}_{int(time.time())}"

        if external_guard:
            self.guard = external_guard
        else:
            self.guard = SafetyGuard(
                job_id=job_id,
                budget_limit=budget_limit,
                timeout_minutes=timeout_minutes
            )

        self.cleanup = PreBuildCleanup(self.project_dir)
        self.analyzer = ErrorAnalyzer(self.project_dir)
        self.auditor = ErrorAuditor()
        self.executor = RepairExecutor(self.project_dir, safety_guard=self.guard)
        self.learning = LearningDB()
        self.tracker = ProgressTracker()

        self.learning.record_run()

        print(f"\n{'='*60}")
        print(f"[Supervisor] Starting: {self.project_name}")
        print(f"[Supervisor] Budget: ${budget_limit}, Timeout: {timeout_minutes}min, Max cycles: {max_cycles}")
        print(f"{'='*60}\n")

        try:
            # Phase 1: Pre-Build Cleanup
            print(f"[Supervisor] Phase 1: Pre-Build Cleanup")
            cleanup_report = self.cleanup.run_all()
            result.pre_build_fixed = cleanup_report.total_fixes
            print(f"[Supervisor] Pre-Build: {cleanup_report.total_fixes} fixes applied")

            # Phase 2: xcodegen
            print(f"\n[Supervisor] Phase 2: xcodegen")
            if not self._run_xcodegen():
                result.status = "ERROR"
                result.reason = "xcodegen failed"
                result.duration_seconds = time.time() - start_time
                return result

            # Phase 3: First compile
            print(f"\n[Supervisor] Phase 3: First compile")
            errors = self._compile()
            result.start_errors = len(errors)
            print(f"[Supervisor] Initial errors: {len(errors)}")

            if not errors:
                result.status = "SUCCESS"
                result.build_succeeded = True
                result.end_errors = 0
            else:
                # Phase 3b: Import Mapping
                print(f"\n[Supervisor] Phase 3b: Import Mapping")
                imports_added = self.cleanup.run_import_mapping(errors)
                result.import_mapping_fixed = imports_added
                print(f"[Supervisor] Import mapping: {imports_added} imports added")

                if imports_added > 0:
                    errors = self._compile()
                    print(f"[Supervisor] After import fix: {len(errors)} errors")

                self.auditor.set_baseline(errors)

                # Phase 4: Repair Loop
                print(f"\n[Supervisor] Phase 4: Repair Loop")

                best_errors = len(errors)
                self._save_checkpoint(f"Baseline: {len(errors)} errors")
                regen_disabled = False

                for cycle in range(max_cycles):
                    if not errors:
                        break

                    if not self.guard.check():
                        result.status = "STOPPED"
                        result.reason = self.guard.stop_reason
                        break

                    print(f"\n[Supervisor] --- Cycle {cycle + 1}/{max_cycles} ({len(errors)} errors) ---")
                    self.tracker.start_cycle(len(errors))
                    cycle_cost = 0.0

                    analysis = self.analyzer.analyze(errors)
                    print(f"[Supervisor] Analysis: {analysis.overall_strategy}, {len(analysis.clusters)} clusters")

                    trend = self.tracker.get_trend()
                    no_progress = self.tracker.get_no_progress_count()

                    if trend == "oscillating":
                        print(f"[Supervisor] Oscillation detected -> rolling back")
                        regen_disabled = True
                        self._rollback_checkpoint()
                        errors = self._compile()
                        self.tracker.end_cycle(len(errors), 0)
                        continue

                    if trend == "plateau" and no_progress >= 3:
                        if analysis.clusters:
                            top = analysis.clusters[0]
                            if top.recommended_action != "deep_repair":
                                top.recommended_action = "deep_repair"
                                print(f"[Supervisor] Plateau -> escalating to deep_repair on {top.file_path}")

                    if no_progress >= 5:
                        result.status = "STOPPED"
                        result.reason = f"No progress for {no_progress} cycles"
                        self.tracker.end_cycle(len(errors), 0)
                        break

                    # Execute repairs
                    for cluster in analysis.clusters:
                        if cluster.error_count == 0:
                            continue

                        if regen_disabled and cluster.recommended_action in ("regenerate",):
                            cluster.recommended_action = "repair_tier2"

                        repair_result = self.executor.execute(cluster)
                        cycle_cost += repair_result.cost

                        self.learning.record(
                            cluster.error_pattern or "unknown",
                            cluster.recommended_action,
                            repair_result.success
                        )

                    new_errors = self._compile()

                    diff = self.auditor.diff(new_errors)
                    self.auditor.print_diff(diff, cycle + 1)

                    if diff.regression_detected:
                        print(f"[Supervisor] REGRESSION: {diff.new_count} new from {diff.regression_files[:3]}")
                        self._rollback_checkpoint()
                        new_errors = self._compile()
                        self.tracker.end_cycle(len(new_errors), cycle_cost)
                        errors = new_errors
                        continue

                    if len(new_errors) < best_errors:
                        best_errors = len(new_errors)
                        self._save_checkpoint(f"Cycle {cycle + 1}: {len(new_errors)} errors")
                        self.auditor.update_baseline(new_errors)
                        print(f"[Supervisor] New best: {len(new_errors)} errors (saved)")

                    self.tracker.end_cycle(len(new_errors), cycle_cost)
                    errors = new_errors
                    result.error_trend.append(len(errors))

                result.cycles_used = len(self.tracker.cycles)
                result.end_errors = len(errors) if errors else 0
                result.compile_repair_fixed = max(
                    0,
                    result.start_errors - result.end_errors
                    - result.pre_build_fixed - result.import_mapping_fixed
                )

                if not errors:
                    result.status = "SUCCESS"
                    result.build_succeeded = True
                elif result.status == "PENDING":
                    result.status = "MAX_CYCLES"
                    result.reason = f"Reached {max_cycles} cycles, best: {best_errors} errors"

            # Phase 5: Archive
            if result.build_succeeded and archive_on_success:
                print(f"\n[Supervisor] Phase 5: Archive")
                archive_result = self._archive()
                if archive_result:
                    result.archive_succeeded = True
                    result.archive_path = archive_result
                    print(f"[Supervisor] ARCHIVE SUCCEEDED: {archive_result}")
                else:
                    print(f"[Supervisor] Archive failed")

        except Exception as e:
            result.status = "ERROR"
            result.reason = str(e)
            print(f"[Supervisor] ERROR: {e}")
            import traceback
            traceback.print_exc()

        result.duration_seconds = time.time() - start_time
        result.total_cost = self.guard.total_cost if self.guard else 0

        print(f"\n{'='*60}")
        print(f"[Supervisor] RESULT: {result.status}")
        print(f"[Supervisor] Errors: {result.start_errors} -> {result.end_errors}")
        print(f"[Supervisor] Pre-build: {result.pre_build_fixed}, Imports: {result.import_mapping_fixed}, Repair: {result.compile_repair_fixed}")
        print(f"[Supervisor] Cycles: {result.cycles_used}, Cost: ${result.total_cost:.2f}, Time: {result.duration_seconds:.0f}s")
        if result.archive_succeeded:
            print(f"[Supervisor] Archive: {result.archive_path}")
        if result.reason:
            print(f"[Supervisor] Reason: {result.reason}")
        print(f"{'='*60}\n")

        try:
            self.tracker.print_summary()
            self.guard.print_summary()
            self.learning.print_report()
        except Exception:
            pass

        self._save_report(result)
        return result

    # ── Xcode Operations ──────────────────────────────────

    def _run_xcodegen(self) -> bool:
        project_yml = os.path.join(self.project_dir, "project.yml")
        if not os.path.exists(project_yml):
            self._generate_project_yml()

        try:
            result = subprocess.run(
                ["xcodegen", "generate"],
                cwd=self.project_dir,
                capture_output=True,
                text=True,
                timeout=60
            )
            if result.returncode == 0:
                print(f"[Supervisor] xcodegen: OK")
                return True
            print(f"[Supervisor] xcodegen failed: {result.stderr[:200]}")
            return False
        except subprocess.TimeoutExpired:
            print(f"[Supervisor] xcodegen timeout")
            return False
        except FileNotFoundError:
            print(f"[Supervisor] xcodegen not found - checking for existing xcodeproj")
            for item in os.listdir(self.project_dir):
                if item.endswith(".xcodeproj"):
                    return True
            return False

    def _generate_project_yml(self):
        name = self.project_name.lower().replace(" ", "").replace("-", "")

        source_dirs = []
        for item in os.listdir(self.project_dir):
            if os.path.isdir(os.path.join(self.project_dir, item)):
                if item not in ('build', 'DerivedData', '.git', 'quarantine',
                                'Tests', 'test', 'tests', '.build', 'Pods'):
                    swift_count = len(list(Path(self.project_dir, item).rglob("*.swift")))
                    if swift_count > 0:
                        source_dirs.append(item)

        root_swift = list(Path(self.project_dir).glob("*.swift"))
        if root_swift:
            source_dirs.insert(0, ".")

        if not source_dirs:
            source_dirs = ["."]

        sources = "\n".join(f'      - path: "{d}"' for d in source_dirs)

        yml = f"""name: {name}
options:
  bundleIdPrefix: com.dai-core
  deploymentTarget:
    iOS: "17.0"
targets:
  {name}:
    type: application
    platform: iOS
    sources:
{sources}
    settings:
      PRODUCT_BUNDLE_IDENTIFIER: com.dai-core.{name}
      SWIFT_VERSION: "5.9"
      CODE_SIGN_IDENTITY: "-"
      CODE_SIGNING_ALLOWED: "NO"
      GENERATE_INFOPLIST_FILE: YES
"""

        with open(os.path.join(self.project_dir, "project.yml"), 'w') as f:
            f.write(yml)
        print(f"[Supervisor] Generated project.yml ({len(source_dirs)} source dirs)")

    def _compile(self) -> list:
        xcodeproj = None
        for item in os.listdir(self.project_dir):
            if item.endswith(".xcodeproj"):
                xcodeproj = os.path.join(self.project_dir, item)
                break

        if not xcodeproj:
            print(f"[Supervisor] No .xcodeproj found")
            return []

        scheme = self._get_scheme(xcodeproj)
        if not scheme:
            print(f"[Supervisor] No scheme found")
            return []

        try:
            result = subprocess.run(
                [
                    "xcodebuild", "build",
                    "-project", xcodeproj,
                    "-scheme", scheme,
                    "-destination", "generic/platform=iOS Simulator",
                    "CODE_SIGN_IDENTITY=-",
                    "CODE_SIGNING_ALLOWED=NO"
                ],
                capture_output=True,
                text=True,
                timeout=300,
                cwd=self.project_dir
            )
        except subprocess.TimeoutExpired:
            print(f"[Supervisor] Build timeout (300s)")
            return []
        except Exception as e:
            print(f"[Supervisor] Build exception: {e}")
            return []

        errors = []
        error_pattern = re.compile(r'(.+?\.swift):(\d+):(\d+): error: (.+)')

        for line in (result.stderr + "\n" + result.stdout).split('\n'):
            match = error_pattern.search(line)
            if match:
                errors.append({
                    "file": match.group(1),
                    "line": int(match.group(2)),
                    "column": int(match.group(3)),
                    "message": match.group(4)
                })

        return errors

    def _get_scheme(self, xcodeproj: str) -> str:
        try:
            result = subprocess.run(
                ["xcodebuild", "-list", "-project", xcodeproj, "-json"],
                capture_output=True, text=True, timeout=30
            )
            if result.returncode == 0:
                data = json.loads(result.stdout)
                schemes = data.get("project", {}).get("schemes", [])
                if schemes:
                    return schemes[0]
        except Exception:
            pass
        return self.project_name.lower().replace(" ", "").replace("-", "")

    def _archive(self) -> str:
        xcodeproj = None
        for item in os.listdir(self.project_dir):
            if item.endswith(".xcodeproj"):
                xcodeproj = os.path.join(self.project_dir, item)
                break

        if not xcodeproj:
            return ""

        scheme = self._get_scheme(xcodeproj)
        archive_path = os.path.join(self.project_dir, "build", f"{self.project_name}.xcarchive")

        try:
            result = subprocess.run(
                [
                    "xcodebuild", "archive",
                    "-project", xcodeproj,
                    "-scheme", scheme,
                    "-configuration", "Release",
                    "-archivePath", archive_path,
                    "-destination", "generic/platform=iOS",
                    "CODE_SIGN_IDENTITY=-",
                    "CODE_SIGNING_ALLOWED=NO"
                ],
                capture_output=True, text=True,
                timeout=600,
                cwd=self.project_dir
            )

            if result.returncode == 0 and os.path.exists(archive_path):
                return archive_path
            print(f"[Supervisor] Archive error: {result.stderr[-200:]}")
            return ""
        except Exception as e:
            print(f"[Supervisor] Archive exception: {e}")
            return ""

    # ── Git Operations ────────────────────────────────────

    def _save_checkpoint(self, message: str):
        try:
            subprocess.run(["git", "add", "-A"], cwd=self.project_dir,
                           capture_output=True, timeout=120)
            subprocess.run(["git", "commit", "-m", f"[Mac Supervisor] {message}"],
                           cwd=self.project_dir, capture_output=True, timeout=120)
        except Exception as e:
            print(f"[Supervisor] Checkpoint failed: {e}")

    def _rollback_checkpoint(self):
        try:
            subprocess.run(["git", "checkout", "--", "."], cwd=self.project_dir,
                           capture_output=True, timeout=120)
            subprocess.run(["git", "clean", "-fd"], cwd=self.project_dir,
                           capture_output=True, timeout=120)
        except Exception as e:
            print(f"[Supervisor] Rollback failed: {e}")

    # ── Reporting ─────────────────────────────────────────

    def _save_report(self, result: SupervisorResult):
        try:
            reports_dir = Path(__file__).parent / "reports"
            reports_dir.mkdir(parents=True, exist_ok=True)
            report_file = reports_dir / f"{self.project_name}_{int(time.time())}.json"
            with open(report_file, "w") as f:
                json.dump(result.to_dict(), f, indent=2)
            print(f"[Supervisor] Report saved: {report_file}")
        except Exception as e:
            print(f"[Supervisor] Report save failed: {e}")
