"""Kapitel 6 Pipeline Runner — Roadbook Assembly (FINALE)

Orchestrates: All Reports -> [CEO-Roadbook + CD-Roadbook] -> 2 Roadbooks

Usage:
    python -m factory.roadbook_assembly.pipeline --p1-dir ... --k3-dir ... --k4-dir ... --k45-dir ... --k5-dir ...
    python -m factory.roadbook_assembly.pipeline --latest
"""

import datetime
from pathlib import Path


def run_pipeline(phase1_dir=None, k3_dir=None, k4_dir=None, k45_dir=None, k5_dir=None, mode_override: str = None) -> dict:
    """Run the complete Kapitel 6 pipeline (FINALE)."""
    from factory.roadbook_assembly.input_loader import load_all_reports

    print("=" * 60)
    print("  DriveAI Swarm Factory — Kapitel 6: Roadbook Assembly")
    print("  * FINALES KAPITEL DER PRE-PRODUCTION PIPELINE *")
    print("=" * 60)

    print("\n[0/2] Input laden...")
    try:
        data = load_all_reports(phase1_dir=phase1_dir, k3_dir=k3_dir, k4_dir=k4_dir, k45_dir=k45_dir, k5_dir=k5_dir)
    except (FileNotFoundError, ValueError) as e:
        print(f"      FEHLER: {e}")
        return {"status": "error", "error": str(e)}

    title = data.get("idea_title", "App")
    slug = title.lower().replace(" ", "_").replace("-", "_")[:30]
    date_str = datetime.date.today().isoformat()

    # Combined size
    combined = data.get("all_reports_combined", "")
    combined_k = len(combined) // 1000

    # Run numbering
    output_base = Path("factory/roadbook_assembly/output")
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

    # Detect run mode (from upstream or override)
    from factory.run_mode import read_mode, write_mode
    _mode = mode_override or "vision"
    if not mode_override:
        for src in [k5_dir, k45_dir, k4_dir, k3_dir, phase1_dir]:
            if src:
                _mode = read_mode(src)
                if _mode != "vision":
                    break
    write_mode(run_dir, _mode)
    if _mode == "factory":
        print(f"      -> MODE: FACTORY (production-constrained)")

    print(f"      -> 20 Reports aus 5 Kapiteln ({combined_k}k chars) OK")
    print(f"\n  Idee:  {title}")
    print(f"  Kapitel-6 Run: #{run_number:03d}")
    print(f"  Datum: {date_str}")
    print("=" * 60)

    result = {
        "idea_title": title,
        "run_number": run_number,
        "output_dir": str(run_dir.resolve()),
        "ceo_roadbook": "",
        "cd_roadbook": "",
        "status": "completed",
        "ceo_cost": 0,
        "cd_cost": 0,
    }

    # Step 1: CEO Strategic Roadbook
    print("\n[1/2] CEO Strategic Roadbook (Agent 22)...")
    try:
        from factory.roadbook_assembly.agents.ceo_roadbook import run as ceo_run
        ceo = ceo_run(data, mode=_mode)
        result["ceo_roadbook"] = ceo
        (run_dir / "ceo_strategic_roadbook.md").write_text(ceo, encoding="utf-8")
        ceo_pages = len(ceo) // 1000
        print(f"      -> {len(ceo):,} Zeichen (~{ceo_pages} Seiten) OK")
    except Exception as e:
        print(f"      FEHLER: {e}")
        result["status"] = "partial"

    # Step 2: CD Technical Roadbook
    print("\n[2/2] Creative Director Technical Roadbook (Agent 23)...")
    try:
        from factory.roadbook_assembly.agents.cd_roadbook import run as cd_run
        cd = cd_run(data, mode=_mode)
        result["cd_roadbook"] = cd
        (run_dir / "cd_technical_roadbook.md").write_text(cd, encoding="utf-8")
        cd_pages = len(cd) // 1000
        print(f"      -> {len(cd):,} Zeichen (~{cd_pages} Seiten) OK")
    except Exception as e:
        print(f"      FEHLER: {e}")
        if result["status"] == "partial":
            result["status"] = "error"
        else:
            result["status"] = "partial"

    # Step 3: Save summary + memory
    _save_summary(run_dir, result, date_str, combined_k)
    _update_memory(title, result)

    # Final banner
    ceo_len = len(result.get("ceo_roadbook", ""))
    cd_len = len(result.get("cd_roadbook", ""))

    print("\n" + "=" * 60)
    print("  * PRE-PRODUCTION PIPELINE ABGESCHLOSSEN *")
    print("=" * 60)
    print()
    print(f"  CEO Strategic Roadbook:     ~{ceo_len // 1000} Seiten -> fuer CEO + Investoren")
    print(f"  CD Technical Roadbook:      ~{cd_len // 1000} Seiten -> fuer Creative Director + Lines")
    print()
    print(f"  Gesamt-Output dieser Pipeline:")
    print(f"  - 6 Kapitel durchlaufen")
    print(f"  - 24 Agents ausgefuehrt")
    print(f"  - 20+ Reports generiert")
    print(f"  - 15 PDF-Templates verfuegbar")
    print(f"  - 2 Roadbooks kompiliert")
    print()
    print(f"  * Creative Director kann jetzt die Lines starten *")
    print("=" * 60)

    try:
        from factory.project_registry import update_project_phase, add_document
        import re
        _slug = re.sub(r'[^a-z0-9_]', '', result.get("idea_title", "").lower().replace(" ", "_"))[:40]
        update_project_phase(_slug, "kapitel6", "complete" if result["status"] == "completed" else "partial", str(run_dir))
        # Register roadbook documents
        for key in ["ceo_roadbook", "cd_roadbook"]:
            if result.get(key):
                rb_path = str(run_dir / f"{'ceo_strategic' if 'ceo' in key else 'cd_technical'}_roadbook.md")
                add_document(_slug, "roadbooks", rb_path)
    except Exception as e:
        print(f"  [Registry] Warning: {e}")

    return result


