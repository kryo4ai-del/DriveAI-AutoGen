"""Decision Engine CLI -- Evaluation und Simulation."""

import argparse
import json
import sys
from datetime import datetime, timezone

from .engine import DecisionEngine
from . import config


# ------------------------------------------------------------------
# Simulation Scenarios
# ------------------------------------------------------------------

def _build_simulated_inputs(scenario: str) -> dict:
    """Baut simulierte Inputs fuer Test-Szenarien."""
    base = {
        "app_id": "sim_app_001",
        "health_score": 75.0,
        "health_zone": "yellow",
        "app_profile": "utility",
        "analytics": {"trends": [], "funnels": []},
        "review_insights": {"rating_health": {}, "patterns": []},
        "support_insights": {},
        "health_history": [],
    }

    if scenario == "crash_spike":
        base["health_score"] = 35.0
        base["health_zone"] = "red"
        base["analytics"]["trends"] = [
            {
                "metric": "crash_rate",
                "name": "crash_rate",
                "current_value": 0.085,
                "direction": "rising",
                "strength": 0.9,
            },
        ]

    elif scenario == "slow_decline":
        base["health_score"] = 58.0
        base["health_zone"] = "yellow"
        base["analytics"]["trends"] = [
            {
                "metric": "retention_day7",
                "name": "retention_day7",
                "current_value": 0.28,
                "direction": "falling",
                "strength": 0.44,
            },
            {
                "metric": "revenue_period",
                "name": "revenue_period",
                "current_value": -0.12,
                "direction": "falling",
                "strength": 0.35,
            },
        ]
        base["review_insights"]["patterns"] = [
            {"theme": "slow loading", "mentions": 4, "severity": "medium"},
        ]

    elif scenario == "healthy":
        base["health_score"] = 88.0
        base["health_zone"] = "green"
        base["analytics"]["trends"] = [
            {
                "metric": "dau",
                "name": "dau",
                "direction": "rising",
                "strength": 0.15,
            },
        ]

    elif scenario == "strategic_pivot":
        base["health_score"] = 32.0
        base["health_zone"] = "red"
        # Simulate 3 weeks (84 records at 4/day) of health below 50
        base["health_history"] = [
            {"overall_score": 30 + (i % 10), "timestamp": f"2026-03-{10 + i // 4:02d}"}
            for i in range(84)
        ]
        base["analytics"]["trends"] = [
            {
                "metric": "retention_day7",
                "name": "retention_day7",
                "direction": "falling",
                "strength": 0.6,
            },
        ]

    elif scenario == "cooling":
        base["health_score"] = 45.0
        base["health_zone"] = "red"
        base["analytics"]["trends"] = [
            {
                "metric": "crash_rate",
                "name": "crash_rate",
                "current_value": 0.07,
                "direction": "rising",
                "strength": 0.8,
            },
        ]
        # Cooling flag handled externally

    return base


class SimulatedEngine(DecisionEngine):
    """Engine die simulierte Inputs statt echte Daten nutzt."""

    def __init__(self, scenario: str) -> None:
        self._scenario = scenario
        self._sim_inputs = _build_simulated_inputs(scenario)
        # No DB needed for simulation
        self.db = None

    def _gather_inputs(self, app_id: str) -> dict:
        return self._sim_inputs

    def _check_cooling(self, app_id: str) -> bool:
        return self._scenario == "cooling"

    def evaluate_app(self, app_id: str) -> dict:
        """Override: Cooling-Szenario braucht keine DB."""
        if self._scenario == "cooling":
            print(f"[Decision Engine] {app_id} in cooling (simulated) -> skip")
            return self._build_cooling_decision(app_id, {
                "cooling_type": "hotfix",
                "remaining_human": "23h 45m",
            })
        return super().evaluate_app(app_id)


def run_simulation(scenario: str) -> dict:
    """Fuehrt eine Simulation durch."""
    print(f"\n{'='*60}")
    print(f"[Decision Engine] SIMULATION: {scenario}")
    print(f"{'='*60}")

    engine = SimulatedEngine(scenario)
    result = engine.evaluate_app("sim_app_001")

    print(f"\n--- Decision ---")
    print(f"  Action Type:    {result['action_type']}")
    print(f"  Health Score:   {result['health_score']}")
    print(f"  Health Zone:    {result['health_zone']}")
    print(f"  Cooling:        {result['cooling_active']}")
    print(f"  Escalation:     Level {result['escalation_level']}")
    print(f"  Primary:        {result['primary_trigger']}")
    print(f"  Recommendation: {result['recommendation']}")

    if result["severity_scores"]:
        print(f"\n--- Severity Scores ({len(result['severity_scores'])}) ---")
        for s in result["severity_scores"]:
            print(f"  [{s['trigger']}] severity={s['severity']:.1f} "
                  f"(dev={s['deviation']:.1f} imp={s['impact']:.1f} vel={s['velocity']:.1f}) "
                  f"cat={s['category']}")
            print(f"    Detail: {s['detail']}")

    summary = result["data_summary"]
    print(f"\n--- Summary ---")
    print(f"  Active Triggers: {summary['active_triggers']}")
    print(f"  Max Severity:    {summary['max_severity']}")
    print(f"  Categories:      {summary['categories_affected']}")

    return result


