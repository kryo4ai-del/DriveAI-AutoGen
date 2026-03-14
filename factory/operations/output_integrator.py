# factory/operations/output_integrator.py
# Post-run integration layer: collects, normalizes, deduplicates, and writes
# Swift artifacts produced by factory pipeline runs.
#
# Runs AFTER a pipeline run. Does NOT modify the pipeline itself.

import os
import re
import json
import datetime
from dataclasses import dataclass, field
from pathlib import Path

# ---------------------------------------------------------------------------
# Project root — two levels up from this file
# ---------------------------------------------------------------------------
_PROJECT_ROOT = Path(__file__).resolve().parent.parent.parent

GENERATED_CODE_DIR = _PROJECT_ROOT / "generated_code"
LOGS_DIR = _PROJECT_ROOT / "logs"
DELIVERY_DIR = _PROJECT_ROOT / "delivery" / "exports"

# ---------------------------------------------------------------------------
# Swift structural keywords used for quality scoring
# ---------------------------------------------------------------------------
SWIFT_KEYWORDS = frozenset({
    "struct", "class", "func", "enum", "protocol",
    "var", "let", "import", "extension", "typealias",
    "init", "deinit", "subscript", "operator",
})

# Minimum file length (characters) — anything shorter is likely a stub
MIN_FILE_LENGTH = 50

# ---------------------------------------------------------------------------
# Deterministic path normalization rules
# ---------------------------------------------------------------------------
# Maps filename patterns to their canonical nested directory.
# Order matters: first match wins.
# Format: (filename_contains, target_directory)

# Rules use (pattern, target_dir, match_mode).
# match_mode: "exact" = filename stem must equal pattern
#             "suffix" = filename stem must end with pattern
#             "contains" = pattern appears anywhere in stem
# Order matters: first match wins.
PATH_NORMALIZATION_RULES: list[tuple[str, str, str]] = [
    # --- Exact matches first (highest priority) ---
    ("TrainingSessionViewModel", "ViewModels", "exact"),
    ("SkillMapViewModel", "ViewModels", "exact"),
    ("DomainSection", "ViewModels", "exact"),
    ("RevealCopy", "ViewModels", "exact"),
    ("AdaptiveQueueBuilder", "ViewModels", "exact"),
    ("RevealDisplayModel", "Views/Training", "exact"),
    ("PersistenceStore", "Services", "exact"),
    ("TestFixtures", "Tests/Helpers", "exact"),
    # --- Exact View names → Views/Training/ ---
    ("TrainingSessionView", "Views/Training", "exact"),
    ("QuestionCardView", "Views/Training", "exact"),
    ("AnswerRevealView", "Views/Training", "exact"),
    ("SessionBriefView", "Views/Training", "exact"),
    ("SessionSummaryView", "Views/Training", "exact"),
    # --- Exact View names → Views/SkillMap/ ---
    ("SkillMapView", "Views/SkillMap", "exact"),
    # --- Views/Components/ (common dashboard components) ---
    ("ExamCountdownCard", "Views/Components", "exact"),
    ("ProgressGridCard", "Views/Components", "exact"),
    ("StreakIndicator", "Views/Components", "exact"),
    ("QuestionCard", "Views/Components", "exact"),
    # --- Suffix-based routing ---
    ("ViewModel", "ViewModels", "suffix"),
    ("Service", "Services", "suffix"),
    ("Manager", "Services", "suffix"),
    ("Protocol", "Services", "suffix"),
    # --- Contains-based routing (broadest, last) ---
    ("Mock", "Tests/Helpers", "contains"),
    ("Tests", "Tests", "suffix"),
    ("View", "Views", "suffix"),
]

# Suffix-based fallback (same logic as code_extractor.py SUBFOLDER_MAP)
SUFFIX_FOLDER_MAP = {
    "ViewModel": "ViewModels",
    "View": "Views",
    "Service": "Services",
    "Model": "Models",
}


# ---------------------------------------------------------------------------
# Data classes
# ---------------------------------------------------------------------------

