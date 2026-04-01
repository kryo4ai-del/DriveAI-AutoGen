"""Stress-Test Runner — Performance, Memory, Error Cascade, Consistency Tests.

Testet das Live Operations System unter Last:
- Performance: Timing aller Cycles bei N Apps
- Memory: Heap-Wachstum ueber mehrere Iterationen
- Error Cascade: Ein fehlerhafter Record darf nicht alles blockieren
- Data Consistency: DB-Zustand nach vollem Cycle muss konsistent sein
"""

import sys
import tempfile
import time
import traceback
from datetime import datetime, timezone
from typing import Optional

from factory.live_operations.app_registry.database import AppRegistryDB
from factory.live_operations.orchestrator import CycleOrchestrator
from factory.live_operations.test_harness.fleet_generator import SyntheticFleetGenerator

_PREFIX = "[Stress Test]"


def _now_iso() -> str:
    return datetime.now(timezone.utc).isoformat()


class StressTestRunner:
    """Fuehrt Stress-Tests gegen das Live Operations System aus."""

    def __init__(
        self,
        fleet_size: int = 15,
        iterations: int = 3,
        seed: int = 42,
    ) -> None:
        self._fleet_size = fleet_size
        self._iterations = iterations
        self._seed = seed
        self._results: dict = {}

    # ------------------------------------------------------------------
    # Public API
    # ------------------------------------------------------------------

    def run_all(self) -> dict:
        """Fuehrt alle Stress-Tests aus."""
        print(f"\n{'='*60}")
        print(f"{_PREFIX} Stress-Test Suite")
        print(f"{_PREFIX} Fleet Size: {self._fleet_size}, Iterations: {self._iterations}")
        print(f"{'='*60}")

        tests = [
            ("performance", self.test_performance),
            ("memory", self.test_memory),
            ("error_cascade", self.test_error_cascade),
            ("data_consistency", self.test_data_consistency),
        ]

        for name, fn in tests:
            print(f"\n{_PREFIX} --- {name.upper()} ---")
            try:
                self._results[name] = fn()
                status = "PASS" if self._results[name].get("ok") else "FAIL"
                print(f"{_PREFIX} {name}: {status}")
            except Exception as e:
                self._results[name] = {"ok": False, "error": str(e), "traceback": traceback.format_exc()}
                print(f"{_PREFIX} {name}: ERROR - {e}")

        passed = sum(1 for r in self._results.values() if r.get("ok"))
        total = len(self._results)
        all_ok = passed == total

        summary = {
            "run_at": _now_iso(),
            "fleet_size": self._fleet_size,
            "iterations": self._iterations,
            "ok": all_ok,
            "passed": passed,
            "total": total,
            "tests": self._results,
        }

        print(f"\n{'='*60}")
        print(f"{_PREFIX} Ergebnis: {passed}/{total} PASS {'(ALL PASS)' if all_ok else '(FAILURES)'}")
        print(f"{'='*60}")

        return summary

    # ------------------------------------------------------------------
    # Test 1: Performance — Timing aller Cycles
    # ------------------------------------------------------------------

    def test_performance(self) -> dict:
        """Misst Execution Time fuer Decision Cycle, Anomaly Scan, Execution Path."""
        db, gen = self._setup_fleet()
        orch = CycleOrchestrator(registry_db=db)

        timings = {}

        # Decision Cycle
        t0 = time.perf_counter()
        dc_result = orch.run_decision_cycle()
        timings["decision_cycle"] = {
            "duration_ms": round((time.perf_counter() - t0) * 1000, 1),
            "apps_evaluated": dc_result.get("apps_evaluated", 0),
        }

        # Anomaly Scan
        t0 = time.perf_counter()
        as_result = orch.run_anomaly_scan()
        timings["anomaly_scan"] = {
            "duration_ms": round((time.perf_counter() - t0) * 1000, 1),
            "anomalies": as_result.get("anomalies_found", 0),
        }

        # Execution Path
        t0 = time.perf_counter()
        ex_result = orch.run_execution_path()
        timings["execution_path"] = {
            "duration_ms": round((time.perf_counter() - t0) * 1000, 1),
            "briefings": ex_result.get("briefings_created", 0),
        }

        # Thresholds (pro App max 200ms Decision, 100ms Anomaly, 500ms Execution)
        dc_limit = self._fleet_size * 200
        as_limit = self._fleet_size * 100
        ex_limit = self._fleet_size * 500

        ok = (
            timings["decision_cycle"]["duration_ms"] < dc_limit
            and timings["anomaly_scan"]["duration_ms"] < as_limit
            and timings["execution_path"]["duration_ms"] < ex_limit
        )

        for name, t in timings.items():
            print(f"{_PREFIX}   {name}: {t['duration_ms']}ms")

        return {
            "ok": ok,
            "timings": timings,
            "thresholds": {
                "decision_cycle_max_ms": dc_limit,
                "anomaly_scan_max_ms": as_limit,
                "execution_path_max_ms": ex_limit,
            },
        }

    # ------------------------------------------------------------------
    # Test 2: Memory — Heap-Wachstum ueber Iterationen
    # ------------------------------------------------------------------

    def test_memory(self) -> dict:
        """Prueft ob Memory ueber mehrere Cycles stabil bleibt."""
        db, gen = self._setup_fleet()
        orch = CycleOrchestrator(registry_db=db)

        snapshots = []

        for i in range(self._iterations):
            # Measure memory before cycle
            mem_before = self._get_memory_usage()

            orch.run_decision_cycle()
            orch.run_anomaly_scan()
            orch.run_execution_path()

            mem_after = self._get_memory_usage()
            growth = mem_after - mem_before

            snapshots.append({
                "iteration": i + 1,
                "mem_before_mb": round(mem_before, 2),
                "mem_after_mb": round(mem_after, 2),
                "growth_mb": round(growth, 2),
            })

            print(f"{_PREFIX}   Iteration {i+1}: {mem_before:.1f}MB -> {mem_after:.1f}MB (delta {growth:+.1f}MB)")

        # Check: kein einzelner Cycle darf mehr als 50MB wachsen
        # und Gesamtwachstum darf nicht mehr als 100MB sein
        max_single_growth = max(s["growth_mb"] for s in snapshots)
        total_growth = snapshots[-1]["mem_after_mb"] - snapshots[0]["mem_before_mb"]

        ok = max_single_growth < 50.0 and total_growth < 100.0

        return {
            "ok": ok,
            "snapshots": snapshots,
            "max_single_growth_mb": round(max_single_growth, 2),
            "total_growth_mb": round(total_growth, 2),
            "limits": {"single_max_mb": 50.0, "total_max_mb": 100.0},
        }

    # ------------------------------------------------------------------
    # Test 3: Error Cascade — ein Fehler darf nicht alles blockieren
    # ------------------------------------------------------------------

    def test_error_cascade(self) -> dict:
        """Injiziert fehlerhafte Daten und prueft ob der Rest weiterlaeuft."""
        db, gen = self._setup_fleet()
        orch = CycleOrchestrator(registry_db=db)

        # Inject: App mit kaputtem health_score (None)
        corrupted_id = "CORRUPT_TEST_APP"
        conn = db._get_conn()
        conn.execute("""
            INSERT INTO apps (app_id, app_name, health_score, health_zone, app_profile, repository_path)
            VALUES (?, ?, ?, ?, ?, ?)
        """, (corrupted_id, "CorruptedApp", None, None, "utility", "SYNTHETIC_FLEET"))
        conn.commit()
        conn.close()

        total_apps = len(db.get_all_apps())
        print(f"{_PREFIX}   {total_apps} Apps in DB (inkl. corrupted)")

        # Decision Cycle sollte trotzdem laufen
        try:
            dc = orch.run_decision_cycle()
            dc_ok = dc.get("apps_evaluated", 0) >= self._fleet_size  # Mindestens die Fleet
            dc_error = None
        except Exception as e:
            dc_ok = False
            dc_error = str(e)

        # Anomaly Scan sollte trotzdem laufen
        try:
            ascan = orch.run_anomaly_scan()
            as_ok = True
            as_error = None
        except Exception as e:
            as_ok = False
            as_error = str(e)

        # Execution Path sollte trotzdem laufen
        try:
            ex = orch.run_execution_path()
            ex_ok = True
            ex_error = None
        except Exception as e:
            ex_ok = False
            ex_error = str(e)

        ok = dc_ok and as_ok and ex_ok

        return {
            "ok": ok,
            "total_apps": total_apps,
            "corrupted_app": corrupted_id,
            "decision_cycle": {"ok": dc_ok, "error": dc_error},
            "anomaly_scan": {"ok": as_ok, "error": as_error},
            "execution_path": {"ok": ex_ok, "error": ex_error},
        }

    # ------------------------------------------------------------------
    # Test 4: Data Consistency — DB-Zustand nach Full Cycle
    # ------------------------------------------------------------------

    def test_data_consistency(self) -> dict:
        """Prueft DB-Integritaet nach vollem Cycle."""
        db, gen = self._setup_fleet()
        orch = CycleOrchestrator(registry_db=db)

        # Run full cycle
        orch.run_decision_cycle()
        orch.run_anomaly_scan()
        orch.run_execution_path()

        checks = {}

        # Check 1: Alle Apps haben gueltigen health_score
        apps = db.get_all_apps()
        invalid_scores = [
            a["app_id"] for a in apps
            if a.get("health_score") is None or not (0 <= a["health_score"] <= 100)
        ]
        checks["valid_health_scores"] = {
            "ok": len(invalid_scores) == 0,
            "invalid": invalid_scores,
        }

        # Check 2: Alle Apps haben gueltige health_zone
        valid_zones = {"green", "yellow", "red"}
        invalid_zones = [
            a["app_id"] for a in apps
            if a.get("health_zone") not in valid_zones
        ]
        checks["valid_health_zones"] = {
            "ok": len(invalid_zones) == 0,
            "invalid": invalid_zones,
        }

        # Check 3: Keine verwaisten Action Queue Eintraege
        conn = db._get_conn()
        orphan_actions = conn.execute("""
            SELECT aq.action_id, aq.app_id
            FROM action_queue aq
            LEFT JOIN apps a ON aq.app_id = a.app_id
            WHERE a.app_id IS NULL
        """).fetchall()
        conn.close()
        checks["no_orphan_actions"] = {
            "ok": len(orphan_actions) == 0,
            "orphans": [dict(r) for r in orphan_actions],
        }

        # Check 4: Keine verwaisten Health Records
        conn = db._get_conn()
        orphan_health = conn.execute("""
            SELECT hsh.record_id, hsh.app_id
            FROM health_score_history hsh
            LEFT JOIN apps a ON hsh.app_id = a.app_id
            WHERE a.app_id IS NULL
        """).fetchall()
        conn.close()
        checks["no_orphan_health_records"] = {
            "ok": len(orphan_health) == 0,
            "orphans": [dict(r) for r in orphan_health],
        }

        # Check 5: App-Count unveraendert nach Cycle
        checks["app_count_stable"] = {
            "ok": len(apps) == self._fleet_size,
            "expected": self._fleet_size,
            "actual": len(apps),
        }

        all_ok = all(c["ok"] for c in checks.values())

        for name, check in checks.items():
            status = "OK" if check["ok"] else "FAIL"
            print(f"{_PREFIX}   {name}: {status}")

        return {"ok": all_ok, "checks": checks}

    # ------------------------------------------------------------------
    # Helpers
    # ------------------------------------------------------------------

    def _setup_fleet(self) -> tuple:
        """Erstellt Temp-DB mit synthetischer Fleet."""
        tmp = tempfile.mktemp(suffix=".db")
        db = AppRegistryDB(tmp)
        gen = SyntheticFleetGenerator(registry_db=db, seed=self._seed)
        gen.generate_fleet(self._fleet_size)
        gen.generate_metrics_history()
        return db, gen

    @staticmethod
    def _get_memory_usage() -> float:
        """Gibt aktuellen RSS-Memory in MB zurueck."""
        try:
            import psutil
            process = psutil.Process()
            return process.memory_info().rss / (1024 * 1024)
        except ImportError:
            # Fallback: sys.getsizeof ist ungenau, aber besser als nichts
            import gc
            gc.collect()
            # Grobe Schaetzung: Anzahl tracked Objects * avg Groesse
            return len(gc.get_objects()) * 0.0001  # ~100 bytes avg -> MB
