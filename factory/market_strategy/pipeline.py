"""Phase 2 Pipeline Runner — Market Strategy Pipeline

Orchestrates: Phase-1-Input -> [Platform + Monetization] -> [Marketing + Release] -> Cost Calculation

Usage:
    python -m factory.market_strategy.pipeline --run-dir factory/pre_production/output/003_echomatch
    python -m factory.market_strategy.pipeline --latest
"""

import re
import traceback
from datetime import date
from pathlib import Path

from factory.market_strategy.input_loader import load_phase1_output, find_latest_go_run
from factory.market_strategy.agents import platform_strategy
from factory.market_strategy.agents import monetization_architect
from factory.market_strategy.agents import marketing_strategy
from factory.market_strategy.agents import release_planner
from factory.market_strategy.agents import cost_calculation
from factory.pre_production.tools.web_research import get_search_stats

OUTPUT_BASE = Path(__file__).resolve().parent / "output"


def _get_next_run_number() -> int:
    """Scan output directory for existing runs and return next number."""
    if not OUTPUT_BASE.exists():
        return 1
    dirs = [d for d in OUTPUT_BASE.iterdir() if d.is_dir() and re.match(r"\d+_", d.name)]
    if not dirs:
        return 1
    max_num = max(int(re.match(r"(\d+)_", d.name).group(1)) for d in dirs)
    return max_num + 1


def _make_slug(title: str) -> str:
    slug = title.lower().replace(" ", "_")
    slug = re.sub(r"[^a-z0-9_]", "", slug)
    return slug[:30]


def _error_report(agent_name: str, error_msg: str) -> str:
    return (
        f"# {agent_name} — FEHLER\n\n"
        f"Der Agent konnte nicht ausgefuehrt werden.\n"
        f"Fehler: {error_msg}\n\n"
        f"Die Pipeline wird fortgesetzt."
    )


def _save_report(output_dir: Path, filename: str, content: str) -> None:
    filepath = output_dir / filename
    filepath.write_text(content, encoding="utf-8")


def _banner(title: str, p1_run: int, p2_run: int, p1_dir: str) -> str:
    line = "=" * 60
    return (
        f"\n{line}\n"
        f"  DriveAI Swarm Factory — Phase 2 Market Strategy Pipeline\n"
        f"{line}\n"
        f"  Idee:  {title}\n"
        f"  Phase-1 Run: #{p1_run:03d} ({p1_dir})\n"
        f"  Phase-2 Run: #{p2_run:03d}\n"
        f"  Datum: {date.today().isoformat()}\n"
        f"{line}\n"
    )


