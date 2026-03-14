# factory/operations/compile_hygiene_validator.py
# Post-generation Compile Hygiene Validator — Round 2
#
# Checks generated Swift artifacts for recurring error patterns
# discovered in Error Pattern Seed Round 1 (FK-011, FK-012, FK-015).
#
# Deterministic only — no LLM, no automatic fixes.
# Reports issues and classifies hygiene status.

import json
import re
from dataclasses import dataclass, field
from enum import Enum
from pathlib import Path

# ---------------------------------------------------------------------------
# Project root — two levels up from this file
# ---------------------------------------------------------------------------
_PROJECT_ROOT = Path(__file__).resolve().parent.parent.parent

REPORTS_DIR = _PROJECT_ROOT / "factory" / "reports" / "hygiene"


# ---------------------------------------------------------------------------
# Enums
# ---------------------------------------------------------------------------

class HygieneStatus(str, Enum):
    CLEAN = "CLEAN"
    WARNINGS = "WARNINGS"
    BLOCKING = "BLOCKING"


class IssueSeverity(str, Enum):
    BLOCKING = "blocking"
    WARNING = "warning"


# ---------------------------------------------------------------------------
# Data classes
# ---------------------------------------------------------------------------

@dataclass
class HygieneIssue:
    """A single detected hygiene issue."""
    pattern_id: str
    severity: IssueSeverity
    file: str
    line: int | None = None
    matched_text: str = ""
    type_name: str = ""
    other_files: list[str] = field(default_factory=list)
    message: str = ""

    def to_dict(self) -> dict:
        d = {
            "pattern_id": self.pattern_id,
            "severity": self.severity.value,
            "file": self.file,
            "message": self.message,
        }
        if self.line is not None:
            d["line"] = self.line
        if self.matched_text:
            d["matched_text"] = self.matched_text
        if self.type_name:
            d["type_name"] = self.type_name
        if self.other_files:
            d["other_files"] = self.other_files
        return d


@dataclass
class HygieneReport:
    """Full hygiene validation report."""
    project: str = ""
    scan_dir: str = ""
    files_scanned: int = 0
    checks_run: list[str] = field(default_factory=list)
    status: HygieneStatus = HygieneStatus.CLEAN
    issues: list[HygieneIssue] = field(default_factory=list)

    @property
    def issues_found(self) -> int:
        return len(self.issues)

    @property
    def blocking_count(self) -> int:
        return sum(1 for i in self.issues if i.severity == IssueSeverity.BLOCKING)

    @property
    def warning_count(self) -> int:
        return sum(1 for i in self.issues if i.severity == IssueSeverity.WARNING)

    def to_dict(self) -> dict:
        return {
            "project": self.project,
            "scan_dir": self.scan_dir,
            "files_scanned": self.files_scanned,
            "checks_run": self.checks_run,
            "status": self.status.value,
            "issues_found": self.issues_found,
            "blocking": self.blocking_count,
            "warnings": self.warning_count,
            "issues": [i.to_dict() for i in self.issues],
        }

    def print_summary(self):
        print()
        print("=" * 60)
        print("  Compile Hygiene Validator")
        print("=" * 60)
        print(f"  Project:        {self.project}")
        print(f"  Scan dir:       {self.scan_dir}")
        print(f"  Files scanned:  {self.files_scanned}")
        print(f"  Checks run:     {', '.join(self.checks_run)}")
        print(f"  Status:         {self.status.value}")
        print("-" * 60)
        print(f"  Issues found:   {self.issues_found}")
        print(f"    Blocking:     {self.blocking_count}")
        print(f"    Warnings:     {self.warning_count}")

        if self.issues:
            print()
            for issue in self.issues:
                severity_tag = "BLOCK" if issue.severity == IssueSeverity.BLOCKING else "WARN "
                loc = f":{issue.line}" if issue.line else ""
                print(f"  [{severity_tag}] {issue.pattern_id}  {issue.file}{loc}")
                print(f"          {issue.message}")
                if issue.matched_text:
                    preview = issue.matched_text[:80]
                    print(f"          > {preview}")
                if issue.other_files:
                    for of in issue.other_files:
                        print(f"          also in: {of}")

        print("=" * 60)
        print()


