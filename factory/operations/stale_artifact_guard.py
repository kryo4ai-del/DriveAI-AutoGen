# factory/operations/stale_artifact_guard.py
# Post-hygiene stale artifact lifecycle guard.
#
# After all repair passes (StubGen, ShapeRepairer), if BLOCKING issues
# remain, this guard checks whether the blocking files were generated
# by a prior factory run and are persisting as stale artifacts.
#
# Stale artifacts are quarantined (moved, not deleted) so the project
# baseline becomes clean without losing the file permanently.
#
# Deterministic, no LLM. Uses git blame for provenance.

import json
import re
import shutil
import subprocess
from dataclasses import dataclass, field
from datetime import datetime
from pathlib import Path

_PROJECT_ROOT = Path(__file__).resolve().parent.parent.parent
REPORTS_DIR = _PROJECT_ROOT / "factory" / "reports" / "lifecycle"

# Git commit message prefix that indicates an AI-generated run
_AI_RUN_COMMIT_PREFIX = "AI run:"


# ---------------------------------------------------------------------------
# Provenance detection
# ---------------------------------------------------------------------------

def _get_file_provenance(file_path: Path, project_root: Path) -> dict:
    """Check git blame to determine if a file was added by an AI run.

    Returns: {
        "is_ai_generated": bool,
        "commit_hash": str,
        "commit_message": str,
        "author_date": str,
    }
    """
    result = {
        "is_ai_generated": False,
        "commit_hash": "",
        "commit_message": "",
        "author_date": "",
    }

    try:
        # Get the commit that added this file (first commit touching it)
        log_out = subprocess.run(
            ["git", "log", "--diff-filter=A", "--format=%H|%s|%ai",
             "--follow", "--", str(file_path)],
            capture_output=True, text=True, cwd=str(project_root),
            timeout=10,
        )
        if log_out.returncode != 0 or not log_out.stdout.strip():
            return result

        # Take the last line (first commit that added the file)
        lines = log_out.stdout.strip().splitlines()
        first_add = lines[-1] if lines else ""
        parts = first_add.split("|", 2)
        if len(parts) < 3:
            return result

        result["commit_hash"] = parts[0][:8]
        result["commit_message"] = parts[1]
        result["author_date"] = parts[2]
        result["is_ai_generated"] = parts[1].startswith(_AI_RUN_COMMIT_PREFIX)

    except (subprocess.TimeoutExpired, OSError):
        pass

    return result


# ---------------------------------------------------------------------------
# Data classes
# ---------------------------------------------------------------------------

@dataclass
class QuarantineAction:
    """One file quarantined."""
    filename: str
    original_path: str
    quarantine_path: str
    blocking_issue: str
    provenance: dict = field(default_factory=dict)


@dataclass
class LifecycleReport:
    """Summary of stale artifact guard actions."""
    project: str = ""
    blocking_files_checked: int = 0
    ai_generated_found: int = 0
    quarantined: int = 0
    kept: int = 0
    actions: list[QuarantineAction] = field(default_factory=list)
    kept_reasons: list[dict] = field(default_factory=list)

    def print_summary(self):
        print()
        print("=" * 60)
        print("  Stale Artifact Guard")
        print("=" * 60)
        print(f"  Project:              {self.project}")
        print(f"  Blocking files:       {self.blocking_files_checked}")
        print(f"  AI-generated:         {self.ai_generated_found}")
        print(f"  Quarantined:          {self.quarantined}")
        print(f"  Kept (not stale):     {self.kept}")
        if self.actions:
            print()
            for a in self.actions:
                print(f"  [QUARANTINED] {a.filename}")
                print(f"                from: {a.original_path}")
                print(f"                  to: {a.quarantine_path}")
                print(f"                issue: {a.blocking_issue}")
                print(f"                provenance: {a.provenance.get('commit_hash', '?')} "
                      f"({a.provenance.get('author_date', '?')[:10]})")
        if self.kept_reasons:
            print()
            for k in self.kept_reasons:
                print(f"  [KEPT] {k['filename']}: {k['reason']}")
        print("=" * 60)


# ---------------------------------------------------------------------------
# Main guard
# ---------------------------------------------------------------------------

