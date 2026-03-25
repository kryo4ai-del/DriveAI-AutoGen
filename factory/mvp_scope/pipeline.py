"""Kapitel 4 Pipeline Runner — MVP & Feature Scope

Orchestrates: All Reports -> Feature Extraction -> Prioritization -> Screen Architecture

Usage:
    python -m factory.mvp_scope.pipeline --p1-dir factory/pre_production/output/003_echomatch --p2-dir factory/market_strategy/output/001_echomatch
    python -m factory.mvp_scope.pipeline --latest
"""

import re
import traceback
from datetime import date
from pathlib import Path

import anthropic
from dotenv import load_dotenv

from factory.mvp_scope.input_loader import load_all_reports
from factory.mvp_scope.agents import feature_extraction, feature_prioritization, screen_architect
from factory.mvp_scope.config import AGENT_MODEL_MAP

load_dotenv()

OUTPUT_BASE = Path(__file__).resolve().parent / "output"


def _get_next_run_number() -> int:
    if not OUTPUT_BASE.exists():
        return 1
    dirs = [d for d in OUTPUT_BASE.iterdir() if d.is_dir() and re.match(r"\d+_", d.name)]
    if not dirs:
        return 1
    return max(int(re.match(r"(\d+)_", d.name).group(1)) for d in dirs) + 1


def _make_slug(title: str) -> str:
    slug = title.lower().replace(" ", "_")
    return re.sub(r"[^a-z0-9_]", "", slug)[:30]


def _save(output_dir: Path, filename: str, content: str) -> None:
    (output_dir / filename).write_text(content, encoding="utf-8")


def _banner(title: str, p1_run: str, p2_run: str, k4_run: int) -> str:
    line = "=" * 60
    return (
        f"\n{line}\n"
        f"  DriveAI Swarm Factory — Kapitel 4: MVP & Feature Scope\n"
        f"{line}\n"
        f"  Idee:  {title}\n"
        f"  Phase-1 Run: {p1_run}\n"
        f"  Kapitel-3 Run: {p2_run}\n"
        f"  Kapitel-4 Run: #{k4_run:03d}\n"
        f"  Datum: {date.today().isoformat()}\n"
        f"{line}\n"
    )


def _retry_flows(screen_architecture: str, concept_brief: str) -> str:
    """Retry user flows generation with Markdown output (avoids JSON parse issues)."""
    prompt = f"""Du bist ein UX-Architekt. Erstelle 7 User Flows und Edge Cases fuer diese Screen-Architektur.

## Screens (bereits definiert)
{screen_architecture[:6000]}

## Concept Brief
{concept_brief[:3000]}

Erstelle die Flows als einfache Markdown-Liste (KEIN JSON):

# User Flows

## Flow 1: Onboarding (Erst-Start)
- Pfad: S001 -> S002 -> ...
- Taps bis Core Loop: X
- Zeitbudget: ~60 Sekunden
- Fallback: Bei Consent-Nein -> generische Levels

## Flow 2: Core Loop (wiederkehrend)
- Pfad: ...
- Taps bis Match: X
- Session-Ziel: 6-10 Minuten

## Flow 3: Erster Kauf
- Pfad: ...
- Taps bis Kauf: X

## Flow 4: Social Challenge
- Pfad: ...
- Taps: X

## Flow 5: Battle-Pass
- Pfad: ...
- Taps: X

## Flow 6: Rewarded Ad
- Pfad: ...
- Taps: X

## Flow 7: Consent (Detail)
- Pfad: ...

# Edge Cases

| Situation | Betroffene Screens | Verhalten |
|---|---|---|
| Consent abgelehnt | ... | Generische Levels |
| Internetverlust im Match | ... | Lokal weiterspielen |
| KI-Fehler | ... | Cache-Fallback |
| Kauf fehlgeschlagen | ... | Fehlermeldung, Retry |
| Server-Ausfall | ... | Core-Loop offline |
| COPPA (unter 13) | ... | Kein Tracking |
| Push abgelehnt | ... | Nudge nach 7 Tagen |

# Tap-Count-Zusammenfassung

| Flow | Taps | Ziel | Status |
|---|---|---|---|
| Onboarding -> Core Loop | X | max 3 | ok/ueber |
| Core Loop -> Match | X | max 3 | ok |
| Home -> Kauf | X | max 3 | ok |
| Social Challenge | X | max 3 | ok |
| Rewarded Ad | X | max 2 | ok |

WICHTIG: Antworte in reinem Markdown, KEIN JSON. Verwende die Screen-IDs aus der Architektur oben."""

    client = anthropic.Anthropic()
    response = client.messages.create(
        model=AGENT_MODEL_MAP["screen_architect"],
        max_tokens=4000,
        messages=[{"role": "user", "content": prompt}],
    )
    return response.content[0].text


