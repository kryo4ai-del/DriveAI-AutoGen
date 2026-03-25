"""QA TestRunner — platform-specific build verification and test execution.

Handles two phases of the QA pipeline:
  Phase A: BuildVerifier — compile/build verification per platform
  Phase C: TestRunner — test execution per platform

Platform support:
  iOS     — Mac Bridge (Git-queue commands to _commands/pending/)
  Android — Gradle (gradle assembleDebug / gradle test)
  Web     — npm install + tsc --noEmit / npx jest --json
  Unity   — Stub (not yet implemented)
"""

import json
import shutil
import subprocess
import sys
import time
import uuid
import xml.etree.ElementTree as ET
from dataclasses import dataclass, field
from datetime import datetime, timezone
from pathlib import Path

from factory.qa.config import QAConfig


# ---------------------------------------------------------------------------
# Dataclasses
# ---------------------------------------------------------------------------

@dataclass
class BuildResult:
    """Result of a build verification pass."""
    success: bool
    status: str = "PASSED"           # PASSED, FAILED, SKIPPED, TIMEOUT, ERROR
    compiler_output: str = ""        # Raw compiler output on failure
    error_lines: list = field(default_factory=list)
    warnings_count: int = 0
    duration_seconds: float = 0.0
    reason: str = ""                 # For SKIPPED/TIMEOUT/ERROR


@dataclass
class TestResult:
    """Result of a test execution pass."""
    status: str = "PASSED"           # PASSED, FAILED, SKIPPED, ERROR
    tests_total: int = 0
    tests_passed: int = 0
    tests_failed: int = 0
    tests_skipped: int = 0
    failure_rate: float = 0.0
    coverage_insufficient: bool = False
    test_time_seconds: float = 0.0
    failures: list = field(default_factory=list)   # [{"test_name": str, "error_message": str}]
    reason: str = ""                 # For SKIPPED/ERROR
    has_crashes: bool = False


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

_REPO_ROOT = Path(__file__).resolve().parent.parent.parent
_COMMANDS_DIR = _REPO_ROOT / "_commands"
_IS_WINDOWS = sys.platform == "win32"

_CRASH_MARKERS = ("crash", "sigabrt", "sigsegv", "exc_bad_access")


def _check_crashes(output: str) -> bool:
    """Check if output contains crash indicators."""
    lower = output.lower()
    return any(m in lower for m in _CRASH_MARKERS)


def _npm_cmd() -> str:
    return "npm.cmd" if _IS_WINDOWS else "npm"


def _npx_cmd() -> str:
    return "npx.cmd" if _IS_WINDOWS else "npx"


def _find_gradle(project_dir: Path) -> str | None:
    """Find a usable Gradle executable."""
    # gradlew in project dir (preferred)
    gradlew = "gradlew.bat" if _IS_WINDOWS else "gradlew"
    local = project_dir / gradlew
    if local.is_file():
        return str(local)
    # system gradle
    gradle_name = "gradle.bat" if _IS_WINDOWS else "gradle"
    found = shutil.which(gradle_name)
    if found:
        return found
    return None


def _send_mac_command(cmd_type: str, project: str, params: dict | None = None) -> str | None:
    """Write a command JSON to _commands/pending/. Returns command ID or None."""
    pending = _COMMANDS_DIR / "pending"
    if not _COMMANDS_DIR.exists():
        return None
    pending.mkdir(parents=True, exist_ok=True)

    cmd_id = f"qa_{datetime.now(timezone.utc).strftime('%Y%m%d_%H%M%S')}_{uuid.uuid4().hex[:6]}"
    cmd = {
        "id": cmd_id,
        "type": cmd_type,
        "project": project,
        "params": params or {},
        "requested_by": "qa_department",
        "timestamp": datetime.now(timezone.utc).isoformat(),
    }
    path = pending / f"{cmd_id}.json"
    path.write_text(json.dumps(cmd, indent=2), encoding="utf-8")

    # Git add + commit + push
    try:
        subprocess.run(["git", "add", str(path)], cwd=str(_REPO_ROOT),
                        capture_output=True, timeout=15)
        subprocess.run(["git", "commit", "-m", f"[QA] Mac command: {cmd_type} for {project}"],
                        cwd=str(_REPO_ROOT), capture_output=True, timeout=15)
        subprocess.run(["git", "push"], cwd=str(_REPO_ROOT),
                        capture_output=True, timeout=30)
    except Exception as e:
        print(f"[QA] WARNING: Git push failed: {e}")

    return cmd_id