@dataclass
class Artifact:
    """A single Swift file artifact collected from any source."""
    filename: str           # e.g. "SkillMapView.swift"
    original_path: str      # path as found (may be flat or nested)
    content: str
    source: str             # "generated_code", "log:<logfile>", "export:<dir>"
    line_count: int = 0
    keyword_count: int = 0
    ends_with_brace: bool = False
    is_truncated: bool = False

    def __post_init__(self):
        self.line_count = len(self.content.splitlines())
        self.keyword_count = sum(
            1 for word in re.findall(r'\b\w+\b', self.content)
            if word in SWIFT_KEYWORDS
        )
        stripped = self.content.rstrip()
        self.ends_with_brace = stripped.endswith("}")
        self.is_truncated = (
            len(self.content) < MIN_FILE_LENGTH
            or not self.ends_with_brace
            or _has_agent_leakage(self.content)
        )


@dataclass
class IntegrationReport:
    """Structured result of an integration run."""
    files_collected: int = 0
    files_normalized: int = 0
    files_written: int = 0
    files_skipped: int = 0
    truncated_detected: list[str] = field(default_factory=list)
    normalized_paths: list[tuple[str, str]] = field(default_factory=list)
    written_files: list[str] = field(default_factory=list)
    skipped_files: list[tuple[str, str]] = field(default_factory=list)
    errors: list[str] = field(default_factory=list)

    def to_dict(self) -> dict:
        return {
            "files_collected": self.files_collected,
            "files_normalized": self.files_normalized,
            "files_written": self.files_written,
            "files_skipped": self.files_skipped,
            "truncated_detected": self.truncated_detected,
            "normalized_paths": [
                {"from": f, "to": t} for f, t in self.normalized_paths
            ],
            "written_files": self.written_files,
            "skipped_files": [
                {"file": f, "reason": r} for f, r in self.skipped_files
            ],
            "errors": self.errors,
        }

    def print_summary(self):
        print()
        print("=" * 50)
        print("  Output Integrator Summary")
        print("=" * 50)
        print(f"  Artifacts collected:   {self.files_collected}")
        print(f"  Artifacts normalized:  {self.files_normalized}")
        print(f"  Artifacts written:     {self.files_written}")
        print(f"  Truncated detected:    {len(self.truncated_detected)}")
        print(f"  Skipped (duplicates):  {self.files_skipped}")
        if self.truncated_detected:
            print()
            print("  Truncated files:")
            for f in self.truncated_detected:
                print(f"    - {f}")
        if self.normalized_paths:
            print()
            print("  Normalized paths:")
            for orig, norm in self.normalized_paths:
                print(f"    {orig} -> {norm}")
        if self.errors:
            print()
            print("  Errors:")
            for e in self.errors:
                print(f"    ! {e}")
        print("=" * 50)
        print()


# ---------------------------------------------------------------------------
# Helper functions
# ---------------------------------------------------------------------------

def _has_agent_leakage(content: str) -> bool:
    """Detect agent name tags or markdown headers leaked into Swift code."""
    # Agent tags like [reviewer], [swift_developer], [bug_hunter]
    if re.search(r'^\[[\w_]+\]\s*$', content, re.MULTILINE):
        return True
    # Markdown headers inside Swift (not comments)
    lines = content.splitlines()
    for line in lines:
        stripped = line.strip()
        if stripped.startswith("# ") and not stripped.startswith("// "):
            # Could be markdown, but also Swift compiler directives — check context
            if not stripped.startswith("#if ") and not stripped.startswith("#else") \
               and not stripped.startswith("#endif") and not stripped.startswith("#available"):
                return True
    return False


