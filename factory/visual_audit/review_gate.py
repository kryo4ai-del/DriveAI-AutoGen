"""Human Review Gate — Visual Audit

Presents the Visual Consistency Report to the reviewer, sorted by priority.
Supports GO / GO_MIT_NOTES / REDO decisions.
"""

import datetime
from pathlib import Path


def present_review_summary(result: dict) -> str:
    """Generate reviewer-readable summary sorted by priority."""
    title = result.get("idea_title", "App")
    run_num = result.get("run_number", 0)
    vis = result.get("visual_consistency", "")
    disc = result.get("asset_discovery", "")
    strat = result.get("asset_strategy", "")

    # Count ampels
    red = vis.count("\U0001f534")
    yellow = vis.count("\U0001f7e1")
    green = vis.count("\U0001f7e2")
    warn = vis.count("\u26a0\ufe0f")

    # Extract top blockers (lines with 🔴 in table rows)
    top_blockers = []
    for line in vis.split("\n"):
        if "\U0001f534" in line and "|" in line and "---" not in line and "Screen" not in line:
            cells = [c.strip() for c in line.split("|") if c.strip()]
            if cells:
                top_blockers.append(cells[0] if len(cells) == 1 else f"{cells[0]}: {cells[1]}" if len(cells) > 1 else cells[0])
            if len(top_blockers) >= 10:
                break

    # Extract top KI warnings
    top_warnings = []
    in_ki_section = False
    for line in vis.split("\n"):
        if "KI-Warnung" in line or "KI-Entwicklung" in line:
            in_ki_section = True
            continue
        if in_ki_section and "|" in line and "---" not in line and "#" not in line:
            cells = [c.strip() for c in line.split("|") if c.strip()]
            if len(cells) >= 4:
                top_warnings.append(f"{cells[1] if len(cells) > 1 else ''}: {cells[2] if len(cells) > 2 else ''}")
            if len(top_warnings) >= 5:
                break
        if in_ki_section and line.startswith("#") and "KI" not in line:
            in_ki_section = False

    # Extract budget from strategy
    budget_line = "Nicht extrahierbar"
    for line in strat.split("\n"):
        if "Gesamtkosten" in line or "budget_total" in line.lower():
            budget_line = line.strip().lstrip("-*").strip()
            break

    lines = [
        "=" * 60,
        "  HUMAN REVIEW GATE: Visual & Asset Audit",
        "=" * 60,
        f"  Idee: {title}",
        f"  Run: #{run_num:03d}" if isinstance(run_num, int) else f"  Run: #{run_num}",
        "=" * 60,
        "",
        "UEBERSICHT",
        "-" * 40,
        f"  \U0001f534 Blocker:        {red} Stellen",
        f"  \u26a0\ufe0f  KI-Warnungen:   {warn} Stellen",
        f"  \U0001f7e1 Schlechte UX:   {yellow} Stellen",
        f"  \U0001f7e2 Nice-to-have:    {green} Stellen",
        "",
    ]

    if top_blockers:
        lines.append("\U0001f534 TOP BLOCKER")
        lines.append("-" * 40)
        for b in top_blockers[:10]:
            lines.append(f"  {b}")
        lines.append("")

    if top_warnings:
        lines.append("\u26a0\ufe0f  TOP KI-WARNUNGEN")
        lines.append("-" * 40)
        for i, w in enumerate(top_warnings, 1):
            lines.append(f"  #{i} {w}")
        lines.append("")

    lines.append("BUDGET")
    lines.append("-" * 40)
    lines.append(f"  {budget_line}")
    lines.append("")
    lines.append("=" * 60)

    return "\n".join(lines)