def run_pipeline(phase1_run_dir: str = None) -> dict:
    """Run the complete Phase 2 pipeline.

    Args:
        phase1_run_dir: Path to Phase 1 output directory.
                        If None, auto-detects latest GO run.

    Returns:
        dict with all reports, metadata, and status.
    """
    # --- Step 0: Setup ---
    if phase1_run_dir is None:
        print("[0/5] Auto-detecting latest Phase-1 GO run...")
        phase1_run_dir = find_latest_go_run()

    print(f"[0/5] Phase-1 Input laden: {phase1_run_dir}")
    phase1 = load_phase1_output(phase1_run_dir)
    print(f"      -> 6 Reports geladen, CEO-Entscheidung: {phase1['ceo_decision']} ✓\n")

    title = phase1["idea_title"]
    p2_run = _get_next_run_number()
    slug = _make_slug(title)
    output_dir = OUTPUT_BASE / f"{p2_run:03d}_{slug}"
    output_dir.mkdir(parents=True, exist_ok=True)

    result = {
        "idea_title": title,
        "run_number": p2_run,
        "phase1_run_number": phase1["run_number"],
        "phase1_run_dir": phase1_run_dir,
        "platform_strategy": "",
        "monetization_report": "",
        "marketing_strategy": "",
        "release_plan": "",
        "cost_calculation": "",
        "output_dir": str(output_dir),
        "status": "completed",
        "error": "",
        "failed_agents": [],
    }

    print(_banner(title, phase1["run_number"], p2_run, phase1_run_dir))

    # --- Step 1: Wave 1 — Platform + Monetization ---
    print("[1/5] Wave 1: Plattform + Monetarisierung")
    wave1_failed = False

    # 1a: Platform Strategy
    print("      [1a] Plattform-Strategie startet...")
    try:
        result["platform_strategy"] = platform_strategy.run(
            phase1["concept_brief"], phase1["audience_profile"],
            phase1["risk_assessment"], phase1["legal_report"],
        )
        _save_report(output_dir, "platform_strategy.md", result["platform_strategy"])
        print(f"           -> Platform Strategy: {len(result['platform_strategy']):,} Zeichen ✓")
    except Exception as e:
        result["platform_strategy"] = _error_report("Plattform-Strategie", str(e))
        result["failed_agents"].append("platform_strategy")
        _save_report(output_dir, "platform_strategy.md", result["platform_strategy"])
        wave1_failed = True
        print(f"           -> FEHLER: {e}")
        traceback.print_exc()

    # 1b: Monetization Architect
    print("      [1b] Monetarisierungs-Architekt startet...")
    try:
        result["monetization_report"] = monetization_architect.run(
            phase1["concept_brief"], phase1["audience_profile"],
            phase1["competitive_report"], phase1["risk_assessment"],
        )
        _save_report(output_dir, "monetization_report.md", result["monetization_report"])
        print(f"           -> Monetization Report: {len(result['monetization_report']):,} Zeichen ✓")
    except Exception as e:
        result["monetization_report"] = _error_report("Monetarisierungs-Architekt", str(e))
        result["failed_agents"].append("monetization_architect")
        _save_report(output_dir, "monetization_report.md", result["monetization_report"])
        wave1_failed = True
        print(f"           -> FEHLER: {e}")
        traceback.print_exc()

    print()

    # --- Step 2: Wave 2 — Marketing + Release ---
    print("[2/5] Wave 2: Marketing + Release")

    if wave1_failed:
        print("      UEBERSPRUNGEN — Wave 1 nicht vollstaendig.\n")
        result["marketing_strategy"] = _error_report("Marketing-Strategie", "Wave 1 nicht vollstaendig")
        result["release_plan"] = _error_report("Release-Planer", "Wave 1 nicht vollstaendig")
        _save_report(output_dir, "marketing_strategy.md", result["marketing_strategy"])
        _save_report(output_dir, "release_plan.md", result["release_plan"])
        result["failed_agents"].extend(["marketing_strategy", "release_planner"])
    else:
        # 2a: Marketing Strategy
        print("      [2a] Marketing-Strategie startet...")
        try:
            result["marketing_strategy"] = marketing_strategy.run(
                phase1["concept_brief"], phase1["audience_profile"],
                result["platform_strategy"], result["monetization_report"],
            )
            _save_report(output_dir, "marketing_strategy.md", result["marketing_strategy"])
            print(f"           -> Marketing Strategy: {len(result['marketing_strategy']):,} Zeichen ✓")
        except Exception as e:
            result["marketing_strategy"] = _error_report("Marketing-Strategie", str(e))
            result["failed_agents"].append("marketing_strategy")
            _save_report(output_dir, "marketing_strategy.md", result["marketing_strategy"])
            print(f"           -> FEHLER: {e}")
            traceback.print_exc()

        # 2b: Release Planner
        print("      [2b] Release-Planer startet...")
        try:
            result["release_plan"] = release_planner.run(
                phase1["concept_brief"], result["platform_strategy"],
                result["monetization_report"],
            )
            _save_report(output_dir, "release_plan.md", result["release_plan"])
            print(f"           -> Release Plan: {len(result['release_plan']):,} Zeichen ✓")
        except Exception as e:
            result["release_plan"] = _error_report("Release-Planer", str(e))
            result["failed_agents"].append("release_planner")
            _save_report(output_dir, "release_plan.md", result["release_plan"])
            print(f"           -> FEHLER: {e}")
            traceback.print_exc()

    print()

    # --- Step 3: Wave 3 — Cost Calculation ---
    print("[3/5] Wave 3: Kosten-Kalkulation")

    if wave1_failed:
        print("      UEBERSPRUNGEN — Wave 1 nicht vollstaendig.\n")
        result["cost_calculation"] = _error_report("Kosten-Kalkulation", "Vorgaenger-Agents fehlgeschlagen")
        _save_report(output_dir, "cost_calculation.md", result["cost_calculation"])
        result["failed_agents"].append("cost_calculation")
    else:
        try:
            result["cost_calculation"] = cost_calculation.run(
                phase1["concept_brief"], result["platform_strategy"],
                result["monetization_report"], result["marketing_strategy"],
                result["release_plan"], phase1["risk_assessment"],
            )
            _save_report(output_dir, "cost_calculation.md", result["cost_calculation"])
            print(f"      -> Cost Calculation: {len(result['cost_calculation']):,} Zeichen ✓")
        except Exception as e:
            result["cost_calculation"] = _error_report("Kosten-Kalkulation", str(e))
            result["failed_agents"].append("cost_calculation")
            _save_report(output_dir, "cost_calculation.md", result["cost_calculation"])
            print(f"      -> FEHLER: {e}")
            traceback.print_exc()

    print()

    # --- Step 4: Save Summary + Memory ---
    print("[4/5] Reports speichern...")
    stats = get_search_stats()

    report_files = [
        "platform_strategy.md", "monetization_report.md", "marketing_strategy.md",
        "release_plan.md", "cost_calculation.md",
    ]
    file_count = sum(1 for f in report_files if (output_dir / f).exists())

    summary_md = _build_summary(result, phase1, stats)
    _save_report(output_dir, "pipeline_summary.md", summary_md)
    print(f"      -> {file_count + 1} Dateien gespeichert in {output_dir}")

    print("\n[5/5] Memory aktualisieren...")
    try:
        _save_phase2_learnings(result, phase1)
        print("      -> Phase-2 Learnings gespeichert ✓")
    except Exception as e:
        print(f"      -> WARNING: Learnings konnten nicht gespeichert werden — {e}")

    # Final status
    if result["failed_agents"]:
        result["status"] = "completed_with_errors"
        result["error"] = f"Failed agents: {', '.join(result['failed_agents'])}"

    # Print final banner
    line = "=" * 60
    print(f"\n{line}")
    print("  PHASE 2 PIPELINE — ABGESCHLOSSEN")
    print(f"  Idee: {title}")
    print(f"  Reports: {output_dir}")
    print(f"  Status: {result['status']}")
    print(f"  Naechster Schritt: Kapitel 4 (MVP & Feature Scope)")
    print(line)

    return result


