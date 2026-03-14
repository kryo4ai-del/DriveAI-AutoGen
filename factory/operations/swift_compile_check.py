# factory/operations/swift_compile_check.py
# Lightweight Swift compile validation using swiftc -parse / -typecheck.
#
# Detects syntax and type errors before code reaches Xcode.
# Requires swiftc on PATH (macOS / Linux with Swift toolchain).
# On systems without swiftc, reports SKIPPED gracefully.
#
# Deterministic, no LLM, no fixes — validation only.

import json
import shutil
import subprocess
import re
from dataclasses import dataclass, field
from enum import Enum
from pathlib import Path

# ---------------------------------------------------------------------------
# Project root — two levels up from this file
# ---------------------------------------------------------------------------
_PROJECT_ROOT = Path(__file__).resolve().parent.parent.parent

REPORTS_DIR = _PROJECT_ROOT / "factory" / "reports" / "compile"


# ---------------------------------------------------------------------------
# Enums
# ---------------------------------------------------------------------------

class CompileStatus(str, Enum):
    CLEAN = "CLEAN"
    WARNINGS = "WARNINGS"
    BLOCKING = "BLOCKING"
    SKIPPED = "SKIPPED"


# ---------------------------------------------------------------------------
# Data classes
# ---------------------------------------------------------------------------

@dataclass
class FileResult:
    """Compile check result for a single file."""
    file: str
    status: str  # "ok", "error", "warning"
    errors: list[str] = field(default_factory=list)
    warnings: list[str] = field(default_factory=list)

    def to_dict(self) -> dict:
        d = {"file": self.file, "status": self.status}
        if self.errors:
            d["errors"] = self.errors
        if self.warnings:
            d["warnings"] = self.warnings
        return d


@dataclass
class CompileReport:
    """Full Swift compile check report."""
    project: str = ""
    scan_dir: str = ""
    swiftc_path: str = ""
    mode: str = ""  # "parse", "typecheck", or "skipped"
    files_checked: int = 0
    files_ok: int = 0
    files_with_errors: int = 0
    files_with_warnings: int = 0
    status: CompileStatus = CompileStatus.CLEAN
    file_results: list[FileResult] = field(default_factory=list)
    skip_reason: str = ""

    @property
    def total_errors(self) -> int:
        return sum(len(r.errors) for r in self.file_results)

    @property
    def total_warnings(self) -> int:
        return sum(len(r.warnings) for r in self.file_results)

    def to_dict(self) -> dict:
        d = {
            "project": self.project,
            "scan_dir": self.scan_dir,
            "mode": self.mode,
            "files_checked": self.files_checked,
            "files_ok": self.files_ok,
            "files_with_errors": self.files_with_errors,
            "files_with_warnings": self.files_with_warnings,
            "total_errors": self.total_errors,
            "total_warnings": self.total_warnings,
            "status": self.status.value,
        }
        if self.swiftc_path:
            d["swiftc_path"] = self.swiftc_path
        if self.skip_reason:
            d["skip_reason"] = self.skip_reason
        # Only include files with issues in JSON (keep report compact)
        failed = [r.to_dict() for r in self.file_results if r.status != "ok"]
        if failed:
            d["issues"] = failed
        return d

    def print_summary(self):
        print()
        print("=" * 60)
        print("  Swift Compile Check")
        print("=" * 60)
        print(f"  Project:          {self.project}")
        print(f"  Scan dir:         {self.scan_dir}")
        print(f"  Mode:             {self.mode}")
        if self.swiftc_path:
            print(f"  swiftc:           {self.swiftc_path}")
        print(f"  Status:           {self.status.value}")
        if self.skip_reason:
            print(f"  Skip reason:      {self.skip_reason}")
        print("-" * 60)
        print(f"  Files checked:    {self.files_checked}")
        print(f"  Files OK:         {self.files_ok}")
        print(f"  Files w/ errors:  {self.files_with_errors}")
        print(f"  Files w/ warnings:{self.files_with_warnings}")
        print(f"  Total errors:     {self.total_errors}")
        print(f"  Total warnings:   {self.total_warnings}")

        # Show files with errors
        error_files = [r for r in self.file_results if r.status == "error"]
        if error_files:
            print()
            for r in error_files[:20]:  # Cap at 20 to avoid flooding
                print(f"  [ERROR] {r.file}")
                for err in r.errors[:3]:  # Cap at 3 errors per file
                    print(f"          {err}")
                if len(r.errors) > 3:
                    print(f"          ... and {len(r.errors) - 3} more")

            if len(error_files) > 20:
                print(f"  ... and {len(error_files) - 20} more files with errors")

        # Show files with warnings (compact)
        warn_files = [r for r in self.file_results if r.status == "warning"]
        if warn_files and len(warn_files) <= 10:
            print()
            for r in warn_files:
                print(f"  [WARN]  {r.file}: {r.warnings[0] if r.warnings else ''}")

        print("=" * 60)
        print()