# ------------------------------------------------------------------
# Main
# ------------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(description="Decision Engine CLI")
    parser.add_argument("--app", help="Evaluate single app")
    parser.add_argument("--all", action="store_true", help="Evaluate all apps")
    parser.add_argument("--simulate", action="store_true", help="Run simulation")
    parser.add_argument("--scenario", default="crash_spike",
                        choices=["crash_spike", "slow_decline", "healthy",
                                 "strategic_pivot", "cooling"],
                        help="Simulation scenario")
    parser.add_argument("--json", action="store_true", help="JSON output")
    parser.add_argument("--queue", action="store_true", help="Show action queue")
    parser.add_argument("--cooling", action="store_true", help="Show cooling periods")
    parser.add_argument("--override-cooling", metavar="APP_ID", help="Override cooling for app")
    parser.add_argument("--reason", default="CEO override", help="Reason for override")

    args = parser.parse_args()

    if args.queue:
        from .action_queue import ActionQueueManager
        queue = ActionQueueManager()
        actions = queue.get_queue(app_id=args.app, status="pending")
        if args.json:
            print(json.dumps(actions, indent=2, default=str))
        else:
            print(f"\n[Action Queue] {len(actions)} pending actions")
            for a in actions:
                print(f"  [{a.get('action_id', '?')}] {a.get('app_id', '?')} "
                      f"{a.get('action_type', '?')} severity={a.get('severity_score', 0):.1f} "
                      f"status={a.get('status', '?')}")
        return

    if args.cooling:
        from .cooling import CoolingManager
        cm = CoolingManager()
        cooling_apps = cm.get_all_cooling()
        if args.json:
            print(json.dumps(cooling_apps, indent=2, default=str))
        else:
            print(f"\n[Cooling] {len(cooling_apps)} apps in cooling")
            for c in cooling_apps:
                print(f"  {c.get('app_name', c.get('app_id', '?'))} "
                      f"type={c.get('cooling_type', '?')} "
                      f"remaining={c.get('remaining_hours', 0):.1f}h")
        return

    if args.override_cooling:
        from .cooling import CoolingManager
        cm = CoolingManager()
        cm.override_cooling(args.override_cooling, args.reason)
        return

    if args.simulate:
        result = run_simulation(args.scenario)
        if args.json:
            print(json.dumps(result, indent=2, default=str))
        return

    if args.all:
        engine = DecisionEngine()
        result = engine.evaluate_all()
        if args.json:
            print(json.dumps(result, indent=2, default=str))
        return

    if args.app:
        engine = DecisionEngine()
        result = engine.evaluate_app(args.app)
        if args.json:
            print(json.dumps(result, indent=2, default=str))
        else:
            print(f"\nAction: {result['action_type']}")
            print(f"Severity: {result['data_summary']['max_severity']}")
            print(f"Recommendation: {result['recommendation']}")
        return

    # Default: run all simulations
    print("\n" + "="*60)
    print("[Decision Engine] Running all simulation scenarios")
    print("="*60)

    scenarios = ["crash_spike", "slow_decline", "healthy", "strategic_pivot", "cooling"]
    results = {}
    for sc in scenarios:
        results[sc] = run_simulation(sc)

    # Summary
    print("\n" + "="*60)
    print("[Decision Engine] SIMULATION SUMMARY")
    print("="*60)
    for sc, r in results.items():
        action = r["action_type"]
        severity = r["data_summary"]["max_severity"]
        level = r["escalation_level"]
        check = "PASS" if _validate_scenario(sc, r) else "FAIL"
        print(f"  {sc:20s} -> {action:18s} severity={severity:5.1f} level={level} [{check}]")


def _validate_scenario(scenario: str, result: dict) -> bool:
    """Validiert ob das Szenario-Ergebnis korrekt ist."""
    action = result["action_type"]
    severity = result["data_summary"]["max_severity"]

    if scenario == "crash_spike":
        return action == "hotfix" and severity > 85
    if scenario == "slow_decline":
        return action in ("patch", "feature_update")
    if scenario == "healthy":
        return action == "none"
    if scenario == "strategic_pivot":
        return action == "strategic_pivot"
    if scenario == "cooling":
        return action == "none" and result["cooling_active"]
    return False


if __name__ == "__main__":
    main()
