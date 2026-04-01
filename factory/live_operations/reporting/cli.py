"""Weekly Report CLI — Simulation und Validierung.

3 Szenarien:
1. Healthy Fleet: Report fuer gesunde Fleet generieren
2. Mixed Fleet: Fleet mit Problemen (Injections) + Report
3. Full Lifecycle: Fleet + Cycles + Report (End-to-End)
"""

import tempfile
from datetime import datetime, timezone

from factory.live_operations.app_registry.database import AppRegistryDB
from factory.live_operations.orchestrator import CycleOrchestrator
from factory.live_operations.test_harness.fleet_generator import SyntheticFleetGenerator
from factory.live_operations.reporting.weekly_report import WeeklyReportGenerator

_PREFIX = "[Report CLI]"


def _setup_fleet(count: int = 10, seed: int = 42) -> tuple:
    """Erstellt Temp-DB mit Fleet."""
    tmp = tempfile.mktemp(suffix=".db")
    db = AppRegistryDB(tmp)
    gen = SyntheticFleetGenerator(registry_db=db, seed=seed)
    gen.generate_fleet(count)
    gen.generate_metrics_history()
    return db, gen


def run_healthy_fleet_report() -> dict:
    """Szenario 1: Report fuer gesunde Fleet."""
    print(f"\n{'='*60}")
    print(f"{_PREFIX} Szenario 1: Healthy Fleet Report")
    print(f"{'='*60}")

    db, gen = _setup_fleet(10)
    tmp_dir = tempfile.mkdtemp()
    reporter = WeeklyReportGenerator(registry_db=db, output_dir=tmp_dir)

    # Generate
    result = reporter.generate()
    summary = result.get("summary", {})

    print(f"\n  Report: {result['report_path']}")
    print(f"  Fleet Status: {summary.get('fleet_status', '?')}")
    print(f"  Avg Score: {summary.get('avg_health_score', 0)}")
    print(f"  Zones: {summary.get('zones', {})}")

    # Validate
    ok = (
        result.get("report_path") is not None
        and summary.get("total_apps", 0) == 10
        and summary.get("avg_health_score", 0) > 0
        and summary.get("fleet_status") in ("STABIL", "WARNUNG", "EXZELLENT")
    )
    print(f"\n  Ergebnis: {'PASS' if ok else 'FAIL'}")
    return {"ok": ok, "scenario": "healthy_fleet", "summary": summary}


def run_mixed_fleet_report() -> dict:
    """Szenario 2: Fleet mit Injections + Report."""
    print(f"\n{'='*60}")
    print(f"{_PREFIX} Szenario 2: Mixed Fleet Report")
    print(f"{'='*60}")

    db, gen = _setup_fleet(12, seed=99)

    # Get app IDs and inject problems
    apps = db.get_all_apps()
    if len(apps) >= 3:
        gen.inject_scenario(apps[0]["app_id"], "crash_spike")
        gen.inject_scenario(apps[1]["app_id"], "review_bomb")
        gen.inject_scenario(apps[2]["app_id"], "revenue_decline")
    print(f"  Injected 3 scenarios into fleet")

    tmp_dir = tempfile.mkdtemp()
    reporter = WeeklyReportGenerator(registry_db=db, output_dir=tmp_dir)

    # Generate
    result = reporter.generate()
    summary = result.get("summary", {})

    print(f"\n  Report: {result['report_path']}")
    print(f"  Fleet Status: {summary.get('fleet_status', '?')}")
    print(f"  Red Apps: {summary.get('zones', {}).get('red', 0)}")

    # Data only
    data = reporter.generate_data_only()
    recs = data.get("recommendations", [])
    print(f"  Recommendations: {len(recs)}")
    for r in recs[:3]:
        print(f"    - {r[:80]}")

    # Validate: should have recommendations for problems
    ok = (
        result.get("report_path") is not None
        and summary.get("total_apps", 0) == 12
        and len(recs) > 0
    )
    print(f"\n  Ergebnis: {'PASS' if ok else 'FAIL'}")
    return {"ok": ok, "scenario": "mixed_fleet", "summary": summary, "recommendations": recs}


def run_full_lifecycle_report() -> dict:
    """Szenario 3: Fleet + Orchestrator Cycles + Report."""
    print(f"\n{'='*60}")
    print(f"{_PREFIX} Szenario 3: Full Lifecycle Report")
    print(f"{'='*60}")

    db, gen = _setup_fleet(8, seed=77)
    orch = CycleOrchestrator(registry_db=db)

    # Run cycles
    dc = orch.run_decision_cycle()
    ascan = orch.run_anomaly_scan()
    ex = orch.run_execution_path()
    print(f"\n  Cycles: DC={dc['apps_evaluated']} apps, "
          f"Anomalies={ascan['anomalies_found']}, "
          f"Releases={ex['releases_processed']}")

    # Generate report
    tmp_dir = tempfile.mkdtemp()
    reporter = WeeklyReportGenerator(registry_db=db, output_dir=tmp_dir)
    result = reporter.generate()
    summary = result.get("summary", {})

    print(f"  Fleet Status: {summary.get('fleet_status', '?')}")
    print(f"  System Healthy: {summary.get('system_healthy', '?')}")

    # List reports
    reports = reporter.list_reports()
    print(f"  Archived Reports: {len(reports)}")

    # Validate
    ok = (
        result.get("report_path") is not None
        and summary.get("total_apps", 0) == 8
        and summary.get("system_healthy") is True
        and len(reports) == 1
    )
    print(f"\n  Ergebnis: {'PASS' if ok else 'FAIL'}")
    return {"ok": ok, "scenario": "full_lifecycle", "summary": summary}


def run_all() -> dict:
    """Fuehrt alle 3 Szenarien aus."""
    print(f"\n{'#'*60}")
    print(f"{_PREFIX} CEO Weekly Report Simulation")
    print(f"{'#'*60}")

    scenarios = [
        ("healthy_fleet", run_healthy_fleet_report),
        ("mixed_fleet", run_mixed_fleet_report),
        ("full_lifecycle", run_full_lifecycle_report),
    ]

    results = {}
    for name, fn in scenarios:
        try:
            results[name] = fn()
        except Exception as e:
            results[name] = {"ok": False, "error": str(e)}
            import traceback
            traceback.print_exc()
            print(f"\n  {name}: ERROR - {e}")

    passed = sum(1 for r in results.values() if r.get("ok"))
    total = len(results)
    all_ok = passed == total

    print(f"\n{'#'*60}")
    print(f"{_PREFIX} Ergebnis: {passed}/{total} PASS {'(ALL PASS)' if all_ok else '(FAILURES)'}")
    print(f"{'#'*60}")

    return {"ok": all_ok, "passed": passed, "total": total, "scenarios": results}
