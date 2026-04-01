"""Input Loader — Reads reports from Phase 1 and Kapitel 3 as input for Kapitel 4.

Loads all 11 reports (6 from Phase 1, 5 from Kapitel 3) and validates
that Phase 1 CEO-Gate was GO and Kapitel 3 completed successfully.
"""

import re
from pathlib import Path

PHASE1_OUTPUT_BASE = Path(__file__).resolve().parent.parent / "pre_production" / "output"
PHASE2_OUTPUT_BASE = Path(__file__).resolve().parent.parent / "market_strategy" / "output"

PHASE1_REPORTS = {
    "concept_brief": "concept_brief.md",
    "trend_report": "trend_report.md",
    "competitive_report": "competitive_report.md",
    "audience_profile": "audience_profile.md",
    "legal_report": "legal_report.md",
    "risk_assessment": "risk_assessment.md",
}

PHASE2_REPORTS = {
    "platform_strategy": "platform_strategy.md",
    "monetization_report": "monetization_report.md",
    "marketing_strategy": "marketing_strategy.md",
    "release_plan": "release_plan.md",
    "cost_calculation": "cost_calculation.md",
}


def load_all_reports(phase1_dir: str = None, phase2_dir: str = None) -> dict:
    """Load all reports from Phase 1 and Kapitel 3.

    Args:
        phase1_dir: Path to Phase 1 output. If None, auto-detects latest GO run.
        phase2_dir: Path to Kapitel 3 output. If None, auto-detects latest run.

    Returns:
        dict with all 11 reports, metadata, and combined context.
    """
    if phase1_dir is None or phase2_dir is None:
        auto_p1, auto_p2 = find_latest_runs()
        phase1_dir = phase1_dir or auto_p1
        phase2_dir = phase2_dir or auto_p2

    p1_path = Path(phase1_dir).resolve()
    p2_path = Path(phase2_dir).resolve()

    if not p1_path.exists():
        raise FileNotFoundError(f"Phase 1 Verzeichnis nicht gefunden: {phase1_dir}")
    if not p2_path.exists():
        raise FileNotFoundError(f"Kapitel 3 Verzeichnis nicht gefunden: {phase2_dir}")

    # Validate Phase 1 CEO-Gate = GO
    _validate_ceo_gate(p1_path)

    # Validate Kapitel 3 completed
    _validate_phase2_complete(p2_path)

    # Extract title
    dir_name = p1_path.name
    match = re.match(r"\d+_(.*)", dir_name)
    idea_title = match.group(1).replace("_", " ") if match else dir_name

    # Load all reports
    result = {
        "idea_title": idea_title,
        "phase1_run_dir": str(p1_path),
        "phase2_run_dir": str(p2_path),
    }

    for key, filename in PHASE1_REPORTS.items():
        filepath = p1_path / filename
        if not filepath.exists():
            raise ValueError(f"Fehlende Phase 1 Report-Datei: {filename}")
        result[key] = filepath.read_text(encoding="utf-8")

    for key, filename in PHASE2_REPORTS.items():
        filepath = p2_path / filename
        if not filepath.exists():
            raise ValueError(f"Fehlende Kapitel 3 Report-Datei: {filename}")
        result[key] = filepath.read_text(encoding="utf-8")

    # Build combined context
    sections = []
    for key, filename in PHASE1_REPORTS.items():
        label = key.upper().replace("_", " ")
        sections.append(f"=== PHASE 1: {label} ===\n{result[key]}")
    for key, filename in PHASE2_REPORTS.items():
        label = key.upper().replace("_", " ")
        sections.append(f"=== KAPITEL 3: {label} ===\n{result[key]}")
    result["all_reports_combined"] = "\n\n".join(sections)

    return result


def find_latest_runs() -> tuple[str, str]:
    """Find the latest Phase 1 GO run and latest Kapitel 3 run.

    Returns:
        (phase1_dir, phase2_dir)

    Raises:
        FileNotFoundError: If no valid runs found.
    """
    # Phase 1: latest GO run
    phase1_dir = _find_latest_go_run(PHASE1_OUTPUT_BASE)

    # Kapitel 3: latest run (any status)
    phase2_dir = _find_latest_run(PHASE2_OUTPUT_BASE)

    return phase1_dir, phase2_dir


def _find_latest_go_run(base: Path) -> str:
    """Find latest Phase 1 run with GO decision."""
    if not base.exists():
        raise FileNotFoundError("Phase 1 Output-Verzeichnis nicht gefunden.")

    run_dirs = sorted(
        [d for d in base.iterdir() if d.is_dir() and re.match(r"\d+_", d.name)],
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


def _find_latest_run(base: Path) -> str:
    """Find latest run directory."""
    if not base.exists():
        raise FileNotFoundError(f"Output-Verzeichnis nicht gefunden: {base}")

    run_dirs = sorted(
        [d for d in base.iterdir() if d.is_dir() and re.match(r"\d+_", d.name)],
        key=lambda d: d.name,
        reverse=True,
    )

    if not run_dirs:
        raise FileNotFoundError(f"Keine Runs gefunden in: {base}")

    return str(run_dirs[0])


def _validate_ceo_gate(p1_path: Path) -> None:
    """Validate that CEO-Gate decision was GO."""
    gate_file = p1_path / "ceo_gate_decision.md"
    if not gate_file.exists():
        raise ValueError(f"CEO-Gate Entscheidung nicht gefunden: {gate_file}")

    content = gate_file.read_text(encoding="utf-8")
    dec_match = re.search(r"\*\*Entscheidung:\*\*\s*(\w+)", content)
    if not dec_match or dec_match.group(1).upper() not in ("GO", "GO_MIT_NOTES"):
        raise ValueError("CEO-Gate Entscheidung war nicht GO — Kapitel 4 kann nicht starten.")


def _validate_phase2_complete(p2_path: Path) -> None:
    """Validate that Kapitel 3 pipeline completed."""
    summary_file = p2_path / "pipeline_summary.md"
    if not summary_file.exists():
        print("[InputLoader] WARNING: pipeline_summary.md nicht gefunden — Kapitel 3 evtl. unvollstaendig")
        return

    # Check that all 5 report files exist
    for filename in PHASE2_REPORTS.values():
        if not (p2_path / filename).exists():
            raise ValueError(f"Kapitel 3 unvollstaendig — fehlend: {filename}")