def _normalize_content(content: str) -> str:
    """Remove agent leakage and trailing markdown from Swift content."""
    lines = content.splitlines()
    cleaned: list[str] = []

    for line in lines:
        stripped = line.strip()
        # Remove agent name tags
        if re.match(r'^\[[\w_]+\]\s*$', stripped):
            continue
        # Remove markdown headers (not Swift preprocessor directives)
        if stripped.startswith("# ") and not any(
            stripped.startswith(d) for d in ("#if ", "#else", "#endif", "#available")
        ):
            continue
        # Remove markdown formatting leaked into code
        if stripped.startswith("## ") or stripped.startswith("### "):
            continue
        cleaned.append(line)

    result = "\n".join(cleaned)

    # Remove trailing markdown after last closing brace at depth 0
    depth = 0
    last_zero_brace = -1
    for i, ch in enumerate(result):
        if ch == "{":
            depth += 1
        elif ch == "}":
            depth -= 1
            if depth == 0:
                last_zero_brace = i

    if last_zero_brace > 0:
        after = result[last_zero_brace + 1:].strip()
        # If there's substantial non-whitespace after the last balanced brace,
        # it's likely leaked markdown — trim it
        if after and not after.startswith("//"):
            result = result[:last_zero_brace + 1] + "\n"

    return result


def _count_swift_keywords(content: str) -> int:
    """Count Swift structural keywords in content."""
    return sum(
        1 for word in re.findall(r'\b\w+\b', content)
        if word in SWIFT_KEYWORDS
    )


def _check_brace_balance(content: str) -> bool:
    """Check if braces are balanced in Swift code."""
    # Strip string literals and comments to avoid false counts
    # Simple approach: just count { and }
    opens = content.count("{")
    closes = content.count("}")
    return opens == closes and opens > 0


def _normalize_path(filename: str, original_dir: str) -> str:
    """Determine the canonical directory for a Swift file.

    Priority:
    1. If original_dir already contains a nested path (e.g. Views/Training/) → keep it
    2. Match filename against PATH_NORMALIZATION_RULES
    3. Fall back to SUFFIX_FOLDER_MAP
    4. Default to Models/
    """
    name_stem = Path(filename).stem  # e.g. "SkillMapView"

    # Match by rules (exact → suffix → contains)
    for pattern, target_dir, match_mode in PATH_NORMALIZATION_RULES:
        if match_mode == "exact" and name_stem == pattern:
            return target_dir
        elif match_mode == "suffix" and name_stem.endswith(pattern):
            return target_dir
        elif match_mode == "contains" and pattern in name_stem:
            return target_dir

    # Suffix-based fallback
    for suffix, folder in SUFFIX_FOLDER_MAP.items():
        if name_stem.endswith(suffix):
            return folder

    # Default
    return "Models"


# ---------------------------------------------------------------------------
# Log extraction
# ---------------------------------------------------------------------------

# Pattern: ### `path/to/File.swift` or ### `File.swift`
_LOG_HEADER_RE = re.compile(
    r'^###\s+`([^`]+\.swift)`',
    re.MULTILINE
)

# Swift code block in logs
_CODE_BLOCK_RE = re.compile(
    r'```swift\s*\n(.*?)```',
    re.DOTALL
)


def extract_from_log(log_path: str) -> list[Artifact]:
    """Extract Swift artifacts from a pipeline log file.

    Scans for patterns like:
        ### `Views/Training/QuestionCardView.swift`
        ```swift
        ...code...
        ```

    If multiple versions of the same file appear, keeps the LAST occurrence.
    """
    try:
        with open(log_path, encoding="utf-8", errors="replace") as f:
            content = f.read()
    except (OSError, IOError):
        return []

    source_label = f"log:{Path(log_path).name}"
    artifacts_by_name: dict[str, Artifact] = {}

    # Strategy: find all header positions, then for each header find the next
    # code block that follows it
    headers = list(_LOG_HEADER_RE.finditer(content))

    for i, header_match in enumerate(headers):
        file_path = header_match.group(1).strip()
        filename = Path(file_path).name
        header_end = header_match.end()

        # Search for the next ```swift block after this header
        # but before the next header (if any)
        search_end = headers[i + 1].start() if i + 1 < len(headers) else len(content)
        region = content[header_end:search_end]

        code_match = _CODE_BLOCK_RE.search(region)
        if not code_match:
            continue

        code = code_match.group(1).strip()
        if not code or len(code) < 10:
            continue

        # Determine original directory from the header path
        original_dir = str(Path(file_path).parent) if "/" in file_path else ""

        # Keep LAST occurrence (overwrite previous)
        artifacts_by_name[filename] = Artifact(
            filename=filename,
            original_path=file_path,
            content=code,
            source=source_label,
        )

    return list(artifacts_by_name.values())


