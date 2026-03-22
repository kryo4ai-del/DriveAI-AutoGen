"""Kapitel 4.5 Pipeline Runner — Design Vision & UX Innovation

Orchestrates: Trend-Breaker -> Emotion-Architect -> Vision-Compiler

Usage:
    python -m factory.design_vision.pipeline --p1-dir ... --k3-dir ... --k4-dir ...
    python -m factory.design_vision.pipeline --latest
"""

import datetime
from pathlib import Path


def run_pipeline(phase1_dir: str = None, k3_dir: str = None, k4_dir: str = None) -> dict:
    """Run the complete Kapitel 4.5 pipeline."""
    from factory.design_vision.input_loader import load_all_reports

    print("=" * 60)
    print("  DriveAI Swarm Factory — Kapitel 4.5: Design Vision")
    print("=" * 60)

    print("\n[0/3] Input laden...")
    try:
        data = load_all_reports(phase1_dir=phase1_dir, k3_dir=k3_dir, k4_dir=k4_dir)
    except (FileNotFoundError, ValueError) as e:
        print(f"      FEHLER: {e}")
        return {"status": "error", "error": str(e)}

    title = data.get("idea_title", "App")
    slug = title.lower().replace(" ", "_").replace("-", "_")[:30]
    date_str = datetime.date.today().isoformat()

    # Run numbering
    output_base = Path("factory/design_vision/output")
    output_base.mkdir(parents=True, exist_ok=True)
    existing = sorted([d.name for d in output_base.iterdir() if d.is_dir() and not d.name.startswith(".")])
    run_number = 1
    for d in existing:
        try:
            run_number = max(run_number, int(d.split("_")[0]) + 1)
        except ValueError:
            pass
    run_dir = output_base / f"{run_number:03d}_{slug}"
    run_dir.mkdir(parents=True, exist_ok=True)

    print(f"      -> 14 Reports geladen ✓")
    print(f"\n  Idee:  {title}")
    print(f"  Kapitel-4.5 Run: #{run_number:03d}")
    print(f"  Datum: {date_str}")
    print("=" * 60)

    result = {
        "idea_title": title,
        "run_number": run_number,
        "output_dir": str(run_dir.resolve()),
        "trend_breaker_report": "",
        "emotion_architect_report": "",
        "design_vision_document": "",
        "status": "completed",
    }

    # Step 1: Trend-Breaker (17a)
    print("\n[1/3] Design-Trend-Breaker (Agent 17a)...")
    try:
        from factory.design_vision.agents.trend_breaker import run as tb_run
        tb = tb_run(data)
        result["trend_breaker_report"] = tb
        (run_dir / "trend_breaker_report.md").write_text(tb, encoding="utf-8")
        print(f"      -> {len(tb):,} Zeichen ✓")
    except Exception as e:
        print(f"      FEHLER: {e}")
        result["status"] = "error"
        result["error"] = f"Trend-Breaker fehlgeschlagen: {e}"
        _save_summary(run_dir, result, date_str)
        return result

    # Step 2: Emotion-Architect (17b) — needs 17a
    print("\n[2/3] UX-Emotion-Architect (Agent 17b)...")
    try:
        from factory.design_vision.agents.emotion_architect import run as ea_run
        ea = ea_run(data, tb)
        result["emotion_architect_report"] = ea
        (run_dir / "emotion_architect_report.md").write_text(ea, encoding="utf-8")
        print(f"      -> {len(ea):,} Zeichen ✓")
    except Exception as e:
        print(f"      FEHLER: {e}")
        result["status"] = "error"
        result["error"] = f"Emotion-Architect fehlgeschlagen: {e}"
        _save_summary(run_dir, result, date_str)
        return result

    # Step 3: Vision-Compiler (17c) — needs 17a + 17b
    print("\n[3/3] Design-Vision-Compiler (Agent 17c)...")
    try:
        from factory.design_vision.agents.vision_compiler import run as vc_run
        dv = vc_run(data, tb, ea)
        result["design_vision_document"] = dv
        (run_dir / "design_vision_document.md").write_text(dv, encoding="utf-8")
        print(f"      -> {len(dv):,} Zeichen ✓")
    except Exception as e:
        print(f"      FEHLER: {e}")
        result["status"] = "partial"
        result["design_vision_document"] = ""

    # Save summary + memory
    _save_summary(run_dir, result, date_str)
    _update_memory(title, result.get("design_vision_document", ""))

    # Extract design briefing first sentence
    briefing_quote = ""
    dv_text = result.get("design_vision_document", "")
    if "Design-Briefing" in dv_text:
        for line in dv_text.split("\n"):
            line = line.strip()
            if line and not line.startswith("#") and not line.startswith("---") and not line.startswith("[") and len(line) > 30:
                briefing_quote = line[:150]
                break

    print("\n" + "=" * 60)
    print("  KAPITEL 4.5 PIPELINE — ABGESCHLOSSEN")
    print(f"  Status: {result['status']}")
    if briefing_quote:
        print(f"\n  Design-Briefing: \"{briefing_quote}...\"")
    print(f"\n  Naechster Schritt: Kapitel 5 (Visual & Asset Audit)")
    print("=" * 60)

    return result