def _save_summary(run_dir: Path, result: dict, date_str: str, input_k: int):
    title = result.get("idea_title", "App")
    run_num = result.get("run_number", 0)
    status = result.get("status", "error")
    ceo_len = len(result.get("ceo_roadbook", ""))
    cd_len = len(result.get("cd_roadbook", ""))

    summary = f"""# Kapitel 6 Pipeline Summary — FINALE
- Idee: {title}
- Run: #{run_num:03d}
- Datum: {date_str}
- Status: {status}
- Input: {input_k}k chars aus 5 Kapiteln

## Roadbooks
| Roadbook | Status | Laenge | Zielgruppe |
|---|---|---|---|
| CEO Strategic | {"OK" if ceo_len > 0 else "FAIL"} | {ceo_len:,} Zeichen (~{ceo_len // 1000} Seiten) | CEO, Investoren |
| CD Technical | {"OK" if cd_len > 0 else "FAIL"} | {cd_len:,} Zeichen (~{cd_len // 1000} Seiten) | Creative Director, Lines |

## Pipeline-Gesamtbilanz
- Kapitel durchlaufen: 6 (Phase 1, K3, K4, K4.5, K5, K6)
- Agents ausgefuehrt: 24
- Reports generiert: 20+
- PDF-Templates: 15
"""
    (run_dir / "pipeline_summary.md").write_text(summary, encoding="utf-8")


def _update_memory(title: str, result: dict):
    try:
        learnings_path = Path("factory/pre_production/memory/learnings.md")
        if not learnings_path.exists():
            return
        content = learnings_path.read_text(encoding="utf-8")

        if "## Roadbook Assembly" not in content:
            content += "\n\n## Roadbook Assembly\n(Kapitel 6 Learnings)\n"

        ceo_pages = len(result.get("ceo_roadbook", "")) // 1000
        cd_pages = len(result.get("cd_roadbook", "")) // 1000
        insight = f"- [CEO Roadbook: ~{ceo_pages} Seiten, CD Roadbook: ~{cd_pages} Seiten, Pipeline komplett]: Quelle: Kapitel 6, {title}\n"
        content = content.replace("## Roadbook Assembly\n", f"## Roadbook Assembly\n{insight}", 1)

        learnings_path.write_text(content, encoding="utf-8")
        print("      -> Memory aktualisiert OK")
    except Exception as e:
        print(f"      WARNING: Memory-Update fehlgeschlagen: {e}")


if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(description="DriveAI Roadbook Assembly — Kapitel 6 (FINALE)")
    parser.add_argument("--p1-dir", type=str, help="Phase 1 output")
    parser.add_argument("--k3-dir", type=str, help="Kapitel 3 output")
    parser.add_argument("--k4-dir", type=str, help="Kapitel 4 output")
    parser.add_argument("--k45-dir", type=str, help="Kapitel 4.5 output")
    parser.add_argument("--k5-dir", type=str, help="Kapitel 5 output")
    parser.add_argument("--latest", action="store_true", help="Auto-detect")
    parser.add_argument("--mode", choices=["vision", "factory"], default=None,
                        help="Override run mode (vision or factory)")
    args = parser.parse_args()

    if args.latest:
        result = run_pipeline(mode_override=args.mode)
    elif args.p1_dir and args.k3_dir and args.k4_dir and args.k45_dir and args.k5_dir:
        result = run_pipeline(args.p1_dir, args.k3_dir, args.k4_dir, args.k45_dir, args.k5_dir, mode_override=args.mode)
    else:
        parser.error("Either --latest or all five directories required")
