"""CLI for UpdatePlanner — simulate briefing generation."""

import argparse
import json
import sys
import tempfile
from datetime import datetime, timezone
from pathlib import Path

from .planner import UpdatePlanner


# ── Simulated Actions (mimic Decision Engine output) ───────────────

def _make_action(app_id: str, action_type: str, triggers: list, health: float,
                 zone: str, escalation: int = 0) -> dict:
    """Build a simulated Decision Engine action."""
    severity_scores = []
    for t in triggers:
        severity_scores.append({
            "trigger": t["trigger"],
            "severity": t.get("severity", 50.0),
            "deviation": t.get("deviation", 0.5),
            "impact": t.get("impact", 0.5),
            "velocity": t.get("velocity", 0.5),
            "category": t.get("category", "general"),
            "detail": t.get("detail", f"{t['trigger']} detected"),
            "current_value": t.get("current_value"),
        })
    return {
        "app_id": app_id,
        "decided_at": datetime.now(timezone.utc).isoformat(),
        "health_score": health,
        "health_zone": zone,
        "cooling_active": False,
        "action_type": action_type,
        "severity_scores": severity_scores,
        "primary_trigger": triggers[0]["trigger"] if triggers else "unknown",
        "escalation_level": escalation,
        "recommendation": f"Execute {action_type}",
        "data_summary": {
            "active_triggers": len(triggers),
            "max_severity": max((t.get("severity", 0) for t in triggers), default=0),
            "categories_affected": list({t.get("category", "general") for t in triggers}),
        },
        "action_id": f"ACT-{app_id}-SIM",
    }


SCENARIOS = {
    "hotfix": {
        "description": "Crash-Rate Explosion — sofortiger Hotfix",
        "action": lambda: _make_action(
            app_id="echomatch",
            action_type="hotfix",
            triggers=[{
                "trigger": "crash_rate_high",
                "severity": 92.0,
                "deviation": 0.9,
                "impact": 0.85,
                "velocity": 0.95,
                "category": "stability",
                "detail": "Crash-Rate 8.2% vs Baseline 2.1%",
                "current_value": 8.2,
            }],
            health=28.0,
            zone="red",
            escalation=2,
        ),
        "app_info": {
            "name": "EchoMatch",
            "current_version": "1.4.2",
            "repository_path": "/factory/assembly/output/echomatch",
            "platform": "ios",
        },
        "validate": lambda b: (
            b["update_details"]["action_type"] == "hotfix"
            and b["update_details"]["priority"] == "P0-CRITICAL"
            and b["app_context"]["target_version"] == "1.4.3"
            and b["evidence"]["trigger_details"][0]["trigger"] == "crash_rate_high"
            and len(b["evidence"]["trigger_details"]) == 1  # hotfix = 1 trigger only
            and b["factory_instructions"]["urgency"] == "SOFORT — naechster Build-Slot"
        ),
    },

    "patch": {
        "description": "Retention + Funnel Drop — Patch mit mehreren Triggern",
        "action": lambda: _make_action(
            app_id="drivepulse",
            action_type="patch",
            triggers=[
                {
                    "trigger": "retention_dropping",
                    "severity": 58.0,
                    "deviation": 0.6,
                    "impact": 0.55,
                    "velocity": 0.4,
                    "category": "engagement",
                    "detail": "Day-7 Retention 18% vs Baseline 32%",
                    "current_value": 18.0,
                },
                {
                    "trigger": "funnel_dropout",
                    "severity": 45.0,
                    "deviation": 0.4,
                    "impact": 0.5,
                    "velocity": 0.35,
                    "category": "conversion",
                    "detail": "Onboarding-to-Premium 4% vs Baseline 9%",
                    "current_value": 4.0,
                },
            ],
            health=52.0,
            zone="yellow",
            escalation=1,
        ),
        "app_info": {
            "name": "DrivePulse",
            "current_version": "2.1.0",
            "repository_path": "/factory/assembly/output/drivepulse",
            "platform": "android",
        },
        "validate": lambda b: (
            b["update_details"]["action_type"] == "patch"
            and b["update_details"]["priority"] == "P1-HIGH"
            and b["app_context"]["target_version"] == "2.1.1"
            and len(b["evidence"]["trigger_details"]) == 2  # patch = alle Trigger
            and b["evidence"]["trigger_details"][0]["trigger"] == "retention_dropping"
            and b["evidence"]["trigger_details"][1]["trigger"] == "funnel_dropout"
            and len(b["factory_instructions"]["changes_required"]) >= 4
        ),
    },

    "feature_update": {
        "description": "Revenue Decline — Feature Update mit minor Version",
        "action": lambda: _make_action(
            app_id="focusflow",
            action_type="feature_update",
            triggers=[
                {
                    "trigger": "revenue_declining",
                    "severity": 42.0,
                    "deviation": 0.35,
                    "impact": 0.55,
                    "velocity": 0.3,
                    "category": "revenue",
                    "detail": "ARPU $1.20 vs Baseline $2.10",
                    "current_value": 1.20,
                },
                {
                    "trigger": "review_pattern",
                    "severity": 38.0,
                    "deviation": 0.3,
                    "impact": 0.4,
                    "velocity": 0.35,
                    "category": "satisfaction",
                    "detail": "Negative Review Trend: 'too expensive', 'no value'",
                    "current_value": 3.2,
                },
            ],
            health=61.0,
            zone="yellow",
            escalation=0,
        ),
        "app_info": {
            "name": "FocusFlow",
            "current_version": "3.0.5",
            "repository_path": "/factory/assembly/output/focusflow",
            "platform": "web",
        },
        "validate": lambda b: (
            b["update_details"]["action_type"] == "feature_update"
            and b["update_details"]["priority"] == "P2-MEDIUM"
            and b["app_context"]["target_version"] == "3.1.0"  # minor bump
            and b["update_details"]["version_bump"] == "minor"
            and len(b["evidence"]["trigger_details"]) == 2
            and "revenue_declining" in [t["trigger"] for t in b["evidence"]["trigger_details"]]
        ),
    },
}