def run_review_gate(result: dict, decision: str = None, reasoning: str = None) -> dict:
    """Execute the Human Review Gate.

    Args:
        result: Pipeline result dict with reports
        decision: GO / GO_MIT_NOTES / REDO (None = interactive)
        reasoning: Reviewer notes

    Returns:
        Updated result with review_decision, review_reasoning, review_timestamp, review_round
    """
    # Present summary
    summary = present_review_summary(result)
    print(summary)

    # Interactive or programmatic
    if decision is None:
        print("\n" + "=" * 60)
        print("  ENTSCHEIDUNG")
        print("=" * 60)
        print("  GO           — Alles geprueft, weiter zu Kapitel 6")
        print("  GO_MIT_NOTES — Weiter, aber mit Anmerkungen")
        print("  REDO         — Probleme gefunden, Ueberarbeitung noetig")
        print()

        decision = ""
        while decision not in ("GO", "GO_MIT_NOTES", "REDO"):
            raw = input("  Entscheidung (GO / GO_MIT_NOTES / REDO): ").strip().upper()
            decision = raw.replace(" ", "_")
            if decision not in ("GO", "GO_MIT_NOTES", "REDO"):
                print("  Bitte GO, GO_MIT_NOTES oder REDO eingeben.")

        reasoning = input("  Anmerkungen: ").strip()
        if not reasoning:
            reasoning = "Keine Anmerkungen."

    # Determine review round
    output_dir = Path(result.get("output_dir", ""))
    existing_reviews = list(output_dir.glob("review_decision*.md")) if output_dir.exists() else []
    review_round = len(existing_reviews) + 1

    # Update result
    result["review_decision"] = decision
    result["review_reasoning"] = reasoning
    result["review_timestamp"] = datetime.datetime.now().isoformat()
    result["review_round"] = review_round

    # Save review decision
    if output_dir.exists():
        title = result.get("idea_title", "App")
        run_num = result.get("run_number", 0)
        date_str = datetime.date.today().isoformat()

        vis = result.get("visual_consistency", "")
        red = vis.count("\U0001f534")
        yellow = vis.count("\U0001f7e1")
        warn = vis.count("\u26a0\ufe0f")

        suffix = f"_round{review_round}" if review_round > 1 else ""
        decision_md = f"""# Visual Review Entscheidung: {title}
**Run:** #{run_num}
**Datum:** {date_str}
**Entscheidung:** {decision}
**Anmerkungen:** {reasoning}
**Review-Runde:** {review_round}

## Zusammenfassung bei Entscheidung
- \U0001f534 Blocker: {red}
- \u26a0\ufe0f KI-Warnungen: {warn}
- \U0001f7e1 Schlechte UX: {yellow}
"""
        (output_dir / f"review_decision{suffix}.md").write_text(decision_md, encoding="utf-8")
        print(f"\n[ReviewGate] Entscheidung gespeichert: {decision}")

    if decision == "REDO":
        print("[ReviewGate] Tipp: Nutze Agent 20 fuer gezieltes Feedback:")
        print(f"  python -m factory.visual_audit.agents.review_assistant --run-dir {output_dir} --feedback \"Dein Feedback\"")
    elif decision == "GO":
        print("[ReviewGate] -> Naechster Schritt: Kapitel 6")
    elif decision == "GO_MIT_NOTES":
        print("[ReviewGate] -> Weiter mit Anmerkungen. Naechster Schritt: Kapitel 6")

    return result


if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(description="DriveAI Human Review Gate — Visual Audit")
    parser.add_argument("--run-dir", type=str, required=True, help="Kapitel 5 output directory")
    parser.add_argument("--decision", type=str, choices=["GO", "GO_MIT_NOTES", "REDO"], help="Skip interactive")
    parser.add_argument("--reasoning", type=str, help="Reviewer notes")
    args = parser.parse_args()

    run_dir = Path(args.run_dir)
    result = {}
    for filename in ["asset_discovery.md", "asset_strategy.md", "visual_consistency.md", "pipeline_summary.md"]:
        filepath = run_dir / filename
        if filepath.exists():
            key = filename.replace(".md", "")
            result[key] = filepath.read_text(encoding="utf-8")

    result["idea_title"] = run_dir.name.split("_", 1)[1] if "_" in run_dir.name else run_dir.name
    result["output_dir"] = str(run_dir)
    result["run_number"] = int(run_dir.name.split("_")[0]) if run_dir.name[0].isdigit() else 0

    final = run_review_gate(result, decision=args.decision, reasoning=args.reasoning)

    print(f"\n✓ Entscheidung: {final['review_decision']}")