# ---------------------------------------------------------------------------
# FK-011: AI review text embedded inside source files
# ---------------------------------------------------------------------------

# Patterns that indicate AI review/commentary leaked into Swift code.
# Each tuple: (compiled regex, description)
_AI_CONTAMINATION_PATTERNS: list[tuple[re.Pattern, str]] = [
    # Markdown headings (not inside string literals)
    (re.compile(r'^#{1,4}\s+\w', re.MULTILINE),
     "Markdown heading in Swift file"),

    # Markdown horizontal rules
    (re.compile(r'^---\s*$', re.MULTILINE),
     "Markdown horizontal rule"),

    # Bold markdown syntax
    (re.compile(r'^\*\*[A-Z][^*]+\*\*', re.MULTILINE),
     "Markdown bold text"),

    # Common AI review phrases at line start
    (re.compile(
        r'^\s*(?:Issue:|Fix:|Review:|Recommendation:|Problem:|Solution:|'
        r'Severity:|Root [Cc]ause:|Analysis:|Summary:|Note:)\s',
        re.MULTILINE),
     "AI review label"),

    # Agent self-reference
    (re.compile(
        r"I'm stopping here|I will stop here|Let me review|"
        r"Here's (?:my|the) (?:review|analysis|assessment)|"
        r"Looking at (?:this|the) code",
        re.IGNORECASE),
     "AI agent self-reference"),

    # Numbered review items (1. Issue: ...)
    (re.compile(
        r'^\s*\d+\.\s+(?:Issue|Bug|Problem|Fix|Error)\s*:', re.MULTILINE),
     "Numbered review item"),

    # Bullet point review items outside of doc comments
    (re.compile(r'^- \*\*\w+\*\*:', re.MULTILINE),
     "Markdown bullet with bold label"),
]

# Lines that are safe even if they match (inside string literals or comments)
_SAFE_CONTEXT_RE = re.compile(r'^\s*(?://|/\*|\*|".*")')


def _check_fk011(file_path: Path, content: str, rel_path: str) -> list[HygieneIssue]:
    """Check for AI review text contamination in a Swift source file."""
    issues: list[HygieneIssue] = []
    lines = content.splitlines()

    for pattern, description in _AI_CONTAMINATION_PATTERNS:
        for match in pattern.finditer(content):
            # Find line number
            line_num = content[:match.start()].count('\n') + 1
            line_text = lines[line_num - 1] if line_num <= len(lines) else ""

            # Skip if inside a comment or string literal
            if _SAFE_CONTEXT_RE.match(line_text):
                continue

            issues.append(HygieneIssue(
                pattern_id="FK-011",
                severity=IssueSeverity.BLOCKING,
                file=rel_path,
                line=line_num,
                matched_text=line_text.strip(),
                message=f"AI contamination: {description}",
            ))
            # One match per pattern per file is enough
            break

    return issues


# ---------------------------------------------------------------------------
# FK-012: Duplicate type definitions across files
# ---------------------------------------------------------------------------

# Matches Swift type declarations: struct/class/enum/protocol Name
_TYPE_DECL_RE = re.compile(
    r'^(?:public\s+|internal\s+|private\s+|fileprivate\s+)?'
    r'(?:final\s+)?'
    r'(struct|class|enum|protocol|actor)\s+'
    r'([A-Z][A-Za-z0-9_]+)',
    re.MULTILINE,
)

# Types from Apple frameworks that can appear in multiple files legitimately
_FRAMEWORK_TYPES = frozenset({
    "String", "Int", "Double", "Bool", "Float", "Date", "UUID",
    "Array", "Dictionary", "Set", "Optional", "Result", "Error",
    "URL", "Data", "Void", "Never", "Any", "AnyObject",
    "View", "App", "Scene", "PreviewProvider",
})


