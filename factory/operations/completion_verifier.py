# factory/operations/completion_verifier.py
# Post-integration verification layer: compares expected vs actual artifacts,
# detects missing/incomplete files, and assigns a project health status.
#
# Runs AFTER the Output Integrator. Does NOT modify any files.

import json
import os
import re
from dataclasses import dataclass, field
from enum import Enum
from pathlib import Path

# ---------------------------------------------------------------------------
# Project root — two levels up from this file
# ---------------------------------------------------------------------------
_PROJECT_ROOT = Path(__file__).resolve().parent.parent.parent

# Minimum file length (characters) — anything shorter is likely a stub
MIN_FILE_LENGTH = 50

# Core folders every project should have
EXPECTED_CORE_FOLDERS = ["Models", "Services", "ViewModels", "Views"]

# Reports output directory
REPORTS_DIR = _PROJECT_ROOT / "factory" / "reports" / "completion"


# ---------------------------------------------------------------------------
# Enums
# ---------------------------------------------------------------------------

class FileStatus(str, Enum):
    COMPLETE = "complete"
    INCOMPLETE = "incomplete"
    MISSING = "missing"
    SUSPICIOUS = "suspicious"


class ProjectHealth(str, Enum):
    COMPLETE = "complete"
    MOSTLY_COMPLETE = "mostly_complete"
    INCOMPLETE = "incomplete"
    FAILED = "failed"
    INSUFFICIENT_EVIDENCE = "insufficient_evidence"


# ---------------------------------------------------------------------------
# Data classes
# ---------------------------------------------------------------------------

@dataclass
class FileVerification:
    """Verification result for a single expected file."""
    filename: str
    expected: bool = True
    found: bool = False
    path: str = ""
    size: int = 0
    line_count: int = 0
    ends_with_brace: bool = False
    status: FileStatus = FileStatus.MISSING

    def to_dict(self) -> dict:
        return {
            "filename": self.filename,
            "found": self.found,
            "path": self.path,
            "size": self.size,
            "line_count": self.line_count,
            "ends_with_brace": self.ends_with_brace,
            "status": self.status.value,
        }


@dataclass
class VerificationReport:
    """Full verification report for a project."""
    project_name: str = ""
    spec_source: str = ""
    health: ProjectHealth = ProjectHealth.FAILED

    expected_files: list[str] = field(default_factory=list)
    actual_files: list[str] = field(default_factory=list)
    complete_files: list[str] = field(default_factory=list)
    incomplete_files: list[str] = field(default_factory=list)
    missing_files: list[str] = field(default_factory=list)
    suspicious_files: list[str] = field(default_factory=list)
    unexpected_files: list[str] = field(default_factory=list)
    missing_folders: list[str] = field(default_factory=list)

    file_details: list[FileVerification] = field(default_factory=list)

    # Summary counts
    total_expected: int = 0
    total_actual: int = 0
    total_complete: int = 0
    total_incomplete: int = 0
    total_missing: int = 0
    completeness_pct: float = 0.0

    def to_dict(self) -> dict:
        return {
            "project_name": self.project_name,
            "spec_source": self.spec_source,
            "health": self.health.value,
            "completeness_pct": round(self.completeness_pct, 1),
            "summary": {
                "expected": self.total_expected,
                "actual": self.total_actual,
                "complete": self.total_complete,
                "incomplete": self.total_incomplete,
                "missing": self.total_missing,
            },
            "missing_files": self.missing_files,
            "incomplete_files": self.incomplete_files,
            "suspicious_files": self.suspicious_files,
            "unexpected_files": self.unexpected_files,
            "missing_folders": self.missing_folders,
            "file_details": [f.to_dict() for f in self.file_details],
        }

    def print_summary(self):
        print()
        print("=" * 55)
        print("  Completion Verifier Summary")
        print("=" * 55)
        print(f"  Project:           {self.project_name}")
        print(f"  Spec source:       {self.spec_source or 'none'}")
        print(f"  Health status:     {self.health.value.upper()}")
        print(f"  Completeness:      {self.completeness_pct:.0f}%")
        print("-" * 55)
        print(f"  Expected files:    {self.total_expected}")
        print(f"  Actual files:      {self.total_actual}")
        print(f"  Complete files:    {self.total_complete}")
        print(f"  Incomplete files:  {self.total_incomplete}")
        print(f"  Missing files:     {self.total_missing}")
        if self.unexpected_files:
            print(f"  Unexpected files:  {len(self.unexpected_files)}")
        if self.missing_folders:
            print(f"  Missing folders:   {len(self.missing_folders)}")

        if self.missing_files:
            print()
            print("  Missing files:")
            for f in self.missing_files:
                print(f"    - {f}")

        if self.incomplete_files:
            print()
            print("  Incomplete files:")
            for f in self.incomplete_files:
                print(f"    - {f}")

        if self.suspicious_files:
            print()
            print("  Suspicious files:")
            for f in self.suspicious_files:
                print(f"    - {f}")

        if self.missing_folders:
            print()
            print("  Missing folders:")
            for f in self.missing_folders:
                print(f"    - {f}")

        if self.unexpected_files and len(self.unexpected_files) <= 15:
            print()
            print("  Unexpected files (not in spec):")
            for f in self.unexpected_files:
                print(f"    + {f}")
        elif self.unexpected_files:
            print()
            print(f"  Unexpected files (not in spec): {len(self.unexpected_files)} "
                  f"(showing first 10)")
            for f in self.unexpected_files[:10]:
                print(f"    + {f}")

        print("=" * 55)
        print()