def _poll_mac_result(cmd_id: str, timeout_seconds: int, poll_interval: int = 10) -> dict | None:
    """Poll _commands/completed/ for a result. Returns result dict or None on timeout."""
    completed = _COMMANDS_DIR / "completed"
    deadline = time.time() + timeout_seconds

    while time.time() < deadline:
        # Git pull to get latest
        try:
            subprocess.run(["git", "pull", "--rebase", "--quiet"],
                            cwd=str(_REPO_ROOT), capture_output=True, timeout=30)
        except Exception:
            pass

        result_path = completed / f"{cmd_id}.json"
        if result_path.exists():
            try:
                return json.loads(result_path.read_text(encoding="utf-8"))
            except (json.JSONDecodeError, OSError):
                return None

        remaining = int(deadline - time.time())
        print(f"[QA] Waiting for Mac... ({remaining}s remaining)")
        time.sleep(poll_interval)

    return None


# ---------------------------------------------------------------------------
# BuildVerifier
# ---------------------------------------------------------------------------

class BuildVerifier:
    """Platform-specific build verification (Phase A of QA pipeline)."""

    def __init__(self, project_name: str, platform: str, project_dir: str,
                 config: QAConfig | None = None) -> None:
        self.project_name = project_name
        self.platform = platform
        self.project_dir = Path(project_dir)
        self.config = config or QAConfig()

    def verify(self) -> BuildResult:
        """Run platform-specific build verification."""
        print(f"[QA BuildVerifier] {self.platform} build for {self.project_name}")

        if self.platform == "ios":
            return self._verify_ios()
        elif self.platform == "android":
            return self._verify_android()
        elif self.platform == "web":
            return self._verify_web()
        elif self.platform == "unity":
            return BuildResult(success=False, status="SKIPPED",
                               reason="Unity build not yet implemented")
        else:
            return BuildResult(success=False, status="ERROR",
                               reason=f"Unknown platform: {self.platform}")

    # --- iOS ---

    def _verify_ios(self) -> BuildResult:
        """Send build_ios command to Mac via Git-queue."""
        if not _COMMANDS_DIR.exists():
            return BuildResult(success=False, status="SKIPPED",
                               reason="Mac Bridge not available (_commands/ dir missing)")

        start = time.time()
        print("[QA BuildVerifier] Sending build_ios to Mac...")
        cmd_id = _send_mac_command("build_ios", self.project_name,
                                   {"scheme": self.project_name})
        if not cmd_id:
            return BuildResult(success=False, status="SKIPPED",
                               reason="Failed to send Mac command")

        print(f"[QA BuildVerifier] Polling for result (timeout: {self.config.build_timeout_seconds}s)...")
        result = _poll_mac_result(cmd_id, self.config.build_timeout_seconds)
        elapsed = time.time() - start

        if result is None:
            return BuildResult(success=False, status="TIMEOUT",
                               reason="Mac Bridge build timeout",
                               duration_seconds=elapsed)

        status = result.get("status", "error")
        inner = result.get("result", {})

        if status == "success" and inner.get("build_succeeded", False):
            print(f"[QA BuildVerifier] iOS build PASSED ({elapsed:.0f}s)")
            return BuildResult(success=True, status="PASSED",
                               duration_seconds=elapsed)

        errors = inner.get("error_details", [])
        error_lines = [e.get("message", "") for e in errors] if isinstance(errors, list) else []
        output = inner.get("error", json.dumps(inner, indent=2))

        print(f"[QA BuildVerifier] iOS build FAILED: {len(error_lines)} errors")
        return BuildResult(success=False, status="FAILED",
                           compiler_output=output,
                           error_lines=error_lines,
                           duration_seconds=elapsed)

    # --- Android ---

    def _verify_android(self) -> BuildResult:
        """Run gradle assembleDebug."""
        gradle = _find_gradle(self.project_dir)
        if not gradle:
            return BuildResult(success=False, status="SKIPPED",
                               reason="Gradle not found")

        start = time.time()
        print(f"[QA BuildVerifier] Running: {gradle} assembleDebug")
        try:
            proc = subprocess.run(
                [gradle, "assembleDebug"],
                cwd=str(self.project_dir),
                capture_output=True, text=True,
                timeout=self.config.build_timeout_seconds,
            )
        except subprocess.TimeoutExpired:
            return BuildResult(success=False, status="TIMEOUT",
                               reason=f"Gradle build timeout ({self.config.build_timeout_seconds}s)",
                               duration_seconds=time.time() - start)
        except (FileNotFoundError, OSError) as e:
            return BuildResult(success=False, status="SKIPPED",
                               reason=f"Gradle execution failed: {e}")

        elapsed = time.time() - start
        combined = proc.stderr + proc.stdout
        error_lines = [l.strip() for l in combined.splitlines() if "error:" in l.lower()]
        warn_count = sum(1 for l in combined.splitlines() if "warning:" in l.lower())

        if proc.returncode == 0:
            print(f"[QA BuildVerifier] Android build PASSED ({elapsed:.0f}s, {warn_count} warnings)")
            return BuildResult(success=True, status="PASSED",
                               warnings_count=warn_count,
                               duration_seconds=elapsed)

        print(f"[QA BuildVerifier] Android build FAILED: {len(error_lines)} errors")
        return BuildResult(success=False, status="FAILED",
                           compiler_output=combined[-2000:],
                           error_lines=error_lines,
                           warnings_count=warn_count,
                           duration_seconds=elapsed)

    # --- Web ---

    def _verify_web(self) -> BuildResult:
        """Run npm install + tsc --noEmit."""
        npm = _npm_cmd()
        npx = _npx_cmd()

        if not shutil.which(npm):
            return BuildResult(success=False, status="SKIPPED",
                               reason="npm not found")

        start = time.time()

        # Step 1: npm install
        print("[QA BuildVerifier] Running: npm install")
        try:
            install = subprocess.run(
                [npm, "install"],
                cwd=str(self.project_dir),
                capture_output=True, text=True, timeout=120,
            )
        except subprocess.TimeoutExpired:
            return BuildResult(success=False, status="TIMEOUT",
                               reason="npm install timeout (120s)",
                               duration_seconds=time.time() - start)
        except (FileNotFoundError, OSError) as e:
            return BuildResult(success=False, status="SKIPPED",
                               reason=f"npm execution failed: {e}")

        if install.returncode != 0:
            return BuildResult(success=False, status="FAILED",
                               reason="npm install failed",
                               compiler_output=install.stderr[:2000],
                               duration_seconds=time.time() - start)

        # Step 2: tsc --noEmit
        print("[QA BuildVerifier] Running: npx tsc --noEmit")
        try:
            tsc = subprocess.run(
                [npx, "tsc", "--noEmit"],
                cwd=str(self.project_dir),
                capture_output=True, text=True,
                timeout=self.config.build_timeout_seconds,
            )
        except subprocess.TimeoutExpired:
            return BuildResult(success=False, status="TIMEOUT",
                               reason="tsc timeout",
                               duration_seconds=time.time() - start)
        except (FileNotFoundError, OSError) as e:
            return BuildResult(success=False, status="ERROR",
                               reason=f"tsc execution failed: {e}")

        elapsed = time.time() - start
        combined = tsc.stdout + tsc.stderr
        error_lines = [l.strip() for l in combined.splitlines() if "error " in l.lower()]

        if tsc.returncode == 0:
            print(f"[QA BuildVerifier] Web build PASSED ({elapsed:.0f}s)")
            return BuildResult(success=True, status="PASSED",
                               duration_seconds=elapsed)

        print(f"[QA BuildVerifier] Web build FAILED: {len(error_lines)} errors")
        return BuildResult(success=False, status="FAILED",
                           compiler_output=combined[-2000:],
                           error_lines=error_lines,
                           duration_seconds=elapsed)


