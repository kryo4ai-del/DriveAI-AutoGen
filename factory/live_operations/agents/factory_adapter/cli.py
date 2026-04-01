"""CLI for FactoryAdapter — simulate briefing submission to Factory."""

import argparse
import json
import sys
import tempfile
from datetime import datetime, timezone

from .adapter import FactoryAdapter
from ..update_planner.planner import UpdatePlanner


# ── Simulation Helpers ─────────────────────────────────────────────

def _make_briefing(app_id: str, action_type: str, version: str, trigger: str) -> dict:
    """Build a minimal briefing for testing."""
    planner = UpdatePlanner(data_dir=tempfile.mkdtemp(prefix="adapter_sim_"))
    action = {
        "app_id": app_id,
        "decided_at": datetime.now(timezone.utc).isoformat(),
        "health_score": 45.0,
        "health_zone": "yellow",
        "action_type": action_type,
        "severity_scores": [{
            "trigger": trigger,
            "severity": 60.0,
            "deviation": 0.5,
            "impact": 0.5,
            "velocity": 0.5,
            "category": "stability",
            "detail": f"{trigger} detected",
        }],
        "primary_trigger": trigger,
        "escalation_level": 1,
        "data_summary": {"active_triggers": 1, "max_severity": 60.0, "categories_affected": ["stability"]},
        "action_id": f"ACT-{app_id}-SIM",
    }
    app_info = {"name": app_id.title(), "current_version": version, "platform": "ios"}
    return planner.create_briefing(action, app_info)


SCENARIOS = {
    "submit_hotfix": {
        "description": "Hotfix Briefing an Factory uebergeben",
        "run": lambda tmp: _sim_submit(tmp, "echomatch", "hotfix", "1.4.2", "crash_rate_high"),
        "validate": lambda r: (
            r["submission"]["status"] == "submitted"
            and r["submission"]["factory_task_id"] is not None
            and r["submission"]["factory_product_id"].startswith("PROD-echomatch-hotfix")
            and len(r["submission"]["history"]) == 2
        ),
    },
    "submit_patch": {
        "description": "Patch Briefing mit Status-Update (accepted -> in_progress -> completed)",
        "run": lambda tmp: _sim_lifecycle(tmp),
        "validate": lambda r: (
            r["final_status"] == "completed"
            and r["history_length"] == 5  # created + submitted + accepted + in_progress + completed
            and r["completed_at"] is not None
        ),
    },
    "list_filter": {
        "description": "Submissions auflisten und filtern",
        "run": lambda tmp: _sim_list(tmp),
        "validate": lambda r: (
            r["total"] == 3
            and r["by_app"] == 2
            and r["by_status"] == 1
            and r["active"] == 2  # 2 still submitted, 1 completed
        ),
    },
}


def _sim_submit(tmp: str, app_id: str, action_type: str, version: str, trigger: str) -> dict:
    """Submit a single briefing."""
    adapter = FactoryAdapter(data_dir=tmp)
    briefing = _make_briefing(app_id, action_type, version, trigger)
    submission = adapter.submit_briefing(briefing)
    return {"submission": submission}


def _sim_lifecycle(tmp: str) -> dict:
    """Full lifecycle: submit -> accepted -> in_progress -> completed."""
    adapter = FactoryAdapter(data_dir=tmp)
    briefing = _make_briefing("drivepulse", "patch", "2.1.0", "retention_dropping")
    sub = adapter.submit_briefing(briefing)
    sid = sub["submission_id"]

    adapter.update_status(sid, "accepted", "Factory hat Briefing angenommen")
    adapter.update_status(sid, "in_progress", "Build gestartet")
    adapter.update_status(sid, "completed", "Build erfolgreich")

    final = adapter.get_submission(sid)
    return {
        "final_status": final["status"],
        "history_length": len(final["history"]),
        "completed_at": final["completed_at"],
    }