def _has_flows(text: str) -> bool:
    """Check if screen architecture contains user flows."""
    lower = text.lower()
    return ("flow 1" in lower or "flow1" in lower or "onboarding" in lower) and "flow 2" in lower


def run_pipeline(phase1_dir: str = None, phase2_dir: str = None) -> dict:
    """Run the complete Kapitel 4 pipeline."""
    # --- Step 0: Setup ---
    print("[0/4] Input laden...")
    all_reports = load_all_reports(phase1_dir, phase2_dir)
    title = all_reports["idea_title"]
    print(f"      -> 11 Reports geladen (6 Phase-1 + 5 Kapitel-3) OK\n")

    k4_run = _get_next_run_number()
    slug = _make_slug(title)
    output_dir = OUTPUT_BASE / f"{k4_run:03d}_{slug}"
    output_dir.mkdir(parents=True, exist_ok=True)

    p1_dir = all_reports["phase1_run_dir"]
    p2_dir = all_reports["phase2_run_dir"]

    # Propagate run mode
    from factory.run_mode import read_mode, write_mode
    _mode = read_mode(p2_dir) or read_mode(p1_dir)
    write_mode(output_dir, _mode)

    result = {
        "idea_title": title,
        "run_number": k4_run,
        "feature_list": "",
        "feature_prioritization": "",
        "screen_architecture": "",
        "output_dir": str(output_dir),
        "status": "completed",
        "missing": [],
        "failed_agents": [],
    }

    print(_banner(title, p1_dir, p2_dir, k4_run))

    # --- Step 1: Feature Extraction ---
    print("[1/4] Feature-Extraction (Agent 14)")
    try:
        result["feature_list"] = feature_extraction.run(all_reports)
        _save(output_dir, "feature_list.md", result["feature_list"])
        feature_count = len(set(re.findall(r"F\d{3}", result["feature_list"])))
        print(f"      -> Feature-Liste: {feature_count} Features, {len(result['feature_list']):,} Zeichen OK\n")
    except Exception as e:
        print(f"      -> FEHLER: {e}")
        traceback.print_exc()
        result["status"] = "error"
        result["failed_agents"].append("feature_extraction")
        _save(output_dir, "feature_list.md", f"# FEHLER\n{e}")
        _save_summary(output_dir, result, all_reports)
        return result

    # --- Step 2: Feature Prioritization ---
    print("[2/4] Feature-Priorisierung (Agent 15)")
    try:
        result["feature_prioritization"] = feature_prioritization.run(result["feature_list"], all_reports)
        _save(output_dir, "feature_prioritization.md", result["feature_prioritization"])
        print(f"      -> Priorisierung: {len(result['feature_prioritization']):,} Zeichen OK\n")
    except Exception as e:
        print(f"      -> FEHLER: {e}")
        traceback.print_exc()
        result["status"] = "error"
        result["failed_agents"].append("feature_prioritization")
        _save(output_dir, "feature_prioritization.md", f"# FEHLER\n{e}")
        _save_summary(output_dir, result, all_reports)
        return result

    # --- Step 3: Screen Architecture ---
    print("[3/4] Screen-Architektur (Agent 16)")
    try:
        result["screen_architecture"] = screen_architect.run(result["feature_prioritization"], all_reports)
        _save(output_dir, "screen_architecture.md", result["screen_architecture"])
        print(f"      -> Screen-Architektur: {len(result['screen_architecture']):,} Zeichen")
    except Exception as e:
        print(f"      -> FEHLER: {e}")
        traceback.print_exc()
        result["status"] = "partial"
        result["failed_agents"].append("screen_architect")
        result["missing"].extend(["screens", "user_flows", "edge_cases"])
        _save(output_dir, "screen_architecture.md", f"# FEHLER\n{e}")

    # --- Step 3b: Flow Retry if needed ---
    if result["screen_architecture"] and not _has_flows(result["screen_architecture"]):
        print("      -> Flows fehlgeschlagen, Retry mit Markdown-Prompt...")
        try:
            flows_md = _retry_flows(result["screen_architecture"], all_reports.get("concept_brief", ""))
            if _has_flows(flows_md):
                result["screen_architecture"] += "\n\n" + flows_md
                _save(output_dir, "screen_architecture.md", result["screen_architecture"])
                print("      -> 7 Flows nachgeholt OK")
            else:
                result["missing"].extend(["user_flows", "edge_cases"])
                result["status"] = "partial"
                print("      -> Retry auch fehlgeschlagen — Status: partial ⚠️")
        except Exception as e:
            result["missing"].extend(["user_flows", "edge_cases"])
            result["status"] = "partial"
            print(f"      -> Retry FEHLER: {e}")
    elif result["screen_architecture"] and _has_flows(result["screen_architecture"]):
        print("      -> Flows vorhanden OK")

    print()

    # --- Step 4: Save + Memory ---
    print("[4/4] Reports speichern...")
    _save_summary(output_dir, result, all_reports)
    file_count = sum(1 for f in output_dir.iterdir() if f.suffix == ".md")
    print(f"      -> {file_count} Dateien in {output_dir}")

    try:
        _save_learnings(result, title)
        print("      -> Memory aktualisiert OK")
    except Exception as e:
        print(f"      -> WARNING: Learnings nicht gespeichert — {e}")

    # Final banner
    line = "=" * 60
    print(f"\n{line}")
    print(f"  KAPITEL 4 PIPELINE — ABGESCHLOSSEN")
    print(f"  Status: {result['status']}")
    print(f"  Reports: {output_dir}")
    if result["missing"]:
        print(f"  Fehlend: {', '.join(result['missing'])}")
    print(f"  Naechster Schritt: Kapitel 5 (Visual & Asset Audit)")
    print(line)

    try:
        from factory.project_registry import update_project_phase
        import re
        _slug = re.sub(r'[^a-z0-9_]', '', result.get("idea_title", "").lower().replace(" ", "_"))[:40]
        update_project_phase(_slug, "kapitel4", "complete" if result["status"] == "completed" else "partial", str(output_dir))
    except Exception as e:
        print(f"  [Registry] Warning: {e}")

    return result