# ---------------------------------------------------------------------------
# Spec parser — deterministic, no LLM
# ---------------------------------------------------------------------------

# Patterns to extract Swift filenames from spec files
_BACKTICK_SWIFT_NAME_RE = re.compile(
    r'`([A-Z][A-Za-z0-9]+(?:View|ViewModel|Service|Manager|Protocol|Store))`'
)

# Table row pattern: | `FileName` | ... |
_TABLE_ROW_NAME_RE = re.compile(
    r'\|\s*`([A-Z][A-Za-z0-9]+)`\s*\|'
)

# Explicit .swift filename mentions
_SWIFT_FILE_RE = re.compile(
    r'([A-Z][A-Za-z0-9]+\.swift)'
)

# Numbered list items with backtick names: 1. `TrainingSessionView` — ...
_NUMBERED_LIST_RE = re.compile(
    r'^\s*\d+\.\s+(?:`)?([A-Z][A-Za-z0-9]+View|[A-Z][A-Za-z0-9]+ViewModel|'
    r'[A-Z][A-Za-z0-9]+Service)(?:`)?\s',
    re.MULTILINE
)

# Model definitions: struct/enum/class Name
_MODEL_DEFINITION_RE = re.compile(
    r'(?:struct|enum|class|protocol)\s+([A-Z][A-Za-z0-9]+)',
)

# Section headers that indicate file lists
_FILE_LIST_SECTION_RE = re.compile(
    r'^#+\s+(?:Screens?\s+to\s+Generate|Files?\s+to\s+Generate|Output|'
    r'Deliverables|Components?)\s*$',
    re.MULTILINE | re.IGNORECASE
)