def _sim_list(tmp: str) -> dict:
    """Multiple submissions with filtering."""
    adapter = FactoryAdapter(data_dir=tmp)

    # 3 submissions: 2x echomatch, 1x drivepulse
    b1 = _make_briefing("echomatch", "hotfix", "1.4.2", "crash_rate_high")
    b2 = _make_briefing("echomatch", "patch", "1.4.3", "retention_dropping")
    b3 = _make_briefing("drivepulse", "feature_update", "2.1.0", "revenue_declining")

    s1 = adapter.submit_briefing(b1)
    s2 = adapter.submit_briefing(b2)
    s3 = adapter.submit_briefing(b3)

    # Complete one
    adapter.update_status(s1["submission_id"], "accepted")
    adapter.update_status(s1["submission_id"], "in_progress")
    adapter.update_status(s1["submission_id"], "completed")

    return {
        "total": len(adapter.list_submissions()),
        "by_app": len(adapter.list_submissions(app_id="echomatch")),
        "by_status": len(adapter.list_submissions(status="completed")),
        "active": len(adapter.get_active_submissions()),
    }


# ── Simulation Runner ──────────────────────────────────────────────

def _run_simulation(scenario_name: str, as_json: bool = False) -> dict:
    scenario = SCENARIOS.get(scenario_name)
    if not scenario:
        return {"error": f"Unknown scenario: {scenario_name}", "ok": False}

    tmp = tempfile.mkdtemp(prefix="adapter_sim_")
    raw = scenario["run"](tmp)

    try:
        valid = scenario["validate"](raw)
    except Exception as e:
        valid = False
        raw["validation_error"] = str(e)

    result = {
        "scenario": scenario_name,
        "description": scenario["description"],
        "validation_passed": valid,
        "ok": valid,
    }
    if as_json:
        result["data"] = raw
    return result


def _run_all(as_json: bool = False) -> list:
    return [_run_simulation(name, as_json) for name in SCENARIOS]


# ── CLI Entry ──────────────────────────────────────────────────────

def main():
    parser = argparse.ArgumentParser(description="FactoryAdapter — Briefing Submission")
    parser.add_argument("--simulate", action="store_true", help="Run simulations")
    parser.add_argument("--scenario", type=str, help="Specific scenario")
    parser.add_argument("--submit", type=str, help="Submit briefing from JSON file")
    parser.add_argument("--list", action="store_true", help="List submissions")
    parser.add_argument("--app", type=str, help="Filter by app_id")
    parser.add_argument("--status", type=str, help="Filter by status")
    parser.add_argument("--json", action="store_true", help="JSON output")
    args = parser.parse_args()

    # ── List Submissions ───────────────────────────────────────────
    if args.list:
        adapter = FactoryAdapter()
        subs = adapter.list_submissions(args.app, args.status)
        if args.json:
            print(json.dumps(subs, indent=2, default=str))
        else:
            if not subs:
                print("Keine Submissions vorhanden.")
            else:
                print(f"\n{'='*60}")
                print(f" Submissions ({len(subs)})")
                print(f"{'='*60}")
                for s in subs:
                    print(f"  {s['submission_id']}  {s['action_type']:15s}  "
                          f"{s['priority']:12s}  [{s['status']}]")
        return

    # ── Submit Briefing ────────────────────────────────────────────
    if args.submit:
        from pathlib import Path
        briefing = json.loads(Path(args.submit).read_text(encoding="utf-8"))
        adapter = FactoryAdapter()
        sub = adapter.submit_briefing(briefing)
        if args.json:
            print(json.dumps(sub, indent=2, default=str))
        else:
            print(f"Submission: {sub['submission_id']}")
            print(f"  Status: {sub['status']}")
            print(f"  Factory Task: {sub.get('factory_task_id', '-')}")
        return

    # ── Simulation ─────────────────────────────────────────────────
    if args.simulate or args.scenario:
        results = [_run_simulation(args.scenario, args.json)] if args.scenario else _run_all(args.json)

        if args.json:
            print(json.dumps(results, indent=2, default=str))
        else:
            print(f"\n{'='*60}")
            print(f" FactoryAdapter Simulation")
            print(f"{'='*60}")
            all_ok = True
            for r in results:
                icon = "[+]" if r["ok"] else "[-]"
                print(f"\n  {icon} {r['scenario']}: {'PASS' if r['ok'] else 'FAIL'}")
                print(f"      {r['description']}")
                if not r["ok"]:
                    all_ok = False

            print(f"\n{'='*60}")
            print(f"  Ergebnis: {'ALLE BESTANDEN' if all_ok else 'FEHLER AUFGETRETEN'}")
            print(f"{'='*60}\n")

        sys.exit(0 if all(r["ok"] for r in results) else 1)
        return

    # Default
    sys.argv.append("--simulate")
    main()
