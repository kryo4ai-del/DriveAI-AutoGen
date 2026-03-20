"""Input Loader — Reads Phase 1 output as input for Phase 2.

Loads all 6 reports from a Phase-1 run directory and validates
that the CEO-Gate decision was GO before proceeding.
"""

import re
from pathlib import Path

PHASE1_OUTPUT_BASE = Path(__file__).resolve().parent.parent / "pre_production" / "output"

REQUIRED_REPORTS = {
    "concept_brief": "concept_brief.md",
    "trend_report": "trend_report.md",
    "competitive_report": "competitive_report.md",
    "audience_profile": "audience_profile.md",
    "legal_report": "legal_report.md",
    "risk_assessment": "risk_assessment.md",
}


def load_phase1_output(run_dir: str) -> dict:
    """Load Phase 1 output reports from a run directory.

    Args:
        run_dir: Path to Phase 1 output directory
                 (e.g. "factory/pre_production/output/003_echomatch")

    Returns:
        dict with all reports, metadata, and CEO decision.

    Raises:
        FileNotFoundError: If run_dir doesn't exist
        ValueError: If CEO decision is not GO or required files are missing
    """
    run_path = Path(run_dir).resolve()
    if not run_path.exists():
        raise FileNotFoundError(f"Run-Verzeichnis nicht gefunden: {run_dir}")

    # Extract metadata from directory name
    dir_name = run_path.name
    run_number = 0
    idea_title = dir_name
    match = re.match(r"(\d+)_(.*)", dir_name)
    if match:
        run_number = int(match.group(1))
        idea_title = match.group(2).replace("_", " ")

    # Read and validate CEO-Gate decision
    gate_file = run_path / "ceo_gate_decision.md"
    ceo_decision = ""
    ceo_reasoning = ""

    if gate_file.exists():
        gate_content = gate_file.read_text(encoding="utf-8")
        # Extract decision
        dec_match = re.search(r"\*\*Entscheidung:\*\*\s*(\w+)", gate_content)
        if dec_match:
            ceo_decision = dec_match.group(1).upper()
        # Extract reasoning
        reason_match = re.search(r"\*\*Begr(?:ue|ü)ndung:\*\*\s*(.+)", gate_content)
        if reason_match:
            ceo_reasoning = reason_match.group(1).strip()
    else:
        raise ValueError(f"CEO-Gate Entscheidung nicht gefunden: {gate_file}")

    if ceo_decision != "GO":
        raise ValueError("CEO-Gate Entscheidung war KILL — Phase 2 kann nicht starten.")

    # Read all required reports
    result = {
        "idea_title": idea_title,
        "run_number": run_number,
        "ceo_decision": ceo_decision,
        "ceo_reasoning": ceo_reasoning,
        "source_dir": str(run_path),
    }

    for key, filename in REQUIRED_REPORTS.items():
        filepath = run_path / filename
        if not filepath.exists():
            raise ValueError(f"Fehlende Report-Datei: {filename}")
        result[key] = filepath.read_text(encoding="utf-8")

    return result


def find_latest_go_run() -> str:
    """Find the most recent Phase 1 run with a GO decision.

    Scans factory/pre_production/output/ for run directories,
    checks each for a GO decision, returns the path of the latest one.

    Returns:
        Path to the latest GO run directory

    Raises:
        FileNotFoundError: If no GO runs found
    """
    if not PHASE1_OUTPUT_BASE.exists():
        raise FileNotFoundError("Phase-1 Output-Verzeichnis nicht gefunden.")

    # Get all run directories sorted by name (descending = latest first)
    run_dirs = sorted(
        [d for d in PHASE1_OUTPUT_BASE.iterdir() if d.is_dir() and re.match(r"\d+_", d.name)],
        key=lambda d: d.name,
        reverse=True,
    )

    for run_dir in run_dirs:
        gate_file = run_dir / "ceo_gate_decision.md"
        if not gate_file.exists():
            continue
        content = gate_file.read_text(encoding="utf-8")
        dec_match = re.search(r"\*\*Entscheidung:\*\*\s*(\w+)", content)
        if dec_match and dec_match.group(1).upper() == "GO":
            return str(run_dir)

    raise FileNotFoundError("Kein Phase-1 Run mit GO-Entscheidung gefunden.")