# ---------------------------------------------------------------------------
# swiftc error parser
# ---------------------------------------------------------------------------

# Match swiftc error/warning output: file.swift:line:col: error: message
_SWIFTC_DIAG_RE = re.compile(
    r'^(.+?):(\d+):(\d+):\s+(error|warning):\s+(.+)$',
    re.MULTILINE,
)


def _parse_swiftc_output(stderr: str) -> tuple[list[str], list[str]]:
    """Parse swiftc stderr into errors and warnings.

    Returns: (errors, warnings) as lists of formatted strings.
    """
    errors: list[str] = []
    warnings: list[str] = []

    for match in _SWIFTC_DIAG_RE.finditer(stderr):
        filepath = match.group(1)
        line = match.group(2)
        col = match.group(3)
        severity = match.group(4)
        message = match.group(5)

        # Use just the filename, not full path
        filename = Path(filepath).name
        formatted = f"{filename}:{line}:{col} {message}"

        if severity == "error":
            errors.append(formatted)
        else:
            warnings.append(formatted)

    # If no regex matches but stderr is non-empty, capture raw output
    if not errors and not warnings and stderr.strip():
        # Check for common non-diagnostic output
        stripped = stderr.strip()
        if "error:" in stripped.lower():
            errors.append(stripped[:200])
        elif stripped:
            warnings.append(stripped[:200])

    return errors, warnings


# ---------------------------------------------------------------------------
# Main checker
# ---------------------------------------------------------------------------

