"""Kapitel 5 Pipeline Runner — Visual & Asset Audit

Orchestrates: All Reports -> Asset Discovery -> Asset Strategy -> Visual Consistency -> Human Review

Usage:
    python -m factory.visual_audit.pipeline --p1-dir ... --k3-dir ... --k4-dir ...
    python -m factory.visual_audit.pipeline --latest
"""

import datetime
from pathlib import Path


def run_pipeline(phase1_dir: str = None, k3_dir: str = None, k4_dir: str = None) -> dict:
    """Run the complete Kapitel 5 pipeline.

    Args:
        phase1_dir: Phase 1 output directory
        k3_dir: Kapitel 3 output directory
        k4_dir: Kapitel 4 output directory
        All None = auto-detect latest runs.

    Returns:
        dict with asset_discovery, asset_strategy, visual_consistency, output_dir, status
    """
    from factory.visual_audit.input_loader import load_all_reports

    # Step 0: Setup
    print("=" * 60)
    print("  DriveAI Swarm Factory — Kapitel 5: Visual & Asset Audit")
    print("=" * 60)

    print("\n[0/4] Input laden...")
    try:
        data = load_all_reports(phase1_dir=phase1_dir, k3_dir=k3_dir, k4_dir=k4_dir)
    except (FileNotFoundError, ValueError) as e:
        print(f"      FEHLER: {e}")
        return {"status": "error", "error": str(e)}

    title = data.get("idea_title", "App")
    slug = title.lower().replace(" ", "_").replace("-", "_")[:30]
    date_str = datetime.date.today().isoformat()

    # Run numbering
    output_base = Path("factory/visual_audit/output")
    output_base.mkdir(parents=True, exist_ok=True)
    existing = sorted([d.name for d in output_base.iterdir() if d.is_dir() and not d.name.startswith(".")])
    run_number = 1
    for d in existing:
        try:
            num = int(d.split("_")[0])
            run_number = max(run_number, num + 1)
        except ValueError:
            pass
    run_dir = output_base / f"{run_number:03d}_{slug}"
    run_dir.mkdir(parents=True, exist_ok=True)

    p1_count = sum(1 for k in ["concept_brief", "trend_report", "competitive_report", "audience_profile", "legal_report", "risk_assessment"] if data.get(k))
    k3_count = sum(1 for k in ["platform_strategy", "monetization_report", "marketing_strategy", "release_plan", "cost_calculation"] if data.get(k))
    k4_count = sum(1 for k in ["feature_list", "feature_prioritization", "screen_architecture"] if data.get(k))
    print(f"      -> {p1_count + k3_count + k4_count} Reports geladen ({p1_count} + {k3_count} + {k4_count}) ✓")

    print(f"\n  Idee:  {title}")
    print(f"  Kapitel-5 Run: #{run_number:03d}")
    print(f"  Datum: {date_str}")
    print("=" * 60)

    result = {
        "idea_title": title,
        "run_number": run_number,
        "output_dir": str(run_dir.resolve()),
        "asset_discovery": "",
        "asset_strategy": "",
        "visual_consistency": "",
        "status": "completed",
    }

    # Step 1: Asset Discovery (Agent 17)
    print("\n[1/4] Asset-Discovery (Agent 17)")
    try:
        from factory.visual_audit.agents.asset_discovery import run as discover_run
        asset_disc = discover_run(data)
        result["asset_discovery"] = asset_disc
        (run_dir / "asset_discovery.md").write_text(asset_disc, encoding="utf-8")
        print(f"      -> {len(asset_disc):,} Zeichen ✓")
    except Exception as e:
        print(f"      FEHLER: {e}")
        result["status"] = "error"
        result["error"] = f"Asset-Discovery fehlgeschlagen: {e}"
        _save_summary(run_dir, result, date_str)
        return result

    # Step 2: Asset Strategy (Agent 18)
    print("\n[2/4] Asset-Strategie (Agent 18)")
    try:
        from factory.visual_audit.agents.asset_strategy import run as strategy_run
        asset_strat = strategy_run(data, asset_disc)
        result["asset_strategy"] = asset_strat
        (run_dir / "asset_strategy.md").write_text(asset_strat, encoding="utf-8")
        print(f"      -> {len(asset_strat):,} Zeichen ✓")
    except Exception as e:
        print(f"      FEHLER: {e} — fahre ohne Strategie fort")
        result["asset_strategy"] = ""

    # Step 3: Visual Consistency (Agent 19)
    print("\n[3/4] Visual-Consistency-Check (Agent 19)")
    try:
        from factory.visual_audit.agents.visual_consistency import run as consistency_run
        vis_report = consistency_run(data, asset_disc, result["asset_strategy"])
        result["visual_consistency"] = vis_report
        (run_dir / "visual_consistency.md").write_text(vis_report, encoding="utf-8")
        print(f"      -> {len(vis_report):,} Zeichen ✓")
    except Exception as e:
        print(f"      FEHLER: {e}")
        result["status"] = "partial"
        result["visual_consistency"] = ""

    # Step 4: Save + Memory
    print("\n[4/4] Reports speichern + Memory...")
    counts = _extract_counts(result.get("visual_consistency", ""))
    _save_summary(run_dir, result, date_str, counts)
    _update_memory(title, asset_disc, counts)

    file_count = sum(1 for f in run_dir.iterdir() if f.is_file())
    print(f"      -> {file_count} Dateien in {run_dir}")

    # Final banner
    print("\n" + "=" * 60)
    print("  KAPITEL 5 PIPELINE — ABGESCHLOSSEN")
    print(f"  Status: {result['status']}")
    print()
    print("  REVIEW-ZUSAMMENFASSUNG:")
    print(f"  \U0001f534 {counts.get('red', '?')} Blocker — MUESSEN vor Launch geloest werden")
    print(f"  \u26a0\ufe0f  {counts.get('warn', '?')} KI-Warnungen — MUESSEN vom Reviewer geprueft werden")
    print(f"  \U0001f7e1 {counts.get('yellow', '?')} Schlechte UX — SOLLTEN vor Launch geloest werden")
    print(f"  \U0001f7e2 {counts.get('green', '?')} Nice-to-have — Nach Launch moeglich")
    print()
    print(f"  Naechster Schritt: Human Review Gate")
    print(f"  python -m factory.visual_audit.review_gate --run-dir {run_dir}")
    print("=" * 60)

    return result