def _save_summary(output_dir: Path, result: dict, all_reports: dict) -> None:
    """Save pipeline_summary.md."""
    agents = [
        ("Feature-Extraction (14)", "feature_list"),
        ("Feature-Priorisierung (15)", "feature_prioritization"),
        ("Screen-Architect (16)", "screen_architecture"),
    ]
    rows = []
    for name, key in agents:
        failed = key.replace("_list", "").replace("_", "") in [
            a.replace("_", "") for a in result.get("failed_agents", [])
        ]
        status = "FEHLER" if failed else ("partial" if key == "screen_architecture" and result.get("missing") else "OK")
        length = len(result.get(key, ""))
        rows.append(f"| {name} | {status} | {length:,} Zeichen |")

    missing_text = "\n".join(f"- {m}" for m in result.get("missing", [])) or "Keine"

    summary = f"""# Kapitel 4 Pipeline Summary

- **Idee:** {result['idea_title']}
- **Kapitel-4 Run:** #{result['run_number']:03d}
- **Datum:** {date.today().isoformat()}
- **Status:** {result['status']}

## Agent-Status
| Agent | Status | Report-Laenge |
|---|---|---|
{chr(10).join(rows)}

## Fehlende Sektionen
{missing_text}
"""
    _save(output_dir, "pipeline_summary.md", summary)


def _save_learnings(result: dict, title: str) -> None:
    """Append Kapitel 4 learnings to shared learnings file."""
    learnings_path = Path(__file__).resolve().parent.parent / "pre_production" / "memory" / "learnings.md"
    content = learnings_path.read_text(encoding="utf-8")

    if "## Features & Screens" not in content:
        content += "\n\n## Features & Screens\n(Kapitel 4 Learnings)\n"

    # Extract feature count
    feature_count = len(set(re.findall(r"F\d{3}", result.get("feature_list", ""))))
    prio = result.get("feature_prioritization", "")
    phase_a_match = re.search(r"Phase A.*?(\d+)\s*Features", prio)
    phase_a_count = phase_a_match.group(1) if phase_a_match else "?"

    insight = f"Phase A: {phase_a_count} Features von {feature_count} gesamt"
    entry = f"- [{insight}]: Quelle: Kapitel 4, {title}\n"

    content = content.replace(
        "## Features & Screens\n",
        f"## Features & Screens\n{entry}",
        1,
    )
    learnings_path.write_text(content, encoding="utf-8")


if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(description="DriveAI MVP & Feature Scope — Kapitel 4")
    parser.add_argument("--p1-dir", type=str, help="Phase 1 output directory")
    parser.add_argument("--p2-dir", type=str, help="Kapitel 3 output directory")
    parser.add_argument("--latest", action="store_true", help="Auto-detect latest runs")
    args = parser.parse_args()

    if args.latest:
        run_pipeline()
    elif args.p1_dir and args.p2_dir:
        run_pipeline(phase1_dir=args.p1_dir, phase2_dir=args.p2_dir)
    else:
        parser.error("Either --latest or both --p1-dir and --p2-dir required")