# ── Simulation Runner ──────────────────────────────────────────────

def _run_simulation(scenario_name: str, as_json: bool = False) -> dict:
    """Run a single simulation scenario."""
    scenario = SCENARIOS.get(scenario_name)
    if not scenario:
        return {"error": f"Unknown scenario: {scenario_name}", "ok": False}

    tmp = tempfile.mkdtemp(prefix="briefing_sim_")
    planner = UpdatePlanner(data_dir=tmp)

    action = scenario["action"]()
    app_info = scenario.get("app_info")
    briefing = planner.create_briefing(action, app_info)

    # Validate
    try:
        valid = scenario["validate"](briefing)
    except Exception as e:
        valid = False
        briefing["validation_error"] = str(e)

    # Check briefing was saved
    saved = planner.get_briefing(briefing["briefing_id"])
    file_saved = saved is not None

    # Check list_briefings works
    listed = planner.list_briefings()
    in_list = any(b["briefing_id"] == briefing["briefing_id"] for b in listed)

    result = {
        "scenario": scenario_name,
        "description": scenario["description"],
        "briefing_id": briefing["briefing_id"],
        "action_type": briefing["update_details"]["action_type"],
        "target_version": briefing["app_context"]["target_version"],
        "priority": briefing["update_details"]["priority"],
        "trigger_count": len(briefing["evidence"]["trigger_details"]),
        "changes_count": len(briefing["factory_instructions"]["changes_required"]),
        "validation_passed": valid,
        "file_saved": file_saved,
        "in_list": in_list,
        "ok": valid and file_saved and in_list,
    }

    if as_json:
        result["briefing"] = briefing

    return result