# ---------------------------------------------------------------------------
# TestRunner
# ---------------------------------------------------------------------------

class TestRunner:
    """Platform-specific test execution (Phase C of QA pipeline)."""

    def __init__(self, platform: str, project_dir: str,
                 project_name: str = "", config: QAConfig | None = None) -> None:
        self.platform = platform
        self.project_dir = Path(project_dir)
        self.project_name = project_name
        self.config = config or QAConfig()

    def run(self) -> TestResult:
        """Run platform-specific tests."""
        print(f"[QA TestRunner] {self.platform} tests for {self.project_name or self.project_dir.name}")

        if self.platform == "ios":
            return self._run_ios_tests()
        elif self.platform == "android":
            return self._run_android_tests()
        elif self.platform == "web":
            return self._run_web_tests()
        elif self.platform == "unity":
            return TestResult(status="SKIPPED",
                              reason="Unity test runner not yet implemented")
        else:
            return TestResult(status="ERROR",
                              reason=f"Unknown platform: {self.platform}")

    # --- iOS ---

    def _run_ios_tests(self) -> TestResult:
        """Send run_tests command to Mac via Git-queue."""
        if not _COMMANDS_DIR.exists():
            return TestResult(status="SKIPPED",
                              reason="Mac Bridge not available")

        start = time.time()
        print("[QA TestRunner] Sending run_tests to Mac...")
        cmd_id = _send_mac_command("run_tests", self.project_name,
                                   {"suite": "golden_gates"})
        if not cmd_id:
            return TestResult(status="ERROR",
                              reason="Failed to send Mac command")

        result = _poll_mac_result(cmd_id, self.config.test_timeout_seconds)
        elapsed = time.time() - start

        if result is None:
            return TestResult(status="ERROR", reason="Test timeout",
                              test_time_seconds=elapsed)

        status = result.get("status", "error")
        inner = result.get("result", {})

        passed = inner.get("tests_passed", 0)
        failed = inner.get("tests_failed", 0)
        total = passed + failed
        rate = failed / total if total > 0 else 0.0
        raw_output = json.dumps(inner)

        tr = TestResult(
            status="PASSED" if status == "success" and failed == 0 else "FAILED",
            tests_total=total,
            tests_passed=passed,
            tests_failed=failed,
            failure_rate=round(rate, 3),
            test_time_seconds=inner.get("test_time_seconds", elapsed),
            has_crashes=_check_crashes(raw_output),
        )

        if total == 0:
            tr.coverage_insufficient = True

        print(f"[QA TestRunner] iOS tests: {passed} passed, {failed} failed")
        return tr

    # --- Android ---

    def _run_android_tests(self) -> TestResult:
        """Run gradle test and parse JUnit XML results."""
        gradle = _find_gradle(self.project_dir)
        if not gradle:
            return TestResult(status="SKIPPED", reason="Gradle not found")

        start = time.time()
        print(f"[QA TestRunner] Running: {gradle} test")
        try:
            proc = subprocess.run(
                [gradle, "test"],
                cwd=str(self.project_dir),
                capture_output=True, text=True,
                timeout=self.config.test_timeout_seconds,
            )
        except subprocess.TimeoutExpired:
            return TestResult(status="ERROR",
                              reason=f"Gradle test timeout ({self.config.test_timeout_seconds}s)",
                              test_time_seconds=time.time() - start)
        except (FileNotFoundError, OSError) as e:
            return TestResult(status="SKIPPED", reason=f"Gradle failed: {e}")

        elapsed = time.time() - start
        combined = proc.stderr + proc.stdout

        # Try to parse JUnit XML results
        tr = self._parse_junit_xml()
        if tr is not None:
            tr.test_time_seconds = elapsed
            tr.has_crashes = _check_crashes(combined)
            print(f"[QA TestRunner] Android tests: {tr.tests_passed} passed, {tr.tests_failed} failed")
            return tr

        # No XML results — fallback to exit code
        if proc.returncode == 0:
            return TestResult(status="PASSED", test_time_seconds=elapsed,
                              coverage_insufficient=True)

        return TestResult(status="FAILED", test_time_seconds=elapsed,
                          reason="Gradle test failed (no XML results)",
                          has_crashes=_check_crashes(combined))

    def _parse_junit_xml(self) -> TestResult | None:
        """Parse JUnit XML from build/test-results/. Returns None if not found."""
        results_dir = self.project_dir / "build" / "test-results"
        if not results_dir.is_dir():
            return None

        total = 0
        failed = 0
        failures_list = []

        for xml_file in results_dir.rglob("*.xml"):
            try:
                tree = ET.parse(xml_file)
                for tc in tree.iter("testcase"):
                    total += 1
                    fail_el = tc.find("failure")
                    err_el = tc.find("error")
                    if fail_el is not None or err_el is not None:
                        failed += 1
                        msg = ""
                        if fail_el is not None:
                            msg = fail_el.get("message", "")
                        elif err_el is not None:
                            msg = err_el.get("message", "")
                        failures_list.append({
                            "test_name": f"{tc.get('classname', '')}.{tc.get('name', '')}",
                            "error_message": msg[:500],
                        })
            except (ET.ParseError, OSError):
                continue

        if total == 0:
            return None

        passed = total - failed
        rate = failed / total if total > 0 else 0.0
        return TestResult(
            status="PASSED" if failed == 0 else "FAILED",
            tests_total=total,
            tests_passed=passed,
            tests_failed=failed,
            failure_rate=round(rate, 3),
            failures=failures_list,
        )

    # --- Web ---

    def _run_web_tests(self) -> TestResult:
        """Run npx jest --json and parse output."""
        npx = _npx_cmd()
        if not shutil.which(npx):
            return TestResult(status="SKIPPED", reason="npx not found")

        start = time.time()
        print("[QA TestRunner] Running: npx jest --json")
        try:
            proc = subprocess.run(
                [npx, "jest", "--json", "--forceExit"],
                cwd=str(self.project_dir),
                capture_output=True, text=True,
                timeout=self.config.test_timeout_seconds,
            )
        except subprocess.TimeoutExpired:
            return TestResult(status="ERROR",
                              reason=f"Jest timeout ({self.config.test_timeout_seconds}s)",
                              test_time_seconds=time.time() - start)
        except (FileNotFoundError, OSError) as e:
            return TestResult(status="SKIPPED", reason=f"Jest failed: {e}")

        elapsed = time.time() - start
        combined = proc.stdout + proc.stderr

        # Parse JSON output
        try:
            data = json.loads(proc.stdout)
        except json.JSONDecodeError:
            # Jest sometimes prefixes non-JSON text before the JSON blob
            try:
                json_start = proc.stdout.index("{")
                data = json.loads(proc.stdout[json_start:])
            except (ValueError, json.JSONDecodeError):
                if proc.returncode == 0:
                    return TestResult(status="PASSED", test_time_seconds=elapsed,
                                     coverage_insufficient=True)
                return TestResult(status="ERROR",
                                  reason="Failed to parse Jest output",
                                  test_time_seconds=elapsed)

        total = data.get("numTotalTests", 0)
        passed = data.get("numPassedTests", 0)
        failed = data.get("numFailedTests", 0)
        skipped = data.get("numPendingTests", 0)
        rate = failed / total if total > 0 else 0.0

        failures_list = []
        for suite in data.get("testResults", []):
            for ar in suite.get("assertionResults", []):
                if ar.get("status") == "failed":
                    msgs = ar.get("failureMessages", [])
                    failures_list.append({
                        "test_name": ar.get("fullName", ar.get("title", "unknown")),
                        "error_message": (msgs[0][:500] if msgs else ""),
                    })

        tr = TestResult(
            status="PASSED" if failed == 0 else "FAILED",
            tests_total=total,
            tests_passed=passed,
            tests_failed=failed,
            tests_skipped=skipped,
            failure_rate=round(rate, 3),
            test_time_seconds=elapsed,
            failures=failures_list,
            has_crashes=_check_crashes(combined),
            coverage_insufficient=(total == 0),
        )

        print(f"[QA TestRunner] Web tests: {passed} passed, {failed} failed, {skipped} skipped")
        return tr
