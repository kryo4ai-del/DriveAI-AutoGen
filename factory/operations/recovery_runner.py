# factory/operations/recovery_runner.py
# Focused recovery mechanism: reads completion reports, identifies missing/incomplete
# artifacts, builds a targeted recovery prompt, and optionally executes a recovery run.
#
# Runs AFTER the Completion Verifier. Builds on Output Integrator + Completion Verifier.

import json
import subprocess
import sys
import datetime
from dataclasses import dataclass, field
from pathlib import Path

from factory.operations.output_integrator import _PROJECT_ROOT, PATH_NORMALIZATION_RULES

# ---------------------------------------------------------------------------
# Directories
# ---------------------------------------------------------------------------
COMPLETION_REPORTS_DIR = _PROJECT_ROOT / "factory" / "reports" / "completion"
RECOVERY_REPORTS_DIR = _PROJECT_ROOT / "factory" / "reports" / "recovery"

# Maximum recovery attempts per project (safety guard)
MAX_RECOVERY_ATTEMPTS = 2

# Recovery state file — persists between attempts within one ops-layer run
RECOVERY_STATE_FILE = RECOVERY_REPORTS_DIR / "recovery_state.json"


# ---------------------------------------------------------------------------
# Failure fingerprinting
# ---------------------------------------------------------------------------

def _build_failure_fingerprint(targets: list["RecoveryTarget"]) -> str:
    """Build a deterministic fingerprint from sorted target filenames + reasons.

    Two failures with the same missing/incomplete files produce the same
    fingerprint, allowing detection of repeated identical failures.
    """
    import hashlib
    parts = sorted(f"{t.filename}:{t.reason}" for t in targets)
    raw = "|".join(parts)
    return hashlib.sha256(raw.encode()).hexdigest()[:16]


# ---------------------------------------------------------------------------
# Recovery state (persisted between attempts)
# ---------------------------------------------------------------------------

@dataclass
class RecoveryState:
    """Structured state handed off between recovery attempts."""
    project_name: str = ""
    attempt_number: int = 0
    failed_stage: str = ""           # e.g. "completion_verifier", "compile_hygiene"
    failure_status: str = ""         # e.g. "incomplete", "failed"
    failure_summary: str = ""        # one-line human-readable reason
    error_excerpt: str = ""          # first 400 chars of error detail
    failure_fingerprint: str = ""    # hash of missing/incomplete file set
    prior_fingerprints: list[str] = field(default_factory=list)
    repeated_failure: bool = False
    timestamp: str = ""

    def to_dict(self) -> dict:
        return {
            "project_name": self.project_name,
            "attempt_number": self.attempt_number,
            "failed_stage": self.failed_stage,
            "failure_status": self.failure_status,
            "failure_summary": self.failure_summary,
            "error_excerpt": self.error_excerpt,
            "failure_fingerprint": self.failure_fingerprint,
            "prior_fingerprints": self.prior_fingerprints,
            "repeated_failure": self.repeated_failure,
            "timestamp": self.timestamp,
        }

    @classmethod
    def from_dict(cls, d: dict) -> "RecoveryState":
        return cls(
            project_name=d.get("project_name", ""),
            attempt_number=d.get("attempt_number", 0),
            failed_stage=d.get("failed_stage", ""),
            failure_status=d.get("failure_status", ""),
            failure_summary=d.get("failure_summary", ""),
            error_excerpt=d.get("error_excerpt", ""),
            failure_fingerprint=d.get("failure_fingerprint", ""),
            prior_fingerprints=d.get("prior_fingerprints", []),
            repeated_failure=d.get("repeated_failure", False),
            timestamp=d.get("timestamp", ""),
        )


def load_recovery_state(project_name: str) -> RecoveryState | None:
    """Load persisted recovery state for a project, if any."""
    if not RECOVERY_STATE_FILE.exists():
        return None
    try:
        data = json.loads(RECOVERY_STATE_FILE.read_text(encoding="utf-8"))
        if data.get("project_name") == project_name:
            return RecoveryState.from_dict(data)
        return None
    except (OSError, json.JSONDecodeError):
        return None


def save_recovery_state(state: RecoveryState) -> None:
    """Persist recovery state to disk."""
    RECOVERY_REPORTS_DIR.mkdir(parents=True, exist_ok=True)
    try:
        RECOVERY_STATE_FILE.write_text(
            json.dumps(state.to_dict(), indent=2, ensure_ascii=False),
            encoding="utf-8",
        )
    except OSError as e:
        print(f"[RecoveryRunner] Error saving recovery state: {e}")


