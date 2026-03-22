"""Input Loader — Reads reports from Phase 1, Kapitel 3, AND Kapitel 4.

Loads all 14 reports and validates pipeline completion at each stage.
"""

from pathlib import Path


def load_all_reports(phase1_dir: str = None, k3_dir: str = None, k4_dir: str = None) -> dict:
    """Load all reports from Phase 1, Kapitel 3, and Kapitel 4.

    Args:
        phase1_dir: Phase 1 output dir (auto-detects if None)
        k3_dir: Kapitel 3 output dir (auto-detects if None)
        k4_dir: Kapitel 4 output dir (auto-detects if None)

    Returns:
        dict with all 14 reports + metadata + combined text.

    Raises:
        FileNotFoundError: If directories don't exist
        ValueError: If CEO decision is not GO or required files missing
    """
    if not phase1_dir or not k3_dir or not k4_dir:
        auto_p1, auto_k3, auto_k4 = find_latest_runs()
        phase1_dir = phase1_dir or auto_p1
        k3_dir = k3_dir or auto_k3
        k4_dir = k4_dir or auto_k4

    p1 = Path(phase1_dir)
    k3 = Path(k3_dir)
    k4 = Path(k4_dir)

    for d, label in [(p1, "Phase 1"), (k3, "Kapitel 3"), (k4, "Kapitel 4")]:
        if not d.exists():
            raise FileNotFoundError(f"{label} Verzeichnis nicht gefunden: {d}")

    # Validate CEO-Gate = GO
    gate_file = p1 / "ceo_gate_decision.md"
    if gate_file.exists():
        gate_text = gate_file.read_text(encoding="utf-8")
        if "KILL" in gate_text and "GO" not in gate_text.split("KILL")[0]:
            raise ValueError("CEO-Gate Entscheidung war KILL — Kapitel 5 kann nicht starten.")
    else:
        print("[InputLoader] WARNING: ceo_gate_decision.md nicht gefunden — fahre trotzdem fort")

    # Phase 1 reports
    p1_files = {
        "concept_brief": "concept_brief.md",
        "trend_report": "trend_report.md",
        "competitive_report": "competitive_report.md",
        "audience_profile": "audience_profile.md",
        "legal_report": "legal_report.md",
        "risk_assessment": "risk_assessment.md",
    }

    # Kapitel 3 reports
    k3_files = {
        "platform_strategy": "platform_strategy.md",
        "monetization_report": "monetization_report.md",
        "marketing_strategy": "marketing_strategy.md",
        "release_plan": "release_plan.md",
        "cost_calculation": "cost_calculation.md",
    }

    # Kapitel 4 reports
    k4_files = {
        "feature_list": "feature_list.md",
        "feature_prioritization": "feature_prioritization.md",
        "screen_architecture": "screen_architecture.md",
    }

    result = {
        "phase1_run_dir": str(p1.resolve()),
        "k3_run_dir": str(k3.resolve()),
        "k4_run_dir": str(k4.resolve()),
    }

    # Extract idea_title from directory name
    dir_name = p1.name
    if "_" in dir_name:
        result["idea_title"] = dir_name.split("_", 1)[1]
    else:
        result["idea_title"] = dir_name

    # Load all reports
    for mapping, base_dir in [(p1_files, p1), (k3_files, k3), (k4_files, k4)]:
        for key, filename in mapping.items():
            filepath = base_dir / filename
            if filepath.exists():
                result[key] = filepath.read_text(encoding="utf-8")
            else:
                print(f"[InputLoader] WARNING: {filename} nicht gefunden in {base_dir}")
                result[key] = ""

    # Validate required files
    required = ["concept_brief", "screen_architecture", "feature_list"]
    for key in required:
        if not result.get(key):
            raise ValueError(f"Fehlende Report-Datei: {key}")

    # Screen architecture completeness check
    sa = result.get("screen_architecture", "")
    if len(sa) < 500:
        print("[InputLoader] WARNING: Screen-Architektur moeglicherweise unvollstaendig — Agent 17 wird mit eingeschraenktem Input arbeiten.")

    # Build combined text
    combined_parts = []
    section_map = {
        "concept_brief": "PHASE 1: CONCEPT BRIEF",
        "trend_report": "PHASE 1: TREND REPORT",
        "competitive_report": "PHASE 1: COMPETITIVE REPORT",
        "audience_profile": "PHASE 1: AUDIENCE PROFILE",
        "legal_report": "PHASE 1: LEGAL REPORT",
        "risk_assessment": "PHASE 1: RISK ASSESSMENT",
        "platform_strategy": "KAPITEL 3: PLATFORM STRATEGY",
        "monetization_report": "KAPITEL 3: MONETIZATION REPORT",
        "marketing_strategy": "KAPITEL 3: MARKETING STRATEGY",
        "release_plan": "KAPITEL 3: RELEASE PLAN",
        "cost_calculation": "KAPITEL 3: COST CALCULATION",
        "feature_list": "KAPITEL 4: FEATURE LIST",
        "feature_prioritization": "KAPITEL 4: FEATURE PRIORITIZATION",
        "screen_architecture": "KAPITEL 4: SCREEN ARCHITECTURE",
    }
    for key, header in section_map.items():
        content = result.get(key, "")
        if content:
            combined_parts.append(f"=== {header} ===\n{content}")
    result["all_reports_combined"] = "\n\n".join(combined_parts)

    return result


def find_latest_runs() -> tuple[str, str, str]:
    """Find latest Phase 1 GO run, Kapitel 3 run, and Kapitel 4 run.

    Returns:
        (phase1_dir, k3_dir, k4_dir)

    Raises:
        FileNotFoundError: If no valid runs found
    """
    base = Path("factory")

    # Phase 1: latest GO run
    p1_output = base / "pre_production" / "output"
    p1_dir = _find_latest_go_run(p1_output)

    # Kapitel 3: latest run
    k3_output = base / "market_strategy" / "output"
    k3_dir = _find_latest_run(k3_output, "Kapitel 3")

    # Kapitel 4: latest run
    k4_output = base / "mvp_scope" / "output"
    k4_dir = _find_latest_run(k4_output, "Kapitel 4")

    return str(p1_dir), str(k3_dir), str(k4_dir)


def _find_latest_go_run(output_dir: Path) -> Path:
    """Find the most recent Phase 1 run with a GO decision."""
    if not output_dir.exists():
        raise FileNotFoundError(f"Phase 1 Output nicht gefunden: {output_dir}")

    run_dirs = sorted(
        [d for d in output_dir.iterdir() if d.is_dir() and not d.name.startswith(".")],
        reverse=True,
    )

    for run_dir in run_dirs:
        gate_file = run_dir / "ceo_gate_decision.md"
        if gate_file.exists():
            text = gate_file.read_text(encoding="utf-8")
            if "GO" in text:
                return run_dir

    raise FileNotFoundError("Kein Phase 1 Run mit GO-Entscheidung gefunden")


def _find_latest_run(output_dir: Path, label: str) -> Path:
    """Find the most recent run directory."""
    if not output_dir.exists():
        raise FileNotFoundError(f"{label} Output nicht gefunden: {output_dir}")

    run_dirs = sorted(
        [d for d in output_dir.iterdir() if d.is_dir() and not d.name.startswith(".")],
        reverse=True,
    )

    if not run_dirs:
        raise FileNotFoundError(f"Keine {label} Runs gefunden in {output_dir}")

    return run_dirs[0]
