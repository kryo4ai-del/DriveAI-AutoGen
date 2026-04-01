"""Entry point: python -m factory.live_operations

Usage:
  python -m factory.live_operations --decision-cycle    Single Decision Cycle
  python -m factory.live_operations --anomaly-scan      Single Anomaly Scan
  python -m factory.live_operations --execution          Single Execution Path
  python -m factory.live_operations --status             Orchestrator Status
  python -m factory.live_operations --submissions        List Factory Submissions
  python -m factory.live_operations --releases           List Releases
  python -m factory.live_operations --briefings          List Briefings
  python -m factory.live_operations --check-cooling      Check Cooling Status
  python -m factory.live_operations --continuous         Continuous Mode (Daemon)
  python -m factory.live_operations --simulate           Simulation
"""

import argparse
import json
import tempfile
from datetime import datetime, timezone

from .orchestrator import CycleOrchestrator


def _simulate() -> dict:
    """Simulation mit Temp-DB."""
    from .app_registry.database import AppRegistryDB

    tmp = tempfile.mktemp(suffix='.db')
    db = AppRegistryDB(tmp)

    # Register 2 test apps
    app1 = db.add_app({"app_name": "HealthyApp", "bundle_id": "com.test.healthy"})
    app2 = db.add_app({"app_name": "SickApp", "bundle_id": "com.test.sick"})

    orch = CycleOrchestrator(db)

    # Run one decision cycle
    decision_result = orch.run_decision_cycle()

    # Run one anomaly scan
    anomaly_result = orch.run_anomaly_scan()

    # Manually enqueue an action to test execution path
    from .agents.decision_engine.action_queue import ActionQueueManager
    aq = ActionQueueManager(db)
    test_decision = {
        "app_id": app1,
        "action_type": "hotfix",
        "data_summary": {"max_severity": 90.0, "active_triggers": 1, "categories_affected": ["stability"]},
        "severity_scores": [{"trigger": "crash_rate_high", "severity": 90.0, "deviation": 0.8,
                            "impact": 0.7, "velocity": 0.6, "category": "stability",
                            "detail": "Crash rate 5x baseline"}],
        "primary_trigger": "crash_rate_high",
        "health_score": 30.0,
        "health_zone": "red",
        "decided_at": datetime.now(timezone.utc).isoformat(),
        "escalation_level": 1,
        "recommendation": "Sofortiger Hotfix noetig",
    }
    aq.enqueue(test_decision)

    # Run execution path
    execution_result = orch.run_execution_path()

    # Get status
    status = orch.get_status()

    import os
    os.unlink(tmp)

    ok = (decision_result["apps_evaluated"] == 2 and
          status["decision_cycles_completed"] == 1 and
          status["anomaly_scans_completed"] == 1 and
          status["execution_runs_completed"] == 1 and
          execution_result["briefings_created"] == 1 and
          execution_result["submissions_created"] == 1 and
          execution_result["releases_processed"] == 1)

    return {
        "decision_cycle": decision_result,
        "anomaly_scan": anomaly_result,
        "execution_path": execution_result,
        "status": status,
        "ok": ok,
    }


