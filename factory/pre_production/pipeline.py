"""Phase 1 Pipeline Runner — Pre-Production Pipeline

Orchestrates: CEO-Idee -> Memory -> Research (3x) -> Concept Brief -> Legal -> Risk -> Save

Usage:
    python -m factory.pre_production.pipeline --idea "Your app idea here"
    python -m factory.pre_production.pipeline --idea-file path/to/idea.txt
"""

import re
import traceback
from datetime import date
from pathlib import Path

from factory.pre_production.agents import memory_agent
from factory.pre_production.agents import trend_scout
from factory.pre_production.agents import competitor_scan
from factory.pre_production.agents import audience_analyst
from factory.pre_production.agents import concept_analyst
from factory.pre_production.agents import legal_research
from factory.pre_production.agents import risk_assessment
from factory.pre_production.tools.web_research import get_search_stats

OUTPUT_BASE = Path(__file__).resolve().parent / "output"


def _extract_title(ceo_idea: str) -> str:
    """Extract a short title from the CEO idea text."""
    # Try text before first dash/colon/period
    for sep in ["–", "—", "-", ":", "."]:
        if sep in ceo_idea:
            candidate = ceo_idea.split(sep)[0].strip()
            if 2 <= len(candidate) <= 40:
                return candidate
    # Fallback: first 3 words
    words = ceo_idea.split()[:3]
    return " ".join(words) if words else "Untitled"


def _make_slug(title: str) -> str:
    """Create a filesystem-safe slug from a title."""
    slug = title.lower().replace(" ", "_")
    slug = re.sub(r"[^a-z0-9_]", "", slug)
    return slug[:30]


def _error_report(agent_name: str, error_msg: str) -> str:
    """Generate a placeholder report for a failed agent."""
    return (
        f"# {agent_name} — FEHLER\n\n"
        f"Der Agent konnte nicht ausgefuehrt werden.\n"
        f"Fehler: {error_msg}\n\n"
        f"Die Pipeline wird fortgesetzt."
    )


def _save_report(output_dir: Path, filename: str, content: str) -> None:
    """Save a report to the output directory."""
    filepath = output_dir / filename
    filepath.write_text(content, encoding="utf-8")


def _banner(title: str, run_number: int) -> str:
    """Generate the pipeline banner."""
    line = "=" * 60
    return (
        f"\n{line}\n"
        f"  DriveAI Swarm Factory — Phase 1 Pre-Production Pipeline\n"
        f"{line}\n"
        f"  Idee:  {title}\n"
        f"  Run:   #{run_number:03d}\n"
        f"  Datum: {date.today().isoformat()}\n"
        f"{line}\n"
    )