def _collect_type_declarations(
    swift_files: dict[str, tuple[Path, str]],
) -> dict[str, list[tuple[str, str, int]]]:
    """Collect all type declarations across all files.

    Returns: {type_name: [(rel_path, kind, line_num), ...]}
    """
    registry: dict[str, list[tuple[str, str, int]]] = {}

    for rel_path, (_, content) in swift_files.items():
        for match in _TYPE_DECL_RE.finditer(content):
            kind = match.group(1)
            name = match.group(2)

            if name in _FRAMEWORK_TYPES:
                continue

            line_num = content[:match.start()].count('\n') + 1

            if name not in registry:
                registry[name] = []
            registry[name].append((rel_path, kind, line_num))

    return registry


def _check_fk012(
    type_registry: dict[str, list[tuple[str, str, int]]],
) -> list[HygieneIssue]:
    """Check for duplicate type definitions."""
    issues: list[HygieneIssue] = []

    for type_name, locations in sorted(type_registry.items()):
        if len(locations) <= 1:
            continue

        # First occurrence is treated as primary
        primary_path, primary_kind, primary_line = locations[0]
        other_files = [f"{loc[0]}:{loc[2]}" for loc in locations[1:]]

        issues.append(HygieneIssue(
            pattern_id="FK-012",
            severity=IssueSeverity.BLOCKING,
            file=primary_path,
            line=primary_line,
            type_name=type_name,
            other_files=other_files,
            message=f"Duplicate {primary_kind} '{type_name}' defined in {len(locations)} files",
        ))

    return issues


# ---------------------------------------------------------------------------
# FK-015: Bundle.module used in normal Xcode app targets
# ---------------------------------------------------------------------------

_BUNDLE_MODULE_RE = re.compile(
    r'Bundle\.module|bundle:\s*\.module',
)


def _check_fk015(
    file_path: Path, content: str, rel_path: str,
) -> list[HygieneIssue]:
    """Check for Bundle.module usage (invalid in regular Xcode app targets)."""
    issues: list[HygieneIssue] = []
    lines = content.splitlines()

    for match in _BUNDLE_MODULE_RE.finditer(content):
        line_num = content[:match.start()].count('\n') + 1
        line_text = lines[line_num - 1] if line_num <= len(lines) else ""

        # Skip if inside a comment
        stripped = line_text.strip()
        if stripped.startswith("//") or stripped.startswith("/*"):
            continue

        issues.append(HygieneIssue(
            pattern_id="FK-015",
            severity=IssueSeverity.WARNING,
            file=rel_path,
            line=line_num,
            matched_text=stripped,
            message="Bundle.module is only available in Swift Package targets, not regular Xcode apps",
        ))
        # One match per file is enough
        break

    return issues


# ---------------------------------------------------------------------------
# Status classification
# ---------------------------------------------------------------------------

def classify_status(issues: list[HygieneIssue]) -> HygieneStatus:
    """Classify hygiene status based on issues found.

    - CLEAN: no issues
    - WARNINGS: only warning-level findings (FK-015)
    - BLOCKING: any blocking-level finding (FK-011, FK-012)
    """
    if not issues:
        return HygieneStatus.CLEAN

    has_blocking = any(i.severity == IssueSeverity.BLOCKING for i in issues)
    if has_blocking:
        return HygieneStatus.BLOCKING

    return HygieneStatus.WARNINGS


# ---------------------------------------------------------------------------
# Main validator
# ---------------------------------------------------------------------------