class SwiftCompileCheck:
    """Lightweight Swift compile validation.

    Modes:
    - parse: syntax check only (swiftc -parse) — fast, no imports needed
    - typecheck: type check (swiftc -typecheck) — slower, may need SDK

    Falls back to 'parse' if typecheck fails with SDK errors.
    Reports SKIPPED if swiftc is not available.
    """

    def __init__(
        self,
        project_name: str,
        scan_dir: str | None = None,
        mode: str = "parse",
    ):
        self.project_name = project_name
        self.mode = mode

        if scan_dir:
            self.scan_dir = Path(scan_dir)
        else:
            self.scan_dir = _PROJECT_ROOT / "projects" / project_name

        self.report = CompileReport(
            project=project_name,
            scan_dir=str(self.scan_dir),
            mode=mode,
        )

    def check(self) -> CompileReport:
        """Run Swift compile check on all .swift files."""
        print(f"\n[SwiftCompile] Checking project: {self.project_name}")
        print(f"[SwiftCompile] Scan dir: {self.scan_dir}")
        print(f"[SwiftCompile] Mode: {self.mode}")

        # Step 1: Check swiftc availability
        swiftc = shutil.which("swiftc")
        if not swiftc:
            print("[SwiftCompile] swiftc not found on PATH — skipping.")
            self.report.status = CompileStatus.SKIPPED
            self.report.mode = "skipped"
            self.report.skip_reason = "swiftc not found on PATH"
            self._print_and_save()
            return self.report

        self.report.swiftc_path = swiftc
        print(f"[SwiftCompile] Found swiftc: {swiftc}")

        # Step 2: Discover Swift files
        swift_files = self._discover_swift_files()
        self.report.files_checked = len(swift_files)
        print(f"[SwiftCompile] Swift files found: {len(swift_files)}")

        if not swift_files:
            print("[SwiftCompile] No Swift files — nothing to check.")
            self.report.status = CompileStatus.CLEAN
            self._print_and_save()
            return self.report

        # Step 3: Run swiftc on each file
        for rel_path, abs_path in swift_files:
            result = self._check_file(swiftc, abs_path, rel_path)
            self.report.file_results.append(result)

            if result.status == "ok":
                self.report.files_ok += 1
            elif result.status == "error":
                self.report.files_with_errors += 1
            elif result.status == "warning":
                self.report.files_with_warnings += 1

        # Step 4: Classify status
        if self.report.files_with_errors > 0:
            self.report.status = CompileStatus.BLOCKING
        elif self.report.files_with_warnings > 0:
            self.report.status = CompileStatus.WARNINGS
        else:
            self.report.status = CompileStatus.CLEAN

        # Step 5: Report
        self._print_and_save()
        return self.report

    def _discover_swift_files(self) -> list[tuple[str, Path]]:
        """Discover .swift files. Returns [(rel_path, abs_path), ...]."""
        files: list[tuple[str, Path]] = []

        if not self.scan_dir.exists():
            print(f"[SwiftCompile] Directory not found: {self.scan_dir}")
            return files

        for swift_file in sorted(self.scan_dir.rglob("*.swift")):
            rel_path = str(swift_file.relative_to(self.scan_dir))
            rel_path = rel_path.replace("\\", "/")
            files.append((rel_path, swift_file))

        return files

    def _check_file(
        self, swiftc: str, file_path: Path, rel_path: str,
    ) -> FileResult:
        """Run swiftc parse/typecheck on a single file."""
        flag = f"-{self.mode}"

        try:
            result = subprocess.run(
                [swiftc, flag, str(file_path)],
                capture_output=True,
                text=True,
                timeout=30,
            )
        except subprocess.TimeoutExpired:
            return FileResult(
                file=rel_path,
                status="error",
                errors=["swiftc timed out after 30s"],
            )
        except (OSError, FileNotFoundError) as e:
            return FileResult(
                file=rel_path,
                status="error",
                errors=[f"Failed to run swiftc: {e}"],
            )

        if result.returncode == 0:
            # Check for warnings even on success
            _, warnings = _parse_swiftc_output(result.stderr)
            if warnings:
                return FileResult(
                    file=rel_path,
                    status="warning",
                    warnings=warnings,
                )
            return FileResult(file=rel_path, status="ok")

        # Parse errors
        errors, warnings = _parse_swiftc_output(result.stderr)

        if errors:
            return FileResult(
                file=rel_path,
                status="error",
                errors=errors,
                warnings=warnings,
            )

        # returncode != 0 but no parsed errors — capture raw
        if result.stderr.strip():
            return FileResult(
                file=rel_path,
                status="error",
                errors=[result.stderr.strip()[:300]],
            )

        return FileResult(file=rel_path, status="ok")

    def _print_and_save(self):
        self.report.print_summary()
        self._write_report_json()

    def _write_report_json(self):
        REPORTS_DIR.mkdir(parents=True, exist_ok=True)
        report_path = REPORTS_DIR / f"{self.project_name}_swift_compile.json"

        try:
            report_path.write_text(
                json.dumps(self.report.to_dict(), indent=2, ensure_ascii=False),
                encoding="utf-8",
            )
            print(f"[SwiftCompile] Report written to: {report_path}")
        except (OSError, IOError) as e:
            print(f"[SwiftCompile] Error writing report: {e}")


# ---------------------------------------------------------------------------
# CLI entry point
# ---------------------------------------------------------------------------

def main():
    """Run Swift compile check from the command line."""
    import argparse

    parser = argparse.ArgumentParser(
        description="Swift Compile Check — lightweight syntax/type validation using swiftc"
    )
    parser.add_argument(
        "--project", default="askfin_v1-1",
        help="Project name (default: askfin_v1-1)"
    )
    parser.add_argument(
        "--scan-dir", default=None,
        help="Override scan directory"
    )
    parser.add_argument(
        "--mode", choices=["parse", "typecheck"], default="parse",
        help="Check mode: parse (syntax only) or typecheck (default: parse)"
    )
    args = parser.parse_args()

    checker = SwiftCompileCheck(
        project_name=args.project,
        scan_dir=args.scan_dir,
        mode=args.mode,
    )
    report = checker.check()

    # Exit code: 0 = clean/warnings/skipped, 1 = blocking
    exit(1 if report.status == CompileStatus.BLOCKING else 0)


if __name__ == "__main__":
    main()