def clear_recovery_state() -> None:
    """Remove recovery state file (called after successful run or terminal stop)."""
    try:
        if RECOVERY_STATE_FILE.exists():
            RECOVERY_STATE_FILE.unlink()
    except OSError:
        pass


# ---------------------------------------------------------------------------
# Data classes
# ---------------------------------------------------------------------------

@dataclass
class RecoveryTarget:
    """A single file that needs recovery."""
    filename: str       # e.g. "TopicPickerView.swift"
    stem: str           # e.g. "TopicPickerView"
    reason: str         # "missing" or "incomplete"
    category: str       # "Views", "ViewModels", "Services", "Models", "Tests"
    target_dir: str     # e.g. "Views/Training"

    def to_dict(self) -> dict:
        return {
            "filename": self.filename,
            "reason": self.reason,
            "category": self.category,
            "target_dir": self.target_dir,
        }


@dataclass
class RecoverySummary:
    """Result of a recovery run."""
    project_name: str = ""
    health_before: str = ""
    targets: list[RecoveryTarget] = field(default_factory=list)
    mode: str = "dry-run"
    prompt_file: str = ""
    command: str = ""
    executed: bool = False
    exit_code: int | None = None
    timestamp: str = ""
    errors: list[str] = field(default_factory=list)
    attempt_number: int = 1
    failure_fingerprint: str = ""
    repeated_failure: bool = False
    outcome: str = ""  # "recovered", "repeated_failure", "terminal_stop", "skipped"

    def to_dict(self) -> dict:
        return {
            "project_name": self.project_name,
            "health_before": self.health_before,
            "targets": [t.to_dict() for t in self.targets],
            "target_count": len(self.targets),
            "mode": self.mode,
            "prompt_file": self.prompt_file,
            "command": self.command,
            "executed": self.executed,
            "exit_code": self.exit_code,
            "timestamp": self.timestamp,
            "errors": self.errors,
            "attempt_number": self.attempt_number,
            "failure_fingerprint": self.failure_fingerprint,
            "repeated_failure": self.repeated_failure,
            "outcome": self.outcome,
        }

    def print_summary(self):
        print()
        print("=" * 55)
        print("  Recovery Runner Summary")
        print("=" * 55)
        print(f"  Project:              {self.project_name}")
        print(f"  Health before:        {self.health_before}")
        print(f"  Recovery targets:     {len(self.targets)}")
        print(f"  Attempt:              {self.attempt_number} / {MAX_RECOVERY_ATTEMPTS}")
        print(f"  Mode:                 {self.mode}")
        if self.failure_fingerprint:
            print(f"  Failure fingerprint:  {self.failure_fingerprint}")
        if self.repeated_failure:
            print(f"  REPEATED FAILURE:     yes (same files failing again)")
        if self.outcome:
            print(f"  Outcome:              {self.outcome.upper()}")
        if self.executed:
            print(f"  Exit code:            {self.exit_code}")
        print(f"  Prompt file:          {self.prompt_file}")
        print(f"  Command:              {self.command}")

        if self.targets:
            print()
            print("  Targets:")
            for t in self.targets:
                reason_tag = "[MISSING]" if t.reason == "missing" else "[INCOMPLETE]"
                print(f"    {reason_tag} {t.target_dir}/{t.filename}")

        if self.errors:
            print()
            print("  Errors:")
            for e in self.errors:
                print(f"    ! {e}")

        print("=" * 55)
        print()


# ---------------------------------------------------------------------------
# Report ingestion
# ---------------------------------------------------------------------------