# ---------------------------------------------------------------------------
# Filesystem collection
# ---------------------------------------------------------------------------

def collect_from_directory(directory: str, source_label: str) -> list[Artifact]:
    """Recursively collect all .swift files from a directory."""
    artifacts: list[Artifact] = []
    root = Path(directory)

    if not root.exists():
        return artifacts

    for swift_file in root.rglob("*.swift"):
        try:
            content = swift_file.read_text(encoding="utf-8", errors="replace")
        except (OSError, IOError):
            continue

        if not content.strip():
            continue

        # Preserve the relative path from the collection root
        rel_path = swift_file.relative_to(root)
        original_dir = str(rel_path.parent) if rel_path.parent != Path(".") else ""

        artifacts.append(Artifact(
            filename=swift_file.name,
            original_path=str(rel_path),
            content=content,
            source=source_label,
        ))

    return artifacts


# ---------------------------------------------------------------------------
# Version selection
# ---------------------------------------------------------------------------

def select_best_version(candidates: list[Artifact]) -> Artifact:
    """Select the best version from multiple candidates of the same file.

    Selection rules (in priority order):
    1. Longest file (by character count)
    2. File that ends with a closing brace "}"
    3. File with the most Swift structural keywords
    """
    if len(candidates) == 1:
        return candidates[0]

    def score(artifact: Artifact) -> tuple:
        return (
            len(artifact.content),            # longest first
            1 if artifact.ends_with_brace else 0,  # complete first
            artifact.keyword_count,           # most keywords first
        )

    return max(candidates, key=score)


# ---------------------------------------------------------------------------
# Main integrator
# ---------------------------------------------------------------------------