def _save_summary(run_dir: Path, result: dict, date_str: str):
    title = result.get("idea_title", "App")
    run_num = result.get("run_number", 0)
    status = result.get("status", "error")
    tb_len = len(result.get("trend_breaker_report", ""))
    ea_len = len(result.get("emotion_architect_report", ""))
    dv_len = len(result.get("design_vision_document", ""))

    summary = f"""# Kapitel 4.5 Pipeline Summary
- Idee: {title}
- Run: #{run_num:03d}
- Datum: {date_str}
- Status: {status}

## Agent-Status
| Agent | Status | Report-Laenge |
|---|---|---|
| Trend-Breaker (17a) | {"✓" if tb_len > 0 else "✗"} | {tb_len:,} Zeichen |
| Emotion-Architect (17b) | {"✓" if ea_len > 0 else "✗"} | {ea_len:,} Zeichen |
| Vision-Compiler (17c) | {"✓" if dv_len > 0 else "✗"} | {dv_len:,} Zeichen |
"""
    (run_dir / "pipeline_summary.md").write_text(summary, encoding="utf-8")


def _update_memory(title: str, design_vision: str):
    try:
        learnings_path = Path("factory/pre_production/memory/learnings.md")
        if not learnings_path.exists():
            return
        content = learnings_path.read_text(encoding="utf-8")
        if "## Design Vision" not in content:
            content += "\n\n## Design Vision\n(Kapitel 4.5 Learnings)\n"

        # Extract first meaningful sentence from design briefing
        briefing = ""
        if "Design-Briefing" in design_vision:
            in_briefing = False
            for line in design_vision.split("\n"):
                if "Design-Briefing" in line:
                    in_briefing = True
                    continue
                if in_briefing and line.strip() and not line.startswith("#") and not line.startswith("---"):
                    briefing = line.strip()[:100]
                    break

        if briefing:
            insight = f"- [{briefing}]: Quelle: Kapitel 4.5, {title}\n"
            content = content.replace("## Design Vision\n", f"## Design Vision\n{insight}", 1)

        learnings_path.write_text(content, encoding="utf-8")
        print("      -> Memory aktualisiert ✓")
    except Exception as e:
        print(f"      WARNING: Memory-Update fehlgeschlagen: {e}")


if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(description="DriveAI Design Vision — Kapitel 4.5")
    parser.add_argument("--p1-dir", type=str, help="Phase 1 output")
    parser.add_argument("--k3-dir", type=str, help="Kapitel 3 output")
    parser.add_argument("--k4-dir", type=str, help="Kapitel 4 output")
    parser.add_argument("--latest", action="store_true", help="Auto-detect")
    args = parser.parse_args()

    if args.latest:
        result = run_pipeline()
    elif args.p1_dir and args.k3_dir and args.k4_dir:
        result = run_pipeline(phase1_dir=args.p1_dir, k3_dir=args.k3_dir, k4_dir=args.k4_dir)
    else:
        parser.error("Either --latest or all three --p1-dir, --k3-dir, --k4-dir required")
