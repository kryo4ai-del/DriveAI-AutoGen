"""Anomaly Detector CLI -- Scan und Simulation."""

import argparse
import json
from datetime import datetime, timezone, timedelta

from .detector import AnomalyDetector
from .rollback import RollbackManager
from . import config


# ------------------------------------------------------------------
# Simulation
# ------------------------------------------------------------------

def _simulate_crash_explosion() -> dict:
    """Crash Rate verdoppelt sich."""
    from ...app_registry.database import AppRegistryDB
    import tempfile, os

    tmp = tempfile.mktemp(suffix='.db')
    db = AppRegistryDB(tmp)
    app_id = db.add_app({"app_name": "CrashApp", "bundle_id": "com.test.crash"})

    detector = AnomalyDetector(db)
    current = {"app_id": app_id, "crash_rate": 0.085, "health_score": 35}
    baseline = {"app_id": app_id, "crash_rate": 0.012, "health_score": 78}

    anomaly = detector.scan_app(app_id, current=current, baseline=baseline)
    os.unlink(tmp)
    return anomaly


def _simulate_post_update_regression() -> dict:
    """Metriken nach Update schlechter."""
    from ...app_registry.database import AppRegistryDB
    import tempfile, os

    tmp = tempfile.mktemp(suffix='.db')
    db = AppRegistryDB(tmp)
    app_id = db.add_app({
        "app_name": "RegressApp",
        "bundle_id": "com.test.regress",
        "current_version": "1.3.0",
        "last_stable_version": "1.2.0",
    })

    # Add recent release
    release_date = (datetime.now(timezone.utc) - timedelta(hours=6)).isoformat()
    db.add_release(app_id, {"version": "1.3.0", "update_type": "feature",
                            "release_date": release_date,
                            "triggered_by": "test_simulation"})

    detector = AnomalyDetector(db)
    current = {
        "app_id": app_id,
        "crash_rate": 0.06,
        "dau": 500,
        "retention_day7": 0.15,
        "health_score": 45,
        "last_release_date": release_date,
        "last_stable_version": "1.2.0",
    }
    baseline = {
        "app_id": app_id,
        "crash_rate": 0.012,
        "dau": 1200,
        "retention_day7": 0.35,
        "health_score": 82,
    }

    anomaly = detector.scan_app(app_id, current=current, baseline=baseline)

    # Execute rollback if possible
    rollback_report = None
    if anomaly and anomaly.get("can_auto_rollback"):
        rm = RollbackManager(db)
        rollback_report = rm.execute_rollback(app_id, anomaly["detail"])

    os.unlink(tmp)
    return {"anomaly": anomaly, "rollback": rollback_report}


def _simulate_normal() -> dict:
    """Alles normal, keine Anomalie."""
    from ...app_registry.database import AppRegistryDB
    import tempfile, os

    tmp = tempfile.mktemp(suffix='.db')
    db = AppRegistryDB(tmp)
    app_id = db.add_app({"app_name": "NormalApp", "bundle_id": "com.test.normal"})

    detector = AnomalyDetector(db)
    current = {"app_id": app_id, "crash_rate": 0.015, "health_score": 82, "revenue": 95}
    baseline = {"app_id": app_id, "crash_rate": 0.012, "health_score": 80, "revenue": 100}

    anomaly = detector.scan_app(app_id, current=current, baseline=baseline)
    os.unlink(tmp)
    return anomaly


# ------------------------------------------------------------------
# Main
# ------------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(description="Anomaly Detector CLI")
    parser.add_argument("--scan", action="store_true", help="Scan all apps")
    parser.add_argument("--app", help="Scan single app")
    parser.add_argument("--simulate", action="store_true", help="Run simulation")
    parser.add_argument("--scenario", default="crash_explosion",
                        choices=["crash_explosion", "post_update_regression", "normal"],
                        help="Simulation scenario")
    parser.add_argument("--rollback", metavar="APP_ID", help="Manual rollback")
    parser.add_argument("--reason", default="Manual rollback", help="Rollback reason")
    parser.add_argument("--json", action="store_true", help="JSON output")

    args = parser.parse_args()

    if args.simulate:
        print(f"\n{'='*60}")
        print(f"[Anomaly Detector] SIMULATION: {args.scenario}")
        print(f"{'='*60}")

        if args.scenario == "crash_explosion":
            result = _simulate_crash_explosion()
            if result:
                print(f"\n  Anomaly: {result['anomaly_type']}")
                print(f"  Severity: {result['severity']}")
                print(f"  Detail: {result['detail']}")
                print(f"  Auto-Rollback: {result['can_auto_rollback']}")
                print(f"  Action: {result['recommended_action']}")
                ok = result["anomaly_type"] == "crash_explosion" and result["severity"] == "critical"
            else:
                print("  No anomaly detected")
                ok = False
            print(f"\n  Result: {'PASS' if ok else 'FAIL'}")

        elif args.scenario == "post_update_regression":
            result = _simulate_post_update_regression()
            anomaly = result.get("anomaly")
            rollback = result.get("rollback")
            if anomaly:
                print(f"\n  Anomaly: {anomaly['anomaly_type']}")
                print(f"  Severity: {anomaly['severity']}")
                print(f"  Auto-Rollback: {anomaly['can_auto_rollback']}")
                print(f"  Regressions: {anomaly.get('regressions', [])}")
            if rollback:
                print(f"\n  Rollback: {rollback['rolled_back_from']} -> {rollback['rolled_back_to']}")
                print(f"  Store: {rollback['store_redeploy']}")
                print(f"  Cooling: {rollback['cooling_started']}")
            ok = (anomaly and anomaly["can_auto_rollback"] and
                  rollback and rollback.get("success"))
            print(f"\n  Result: {'PASS' if ok else 'FAIL'}")

        elif args.scenario == "normal":
            result = _simulate_normal()
            ok = result is None
            print(f"\n  Anomaly: {'None (correct)' if ok else result}")
            print(f"  Result: {'PASS' if ok else 'FAIL'}")

        if args.json:
            print(json.dumps(result, indent=2, default=str))
        return

    if args.rollback:
        rm = RollbackManager()
        report = rm.execute_rollback(args.rollback, args.reason)
        if args.json:
            print(json.dumps(report, indent=2, default=str))
        else:
            print(f"Rollback: {'SUCCESS' if report.get('success') else 'FAILED'}")
        return

    if args.scan:
        detector = AnomalyDetector()
        if args.app:
            anomaly = detector.scan_app(args.app)
            if anomaly:
                print(json.dumps(anomaly, indent=2, default=str))
            else:
                print("No anomaly detected")
        else:
            anomalies = detector.scan_all()
            if args.json:
                print(json.dumps(anomalies, indent=2, default=str))
            else:
                print(f"\n{len(anomalies)} anomalies found")
                for a in anomalies:
                    print(f"  [{a['app_id']}] {a['anomaly_type']} ({a['severity']})")
        return

    # Default: run all simulations
    print("\n" + "="*60)
    print("[Anomaly Detector] Running all simulations")
    print("="*60)
    for sc in ["crash_explosion", "post_update_regression", "normal"]:
        parser.parse_args(["--simulate", "--scenario", sc])
        # Re-invoke with scenario
        import sys
        old_argv = sys.argv
        sys.argv = ["cli", "--simulate", "--scenario", sc]
        main()
        sys.argv = old_argv
        break  # Avoid recursion, just run crash_explosion as default


if __name__ == "__main__":
    main()