def _build_summary(result: dict, phase1: dict, stats: dict) -> str:
    agents = [
        ("Platform Strategy", "platform_strategy"),
        ("Monetization Architect", "monetization_report"),
        ("Marketing Strategy", "marketing_strategy"),
        ("Release Planner", "release_plan"),
        ("Cost Calculation", "cost_calculation"),
    ]

    agent_rows = []
    for name, key in agents:
        failed = key.replace("_report", "").replace("_", "") in [
            a.replace("_", "") for a in result.get("failed_agents", [])
        ]
        status = "FEHLER" if failed else "OK"
        length = len(result.get(key, ""))
        agent_rows.append(f"| {name} | {status} | {length:,} Zeichen |")

    return f"""# Phase 2 Pipeline Summary

- **Idee:** {result['idea_title']}
- **Phase-1 Run:** #{phase1.get('run_number', 0):03d}
- **Phase-2 Run:** #{result['run_number']:03d}
- **Datum:** {date.today().isoformat()}
- **Status:** {result['status']}

## Agent-Status
| Agent | Status | Report-Laenge |
|---|---|---|
{chr(10).join(agent_rows)}

## SerpAPI-Stats
- Total Searches: {stats['total_searches']}
- Cache Hits: {stats['cache_hits']}
"""


def _save_phase2_learnings(result: dict, phase1: dict):
    """Append Phase 2 learnings to the shared learnings file."""
    learnings_path = Path(__file__).resolve().parent.parent / "pre_production" / "memory" / "learnings.md"
    content = learnings_path.read_text(encoding="utf-8")
    idea = phase1.get("idea_title", "Unknown")

    # Add Phase 2 sections if not present
    if "## Strategie" not in content:
        content += "\n\n## Strategie\n(Phase 2 Learnings)\n"
    if "## Marketing" not in content:
        content += "\n\n## Marketing\n(Phase 2 Learnings)\n"
    if "## Kosten" not in content:
        content += "\n\n## Kosten\n(Phase 2 Learnings)\n"

    # Platform insight
    platform_text = result.get("platform_strategy", "")
    for line in platform_text.splitlines():
        if "Phase 1 Launch" in line or ("Finale" in line and "Launch" in line):
            insight = line.strip().lstrip("-").strip()
            if insight and len(insight) > 5:
                content = content.replace(
                    "## Strategie\n",
                    f"## Strategie\n- [{insight}]: Quelle: Phase 2, {idea}\n",
                    1,
                )
                break

    # Cost insight
    cost_text = result.get("cost_calculation", "")
    for line in cost_text.splitlines():
        if "Gesamtbudget bis Launch" in line or "Break-Even" in line:
            insight = line.strip().lstrip("|").strip()
            if insight and len(insight) > 10:
                content = content.replace(
                    "## Kosten\n",
                    f"## Kosten\n- [{insight}]: Quelle: Phase 2, {idea}\n",
                    1,
                )
                break

    learnings_path.write_text(content, encoding="utf-8")


if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(
        description="DriveAI Market Strategy Pipeline — Phase 2"
    )
    parser.add_argument("--run-dir", type=str, help="Path to Phase 1 output directory")
    parser.add_argument("--latest", action="store_true", help="Auto-detect latest GO run from Phase 1")
    args = parser.parse_args()

    if args.latest:
        run_dir = None
    elif args.run_dir:
        run_dir = args.run_dir
    else:
        parser.error("Either --run-dir or --latest is required")

    run_pipeline(phase1_run_dir=run_dir)
