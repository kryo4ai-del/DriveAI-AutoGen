"""CEO Gate — Kill or Go Decision Interface

Presents all reports to the CEO and captures the decision.
After the decision, saves the run and updates learnings via Memory-Agent.

Usage:
    python -m factory.pre_production.ceo_gate --run-dir factory/pre_production/output/001_echomatch/
    python -m factory.pre_production.ceo_gate --run-dir ... --decision GO --reasoning "Markt passt"
"""

import re
from datetime import datetime
from pathlib import Path

from factory.pre_production.agents import memory_agent


def _extract_section(text: str, header: str, max_lines: int = 5) -> str:
    """Extract content after a markdown header. Returns first max_lines non-empty lines."""
    lines = text.splitlines()
    found = False
    result = []
    for line in lines:
        if found:
            if line.startswith("## ") and len(result) > 0:
                break
            stripped = line.strip()
            if stripped:
                result.append(stripped)
                if len(result) >= max_lines:
                    break
        elif header.lower() in line.lower():
            found = True
    return "\n".join(result) if result else "[Nicht extrahierbar — siehe vollstaendigen Report]"


def _extract_trends(trend_report: str) -> list[str]:
    """Extract trend names and status from trend report."""
    trends = []
    for match in re.finditer(r"## Trend \d+:\s*(.+)", trend_report):
        name = match.group(1).strip()
        # Try to find status line after the trend header
        pos = match.end()
        rest = trend_report[pos:pos + 200]
        status_match = re.search(r"Status:\s*(.+)", rest)
        status = status_match.group(1).strip() if status_match else ""
        entry = f"{name} ({status})" if status else name
        trends.append(entry)
        if len(trends) >= 3:
            break
    return trends


def _extract_table(text: str, header: str) -> str:
    """Extract a markdown table after a header."""
    lines = text.splitlines()
    found = False
    table_lines = []
    for line in lines:
        if found:
            if line.strip().startswith("|"):
                table_lines.append(line)
            elif table_lines:
                break
        elif header.lower() in line.lower():
            found = True
    return "\n".join(table_lines) if table_lines else "[Keine Tabelle gefunden]"


def present_summary(result: dict) -> str:
    """Generate a CEO-readable summary of all reports."""
    title = result.get("idea_title", "Unbekannt")
    run_num = result.get("run_number", 0)

    # Extract from concept brief
    cb = result.get("concept_brief", "")
    one_liner = _extract_section(cb, "## One-Liner", 1)
    kern_mechanik = _extract_section(cb, "## Kern-Mechanik", 2)
    zielgruppe_cb = _extract_section(cb, "## Zielgruppe", 2)
    monetarisierung = _extract_section(cb, "## Monetarisierung", 2)
    differenzierung = _extract_section(cb, "## Differenzierung", 2)

    # Extract trends
    trends = _extract_trends(result.get("trend_report", ""))
    trends_str = "\n".join(f"  - {t}" for t in trends) if trends else "  [Keine Trends extrahierbar]"

    # Extract from competitive report
    comp = result.get("competitive_report", "")
    saettigung = _extract_section(comp, "Saettigungseinschaetzung", 2)
    if "[Nicht extrahierbar" in saettigung:
        saettigung = _extract_section(comp, "Sättigungseinschätzung", 2)
    gap = _extract_section(comp, "Gap-Analyse", 2)

    # Extract from audience profile
    aud = result.get("audience_profile", "")
    zielgruppe = _extract_section(aud, "Primäre Zielgruppe", 3)
    if "[Nicht extrahierbar" in zielgruppe:
        zielgruppe = _extract_section(aud, "Primaere Zielgruppe", 3)
    session = _extract_section(aud, "Session-Verhalten", 2)

    # Extract from risk assessment
    risk = result.get("risk_assessment", "")
    ampel_table = _extract_table(risk, "Risiko-Übersicht")
    if ampel_table == "[Keine Tabelle gefunden]":
        ampel_table = _extract_table(risk, "Risiko-Uebersicht")
    gesamtrisiko = _extract_section(risk, "Gesamtrisiko-Bewertung", 2)
    empfehlung = _extract_section(risk, "Empfehlung", 3)

    line = "=" * 60
    sep = "-" * 40

    return f"""{line}
  CEO-GATE: KILL OR GO
{line}
  Idee: {title}
  Run:  #{run_num:03d}
{line}

CONCEPT BRIEF — ZUSAMMENFASSUNG
{sep}
One-Liner: {one_liner}

Kern-Mechanik: {kern_mechanik}
Zielgruppe: {zielgruppe_cb}
Monetarisierung: {monetarisierung}
Differenzierung: {differenzierung}

MARKT-HIGHLIGHTS
{sep}
Top-Trends:
{trends_str}

Wettbewerb:
  Saettigung: {saettigung}
  Wichtigste Luecke: {gap}

Zielgruppe:
  Profil: {zielgruppe}
  Session: {session}

LEGAL & RISIKO
{sep}
{ampel_table}

Gesamtrisiko: {gesamtrisiko}

EMPFEHLUNG
{sep}
{empfehlung}

{line}"""