def parse_expected_files_from_spec(spec_path: str) -> list[str]:
    """Extract expected Swift filenames from a spec file.

    Uses multiple deterministic patterns:
    1. Table rows with backtick names (e.g. | `TrainingSessionView` | ...)
    2. Backtick names matching View/ViewModel/Service suffix
    3. Explicit .swift filenames
    4. Numbered list items with type names
    5. Model definitions (struct/enum/class) in code blocks

    Returns deduplicated list of filenames (without .swift extension).
    """
    try:
        content = Path(spec_path).read_text(encoding="utf-8", errors="replace")
    except (OSError, IOError):
        return []

    names: set[str] = set()

    # --- Priority 1: "Screens to Generate" table rows ---
    # Find the section, then parse table rows within it
    section_match = _FILE_LIST_SECTION_RE.search(content)
    if section_match:
        # Extract content from this section until the next ## header
        section_start = section_match.end()
        next_section = re.search(r'^---\s*$|^##\s+', content[section_start:], re.MULTILINE)
        section_end = section_start + next_section.start() if next_section else len(content)
        section_text = content[section_start:section_end]

        for m in _TABLE_ROW_NAME_RE.finditer(section_text):
            names.add(m.group(1))

    # --- Priority 2: Backtick names with known suffixes ---
    for m in _BACKTICK_SWIFT_NAME_RE.finditer(content):
        names.add(m.group(1))

    # --- Priority 3: Numbered list items ---
    for m in _NUMBERED_LIST_RE.finditer(content):
        names.add(m.group(1))

    # --- Priority 4: Explicit .swift filenames ---
    for m in _SWIFT_FILE_RE.finditer(content):
        name = m.group(1).replace(".swift", "")
        names.add(name)

    # --- Priority 5: Model definitions in code blocks ---
    code_blocks = re.findall(r'```swift\s*\n(.*?)```', content, re.DOTALL)
    for block in code_blocks:
        for m in _MODEL_DEFINITION_RE.finditer(block):
            name = m.group(1)
            # Skip common Swift stdlib types
            if name not in _STDLIB_TYPES:
                names.add(name)

    # Filter out noise
    filtered = [n for n in sorted(names) if _is_valid_expected_name(n)]
    return filtered


# Swift standard library types to exclude from model detection
_STDLIB_TYPES = frozenset({
    "String", "Int", "Double", "Bool", "Float", "Date", "UUID",
    "Array", "Dictionary", "Set", "Optional", "Result", "Error",
    "URL", "Data", "Void", "Never", "Any", "AnyObject",
    "Codable", "Identifiable", "Hashable", "Equatable", "Comparable",
    "View", "ObservableObject", "Published",
})


def _is_valid_expected_name(name: str) -> bool:
    """Filter out names that are too generic or likely false positives."""
    if len(name) < 4:
        return False
    if name in _STDLIB_TYPES:
        return False
    # Must start with uppercase
    if not name[0].isupper():
        return False
    return True


# ---------------------------------------------------------------------------
# Actual artifact discovery
# ---------------------------------------------------------------------------

def discover_actual_artifacts(generated_dir: str) -> dict[str, FileVerification]:
    """Scan the generated output directory and verify each file.

    Returns a dict mapping filename (stem) to its verification result.
    """
    root = Path(generated_dir)
    results: dict[str, FileVerification] = {}

    if not root.exists():
        return results

    for swift_file in root.rglob("*.swift"):
        try:
            content = swift_file.read_text(encoding="utf-8", errors="replace")
        except (OSError, IOError):
            continue

        rel_path = str(swift_file.relative_to(root))
        stem = swift_file.stem
        size = len(content)
        line_count = len(content.splitlines())
        stripped_end = content.rstrip()
        # Swift files may end with } or #endif (compiler directives)
        ends_with_brace = (
            stripped_end.endswith("}")
            or stripped_end.endswith("#endif")
        )

        # Classify
        if size < MIN_FILE_LENGTH:
            status = FileStatus.SUSPICIOUS
        elif not ends_with_brace:
            status = FileStatus.INCOMPLETE
        elif _has_agent_leakage(content):
            status = FileStatus.SUSPICIOUS
        else:
            status = FileStatus.COMPLETE

        results[stem] = FileVerification(
            filename=swift_file.name,
            expected=False,  # will be set later during comparison
            found=True,
            path=rel_path,
            size=size,
            line_count=line_count,
            ends_with_brace=ends_with_brace,
            status=status,
        )

    return results


def _has_agent_leakage(content: str) -> bool:
    """Detect agent name tags leaked into Swift code."""
    if re.search(r'^\[[\w_]+\]\s*$', content, re.MULTILINE):
        return True
    return False


# ---------------------------------------------------------------------------
# Health status classification
# ---------------------------------------------------------------------------