def main():
    parser = argparse.ArgumentParser(description="Live Operations Orchestrator")
    parser.add_argument("--decision-cycle", action="store_true",
                        help="Run single decision cycle")
    parser.add_argument("--anomaly-scan", action="store_true",
                        help="Run single anomaly scan")
    parser.add_argument("--status", action="store_true",
                        help="Show orchestrator status")
    parser.add_argument("--execution", action="store_true",
                        help="Run single execution path")
    parser.add_argument("--submissions", action="store_true",
                        help="List factory submissions")
    parser.add_argument("--releases", action="store_true",
                        help="List releases")
    parser.add_argument("--briefings", action="store_true",
                        help="List briefings")
    parser.add_argument("--check-cooling", action="store_true",
                        help="Check cooling status")
    parser.add_argument("--app", type=str,
                        help="Filter by app_id")
    parser.add_argument("--continuous", action="store_true",
                        help="Start continuous mode (daemon)")
    parser.add_argument("--simulate", action="store_true",
                        help="Run simulation")
    parser.add_argument("--json", action="store_true",
                        help="JSON output")

    args = parser.parse_args()

    if args.simulate:
        print(f"\n{'='*60}")
        print(f"[Orchestrator] SIMULATION")
        print(f"{'='*60}")

        result = _simulate()
        ok = result.get("ok", False)

        if args.json:
            print(json.dumps(result, indent=2, default=str))
        else:
            dc = result["decision_cycle"]
            ascan = result["anomaly_scan"]
            ex = result["execution_path"]
            st = result["status"]
            print(f"\n  Decision Cycle: {dc['apps_evaluated']} apps, "
                  f"{dc['actions_created']} actions, {dc['duration_seconds']}s")
            print(f"  Anomaly Scan: {ascan['anomalies_found']} anomalies, "
                  f"{ascan['rollbacks_executed']} rollbacks")
            print(f"  Execution Path: {ex['briefings_created']} briefings, "
                  f"{ex['submissions_created']} submissions, "
                  f"{ex['releases_processed']} releases")
            print(f"  Cycles completed: {st['decision_cycles_completed']} decision, "
                  f"{st['anomaly_scans_completed']} anomaly, "
                  f"{st['execution_runs_completed']} execution")

        print(f"\n  Result: {'PASS' if ok else 'FAIL'}")
        return

    orch = CycleOrchestrator()

    if args.status:
        status = orch.get_status()
        if args.json:
            print(json.dumps(status, indent=2, default=str))
        else:
            print(f"\nOrchestrator Status:")
            for k, v in status.items():
                print(f"  {k}: {v}")
        return

    if args.decision_cycle:
        result = orch.run_decision_cycle()
        if args.json:
            print(json.dumps(result, indent=2, default=str))
        return

    if args.anomaly_scan:
        result = orch.run_anomaly_scan()
        if args.json:
            print(json.dumps(result, indent=2, default=str))
        return

    if args.execution:
        result = orch.run_execution_path()
        if args.json:
            print(json.dumps(result, indent=2, default=str))
        return

    if args.submissions:
        subs = orch.get_submissions(app_id=args.app)
        if args.json:
            print(json.dumps(subs, indent=2, default=str))
        else:
            if not subs:
                print("Keine Submissions.")
            else:
                for s in subs:
                    print(f"  {s['submission_id']}  {s['app_id']}  {s['action_type']}  [{s['status']}]")
        return

    if args.releases:
        rels = orch.get_releases(app_id=args.app)
        if args.json:
            print(json.dumps(rels, indent=2, default=str))
        else:
            if not rels:
                print("Keine Releases.")
            else:
                for r in rels:
                    print(f"  {r['release_id']}  {r['app_id']}  v{r['target_version']}  [{r['status']}]")
        return

    if args.briefings:
        brfs = orch.get_briefings(app_id=args.app)
        if args.json:
            print(json.dumps(brfs, indent=2, default=str))
        else:
            if not brfs:
                print("Keine Briefings.")
            else:
                for b in brfs:
                    print(f"  {b['briefing_id']}  {b['app_id']}  {b['action_type']}  [{b['status']}]")
        return

    if args.check_cooling:
        cooling = orch.check_cooling(app_id=args.app)
        if args.json:
            print(json.dumps(cooling, indent=2, default=str))
        else:
            if not cooling:
                print("Kein aktives Cooling.")
            else:
                for c in cooling:
                    print(f"  {c.get('app_id', '?')}  {c.get('cooling_type', '?')}  "
                          f"bis {c.get('cooling_until', '?')}")
        return

    if args.continuous:
        orch.start_continuous()
        return

    # Default: show help
    parser.print_help()


if __name__ == "__main__":
    main()