def run_gate(result: dict, decision: str = None, reasoning: str = None) -> dict:
    """Execute the CEO-Gate.

    Args:
        result: Pipeline result dict (from pipeline.run_pipeline)
        decision: "GO" or "KILL" (if None, asks interactively)
        reasoning: CEO's reasoning (if None, asks interactively)

    Returns:
        Updated result dict with ceo_decision, ceo_reasoning, gate_timestamp.
    """
    # Present summary
    summary = present_summary(result)
    print(summary)

    # Get decision
    if decision is None:
        print("\n" + "=" * 60)
        print("  ENTSCHEIDUNG")
        print("=" * 60)
        while True:
            decision = input("\n  Kill or Go? (GO / KILL): ").strip().upper()
            if decision in ("GO", "KILL"):
                break
            print("  Bitte 'GO' oder 'KILL' eingeben.")

    if reasoning is None:
        reasoning = input("  Begruendung: ").strip()
        if not reasoning:
            reasoning = "Keine Begruendung angegeben."

    # Update result
    result["ceo_decision"] = decision
    result["ceo_reasoning"] = reasoning
    result["gate_timestamp"] = datetime.now().isoformat()

    # Save CEO-Gate decision file
    output_dir = Path(result.get("output_dir", ""))
    if output_dir.name:
        output_dir.mkdir(parents=True, exist_ok=True)
        next_step = (
            "-> Weiter zu Phase 2: Production Pipeline"
            if decision == "GO"
            else "-> Idee archiviert. Learnings gespeichert."
        )
        gate_md = f"""# CEO-Gate Entscheidung: {result.get('idea_title', 'Unbekannt')}

**Run:** #{result.get('run_number', 0):03d}
**Datum:** {datetime.now().strftime('%Y-%m-%d')}
**Entscheidung:** {decision}
**Begruendung:** {reasoning}

## Zusammenfassung
{summary}

## Naechste Schritte
{next_step}
"""
        try:
            (output_dir / "ceo_gate_decision.md").write_text(gate_md, encoding="utf-8")
        except Exception as e:
            print(f"[CEOGate] WARNING: Could not save decision file — {e}")

    # Save run to memory
    run_data = {
        "idea_title": result.get("idea_title", ""),
        "idea_raw": result.get("idea_raw", ""),
        "trend_report": result.get("trend_report", ""),
        "competitive_report": result.get("competitive_report", ""),
        "audience_profile": result.get("audience_profile", ""),
        "concept_brief": result.get("concept_brief", ""),
        "legal_report": result.get("legal_report", ""),
        "risk_assessment": result.get("risk_assessment", ""),
        "ceo_decision": decision,
        "ceo_reasoning": reasoning,
    }

    try:
        filepath = memory_agent.save_run(run_data)
        print(f"\n[CEOGate] Run gespeichert: {filepath}")
    except Exception as e:
        print(f"[CEOGate] WARNING: Could not save run — {e}")

    try:
        memory_agent.update_learnings(run_data)
        print("[CEOGate] Learnings aktualisiert.")
    except Exception as e:
        print(f"[CEOGate] WARNING: Could not update learnings — {e}")

    return result


if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(description="DriveAI CEO-Gate — Kill or Go")
    parser.add_argument("--run-dir", type=str, required=True, help="Path to pipeline output directory")
    parser.add_argument("--decision", type=str, choices=["GO", "KILL"], help="Decision (skip interactive)")
    parser.add_argument("--reasoning", type=str, help="Reasoning (skip interactive)")
    args = parser.parse_args()

    # Load reports from run directory
    run_dir = Path(args.run_dir)
    run_name = run_dir.name
    result = {
        "idea_title": run_name.split("_", 1)[1] if "_" in run_name else run_name,
        "idea_raw": "",
        "output_dir": str(run_dir),
        "run_number": int(run_name.split("_")[0]) if run_name[0:1].isdigit() else 0,
    }

    report_files = {
        "trend_report": "trend_report.md",
        "competitive_report": "competitive_report.md",
        "audience_profile": "audience_profile.md",
        "concept_brief": "concept_brief.md",
        "legal_report": "legal_report.md",
        "risk_assessment": "risk_assessment.md",
    }
    for key, filename in report_files.items():
        filepath = run_dir / filename
        if filepath.exists():
            try:
                result[key] = filepath.read_text(encoding="utf-8")
            except Exception as e:
                result[key] = f"# {filename} — LESEFEHLER\n{e}"
                print(f"[CEOGate] WARNING: Could not read {filename} — {e}")
        else:
            result[key] = f"# {filename} — NICHT GEFUNDEN"

    final = run_gate(result, decision=args.decision, reasoning=args.reasoning)

    print(f"\nEntscheidung gespeichert: {final['ceo_decision']}")
    print(f"Memory aktualisiert")
    if final["ceo_decision"] == "GO":
        print(f"\n-> Naechster Schritt: Phase 2")
    else:
        print(f"\n-> Idee archiviert. Learnings gespeichert.")