class StaleArtifactGuard:
    """Detect and quarantine stale AI-generated artifacts that persist as blockers."""

    def __init__(self, project_name: str, project_dir: Path | None = None):
        self.project_name = project_name
        self.project_dir = project_dir or (_PROJECT_ROOT / "projects" / project_name)
        self.quarantine_dir = self.project_dir / "quarantine"
        self.report = LifecycleReport(project=project_name)

    def check_and_quarantine(self, hygiene_report) -> LifecycleReport:
        """Check BLOCKING issues for stale AI-generated artifacts.

        Only quarantines files that:
        1. Are referenced in a BLOCKING hygiene issue
        2. Were added by an AI run commit (git provenance)
        3. Are not in a protected set (App/, core config files)

        Args:
            hygiene_report: HygieneReport from compile_hygiene_validator
        """
        # Extract files from BLOCKING issues
        blocking_files: list[tuple[str, str]] = []  # (rel_path, issue_message)
        for issue in hygiene_report.issues:
            if issue.severity.value != "blocking":
                continue
            if issue.file:
                blocking_files.append((issue.file, issue.message))

        self.report.blocking_files_checked = len(blocking_files)

        if not blocking_files:
            print("[StaleGuard] No blocking files to check.")
            return self.report

        print(f"[StaleGuard] Checking {len(blocking_files)} blocking file(s) for stale artifacts...")

        for rel_path, issue_msg in blocking_files:
            abs_path = self.project_dir / rel_path

            if not abs_path.exists():
                self.report.kept_reasons.append({
                    "filename": rel_path,
                    "reason": "file does not exist",
                })
                self.report.kept += 1
                continue

            # Safety: never quarantine protected paths
            if self._is_protected(rel_path):
                self.report.kept_reasons.append({
                    "filename": rel_path,
                    "reason": "protected path",
                })
                self.report.kept += 1
                continue

            # Check provenance
            provenance = _get_file_provenance(abs_path, _PROJECT_ROOT)

            if not provenance["is_ai_generated"]:
                self.report.kept_reasons.append({
                    "filename": rel_path,
                    "reason": f"not AI-generated (commit: {provenance.get('commit_message', 'unknown')[:50]})",
                })
                self.report.kept += 1
                continue

            self.report.ai_generated_found += 1

            # Quarantine: move to quarantine/ with timestamp
            self.quarantine_dir.mkdir(parents=True, exist_ok=True)
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            quarantine_name = f"{timestamp}_{abs_path.name}"
            quarantine_path = self.quarantine_dir / quarantine_name

            shutil.move(str(abs_path), str(quarantine_path))

            self.report.actions.append(QuarantineAction(
                filename=abs_path.name,
                original_path=rel_path,
                quarantine_path=str(quarantine_path.relative_to(self.project_dir)),
                blocking_issue=issue_msg[:100],
                provenance=provenance,
            ))
            self.report.quarantined += 1
            print(f"  [QUARANTINE] {rel_path} -> quarantine/{quarantine_name}")

        # Save report
        REPORTS_DIR.mkdir(parents=True, exist_ok=True)
        report_path = REPORTS_DIR / f"{self.project_name}_lifecycle.json"
        report_dict = {
            "project": self.report.project,
            "timestamp": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
            "blocking_files_checked": self.report.blocking_files_checked,
            "ai_generated_found": self.report.ai_generated_found,
            "quarantined": self.report.quarantined,
            "kept": self.report.kept,
            "actions": [
                {
                    "filename": a.filename,
                    "original_path": a.original_path,
                    "quarantine_path": a.quarantine_path,
                    "blocking_issue": a.blocking_issue,
                    "provenance": a.provenance,
                }
                for a in self.report.actions
            ],
            "kept_reasons": self.report.kept_reasons,
        }
        report_path.write_text(json.dumps(report_dict, indent=2), encoding="utf-8")
        print(f"\n[StaleGuard] Report written to: {report_path}")

        return self.report

    def _is_protected(self, rel_path: str) -> bool:
        """Check if a file is in a protected path that should never be quarantined."""
        protected_prefixes = (
            "App/",           # App entry point
            "Config/",        # Configuration
            "Resources/",     # Assets
        )
        protected_files = {
            "Info.plist",
            "ContentView.swift",
            "AppDelegate.swift",
        }

        for prefix in protected_prefixes:
            if rel_path.startswith(prefix):
                return True

        filename = Path(rel_path).name
        return filename in protected_files