def _extract_counts(vis_report: str) -> dict:
    """Extract ampel counts from visual consistency report."""
    if not vis_report:
        return {"red": "?", "yellow": "?", "green": "?", "warn": "?"}
    return {
        "red": vis_report.count("\U0001f534"),
        "yellow": vis_report.count("\U0001f7e1"),
        "green": vis_report.count("\U0001f7e2"),
        "warn": vis_report.count("\u26a0\ufe0f"),
    }


def _save_summary(run_dir: Path, result: dict, date_str: str, counts: dict = None):
    """Save pipeline_summary.md."""
    if counts is None:
        counts = {"red": "?", "yellow": "?", "green": "?", "warn": "?"}

    title = result.get("idea_title", "App")
    run_num = result.get("run_number", 0)
    status = result.get("status", "error")

    disc_len = len(result.get("asset_discovery", ""))
    strat_len = len(result.get("asset_strategy", ""))
    vis_len = len(result.get("visual_consistency", ""))

    summary = f"""# Kapitel 5 Pipeline Summary
- Idee: {title}
- Kapitel-5 Run: #{run_num:03d}
- Datum: {date_str}
- Status: {status}

## Agent-Status
| Agent | Status | Report-Laenge |
|---|---|---|
| Asset-Discovery (17) | {"✓" if disc_len > 0 else "✗"} | {disc_len:,} Zeichen |
| Asset-Strategie (18) | {"✓" if strat_len > 0 else "✗"} | {strat_len:,} Zeichen |
| Visual-Consistency (19) | {"✓" if vis_len > 0 else "✗"} | {vis_len:,} Zeichen |

## Review-Zusammenfassung
| Rating | Anzahl |
|---|---|
| \U0001f534 Blocker | {counts.get('red', '?')} |
| \u26a0\ufe0f KI-Warnungen | {counts.get('warn', '?')} |
| \U0001f7e1 Schlechte UX | {counts.get('yellow', '?')} |
| \U0001f7e2 Nice-to-have | {counts.get('green', '?')} |

## Naechster Schritt
Human Review Gate: `python -m factory.visual_audit.review_gate --run-dir {run_dir}`
"""
    (run_dir / "pipeline_summary.md").write_text(summary, encoding="utf-8")


def _update_memory(title: str, asset_disc: str, counts: dict):
    """Append Kapitel 5 learnings to shared learnings file."""
    try:
        learnings_path = Path("factory/pre_production/memory/learnings.md")
        if not learnings_path.exists():
            return

        content = learnings_path.read_text(encoding="utf-8")

        if "## Visual Audit" not in content:
            content += "\n\n## Visual Audit\n(Kapitel 5 Learnings)\n"

        import re
        asset_count = len(set(re.findall(r"A\d{3}", asset_disc)))
        launch_crit = asset_disc.lower().count("| ja |")
        red = counts.get("red", "?")
        warn = counts.get("warn", "?")

        insight = f"- [{asset_count} Assets, {launch_crit} launch-kritisch, {red} Blocker, {warn} KI-Warnungen]: Quelle: Kapitel 5, {title}\n"
        content = content.replace(
            "## Visual Audit\n",
            f"## Visual Audit\n{insight}",
            1,
        )
        learnings_path.write_text(content, encoding="utf-8")
        print("      -> Memory aktualisiert ✓")
    except Exception as e:
        print(f"      WARNING: Memory-Update fehlgeschlagen: {e}")


if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(description="DriveAI Visual & Asset Audit — Kapitel 5")
    parser.add_argument("--p1-dir", type=str, help="Phase 1 output directory")
    parser.add_argument("--k3-dir", type=str, help="Kapitel 3 output directory")
    parser.add_argument("--k4-dir", type=str, help="Kapitel 4 output directory")
    parser.add_argument("--latest", action="store_true", help="Auto-detect latest runs")
    args = parser.parse_args()

    if args.latest:
        result = run_pipeline()
    elif args.p1_dir and args.k3_dir and args.k4_dir:
        result = run_pipeline(phase1_dir=args.p1_dir, k3_dir=args.k3_dir, k4_dir=args.k4_dir)
    else:
        parser.error("Either --latest or all three --p1-dir, --k3-dir, --k4-dir required")