class OutputIntegrator:
    """Collects, normalizes, deduplicates, and writes pipeline artifacts."""

    def __init__(
        self,
        project_name: str = "askfin_premium",
        output_base: str | None = None,
        log_filter: str | None = None,
        clean_before_integrate: bool = True,
    ):
        """
        Args:
            project_name: Target project (used to resolve output directory).
            output_base: Override output directory. If None, uses
                         projects/<project_name>/generated/
            log_filter: If set, only process logs containing this string
                        (e.g. a run ID like "20260313_101710").
            clean_before_integrate: If True, clear the generated/ output dir
                        before writing new artifacts (prevents cross-run accumulation).
        """
        self.project_name = project_name
        self.log_filter = log_filter
        self.clean_before_integrate = clean_before_integrate

        if output_base:
            self.output_dir = Path(output_base)
        else:
            self.output_dir = _PROJECT_ROOT / "projects" / project_name / "generated"

        # Project root dir (non-generated) for dedup checking
        self.project_dir = _PROJECT_ROOT / "projects" / project_name

        self.report = IntegrationReport()

    def run(self) -> IntegrationReport:
        """Execute the full integration pipeline.

        Steps:
        1. Collect artifacts from all sources
        2. Normalize content (remove agent leakage)
        3. Normalize paths (deterministic folder placement)
        4. Select best version per file
        5. Write to project output directory
        6. Generate report
        """
        print(f"\n[OutputIntegrator] Starting integration for project: {self.project_name}")
        print(f"[OutputIntegrator] Output directory: {self.output_dir}")

        # Step 1: Collect from all sources
        all_artifacts = self._collect_all()
        self.report.files_collected = len(all_artifacts)
        print(f"[OutputIntegrator] Collected {len(all_artifacts)} artifacts")

        if not all_artifacts:
            print("[OutputIntegrator] No artifacts found. Nothing to integrate.")
            self.report.print_summary()
            return self.report

        # Step 2: Normalize content
        for artifact in all_artifacts:
            original_len = len(artifact.content)
            artifact.content = _normalize_content(artifact.content)
            if len(artifact.content) != original_len:
                self.report.files_normalized += 1
            # Recompute truncation flags after normalization
            artifact.__post_init__()

        # Step 3: Detect truncated files
        for artifact in all_artifacts:
            if artifact.is_truncated:
                self.report.truncated_detected.append(
                    f"{artifact.filename} ({artifact.source}, {artifact.line_count} lines)"
                )

        # Step 4: Group by filename and select best version
        by_filename: dict[str, list[Artifact]] = {}
        for artifact in all_artifacts:
            by_filename.setdefault(artifact.filename, []).append(artifact)

        best_artifacts: list[Artifact] = []
        for filename, candidates in by_filename.items():
            best = select_best_version(candidates)
            best_artifacts.append(best)
            if len(candidates) > 1:
                self.report.files_skipped += len(candidates) - 1
                for c in candidates:
                    if c is not best:
                        self.report.skipped_files.append((
                            f"{c.filename} ({c.source})",
                            f"shorter version ({len(c.content)} chars vs {len(best.content)} chars)"
                        ))

        # Step 5: Normalize paths and write
        self._write_artifacts(best_artifacts)

        # Step 6: Report
        self.report.print_summary()
        self._write_report_json()

        return self.report

    def _collect_all(self) -> list[Artifact]:
        """Collect artifacts from all known sources."""
        all_artifacts: list[Artifact] = []

        # Source 1: generated_code/
        if GENERATED_CODE_DIR.exists():
            artifacts = collect_from_directory(
                str(GENERATED_CODE_DIR), "generated_code"
            )
            print(f"  [generated_code] {len(artifacts)} files")
            all_artifacts.extend(artifacts)

        # Source 2: Log files
        if LOGS_DIR.exists():
            log_files = sorted(LOGS_DIR.glob("driveai_run_*.txt"))
            if self.log_filter:
                log_files = [f for f in log_files if self.log_filter in f.name]

            for log_file in log_files:
                artifacts = extract_from_log(str(log_file))
                if artifacts:
                    print(f"  [log:{log_file.name}] {len(artifacts)} files")
                    all_artifacts.extend(artifacts)

        # Source 3: Delivery exports
        if DELIVERY_DIR.exists():
            for export_dir in sorted(DELIVERY_DIR.iterdir()):
                if export_dir.is_dir():
                    artifacts = collect_from_directory(
                        str(export_dir), f"export:{export_dir.name}"
                    )
                    if artifacts:
                        print(f"  [export:{export_dir.name}] {len(artifacts)} files")
                        all_artifacts.extend(artifacts)

        # Source 4: Existing project output (for merge comparison)
        if self.output_dir.exists():
            artifacts = collect_from_directory(
                str(self.output_dir), "existing_output"
            )
            if artifacts:
                print(f"  [existing_output] {len(artifacts)} files")
                all_artifacts.extend(artifacts)

        return all_artifacts

    def _write_artifacts(self, artifacts: list[Artifact]):
        """Write normalized artifacts to the output directory."""
        for artifact in artifacts:
            # Determine canonical path
            original_dir = str(Path(artifact.original_path).parent) \
                if "/" in artifact.original_path or "\\" in artifact.original_path \
                else ""
            canonical_dir = _normalize_path(artifact.filename, original_dir)

            # Track normalization
            original_relative = artifact.original_path or artifact.filename
            canonical_relative = f"{canonical_dir}/{artifact.filename}"
            if original_relative != canonical_relative:
                self.report.normalized_paths.append(
                    (original_relative, canonical_relative)
                )

            # Build full output path
            dest_dir = self.output_dir / canonical_dir
            dest_path = dest_dir / artifact.filename

            # Safety: never overwrite a larger file with a smaller one
            if dest_path.exists():
                try:
                    existing_content = dest_path.read_text(encoding="utf-8")
                    existing_len = len(existing_content)
                    new_len = len(artifact.content)

                    if new_len < existing_len:
                        self.report.skipped_files.append((
                            str(dest_path.relative_to(self.output_dir)),
                            f"existing file is larger ({existing_len} > {new_len} chars)"
                        ))
                        self.report.files_skipped += 1
                        continue

                    # Never overwrite a complete file with a truncated one
                    existing_complete = existing_content.rstrip().endswith("}")
                    if existing_complete and not artifact.ends_with_brace:
                        self.report.skipped_files.append((
                            str(dest_path.relative_to(self.output_dir)),
                            "existing file is complete, new version is truncated"
                        ))
                        self.report.files_skipped += 1
                        continue

                    # Skip if content is identical
                    if existing_content == artifact.content:
                        self.report.files_skipped += 1
                        continue

                except (OSError, IOError):
                    pass

            # Write
            dest_dir.mkdir(parents=True, exist_ok=True)
            dest_path.write_text(artifact.content, encoding="utf-8")
            self.report.files_written += 1
            self.report.written_files.append(
                str(dest_path.relative_to(self.output_dir))
            )

    def _write_report_json(self):
        """Write integration report as JSON next to the output directory."""
        report_dir = self.output_dir.parent
        timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
        report_path = report_dir / f"integration_report_{timestamp}.json"

        report_data = {
            "timestamp": timestamp,
            "project": self.project_name,
            "output_dir": str(self.output_dir),
            **self.report.to_dict(),
        }

        try:
            report_path.write_text(
                json.dumps(report_data, indent=2, ensure_ascii=False),
                encoding="utf-8",
            )
            print(f"[OutputIntegrator] Report written to: {report_path}")
        except (OSError, IOError) as e:
            self.report.errors.append(f"Failed to write report: {e}")