def _run_all_simulations(as_json: bool = False) -> list:
    """Run all scenarios."""
    results = []
    for name in SCENARIOS:
        results.append(_run_simulation(name, as_json))
    return results


# ── CLI Entry ──────────────────────────────────────────────────────

def main():
    parser = argparse.ArgumentParser(description="UpdatePlanner — Briefing Generator")
    parser.add_argument("--simulate", action="store_true", help="Run simulation")
    parser.add_argument("--scenario", type=str, help="Specific scenario (hotfix|patch|feature_update)")
    parser.add_argument("--action", type=str, help="JSON action from Decision Engine (stdin or file)")
    parser.add_argument("--list-briefings", action="store_true", help="List all saved briefings")
    parser.add_argument("--app", type=str, help="Filter by app_id")
    parser.add_argument("--json", action="store_true", help="JSON output")
    args = parser.parse_args()

    # ── List Briefings ─────────────────────────────────────────────
    if args.list_briefings:
        planner = UpdatePlanner()
        briefings = planner.list_briefings(args.app)
        if args.json:
            print(json.dumps(briefings, indent=2, default=str))
        else:
            if not briefings:
                print("Keine Briefings vorhanden.")
            else:
                print(f"\n{'='*60}")
                print(f" Briefings ({len(briefings)})")
                print(f"{'='*60}")
                for b in briefings:
                    print(f"  {b['briefing_id']}  {b['action_type']:15s}  "
                          f"{b['priority']:12s}  → v{b['target_version']}  [{b['status']}]")
        return

    # ── From Action JSON ───────────────────────────────────────────
    if args.action:
        action_data = json.loads(args.action) if not args.action.endswith(".json") \
            else json.loads(Path(args.action).read_text())
        planner = UpdatePlanner()
        briefing = planner.create_briefing(action_data)
        if args.json:
            print(json.dumps(briefing, indent=2, default=str))
        else:
            print(f"Briefing erstellt: {briefing['briefing_id']}")
            print(f"  Typ: {briefing['update_details']['action_type']}")
            print(f"  Prioritaet: {briefing['update_details']['priority']}")
            print(f"  Version: {briefing['app_context']['current_version']} -> {briefing['app_context']['target_version']}")
        return

    # ── Simulation ─────────────────────────────────────────────────
    if args.simulate or args.scenario:
        if args.scenario:
            result = _run_simulation(args.scenario, args.json)
            results = [result]
        else:
            results = _run_all_simulations(args.json)

        if args.json:
            print(json.dumps(results, indent=2, default=str))
        else:
            print(f"\n{'='*60}")
            print(f" UpdatePlanner Simulation")
            print(f"{'='*60}")
            all_ok = True
            for r in results:
                status = "PASS" if r["ok"] else "FAIL"
                icon = "[+]" if r["ok"] else "[-]"
                print(f"\n  {icon} {r['scenario']}: {status}")
                print(f"      {r['description']}")
                print(f"      Briefing: {r['briefing_id']}")
                print(f"      {r['action_type']} -> v{r['target_version']} ({r['priority']})")
                print(f"      Triggers: {r['trigger_count']}, Changes: {r['changes_count']}")
                print(f"      Validation: {'OK' if r['validation_passed'] else 'FAILED'}")
                print(f"      File saved: {'OK' if r['file_saved'] else 'FAILED'}")
                print(f"      In list: {'OK' if r['in_list'] else 'FAILED'}")
                if not r["ok"]:
                    all_ok = False

            print(f"\n{'='*60}")
            print(f"  Ergebnis: {'ALLE BESTANDEN' if all_ok else 'FEHLER AUFGETRETEN'}")
            print(f"{'='*60}\n")

        sys.exit(0 if all(r["ok"] for r in results) else 1)
        return

    # ── Default: run all simulations ───────────────────────────────
    sys.argv.append("--simulate")
    main()
