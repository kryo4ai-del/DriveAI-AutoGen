"""Self-Healing CLI — Simulation und Validierung.

3 Szenarien:
1. Health Check + Heal: Normalbetrieb pruefen
2. Inject Damage + Auto-Heal: Schaden verursachen, automatisch reparieren
3. Full Cycle mit Pre-Check: Orchestrator Cycle mit integriertem Health Check
"""

import tempfile
from datetime import datetime, timezone

from factory.live_operations.app_registry.database import AppRegistryDB
from factory.live_operations.orchestrator import CycleOrchestrator
from factory.live_operations.test_harness.fleet_generator import SyntheticFleetGenerator
from factory.live_operations.self_healing.health_monitor import SystemHealthMonitor
from factory.live_operations.self_healing.healer import SelfHealer
from factory.live_operations.self_healing.utilities import ErrorLog

_PREFIX = "[Self-Healing CLI]"


def _setup_env() -> tuple:
    """Erstellt Temp-DB mit Fleet + Self-Healing Komponenten."""
    tmp = tempfile.mktemp(suffix=".db")
    db = AppRegistryDB(tmp)
    gen = SyntheticFleetGenerator(registry_db=db, seed=42)
    gen.generate_fleet(10)
    gen.generate_metrics_history()
    return db, gen


def run_health_check_and_heal() -> dict:
    """Szenario 1: Health Check auf sauberem System + Heal-Versuch."""
    print(f"\n{'='*60}")
    print(f"{_PREFIX} Szenario 1: Health Check + Heal")
    print(f"{'='*60}")

    db, gen = _setup_env()
    error_log = ErrorLog()
    monitor = SystemHealthMonitor(registry_db=db, error_log=error_log)
    healer = SelfHealer(registry_db=db, error_log=error_log)

    # 1. Health Check (sollte clean sein)
    check = monitor.run_health_check()
    print(f"\n  Health Check: {'ALL OK' if check['all_ok'] else 'ISSUES FOUND'}")
    for name, c in check["checks"].items():
        status = "OK" if c["ok"] else "FAIL"
        print(f"    {name}: {status}")

    # 2. Heal All (sollte nichts zu tun haben)
    heal = healer.heal_all()
    print(f"\n  Heal All: {heal['total_healed']} repariert")

    # Health Check muss OK sein. Healer darf proaktiv Dirs erstellen (nicht kritisch).
    ok = check["all_ok"]
    print(f"\n  Ergebnis: {'PASS' if ok else 'FAIL'}")
    return {"ok": ok, "scenario": "health_check_clean", "check": check, "heal": heal}


def run_inject_damage_and_heal() -> dict:
    """Szenario 2: Schaden injizieren + automatisch reparieren."""
    print(f"\n{'='*60}")
    print(f"{_PREFIX} Szenario 2: Inject Damage + Auto-Heal")
    print(f"{'='*60}")

    db, gen = _setup_env()
    error_log = ErrorLog()
    monitor = SystemHealthMonitor(registry_db=db, error_log=error_log)
    healer = SelfHealer(registry_db=db, error_log=error_log)

    # 1. Inject: Corrupted Scores (NULL + out of range)
    conn = db._get_conn()
    apps = conn.execute("SELECT app_id FROM apps LIMIT 3").fetchall()
    if len(apps) >= 3:
        conn.execute("UPDATE apps SET health_score = NULL WHERE app_id = ?", (apps[0]["app_id"],))
        conn.execute("UPDATE apps SET health_score = -10 WHERE app_id = ?", (apps[1]["app_id"],))
        conn.execute("UPDATE apps SET health_zone = 'invalid' WHERE app_id = ?", (apps[2]["app_id"],))
    conn.commit()
    conn.close()
    print(f"  Injected: 3 corrupted records")

    # 2. Inject: Stuck action
    conn = db._get_conn()
    conn.execute("""
        INSERT INTO action_queue (action_id, app_id, action_type, status, started_at, created_at)
        VALUES ('STUCK_001', ?, 'patch', 'in_progress', '2020-01-01T00:00:00', ?)
    """, (apps[0]["app_id"], datetime.now(timezone.utc).isoformat()))
    conn.commit()
    conn.close()
    print(f"  Injected: 1 stuck action")

    # 3. Health Check (sollte Probleme finden)
    check = monitor.run_health_check()
    has_issues = not check["all_ok"]
    print(f"\n  Health Check: {'ISSUES FOUND' if has_issues else 'ALL OK (unexpected)'}")

    # 4. Heal All
    heal = healer.heal_all()
    healed = heal["total_healed"]
    print(f"  Heal All: {healed} repariert")

    # 5. Verify: Re-Check
    recheck = monitor.run_health_check()
    is_clean = recheck["all_ok"]
    print(f"  Re-Check: {'ALL OK' if is_clean else 'STILL ISSUES'}")

    # Mindestens 3 corrupted scores + 1 stuck action = 4 healed
    ok = has_issues and healed >= 3 and is_clean
    print(f"\n  Ergebnis: {'PASS' if ok else 'FAIL'} (healed={healed}, clean_after={is_clean})")
    return {
        "ok": ok,
        "scenario": "inject_and_heal",
        "issues_detected": has_issues,
        "healed": healed,
        "clean_after_heal": is_clean,
        "check_before": check,
        "check_after": recheck,
    }