def run_pipeline(ceo_idea: str, idea_title: str = None) -> dict:
    """Run the complete Phase 1 pipeline.

    Args:
        ceo_idea: Raw CEO idea text (can be multiple sentences)
        idea_title: Short title for the idea (auto-extracted if not provided)

    Returns:
        dict with all reports, metadata, and status.
    """
    # --- Step 0: Setup ---
    if not idea_title:
        idea_title = _extract_title(ceo_idea)

    run_number = memory_agent.get_next_run_number()
    slug = _make_slug(idea_title)
    output_dir = OUTPUT_BASE / f"{run_number:03d}_{slug}"
    output_dir.mkdir(parents=True, exist_ok=True)

    result = {
        "idea_title": idea_title,
        "idea_raw": ceo_idea,
        "trend_report": "",
        "competitive_report": "",
        "audience_profile": "",
        "concept_brief": "",
        "legal_report": "",
        "risk_assessment": "",
        "output_dir": str(output_dir),
        "run_number": run_number,
        "status": "completed",
        "error": "",
        "failed_agents": [],
    }

    print(_banner(idea_title, run_number))

    # --- Step 1: Memory — Load Learnings ---
    print("[1/6] Memory-Agent: Learnings laden...")
    learnings = memory_agent.load_learnings()
    summary = learnings[:200] if "Keine bisherigen" not in learnings else "Keine bisherigen Learnings (erster Durchlauf)"
    print(f"      -> {summary}\n")

    # --- Step 2: Research — Chapter 1 ---
    print("[2/6] Kapitel 1: Research (3 Agents)")

    # 2a: Trend-Scout
    print("      [2a] Trend-Scout startet...")
    try:
        result["trend_report"] = trend_scout.run(ceo_idea, learnings)
        _save_report(output_dir, "trend_report.md", result["trend_report"])
        print(f"           -> Trend-Report: {len(result['trend_report']):,} Zeichen ✓")
    except Exception as e:
        result["trend_report"] = _error_report("Trend-Scout", str(e))
        result["failed_agents"].append("trend_scout")
        _save_report(output_dir, "trend_report.md", result["trend_report"])
        print(f"           -> FEHLER: {e}")
        traceback.print_exc()

    # 2b: Competitor-Scan
    print("      [2b] Competitor-Scan startet...")
    try:
        result["competitive_report"] = competitor_scan.run(ceo_idea, learnings)
        _save_report(output_dir, "competitive_report.md", result["competitive_report"])
        print(f"           -> Competitive-Report: {len(result['competitive_report']):,} Zeichen ✓")
    except Exception as e:
        result["competitive_report"] = _error_report("Competitor-Scan", str(e))
        result["failed_agents"].append("competitor_scan")
        _save_report(output_dir, "competitive_report.md", result["competitive_report"])
        print(f"           -> FEHLER: {e}")
        traceback.print_exc()

    # 2c: Audience-Analyst
    print("      [2c] Audience-Analyst startet...")
    try:
        result["audience_profile"] = audience_analyst.run(ceo_idea, learnings)
        _save_report(output_dir, "audience_profile.md", result["audience_profile"])
        print(f"           -> Audience-Profile: {len(result['audience_profile']):,} Zeichen ✓")
    except Exception as e:
        result["audience_profile"] = _error_report("Audience-Analyst", str(e))
        result["failed_agents"].append("audience_analyst")
        _save_report(output_dir, "audience_profile.md", result["audience_profile"])
        print(f"           -> FEHLER: {e}")
        traceback.print_exc()

    print()

    # --- Step 3: Synthesis — Concept Brief ---
    print("[3/6] Concept-Analyst: Synthese...")
    concept_failed = False
    try:
        result["concept_brief"] = concept_analyst.run(
            ceo_idea,
            result["trend_report"],
            result["competitive_report"],
            result["audience_profile"],
        )
        _save_report(output_dir, "concept_brief.md", result["concept_brief"])
        print(f"      -> Concept Brief: {len(result['concept_brief']):,} Zeichen ✓\n")
    except Exception as e:
        result["concept_brief"] = _error_report("Concept-Analyst", str(e))
        result["failed_agents"].append("concept_analyst")
        _save_report(output_dir, "concept_brief.md", result["concept_brief"])
        concept_failed = True
        print(f"      -> FEHLER: {e}")
        traceback.print_exc()
        print()

    # --- Step 4: Legal & Compliance — Chapter 2 ---
    print("[4/6] Kapitel 2: Legal & Compliance")

    if concept_failed:
        print("      UEBERSPRUNGEN — Concept Brief nicht verfuegbar.\n")
        result["legal_report"] = _error_report("Legal-Research", "Concept Brief nicht verfuegbar (Vorgaenger-Agent fehlgeschlagen)")
        result["risk_assessment"] = _error_report("Risk-Assessment", "Concept Brief nicht verfuegbar (Vorgaenger-Agent fehlgeschlagen)")
        _save_report(output_dir, "legal_report.md", result["legal_report"])
        _save_report(output_dir, "risk_assessment.md", result["risk_assessment"])
        result["failed_agents"].extend(["legal_research", "risk_assessment"])
    else:
        # 4a: Legal-Research
        print("      [4a] Legal-Research startet...")
        try:
            result["legal_report"] = legal_research.run(result["concept_brief"])
            _save_report(output_dir, "legal_report.md", result["legal_report"])
            print(f"           -> Legal-Report: {len(result['legal_report']):,} Zeichen ✓")
        except Exception as e:
            result["legal_report"] = _error_report("Legal-Research", str(e))
            result["failed_agents"].append("legal_research")
            _save_report(output_dir, "legal_report.md", result["legal_report"])
            print(f"           -> FEHLER: {e}")
            traceback.print_exc()

        # 4b: Risk-Assessment
        print("      [4b] Risk-Assessment startet...")
        try:
            result["risk_assessment"] = risk_assessment.run(
                result["concept_brief"], result["legal_report"]
            )
            _save_report(output_dir, "risk_assessment.md", result["risk_assessment"])
            print(f"           -> Risk-Assessment: {len(result['risk_assessment']):,} Zeichen ✓")
        except Exception as e:
            result["risk_assessment"] = _error_report("Risk-Assessment", str(e))
            result["failed_agents"].append("risk_assessment")
            _save_report(output_dir, "risk_assessment.md", result["risk_assessment"])
            print(f"           -> FEHLER: {e}")
            traceback.print_exc()

        print()

    # --- Step 5: Save Summary ---
    print("[5/6] Reports speichern...")
    stats = get_search_stats()

    report_files = [
        "trend_report.md", "competitive_report.md", "audience_profile.md",
        "concept_brief.md", "legal_report.md", "risk_assessment.md",
    ]
    file_count = sum(1 for f in report_files if (output_dir / f).exists())

    summary_md = _build_summary(result, stats)
    _save_report(output_dir, "pipeline_summary.md", summary_md)
    print(f"      -> {file_count + 1} Dateien gespeichert in {output_dir.relative_to(Path.cwd()) if output_dir.is_relative_to(Path.cwd()) else output_dir}")

    # --- Step 6: Done ---
    print(f"\n[6/6] Pipeline abgeschlossen.")
    print(f"      SerpAPI Credits: {stats['total_searches']} (Cache-Hits: {stats['cache_hits']})")

    if result["failed_agents"]:
        result["status"] = "completed_with_errors"
        result["error"] = f"Failed agents: {', '.join(result['failed_agents'])}"

    return result


