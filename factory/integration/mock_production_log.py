"""Generate mock production_log.jsonl for dashboard smoke testing.

Usage:
    python -m factory.integration.mock_production_log --slug growmeldai
    python -m factory.integration.mock_production_log --slug growmeldai --realtime
"""

import json
import sys
import time
from datetime import datetime, timedelta
from pathlib import Path

_ROOT = Path(__file__).resolve().parent.parent.parent


def generate_entries(slug: str):
    """Generate a realistic sequence of production log entries."""
    now = datetime.now()
    entries = []

    def ts(offset_s):
        return (now + timedelta(seconds=offset_s)).isoformat()

    # Production start
    entries.append({
        "type": "production_start", "phase": "production",
        "total_steps": 8, "message": f"Production gestartet fuer {slug}",
        "timestamp": ts(0), "elapsed_s": 0,
    })

    # Phase 1: Foundation
    entries.append({
        "type": "phase_start", "phase": "foundation", "total_steps": 3,
        "message": "Phase foundation gestartet", "timestamp": ts(2), "elapsed_s": 2,
    })

    screens = [
        ("S001", "AppShell", "foundation", 5, 120, 0.02, 3, 1200, "sonnet"),
        ("S002", "AuthFlow", "foundation", 12, 340, 0.05, 8, 3400, "sonnet"),
        ("S003", "DataModels", "foundation", 8, 210, 0.03, 5, 2100, "haiku"),
        ("S004", "Dashboard", "application", 18, 520, 0.08, 12, 5200, "sonnet"),
        ("S005", "Settings", "application", 10, 280, 0.04, 6, 2800, "haiku"),
        ("S006", "Navigation", "presentation", 6, 150, 0.02, 4, 1500, "sonnet"),
        ("S007", "ThemeSystem", "presentation", 4, 90, 0.01, 2, 900, "haiku"),
        ("S008", "ErrorHandling", "polish", 3, 60, 0.01, 1, 600, "haiku"),
    ]

    offset = 5
    current_phase = "foundation"

    for i, (sid, name, phase, dur, loc, cost, files, tokens, model) in enumerate(screens):
        # Phase transition
        if phase != current_phase:
            entries.append({
                "type": "phase_complete", "phase": current_phase,
                "message": f"Phase {current_phase} abgeschlossen (3 Steps)",
                "timestamp": ts(offset), "elapsed_s": offset,
            })
            offset += 2
            entries.append({
                "type": "phase_start", "phase": phase,
                "total_steps": len([s for s in screens if s[2] == phase]),
                "message": f"Phase {phase} gestartet",
                "timestamp": ts(offset), "elapsed_s": offset,
            })
            current_phase = phase

        # Step start
        entries.append({
            "type": "step_start", "phase": phase, "screen": sid,
            "agent": f"orchestrator/ios", "message": f"{name} gestartet",
            "timestamp": ts(offset), "elapsed_s": offset,
        })
        offset += dur

        # Step complete
        entries.append({
            "type": "step_complete", "phase": phase, "screen": sid,
            "agent": f"orchestrator/ios", "loc": loc, "cost": cost,
            "duration": float(dur), "files": files, "tokens": tokens,
            "model": model, "timestamp": ts(offset), "elapsed_s": offset,
        })
        offset += 1

    # Final phase complete
    entries.append({
        "type": "phase_complete", "phase": current_phase,
        "message": f"Phase {current_phase} abgeschlossen",
        "timestamp": ts(offset), "elapsed_s": offset,
    })
    offset += 2

    # Production complete
    total_loc = sum(s[4] for s in screens)
    total_files = sum(s[6] for s in screens)
    total_cost = sum(s[5] for s in screens)
    entries.append({
        "type": "production_complete", "phase": "production",
        "total_screens": len(screens), "total_files": total_files,
        "total_loc": total_loc, "cost": total_cost,
        "message": "Production abgeschlossen",
        "timestamp": ts(offset), "elapsed_s": offset,
    })

    return entries


def write_mock_log(slug: str, realtime: bool = False):
    """Write mock entries to production_log.jsonl."""
    log_path = _ROOT / "factory" / "projects" / slug / "production_log.jsonl"
    log_path.parent.mkdir(parents=True, exist_ok=True)

    # Clear existing log
    if log_path.exists():
        log_path.unlink()

    entries = generate_entries(slug)
    print(f"Writing {len(entries)} entries to {log_path}")

    for entry in entries:
        line = json.dumps(entry, ensure_ascii=False) + "\n"
        with open(log_path, "a", encoding="utf-8") as f:
            f.write(line)

        if realtime:
            print(f"  [{entry['type']}] {entry.get('screen', '')} {entry.get('message', '')}")
            if entry["type"] == "step_start":
                time.sleep(0.5)
            elif entry["type"] == "step_complete":
                time.sleep(0.2)
            else:
                time.sleep(0.1)

    print(f"Done. {len(entries)} entries written.")
    return str(log_path)


if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(description="Mock Production Logger")
    parser.add_argument("--slug", default="growmeldai", help="Project slug")
    parser.add_argument("--realtime", action="store_true", help="Simulate real-time writing")
    args = parser.parse_args()

    write_mock_log(args.slug, realtime=args.realtime)
