"""Escalation CLI -- Test und Simulation."""

import argparse
import json
import tempfile
import os

from .manager import EscalationManager


# ------------------------------------------------------------------
# Simulations
# ------------------------------------------------------------------

def _simulate_level1() -> dict:
    """Info-Eskalation: Patch empfohlen."""
    tmp = tempfile.mkdtemp()
    mgr = EscalationManager(data_dir=tmp)

    event = {
        "app_id": "test_app_001",
        "escalation_level": 1,
        "source": "decision_engine",
        "action_type": "patch",
        "detail": "Multiple metrics in patch range (retention, funnel)",
        "recommendation": "Patch empfohlen: engagement betroffen (max Severity 52)",
        "severity": 52.0,
    }
    result = mgr.escalate(event)

    # Validate
    ok = (result["escalation_level"] == 1 and
          result["telegram_sent"] is False and
          result["level_label"] == "info")
    return {"result": result, "ok": ok}


def _simulate_level2() -> dict:
    """Warning: Anomaly + Auto-Rollback."""
    tmp = tempfile.mkdtemp()
    mgr = EscalationManager(data_dir=tmp)

    anomaly = {
        "app_id": "test_app_002",
        "anomaly_type": "post_update_regression",
        "severity": "high",
        "escalation_level": 2,
        "detail": "Post-Update Regression (6h nach Release): crash_rate: 1.20% -> 6.00%",
        "can_auto_rollback": True,
        "recommended_action": "rollback",
    }
    rollback = {
        "success": True,
        "rolled_back_from": "1.3.0",
        "rolled_back_to": "1.2.0",
    }
    result = mgr.escalate_from_anomaly(anomaly, rollback)

    ok = (result["escalation_level"] == 2 and
          result["telegram_sent"] is False and
          "Rollback" in result["detail"])
    return {"result": result, "ok": ok}


def _simulate_level3() -> dict:
    """CEO-Eskalation: Strategic Pivot."""
    tmp = tempfile.mkdtemp()
    mgr = EscalationManager(data_dir=tmp)

    decision = {
        "app_id": "test_app_003",
        "action_type": "strategic_pivot",
        "escalation_level": 3,
        "recommendation": "Strategic Pivot: Health Score seit >2 Wochen unter 50 -- CEO-Entscheidung erforderlich",
        "data_summary": {"max_severity": 92.0},
    }
    result = mgr.escalate_from_decision(decision)

    # Telegram not configured in test -> sent=False, error=not_configured
    ok = (result["escalation_level"] == 3 and
          result["level_label"] == "ceo_escalation" and
          result["telegram_error"] == "not_configured")
    return {"result": result, "ok": ok}


def _simulate_log_query() -> dict:
    """Test: Log-Abfragen nach mehreren Eskalationen."""
    tmp = tempfile.mkdtemp()
    mgr = EscalationManager(data_dir=tmp)

    # 3 Events
    for level, app in [(1, "app_a"), (2, "app_b"), (3, "app_a")]:
        mgr.escalate({
            "app_id": app,
            "escalation_level": level,
            "source": "test",
            "action_type": "test",
            "detail": f"Test level {level}",
        })

    recent = mgr.get_recent(10)
    by_app = mgr.get_by_app("app_a", 10)
    ceo = mgr.get_ceo_pending()
    stats = mgr.log.get_stats()

    ok = (len(recent) == 3 and
          len(by_app) == 2 and
          len(ceo) == 1 and
          stats["total_escalations"] == 3)
    return {"recent_count": len(recent), "app_a_count": len(by_app),
            "ceo_pending": len(ceo), "stats": stats, "ok": ok}


# ------------------------------------------------------------------
# Main
# ------------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(description="Escalation Manager CLI")
    parser.add_argument("--simulate", action="store_true", help="Run simulations")
    parser.add_argument("--scenario",
                        choices=["level1", "level2", "level3", "log_query"],
                        help="Simulation scenario")
    parser.add_argument("--recent", type=int, metavar="N", help="Show recent N escalations")
    parser.add_argument("--app", help="Filter by app_id")
    parser.add_argument("--stats", action="store_true", help="Show stats")
    parser.add_argument("--json", action="store_true", help="JSON output")

    args = parser.parse_args()

    if args.simulate:
        scenarios = {
            "level1": ("Level 1 (Info)", _simulate_level1),
            "level2": ("Level 2 (Warning + Rollback)", _simulate_level2),
            "level3": ("Level 3 (CEO + Telegram)", _simulate_level3),
            "log_query": ("Log Queries", _simulate_log_query),
        }

        if args.scenario:
            to_run = {args.scenario: scenarios[args.scenario]}
        else:
            to_run = scenarios

        all_ok = True
        for key, (label, fn) in to_run.items():
            print(f"\n{'='*60}")
            print(f"[Escalation] SIMULATION: {label}")
            print(f"{'='*60}")

            result = fn()
            ok = result.get("ok", False)
            all_ok = all_ok and ok

            if args.json:
                print(json.dumps(result, indent=2, default=str))
            else:
                if "result" in result:
                    r = result["result"]
                    print(f"\n  Level: {r.get('escalation_level')}")
                    print(f"  Label: {r.get('level_label')}")
                    print(f"  Source: {r.get('source')}")
                    print(f"  Telegram: sent={r.get('telegram_sent')}")
                else:
                    for k, v in result.items():
                        if k != "ok":
                            print(f"  {k}: {v}")

            print(f"\n  Result: {'PASS' if ok else 'FAIL'}")

        if len(to_run) > 1:
            print(f"\n{'='*60}")
            print(f"  ALL: {'PASS' if all_ok else 'FAIL'}")
            print(f"{'='*60}")
        return

    # Live queries
    mgr = EscalationManager()

    if args.stats:
        stats = mgr.log.get_stats()
        if args.json:
            print(json.dumps(stats, indent=2, default=str))
        else:
            print(f"\nEscalation Stats:")
            print(f"  Total: {stats['total_escalations']}")
            print(f"  By Level: {stats['by_level']}")
            print(f"  Telegram sent: {stats['telegram_sent']}")
        return

    if args.recent or args.app:
        if args.app:
            entries = mgr.get_by_app(args.app, args.recent or 10)
        else:
            entries = mgr.get_recent(args.recent or 20)

        if args.json:
            print(json.dumps(entries, indent=2, default=str))
        else:
            print(f"\n{len(entries)} escalations:")
            for e in entries:
                level = e.get("escalation_level", 0)
                app = e.get("app_id", "?")
                ts = e.get("timestamp", "?")[:19]
                detail = e.get("detail", "")[:60]
                print(f"  [{level}] {ts} | {app} | {detail}")
        return

    # Default: run all simulations
    import sys
    sys.argv = [sys.argv[0], "--simulate"]
    main()


if __name__ == "__main__":
    main()