# ---------------------------------------------------------------------------
# CLI entry point
# ---------------------------------------------------------------------------

def main():
    """Run the output integrator from the command line."""
    import argparse

    parser = argparse.ArgumentParser(
        description="Factory Output Integrator — collect, normalize, and write pipeline artifacts"
    )
    parser.add_argument(
        "--project", default="askfin_premium",
        help="Project name (default: askfin_premium)"
    )
    parser.add_argument(
        "--output-dir", default=None,
        help="Override output directory (default: projects/<project>/generated/)"
    )
    parser.add_argument(
        "--log-filter", default=None,
        help="Only process logs containing this string (e.g. a run ID)"
    )
    parser.add_argument(
        "--dry-run", action="store_true",
        help="Collect and analyze but do not write files"
    )

    args = parser.parse_args()

    integrator = OutputIntegrator(
        project_name=args.project,
        output_base=args.output_dir,
        log_filter=args.log_filter,
    )

    if args.dry_run:
        # Collect and report without writing
        print("[DRY RUN] Collecting artifacts only — no files will be written.")
        all_artifacts = integrator._collect_all()
        integrator.report.files_collected = len(all_artifacts)

        # Normalize and analyze
        for artifact in all_artifacts:
            artifact.content = _normalize_content(artifact.content)
            artifact.__post_init__()
            if artifact.is_truncated:
                integrator.report.truncated_detected.append(
                    f"{artifact.filename} ({artifact.source}, {artifact.line_count} lines)"
                )

        # Group and show what would happen
        by_filename: dict[str, list[Artifact]] = {}
        for artifact in all_artifacts:
            by_filename.setdefault(artifact.filename, []).append(artifact)

        print(f"\nUnique files: {len(by_filename)}")
        for filename, candidates in sorted(by_filename.items()):
            best = select_best_version(candidates)
            sources = ", ".join(c.source for c in candidates)
            marker = " [TRUNCATED]" if best.is_truncated else ""
            print(f"  {filename}: {len(best.content)} chars, {best.line_count} lines "
                  f"(from: {sources}){marker}")

        integrator.report.print_summary()
    else:
        integrator.run()


if __name__ == "__main__":
    main()