def run_full_cycle_with_health() -> dict:
    """Szenario 3: Voller Orchestrator Cycle mit Pre-Cycle Health Checks."""
    print(f"\n{'='*60}")
    print(f"{_PREFIX} Szenario 3: Full Cycle mit Pre-Cycle Health Check")
    print(f"{'='*60}")

    db, gen = _setup_env()
    orch = CycleOrchestrator(registry_db=db)

    # 1. Decision Cycle (inkl. Pre-Cycle Check)
    dc = orch.run_decision_cycle()
    dc_health = dc.get("pre_cycle_health", {})
    print(f"\n  Decision Cycle: healthy={dc_health.get('healthy')}")

    # 2. Anomaly Scan (inkl. Pre-Cycle Check)
    ascan = orch.run_anomaly_scan()
    as_health = ascan.get("pre_cycle_health", {})
    print(f"  Anomaly Scan: healthy={as_health.get('healthy')}")

    # 3. Execution Path
    ex = orch.run_execution_path()
    print(f"  Execution Path: {ex.get('briefings_created', 0)} briefings")

    # 4. Health Status
    status = orch.get_health_status()
    print(f"  Health Status: {status['healer_status']['cumulative_healed']} cumulative healed")
    print(f"  Error Log: {status['error_log']['total']} total, {status['error_log']['unresolved']} unresolved")

    # Alles sollte healthy sein (saubere Fleet)
    ok = (
        dc_health.get("healthy") is True
        and as_health.get("healthy") is True
        and dc.get("apps_evaluated", 0) >= 10
    )
    print(f"\n  Ergebnis: {'PASS' if ok else 'FAIL'}")
    return {
        "ok": ok,
        "scenario": "full_cycle_health",
        "decision_cycle": dc,
        "anomaly_scan": ascan,
        "execution": ex,
        "health_status": status,
    }


def run_all() -> dict:
    """Fuehrt alle 3 Szenarien aus."""
    print(f"\n{'#'*60}")
    print(f"{_PREFIX} Self-Healing Simulation")
    print(f"{'#'*60}")

    scenarios = [
        ("health_check_clean", run_health_check_and_heal),
        ("inject_and_heal", run_inject_damage_and_heal),
        ("full_cycle_health", run_full_cycle_with_health),
    ]

    results = {}
    for name, fn in scenarios:
        try:
            results[name] = fn()
        except Exception as e:
            results[name] = {"ok": False, "error": str(e)}
            print(f"\n  {name}: ERROR - {e}")

    passed = sum(1 for r in results.values() if r.get("ok"))
    total = len(results)
    all_ok = passed == total

    print(f"\n{'#'*60}")
    print(f"{_PREFIX} Ergebnis: {passed}/{total} PASS {'(ALL PASS)' if all_ok else '(FAILURES)'}")
    print(f"{'#'*60}")

    return {"ok": all_ok, "passed": passed, "total": total, "scenarios": results}