def load_completion_report(project_name: str) -> dict | None:
    """Load the latest completion report for a project."""
    report_path = COMPLETION_REPORTS_DIR / f"{project_name}_completion.json"
    if not report_path.exists():
        return None
    try:
        return json.loads(report_path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as e:
        print(f"[RecoveryRunner] Error reading completion report: {e}")
        return None


# ---------------------------------------------------------------------------
# Target selection
# ---------------------------------------------------------------------------

def _classify_category(stem: str) -> str:
    """Classify a file stem into a project category."""
    for pattern, target_dir, match_mode in PATH_NORMALIZATION_RULES:
        if match_mode == "exact" and stem == pattern:
            return target_dir.split("/")[0]
        elif match_mode == "suffix" and stem.endswith(pattern):
            return target_dir.split("/")[0]
        elif match_mode == "contains" and pattern in stem:
            return target_dir.split("/")[0]
    # Suffix fallback
    if stem.endswith("ViewModel"):
        return "ViewModels"
    if stem.endswith("View"):
        return "Views"
    if stem.endswith("Service") or stem.endswith("Manager"):
        return "Services"
    if stem.endswith("Tests"):
        return "Tests"
    return "Models"


def _resolve_target_dir(stem: str) -> str:
    """Resolve the canonical target directory for a file."""
    for pattern, target_dir, match_mode in PATH_NORMALIZATION_RULES:
        if match_mode == "exact" and stem == pattern:
            return target_dir
        elif match_mode == "suffix" and stem.endswith(pattern):
            return target_dir
        elif match_mode == "contains" and pattern in stem:
            return target_dir
    if stem.endswith("ViewModel"):
        return "ViewModels"
    if stem.endswith("View"):
        return "Views"
    if stem.endswith("Service") or stem.endswith("Manager"):
        return "Services"
    return "Models"


def build_recovery_targets(report: dict) -> list[RecoveryTarget]:
    """Extract recovery targets from a completion report.

    Sources:
    - missing_files: files expected by spec but not found
    - incomplete_files: files found but truncated or broken
    """
    targets: list[RecoveryTarget] = []
    seen: set[str] = set()

    # Missing files
    for entry in report.get("missing_files", []):
        # entry is like "TopicPickerView.swift"
        filename = entry if entry.endswith(".swift") else f"{entry}.swift"
        stem = filename.replace(".swift", "")
        if stem in seen:
            continue
        seen.add(stem)
        targets.append(RecoveryTarget(
            filename=filename,
            stem=stem,
            reason="missing",
            category=_classify_category(stem),
            target_dir=_resolve_target_dir(stem),
        ))

    # Incomplete files
    for entry in report.get("incomplete_files", []):
        # entry may be like "Views/Training/X.swift (N lines, ...)"
        # extract filename
        parts = entry.split("(")[0].strip()
        filename = Path(parts).name if "/" in parts or "\\" in parts else parts
        if not filename.endswith(".swift"):
            filename = f"{filename}.swift"
        stem = filename.replace(".swift", "")
        if stem in seen:
            continue
        seen.add(stem)
        targets.append(RecoveryTarget(
            filename=filename,
            stem=stem,
            reason="incomplete",
            category=_classify_category(stem),
            target_dir=_resolve_target_dir(stem),
        ))

    return targets


# ---------------------------------------------------------------------------
# Context gathering
# ---------------------------------------------------------------------------

def gather_existing_context(generated_dir: Path) -> str:
    """Build a compact context summary of existing generated files.

    Returns a text block listing existing files by category — enough for the
    recovery prompt to reference existing types, but no full file contents.
    """
    if not generated_dir.exists():
        return "No existing generated files found."

    files_by_dir: dict[str, list[str]] = {}
    for swift_file in sorted(generated_dir.rglob("*.swift")):
        rel = swift_file.relative_to(generated_dir)
        parent = str(rel.parent) if rel.parent != Path(".") else "root"
        files_by_dir.setdefault(parent, []).append(swift_file.stem)

    lines = ["Existing generated files:"]
    for dir_name in sorted(files_by_dir.keys()):
        lines.append(f"  {dir_name}/")
        for stem in sorted(files_by_dir[dir_name]):
            lines.append(f"    - {stem}.swift")

    return "\n".join(lines)


# ---------------------------------------------------------------------------
# Prompt building
# ---------------------------------------------------------------------------

_RECOVERY_PROMPT_TEMPLATE = """\
FOCUSED RECOVERY RUN -- {project_name}
======================================

This is a targeted recovery run. Generate ONLY the files listed below.
Do NOT regenerate files that already exist in the project.

Source spec: {spec_source}
Output directory: projects/{project_name}/generated/
{failure_context_block}
---------------------------------------------
FILES TO GENERATE ({target_count} files)
---------------------------------------------

{target_list}

---------------------------------------------
INSTRUCTIONS
---------------------------------------------

1. Generate complete, production-quality Swift code for each file listed above.
2. Each file must be self-contained and compile-ready.
3. Follow the existing code style and architecture already present in the project.
4. Use German UI text where applicable (AskFin targets German driving theory learners).
5. Dark theme, green accent color scheme.
6. Include proper accessibility labels.
7. Each file MUST end with a closing brace.
8. Do NOT generate stubs or placeholder code.

---------------------------------------------
EXISTING PROJECT CONTEXT
---------------------------------------------

{existing_context}

---------------------------------------------
REFERENCE: EXPECTED FILE STRUCTURE
---------------------------------------------

{file_structure}
"""


def _build_failure_context_block(ctx: "RecoveryState | None") -> str:
    """Build a prompt section from prior failure context, if available."""
    if not ctx or not ctx.failure_summary:
        return ""
    lines = [
        "",
        "---------------------------------------------",
        f"PRIOR FAILURE CONTEXT (attempt {ctx.attempt_number})",
        "---------------------------------------------",
        f"Failed stage: {ctx.failed_stage}",
        f"Status: {ctx.failure_status}",
        f"Reason: {ctx.failure_summary}",
    ]
    if ctx.error_excerpt:
        lines.append(f"Error excerpt: {ctx.error_excerpt[:400]}")
    lines.append("")
    return "\n".join(lines)


def build_recovery_prompt(
    project_name: str,
    spec_source: str,
    targets: list[RecoveryTarget],
    generated_dir: Path,
    failure_context: "RecoveryState | None" = None,
) -> str:
    """Build a deterministic recovery prompt from targets and context."""

    # Target list
    target_lines = []
    by_category: dict[str, list[RecoveryTarget]] = {}
    for t in targets:
        by_category.setdefault(t.category, []).append(t)

    for category in sorted(by_category.keys()):
        target_lines.append(f"{category}:")
        for t in by_category[category]:
            reason_tag = "[MISSING]" if t.reason == "missing" else "[INCOMPLETE]"
            target_lines.append(f"  {reason_tag} {t.target_dir}/{t.filename}")
        target_lines.append("")

    # Existing context
    existing_context = gather_existing_context(generated_dir)

    # File structure reference
    structure_lines = []
    for t in targets:
        structure_lines.append(f"  projects/{project_name}/generated/{t.target_dir}/{t.filename}")

    # Failure context block (empty string if no prior failure)
    failure_context_block = _build_failure_context_block(failure_context)

    return _RECOVERY_PROMPT_TEMPLATE.format(
        project_name=project_name,
        spec_source=spec_source,
        target_count=len(targets),
        target_list="\n".join(target_lines),
        existing_context=existing_context,
        file_structure="\n".join(structure_lines),
        failure_context_block=failure_context_block,
    )


# ---------------------------------------------------------------------------
# Execution
# ---------------------------------------------------------------------------

def build_recovery_command(
    project_name: str,
    prompt_file: Path,
    env_profile: str = "standard",
) -> str:
    """Build the CLI command to execute a recovery run."""
    return (
        f"python main.py "
        f"--task-file \"{prompt_file}\" "
        f"--env-profile {env_profile} "
        f"--mode standard "
        f"--approval off "
        f"--template feature "
        f"--no-cd-gate"
    )


# ---------------------------------------------------------------------------
# Main runner
# ---------------------------------------------------------------------------

class RecoveryRunner:
    """Reads completion reports and runs focused recovery for missing artifacts.

    Accepts optional failure_context (RecoveryState) from the operations layer
    to enable stateful recovery: attempt counting, fingerprint comparison,
    and repeated-failure detection.
    """

    def __init__(
        self,
        project_name: str = "askfin_premium",
        env_profile: str = "standard",
        dry_run: bool = True,
        failure_context: RecoveryState | None = None,
    ):
        self.project_name = project_name
        self.env_profile = env_profile
        self.dry_run = dry_run
        self.generated_dir = _PROJECT_ROOT / "projects" / project_name / "generated"
        self.failure_context = failure_context

        # Determine attempt number from state
        attempt = 1
        if failure_context and failure_context.attempt_number > 0:
            attempt = failure_context.attempt_number

        self.summary = RecoverySummary(
            project_name=project_name,
            mode="dry-run" if dry_run else "execute",
            timestamp=datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
            attempt_number=attempt,
        )

    def run(self) -> RecoverySummary:
        """Execute the recovery pipeline with stateful failure awareness.

        Steps:
        1. Load completion report
        2. Check attempt limit (MAX_RECOVERY_ATTEMPTS)
        3. Build recovery targets + fingerprint
        4. Detect repeated identical failure
        5. Build focused recovery prompt (with failure context)
        6. Save prompt file
        7. Execute or show command (depending on mode)
        8. Update and save recovery state + summary
        """
        attempt = self.summary.attempt_number
        print(f"\n[RecoveryRunner] Starting recovery for project: {self.project_name}")
        print(f"[RecoveryRunner] Attempt: {attempt} / {MAX_RECOVERY_ATTEMPTS}")
        print(f"[RecoveryRunner] Mode: {'dry-run' if self.dry_run else 'execute'}")

        # Step 1: Check attempt limit
        if attempt > MAX_RECOVERY_ATTEMPTS:
            msg = (f"Recovery attempt {attempt} exceeds MAX_RECOVERY_ATTEMPTS "
                   f"({MAX_RECOVERY_ATTEMPTS}). Stopping.")
            print(f"[RecoveryRunner] {msg}")
            self.summary.errors.append(msg)
            self.summary.outcome = "terminal_stop"
            self.summary.print_summary()
            self._save_summary()
            clear_recovery_state()
            return self.summary

        # Step 2: Load completion report
        report = load_completion_report(self.project_name)
        if report is None:
            msg = (f"No completion report found at "
                   f"{COMPLETION_REPORTS_DIR / f'{self.project_name}_completion.json'}. "
                   f"Run the Completion Verifier first.")
            print(f"[RecoveryRunner] {msg}")
            self.summary.errors.append(msg)
            self.summary.outcome = "skipped"
            self.summary.print_summary()
            return self.summary

        self.summary.health_before = report.get("health", "unknown")
        print(f"[RecoveryRunner] Health status: {self.summary.health_before}")

        # Check if recovery is needed
        if self.summary.health_before == "complete":
            print("[RecoveryRunner] Project is complete. No recovery needed.")
            self.summary.outcome = "skipped"
            self.summary.print_summary()
            self._save_summary()
            clear_recovery_state()
            return self.summary

        # Step 3: Build recovery targets
        targets = build_recovery_targets(report)
        self.summary.targets = targets

        if not targets:
            print("[RecoveryRunner] No missing or incomplete files found. No recovery needed.")
            self.summary.outcome = "skipped"
            self.summary.print_summary()
            self._save_summary()
            clear_recovery_state()
            return self.summary

        # Step 4: Fingerprint + repeated failure detection
        fingerprint = _build_failure_fingerprint(targets)
        self.summary.failure_fingerprint = fingerprint
        print(f"[RecoveryRunner] Failure fingerprint: {fingerprint}")

        prior_fps = []
        if self.failure_context:
            prior_fps = list(self.failure_context.prior_fingerprints)
            if self.failure_context.failure_fingerprint:
                prior_fps.append(self.failure_context.failure_fingerprint)

        if fingerprint in prior_fps:
            self.summary.repeated_failure = True
            msg = (f"REPEATED FAILURE detected: fingerprint {fingerprint} matches "
                   f"a prior attempt. Same files are failing again.")
            print(f"[RecoveryRunner] {msg}")
            self.summary.errors.append(msg)
            self.summary.outcome = "repeated_failure"
            self.summary.print_summary()
            self._save_summary()
            # Save state so run_memory can record the repeated failure
            self._save_state(fingerprint, prior_fps)
            return self.summary

        print(f"[RecoveryRunner] Recovery targets: {len(targets)}")
        for t in targets:
            print(f"  [{t.reason.upper()}] {t.target_dir}/{t.filename}")

        # Log failure context if available
        if self.failure_context and self.failure_context.failure_summary:
            print(f"[RecoveryRunner] Prior failure: {self.failure_context.failure_summary}")

        # Step 5: Build recovery prompt (enriched with failure context)
        spec_source = report.get("spec_source", "unknown")
        prompt = build_recovery_prompt(
            project_name=self.project_name,
            spec_source=spec_source,
            targets=targets,
            generated_dir=self.generated_dir,
            failure_context=self.failure_context,
        )

        # Step 6: Save prompt file
        RECOVERY_REPORTS_DIR.mkdir(parents=True, exist_ok=True)
        prompt_path = RECOVERY_REPORTS_DIR / f"{self.project_name}_recovery_prompt.txt"
        prompt_path.write_text(prompt, encoding="utf-8")
        self.summary.prompt_file = str(prompt_path)
        print(f"[RecoveryRunner] Prompt saved to: {prompt_path}")

        # Step 7: Build command
        command = build_recovery_command(
            project_name=self.project_name,
            prompt_file=prompt_path,
            env_profile=self.env_profile,
        )
        self.summary.command = command

        if self.dry_run:
            print()
            print("-" * 55)
            print("  DRY RUN -- Recovery prompt preview")
            print("-" * 55)
            prompt_lines = prompt.splitlines()
            for line in prompt_lines[:40]:
                print(f"  {line}")
            if len(prompt_lines) > 40:
                print(f"  ... ({len(prompt_lines) - 40} more lines)")
            print("-" * 55)
            print()
            print("  To execute recovery, run:")
            print(f"  {command}")
            print()
            print("  Or run this module without --dry-run:")
            print(f"  python -m factory.operations.recovery_runner "
                  f"--project {self.project_name}")
            print("-" * 55)
            self.summary.outcome = "recovered"
        else:
            # Step 7b: Execute
            self._execute(command)
            self.summary.outcome = "recovered" if self.summary.exit_code == 0 else "terminal_stop"

        # Step 8: Save state + summary
        self._save_state(fingerprint, prior_fps)
        self.summary.print_summary()
        self._save_summary()

        return self.summary

    def _execute(self, command: str):
        """Execute the recovery command as a subprocess."""
        print(f"\n[RecoveryRunner] Executing: {command}")
        print("[RecoveryRunner] This may take several minutes...")

        try:
            result = subprocess.run(
                command,
                shell=True,
                cwd=str(_PROJECT_ROOT),
                capture_output=False,  # let output stream to console
                timeout=600,  # 10 minute timeout
            )
            self.summary.executed = True
            self.summary.exit_code = result.returncode

            if result.returncode == 0:
                print(f"\n[RecoveryRunner] Recovery run completed (exit code 0)")
            else:
                msg = f"Recovery run exited with code {result.returncode}"
                print(f"\n[RecoveryRunner] {msg}")
                self.summary.errors.append(msg)

        except subprocess.TimeoutExpired:
            msg = "Recovery run timed out after 10 minutes"
            print(f"\n[RecoveryRunner] {msg}")
            self.summary.errors.append(msg)
            self.summary.executed = True
            self.summary.exit_code = -1

        except Exception as e:
            msg = f"Recovery execution failed: {e}"
            print(f"\n[RecoveryRunner] {msg}")
            self.summary.errors.append(msg)

    def _save_state(self, fingerprint: str, prior_fingerprints: list[str]):
        """Persist recovery state for potential next attempt."""
        state = RecoveryState(
            project_name=self.project_name,
            attempt_number=self.summary.attempt_number,
            failed_stage=self.failure_context.failed_stage if self.failure_context else "completion_verifier",
            failure_status=self.summary.health_before,
            failure_summary=(self.failure_context.failure_summary if self.failure_context
                             else f"{len(self.summary.targets)} targets ({self.summary.health_before})"),
            error_excerpt=self.failure_context.error_excerpt if self.failure_context else "",
            failure_fingerprint=fingerprint,
            prior_fingerprints=prior_fingerprints,
            repeated_failure=self.summary.repeated_failure,
            timestamp=self.summary.timestamp,
        )
        save_recovery_state(state)

    def _save_summary(self):
        """Save recovery summary as JSON."""
        RECOVERY_REPORTS_DIR.mkdir(parents=True, exist_ok=True)
        summary_path = RECOVERY_REPORTS_DIR / f"{self.project_name}_recovery_summary.json"

        try:
            summary_path.write_text(
                json.dumps(self.summary.to_dict(), indent=2, ensure_ascii=False),
                encoding="utf-8",
            )
            print(f"[RecoveryRunner] Summary saved to: {summary_path}")
        except (OSError, IOError) as e:
            print(f"[RecoveryRunner] Error saving summary: {e}")


# ---------------------------------------------------------------------------
# CLI entry point
# ---------------------------------------------------------------------------

def main():
    """Run the recovery runner from the command line."""
    import argparse

    parser = argparse.ArgumentParser(
        description="Factory Recovery Runner -- focused recovery for missing/incomplete artifacts"
    )
    parser.add_argument(
        "--project", default="askfin_premium",
        help="Project name (default: askfin_premium)"
    )
    parser.add_argument(
        "--env-profile", default="standard",
        help="LLM env profile for recovery run (default: standard)"
    )
    parser.add_argument(
        "--dry-run", action="store_true", default=True,
        help="Show recovery plan without executing (default: true)"
    )
    parser.add_argument(
        "--execute", action="store_true", default=False,
        help="Actually execute the recovery run"
    )

    args = parser.parse_args()

    # --execute overrides --dry-run
    dry_run = not args.execute

    runner = RecoveryRunner(
        project_name=args.project,
        env_profile=args.env_profile,
        dry_run=dry_run,
    )
    runner.run()


if __name__ == "__main__":
    main()