def _build_summary(result: dict, stats: dict) -> str:
    """Build the pipeline_summary.md content."""
    agents = [
        ("Trend-Scout", "trend_report"),
        ("Competitor-Scan", "competitive_report"),
        ("Audience-Analyst", "audience_profile"),
        ("Concept-Analyst", "concept_brief"),
        ("Legal-Research", "legal_report"),
        ("Risk-Assessment", "risk_assessment"),
    ]

    agent_rows = []
    for name, key in agents:
        status = "FEHLER" if key.replace("_report", "").replace("_", "") in [
            a.replace("_", "") for a in result.get("failed_agents", [])
        ] else "OK"
        length = len(result.get(key, ""))
        agent_rows.append(f"| {name} | {status} | {length:,} Zeichen |")

    return f"""# Pipeline-Summary: {result['idea_title']}

**Run:** #{result['run_number']:03d}
**Datum:** {date.today().isoformat()}
**Status:** {result['status']}

## Agent-Status
| Agent | Status | Report-Laenge |
|---|---|---|
{chr(10).join(agent_rows)}

## SerpAPI-Nutzung
- API-Calls: {stats['total_searches']}
- Cache-Hits: {stats['cache_hits']}
- Cache-Groesse: {stats['cache_size']}

## Naechster Schritt
CEO-Gate: `python -m factory.pre_production.ceo_gate --run-dir {result['output_dir']}`
"""


if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(
        description="DriveAI Pre-Production Pipeline — Phase 1"
    )
    parser.add_argument("--idea", type=str, help="CEO idea text (in quotes)")
    parser.add_argument("--idea-file", type=str, help="Path to text file with CEO idea")
    parser.add_argument("--title", type=str, help="Short title for the idea (optional)")
    args = parser.parse_args()

    if args.idea_file:
        idea_text = Path(args.idea_file).read_text(encoding="utf-8")
    elif args.idea:
        idea_text = args.idea
    else:
        parser.error("Either --idea or --idea-file is required")

    result = run_pipeline(idea_text, idea_title=args.title)

    # Print final summary
    line = "=" * 60
    print(f"\n{line}")
    print("PHASE 1 PIPELINE — ABGESCHLOSSEN")
    print(line)
    print(f"Idee: {result['idea_title']}")
    print(f"Run: #{result['run_number']:03d}")
    print(f"Reports: {result['output_dir']}")
    print(f"Status: {result['status']}")
    if result["status"] in ("completed", "completed_with_errors"):
        print(f"\nNaechster Schritt: CEO-Gate")
        print(f"  python -m factory.pre_production.ceo_gate --run-dir {result['output_dir']}")
    print(line)
