# factory/operations/run_memory.py
# Records run outcomes to factory/memory/run_history.json for pattern analysis.
# Read-only against pipeline — only reads reports, writes JSON, prints summary.

import json
import os
from datetime import datetime
from pathlib import Path

# ---------------------------------------------------------------------------
# Project root — two levels up from this file
# ---------------------------------------------------------------------------
_PROJECT_ROOT = Path(__file__).resolve().parent.parent.parent

# Memory storage
MEMORY_DIR = _PROJECT_ROOT / "factory" / "memory"
HISTORY_FILE = MEMORY_DIR / "run_history.json"

# Reports directories (read-only)
COMPLETION_REPORTS_DIR = _PROJECT_ROOT / "factory" / "reports" / "completion"
RECOVERY_REPORTS_DIR = _PROJECT_ROOT / "factory" / "reports" / "recovery"


# ---------------------------------------------------------------------------
# Core functions
# ---------------------------------------------------------------------------

def record_run(
    project_name: str,
    completion_report: dict,
    recovery_attempts: int = 0,
    recovery_outcome: str = "none",
) -> dict:
    """Build a run record from a completion report dict and store it.

    Args:
        project_name: e.g. "askfin_premium"
        completion_report: the dict returned by VerificationReport.to_dict()
        recovery_attempts: number of recovery attempts made (0 = no recovery)
        recovery_outcome: "none", "recovered", "repeated_failure", "terminal_stop", "skipped"

    Returns:
        The run record that was stored.
    """
    run_id = datetime.now().strftime("%Y%m%d_%H%M%S")
    timestamp = datetime.now().isoformat()

    # Extract fields from completion report
    summary = completion_report.get("summary", {})
    health = completion_report.get("health", "unknown")
    missing = completion_report.get("missing_files", [])
    incomplete = completion_report.get("incomplete_files", [])
    expected = summary.get("expected", 0)
    actual = summary.get("actual", 0)
    completeness = completion_report.get("completeness_pct", 0.0)

    # Read recovery state for fingerprint (if available)
    recovery_fingerprint = ""
    repeated_failure = False
    recovery_summary_path = RECOVERY_REPORTS_DIR / f"{project_name}_recovery_summary.json"
    if recovery_summary_path.exists():
        try:
            with open(recovery_summary_path, "r", encoding="utf-8") as f:
                recovery_data = json.load(f)
            recovery_fingerprint = recovery_data.get("failure_fingerprint", "")
            repeated_failure = recovery_data.get("repeated_failure", False)
        except (json.JSONDecodeError, OSError):
            pass

    run_record = {
        "run_id": run_id,
        "timestamp": timestamp,
        "status": health,
        "completeness_pct": completeness,
        "expected_files": expected,
        "actual_files": actual,
        "missing_files": missing,
        "truncated_files": incomplete,
        "recovery_attempts": recovery_attempts,
        "recovery_outcome": recovery_outcome,
        "recovery_fingerprint": recovery_fingerprint,
        "repeated_failure": repeated_failure,
    }

    store_run_history(project_name, run_record)
    return run_record


def store_run_history(project_name: str, run_record: dict) -> None:
    """Append a run record to the project's history in run_history.json."""
    MEMORY_DIR.mkdir(parents=True, exist_ok=True)

    history = load_run_history()

    # Find or create the project entry
    project_entry = None
    for entry in history:
        if entry.get("project") == project_name:
            project_entry = entry
            break

    if project_entry is None:
        project_entry = {"project": project_name, "runs": []}
        history.append(project_entry)

    project_entry["runs"].append(run_record)

    # Write back
    with open(HISTORY_FILE, "w", encoding="utf-8") as f:
        json.dump(history, f, indent=2, ensure_ascii=False)


def load_run_history() -> list[dict]:
    """Load the full run history from run_history.json.

    Returns:
        List of project entries, each with "project" and "runs" keys.
        Returns empty list if file doesn't exist or is invalid.
    """
    if not HISTORY_FILE.exists():
        return []

    try:
        with open(HISTORY_FILE, "r", encoding="utf-8") as f:
            data = json.load(f)
        if isinstance(data, list):
            return data
        return []
    except (json.JSONDecodeError, OSError):
        return []


def summarize_run_history(project_name: str) -> str:
    """Generate a human-readable summary of run history for a project.

    Returns:
        Formatted summary string.
    """
    history = load_run_history()

    # Find project entry
    runs = []
    for entry in history:
        if entry.get("project") == project_name:
            runs = entry.get("runs", [])
            break

    if not runs:
        return f"[RunMemory] No run history for project '{project_name}'."

    # Count recurring missing files
    missing_counts: dict[str, int] = {}
    for run in runs:
        for f in run.get("missing_files", []):
            missing_counts[f] = missing_counts.get(f, 0) + 1

    # Count recurring truncated files
    truncated_counts: dict[str, int] = {}
    for run in runs:
        for f in run.get("truncated_files", []):
            truncated_counts[f] = truncated_counts.get(f, 0) + 1

    # Count recovery runs (support both old and new format)
    recovery_count = sum(
        1 for r in runs
        if r.get("recovery_attempts", 0) > 0 or r.get("recovery_triggered", False)
    )
    repeated_failure_count = sum(1 for r in runs if r.get("repeated_failure", False))

    # Latest run details
    latest = runs[-1]
    latest_outcome = latest.get("recovery_outcome", "none")

    # Build summary
    lines = [
        "",
        "=" * 55,
        "  Run Memory Summary",
        "=" * 55,
        f"  Project:           {project_name}",
        f"  Runs recorded:     {len(runs)}",
        f"  Latest status:     {latest.get('status', 'unknown').upper()}",
        f"  Latest complete:   {latest.get('completeness_pct', 0):.0f}%",
    ]

    if latest_outcome != "none":
        lines.append(f"  Latest recovery:   {latest_outcome} "
                     f"({latest.get('recovery_attempts', 0)} attempts)")

    # Recurring missing files (appeared in 2+ runs)
    recurring_missing = {f: c for f, c in missing_counts.items() if c >= 2}
    if recurring_missing:
        lines.append("")
        lines.append("  Recurring missing files:")
        for f, c in sorted(recurring_missing.items(), key=lambda x: -x[1]):
            lines.append(f"    - {f} ({c} runs)")

    # Recurring truncations (appeared in 2+ runs)
    recurring_truncated = {f: c for f, c in truncated_counts.items() if c >= 2}
    if recurring_truncated:
        lines.append("")
        lines.append("  Recurring truncations:")
        for f, c in sorted(recurring_truncated.items(), key=lambda x: -x[1]):
            lines.append(f"    - {f} ({c} runs)")

    # Recovery stats
    lines.append("")
    lines.append(f"  Recovery runs:      {recovery_count} of {len(runs)} runs")
    if repeated_failure_count:
        lines.append(f"  Repeated failures:  {repeated_failure_count}")
    lines.append("=" * 55)

    return "\n".join(lines)


def print_summary(project_name: str) -> None:
    """Print the run memory summary to console."""
    summary = summarize_run_history(project_name)
    print(summary)


# ---------------------------------------------------------------------------
# CLI entry point
# ---------------------------------------------------------------------------

if __name__ == "__main__":
    import sys

    project = "askfin_premium"
    for i, arg in enumerate(sys.argv[1:], 1):
        if arg == "--project" and i < len(sys.argv) - 1:
            project = sys.argv[i + 1]
            break

    print(f"[RunMemory] Loading history for: {project}")
    print_summary(project)