def classify_health(
    total_expected: int,
    total_complete: int,
    total_incomplete: int,
    total_missing: int,
    missing_folders: list[str],
) -> ProjectHealth:
    """Determine project health status from verification results.

    Rules:
    - complete: all expected files present and complete, no missing folders
    - mostly_complete: >= 80% complete, no critical missing (Views, Services)
    - incomplete: 40-79% complete or critical files missing
    - failed: < 40% complete or no usable output
    """
    if total_expected == 0:
        return ProjectHealth.FAILED

    completeness = total_complete / total_expected

    # Check for critical missing folders
    critical_folders_missing = any(
        f in ("Views", "Services", "ViewModels") for f in missing_folders
    )

    if total_missing == 0 and total_incomplete == 0 and not missing_folders:
        return ProjectHealth.COMPLETE

    if completeness >= 0.8 and not critical_folders_missing:
        return ProjectHealth.MOSTLY_COMPLETE

    if completeness >= 0.4:
        return ProjectHealth.INCOMPLETE

    return ProjectHealth.FAILED


# ---------------------------------------------------------------------------
# Main verifier
# ---------------------------------------------------------------------------

class CompletionVerifier:
    """Compares expected vs actual artifacts and reports completeness."""

    def __init__(
        self,
        project_name: str = "askfin_premium",
        generated_dir: str | None = None,
        specs_dir: str | None = None,
    ):
        self.project_name = project_name

        if generated_dir:
            self.generated_dir = Path(generated_dir)
        else:
            self.generated_dir = _PROJECT_ROOT / "projects" / project_name / "generated"

        if specs_dir:
            self.specs_dir = Path(specs_dir)
        else:
            self.specs_dir = _PROJECT_ROOT / "projects" / project_name / "specs"

        self.report = VerificationReport(project_name=project_name)

    def verify(self) -> VerificationReport:
        """Run the full verification pipeline.

        Steps:
        1. Discover expected files from specs (if available)
        2. If no specs: use project-evidence mode
        3. Discover actual files from generated output
        4. Check folder structure
        5. Compare expected vs actual (or evaluate project evidence)
        6. Determine project health
        7. Generate report
        """
        print(f"\n[CompletionVerifier] Verifying project: {self.project_name}")
        print(f"[CompletionVerifier] Generated dir: {self.generated_dir}")
        print(f"[CompletionVerifier] Specs dir: {self.specs_dir}")

        # Step 1: Try specs-based discovery
        expected_names = self._discover_expected()
        has_specs = len(expected_names) > 0

        if has_specs:
            # --- Spec-based mode (original path) ---
            self.report.spec_source = self.report.spec_source or "specs"
            self.report.expected_files = [f"{n}.swift" for n in expected_names]
            self.report.total_expected = len(expected_names)
            print(f"[CompletionVerifier] Expected files from specs: {len(expected_names)}")

            # Discover actual generated files
            actual_artifacts = discover_actual_artifacts(str(self.generated_dir))
            self.report.actual_files = sorted(
                fv.path for fv in actual_artifacts.values()
            )
            self.report.total_actual = len(actual_artifacts)
            print(f"[CompletionVerifier] Actual files found: {len(actual_artifacts)}")

            # Check folders in generated/
            self._check_folders()

            # Compare
            self._compare(expected_names, actual_artifacts)

            # Health from spec comparison
            self.report.health = classify_health(
                total_expected=self.report.total_expected,
                total_complete=self.report.total_complete,
                total_incomplete=self.report.total_incomplete,
                total_missing=self.report.total_missing,
                missing_folders=self.report.missing_folders,
            )
            self.report.completeness_pct = (
                (self.report.total_complete / self.report.total_expected * 100)
                if self.report.total_expected > 0 else 0.0
            )
        else:
            # --- Project-evidence mode (no specs available) ---
            print("[CompletionVerifier] No specs found -- using project-evidence mode")
            self.report.spec_source = "project-evidence"
            self._verify_from_project_evidence()

        # Report
        self.report.print_summary()
        self._write_report_json()

        return self.report

    def _verify_from_project_evidence(self):
        """Evaluate project health from available evidence when no specs exist.

        Evidence sources:
        1. Project directory: count Swift files, check folder structure
        2. Generated directory: count new artifacts from this run
        3. Integration report: how many files were integrated vs skipped
        4. Compile hygiene report: blocking vs warning count
        """
        project_dir = _PROJECT_ROOT / "projects" / self.project_name

        # --- Evidence 1: Project file inventory ---
        project_swift_files = []
        if project_dir.is_dir():
            gen_dir = self.generated_dir.resolve()
            for sf in project_dir.rglob("*.swift"):
                try:
                    sf.resolve().relative_to(gen_dir)
                    continue  # skip generated/
                except ValueError:
                    pass
                project_swift_files.append(sf)

        project_file_count = len(project_swift_files)
        print(f"[CompletionVerifier] Project Swift files: {project_file_count}")

        # --- Evidence 2: Core folder check (in project root, not generated/) ---
        project_folders_present = []
        project_folders_missing = []
        for folder in EXPECTED_CORE_FOLDERS:
            folder_path = project_dir / folder
            if folder_path.exists() and any(folder_path.iterdir()):
                project_folders_present.append(folder)
            else:
                project_folders_missing.append(folder)
        self.report.missing_folders = project_folders_missing

        # --- Evidence 3: Generated artifacts from this run ---
        actual_artifacts = discover_actual_artifacts(str(self.generated_dir))
        self.report.actual_files = sorted(
            fv.path for fv in actual_artifacts.values()
        )
        self.report.total_actual = len(actual_artifacts)
        print(f"[CompletionVerifier] Generated artifacts: {len(actual_artifacts)}")

        # --- Evidence 4: Compile hygiene report (if available) ---
        hygiene_report_path = (
            _PROJECT_ROOT / "factory" / "reports" / "hygiene"
            / f"{self.project_name}_compile_hygiene.json"
        )
        hygiene_blocking = -1  # unknown
        if hygiene_report_path.exists():
            try:
                hygiene_data = json.loads(
                    hygiene_report_path.read_text(encoding="utf-8")
                )
                hygiene_blocking = hygiene_data.get("blocking", -1)
                print(f"[CompletionVerifier] Compile hygiene blocking: {hygiene_blocking}")
            except (json.JSONDecodeError, OSError):
                pass

        # --- Classify health from evidence ---
        self.report.total_expected = project_file_count  # use project as baseline
        self.report.total_complete = project_file_count   # existing files are "complete"
        self.report.total_actual = len(actual_artifacts)

        # Determine health verdict
        if project_file_count == 0:
            self.report.health = ProjectHealth.FAILED
            self.report.completeness_pct = 0.0
        elif project_file_count < 10:
            self.report.health = ProjectHealth.INSUFFICIENT_EVIDENCE
            self.report.completeness_pct = 0.0
        elif len(project_folders_missing) >= 3:
            self.report.health = ProjectHealth.INCOMPLETE
            self.report.completeness_pct = (
                len(project_folders_present) / len(EXPECTED_CORE_FOLDERS) * 100
            )
        elif hygiene_blocking > 0:
            # Has project files but compile issues remain
            self.report.health = ProjectHealth.INCOMPLETE
            self.report.completeness_pct = 80.0
        elif hygiene_blocking == 0:
            # Project has files, folders, and no blocking hygiene issues
            if len(project_folders_missing) == 0:
                self.report.health = ProjectHealth.MOSTLY_COMPLETE
                self.report.completeness_pct = 95.0
            else:
                self.report.health = ProjectHealth.INCOMPLETE
                self.report.completeness_pct = 70.0
        else:
            # Hygiene status unknown
            if len(project_folders_missing) == 0 and project_file_count >= 50:
                self.report.health = ProjectHealth.MOSTLY_COMPLETE
                self.report.completeness_pct = 85.0
            else:
                self.report.health = ProjectHealth.INSUFFICIENT_EVIDENCE
                self.report.completeness_pct = 0.0

    def _discover_expected(self) -> list[str]:
        """Discover expected files from all spec files in the specs directory."""
        all_names: set[str] = set()

        if not self.specs_dir.exists():
            print(f"[CompletionVerifier] No specs directory found at {self.specs_dir}")
            return []

        spec_files = list(self.specs_dir.glob("*.md"))
        if not spec_files:
            print("[CompletionVerifier] No spec files found")
            return []

        for spec_file in spec_files:
            names = parse_expected_files_from_spec(str(spec_file))
            if names:
                self.report.spec_source = spec_file.name
                print(f"  [spec:{spec_file.name}] {len(names)} expected files")
                all_names.update(names)

        return sorted(all_names)

    def _check_folders(self):
        """Check that expected core folders exist."""
        for folder in EXPECTED_CORE_FOLDERS:
            folder_path = self.generated_dir / folder
            if not folder_path.exists() or not any(folder_path.iterdir()):
                self.report.missing_folders.append(folder)

    def _compare(
        self,
        expected_names: list[str],
        actual_artifacts: dict[str, FileVerification],
    ):
        """Compare expected files against actual artifacts."""
        expected_set = set(expected_names)
        actual_set = set(actual_artifacts.keys())

        # Mark expected files in actual artifacts
        for name in expected_set:
            if name in actual_artifacts:
                actual_artifacts[name].expected = True

        # Classify each expected file
        for name in expected_names:
            if name in actual_artifacts:
                fv = actual_artifacts[name]
                self.report.file_details.append(fv)

                if fv.status == FileStatus.COMPLETE:
                    self.report.complete_files.append(fv.path)
                    self.report.total_complete += 1
                elif fv.status == FileStatus.INCOMPLETE:
                    self.report.incomplete_files.append(
                        f"{fv.path} ({fv.line_count} lines, missing closing brace)"
                    )
                    self.report.total_incomplete += 1
                elif fv.status == FileStatus.SUSPICIOUS:
                    self.report.suspicious_files.append(
                        f"{fv.path} ({fv.size} chars)"
                    )
                    self.report.total_incomplete += 1
            else:
                # File is missing
                fv = FileVerification(
                    filename=f"{name}.swift",
                    expected=True,
                    found=False,
                    status=FileStatus.MISSING,
                )
                self.report.file_details.append(fv)
                self.report.missing_files.append(f"{name}.swift")
                self.report.total_missing += 1

        # Detect unexpected files (in output but not in spec)
        unexpected = actual_set - expected_set
        for name in sorted(unexpected):
            fv = actual_artifacts[name]
            self.report.unexpected_files.append(fv.path)

    def _write_report_json(self):
        """Write verification report as JSON."""
        REPORTS_DIR.mkdir(parents=True, exist_ok=True)
        report_path = REPORTS_DIR / f"{self.project_name}_completion.json"

        report_data = self.report.to_dict()

        try:
            report_path.write_text(
                json.dumps(report_data, indent=2, ensure_ascii=False),
                encoding="utf-8",
            )
            print(f"[CompletionVerifier] Report written to: {report_path}")
        except (OSError, IOError) as e:
            print(f"[CompletionVerifier] Error writing report: {e}")


# ---------------------------------------------------------------------------
# CLI entry point
# ---------------------------------------------------------------------------

def main():
    """Run the completion verifier from the command line."""
    import argparse

    parser = argparse.ArgumentParser(
        description="Factory Completion Verifier -- check expected vs actual artifacts"
    )
    parser.add_argument(
        "--project", default="askfin_premium",
        help="Project name (default: askfin_premium)"
    )
    parser.add_argument(
        "--generated-dir", default=None,
        help="Override generated output directory"
    )
    parser.add_argument(
        "--specs-dir", default=None,
        help="Override specs directory"
    )

    args = parser.parse_args()

    verifier = CompletionVerifier(
        project_name=args.project,
        generated_dir=args.generated_dir,
        specs_dir=args.specs_dir,
    )
    verifier.verify()


if __name__ == "__main__":
    main()