class CompileHygieneValidator:
    """Post-generation validator for Swift compile hygiene.

    Checks:
    - FK-011: AI review text in source files
    - FK-012: Duplicate type definitions
    - FK-015: Bundle.module in regular Xcode targets
    """

    def __init__(
        self,
        project_name: str,
        scan_dir: str | None = None,
    ):
        self.project_name = project_name

        if scan_dir:
            self.scan_dir = Path(scan_dir)
        else:
            # Default: projects/<name>/ (scan all .swift recursively)
            self.scan_dir = _PROJECT_ROOT / "projects" / project_name

        self.report = HygieneReport(
            project=project_name,
            scan_dir=str(self.scan_dir),
            checks_run=["FK-011", "FK-012", "FK-015"],
        )

    def validate(self) -> HygieneReport:
        """Run all hygiene checks and produce report."""
        print(f"\n[CompileHygiene] Validating project: {self.project_name}")
        print(f"[CompileHygiene] Scan dir: {self.scan_dir}")

        # Step 1: Discover and read all Swift files
        swift_files = self._discover_swift_files()
        self.report.files_scanned = len(swift_files)
        print(f"[CompileHygiene] Swift files found: {len(swift_files)}")

        if not swift_files:
            print("[CompileHygiene] No Swift files found — nothing to validate.")
            self.report.status = HygieneStatus.CLEAN
            self._print_and_save()
            return self.report

        # Step 2: Run FK-011 and FK-015 (per-file checks)
        for rel_path, (file_path, content) in swift_files.items():
            self.report.issues.extend(_check_fk011(file_path, content, rel_path))
            self.report.issues.extend(_check_fk015(file_path, content, rel_path))

        # Step 3: Run FK-012 (cross-file check)
        type_registry = _collect_type_declarations(swift_files)
        self.report.issues.extend(_check_fk012(type_registry))

        # Step 4: Classify status
        self.report.status = classify_status(self.report.issues)

        # Step 5: Report
        self._print_and_save()

        return self.report

    def _discover_swift_files(self) -> dict[str, tuple[Path, str]]:
        """Discover all .swift files in scan_dir.

        Returns: {relative_path: (absolute_path, content)}
        """
        files: dict[str, tuple[Path, str]] = {}

        if not self.scan_dir.exists():
            print(f"[CompileHygiene] Directory not found: {self.scan_dir}")
            return files

        for swift_file in sorted(self.scan_dir.rglob("*.swift")):
            try:
                content = swift_file.read_text(encoding="utf-8", errors="replace")
            except (OSError, IOError):
                continue

            rel_path = str(swift_file.relative_to(self.scan_dir))
            # Normalize path separators
            rel_path = rel_path.replace("\\", "/")
            files[rel_path] = (swift_file, content)

        return files

    def _print_and_save(self):
        """Print summary and write JSON report."""
        self.report.print_summary()
        self._write_report_json()

    def _write_report_json(self):
        """Write report as JSON to factory/reports/hygiene/."""
        REPORTS_DIR.mkdir(parents=True, exist_ok=True)
        report_path = REPORTS_DIR / f"{self.project_name}_compile_hygiene.json"

        try:
            report_path.write_text(
                json.dumps(self.report.to_dict(), indent=2, ensure_ascii=False),
                encoding="utf-8",
            )
            print(f"[CompileHygiene] Report written to: {report_path}")
        except (OSError, IOError) as e:
            print(f"[CompileHygiene] Error writing report: {e}")


# ---------------------------------------------------------------------------
# CLI entry point
# ---------------------------------------------------------------------------

def main():
    """Run the compile hygiene validator from the command line."""
    import argparse

    parser = argparse.ArgumentParser(
        description="Factory Compile Hygiene Validator — checks FK-011, FK-012, FK-015"
    )
    parser.add_argument(
        "--project", default="askfin_v1-1",
        help="Project name (default: askfin_v1-1)"
    )
    parser.add_argument(
        "--scan-dir", default=None,
        help="Override scan directory (default: projects/<project>/)"
    )
    args = parser.parse_args()

    validator = CompileHygieneValidator(
        project_name=args.project,
        scan_dir=args.scan_dir,
    )
    report = validator.validate()

    # Exit code: 0 = clean/warnings, 1 = blocking
    exit(1 if report.status == HygieneStatus.BLOCKING else 0)


if __name__ == "__main__":
    main()
