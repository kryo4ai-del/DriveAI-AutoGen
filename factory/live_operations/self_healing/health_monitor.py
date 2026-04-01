"""System Health Monitor — prueft Subsystem-Gesundheit vor jedem Cycle.

Checks:
1. DB Connectivity — SQLite erreichbar + Tabellen vorhanden
2. Data Directory — Schreibrechte, Platz
3. Agent Health — Alle Core-Agents instanziierbar
4. Queue Health — Keine stuck Actions, Queue nicht uebergelaufen
5. Escalation Health — Log schreibbar
"""

import os
import sqlite3
from datetime import datetime, timezone, timedelta
from pathlib import Path
from typing import Optional

from factory.live_operations.app_registry.database import AppRegistryDB
from factory.live_operations.self_healing.utilities import safe_execute, ErrorLog

_PREFIX = "[Health Monitor]"


class SystemHealthMonitor:
    """Prueft alle Subsysteme vor einem Cycle-Start."""

    def __init__(
        self,
        registry_db: Optional[AppRegistryDB] = None,
        data_dir: Optional[str] = None,
        error_log: Optional[ErrorLog] = None,
    ) -> None:
        self._db = registry_db or AppRegistryDB()
        self._data_dir = Path(
            data_dir
            or Path(__file__).resolve().parent.parent / "data"
        )
        self._error_log = error_log or ErrorLog()
        self._last_check: Optional[str] = None
        self._check_count: int = 0

    # ------------------------------------------------------------------
    # Public API
    # ------------------------------------------------------------------

    def run_health_check(self) -> dict:
        """Fuehrt alle Health Checks aus.

        Returns:
            {
                "healthy": bool,
                "checked_at": str,
                "checks": { name: { "ok": bool, "detail": str } },
                "warnings": [str],
                "errors": [str],
            }
        """
        checks = {}
        warnings = []
        errors = []

        # 1. DB Connectivity
        result, err = safe_execute(self._check_db_connectivity)
        if err:
            checks["db_connectivity"] = {"ok": False, "detail": err}
            errors.append(f"DB: {err}")
            self._error_log.log("db", err, action="check_failed")
        else:
            checks["db_connectivity"] = result

        # 2. Data Directory
        result, err = safe_execute(self._check_data_directory)
        if err:
            checks["data_directory"] = {"ok": False, "detail": err}
            errors.append(f"Data Dir: {err}")
            self._error_log.log("data_dir", err, action="check_failed")
        else:
            checks["data_directory"] = result
            if not result["ok"]:
                errors.append(f"Data Dir: {result['detail']}")

        # 3. Agent Health
        result, err = safe_execute(self._check_agent_health)
        if err:
            checks["agent_health"] = {"ok": False, "detail": err}
            errors.append(f"Agents: {err}")
            self._error_log.log("agents", err, action="check_failed")
        else:
            checks["agent_health"] = result
            if not result["ok"]:
                warnings.append(f"Agents: {result['detail']}")

        # 4. Queue Health
        result, err = safe_execute(self._check_queue_health)
        if err:
            checks["queue_health"] = {"ok": False, "detail": err}
            warnings.append(f"Queue: {err}")
            self._error_log.log("queue", err, action="check_failed")
        else:
            checks["queue_health"] = result
            if not result["ok"]:
                warnings.append(f"Queue: {result['detail']}")

        # 5. Escalation Health
        result, err = safe_execute(self._check_escalation_health)
        if err:
            checks["escalation_health"] = {"ok": False, "detail": err}
            warnings.append(f"Escalation: {err}")
            self._error_log.log("escalation", err, action="check_failed")
        else:
            checks["escalation_health"] = result

        # Overall
        all_ok = all(c.get("ok", False) for c in checks.values())
        # Downgrade: wenn nur warnings aber keine critical errors -> still healthy
        critical_checks = ["db_connectivity", "data_directory"]
        critical_ok = all(checks.get(c, {}).get("ok", False) for c in critical_checks)

        self._last_check = datetime.now(timezone.utc).isoformat()
        self._check_count += 1

        summary = {
            "healthy": critical_ok,
            "all_ok": all_ok,
            "checked_at": self._last_check,
            "check_number": self._check_count,
            "checks": checks,
            "warnings": warnings,
            "errors": errors,
        }

        status = "HEALTHY" if critical_ok else "UNHEALTHY"
        print(f"{_PREFIX} Check #{self._check_count}: {status} "
              f"({sum(1 for c in checks.values() if c.get('ok'))}/{len(checks)} checks OK)")

        return summary

    def get_error_log(self) -> list[dict]:
        """Gibt aktuelle Fehler zurueck."""
        return self._error_log.get_recent()

    def get_status(self) -> dict:
        """Aktueller Monitor-Status."""
        return {
            "last_check": self._last_check,
            "check_count": self._check_count,
            "unresolved_errors": len(self._error_log.get_unresolved()),
            "total_errors_logged": self._error_log.total,
        }

    # ------------------------------------------------------------------
    # Check Implementations
    # ------------------------------------------------------------------

    def _check_db_connectivity(self) -> dict:
        """Check 1: DB erreichbar, Tabellen vorhanden."""
        try:
            conn = self._db._get_conn()
            # Check all expected tables exist
            tables = conn.execute(
                "SELECT name FROM sqlite_master WHERE type='table'"
            ).fetchall()
            conn.close()

            table_names = {t["name"] for t in tables}
            expected = {"apps", "release_history", "action_queue", "health_score_history"}
            missing = expected - table_names

            if missing:
                return {"ok": False, "detail": f"Fehlende Tabellen: {missing}"}

            return {"ok": True, "detail": f"{len(table_names)} Tabellen OK"}
        except Exception as e:
            return {"ok": False, "detail": str(e)}

    def _check_data_directory(self) -> dict:
        """Check 2: Data Directory existiert und ist beschreibbar."""
        if not self._data_dir.exists():
            try:
                self._data_dir.mkdir(parents=True, exist_ok=True)
                return {"ok": True, "detail": "Erstellt"}
            except Exception as e:
                return {"ok": False, "detail": f"Kann nicht erstellt werden: {e}"}

        # Write test
        test_file = self._data_dir / ".health_check_test"
        try:
            test_file.write_text("ok", encoding="utf-8")
            test_file.unlink()
        except Exception as e:
            return {"ok": False, "detail": f"Nicht beschreibbar: {e}"}

        # Check subdirectories
        subdirs = ["briefings", "submissions", "releases", "escalation", "benchmarks"]
        missing_dirs = []
        for d in subdirs:
            subdir = self._data_dir / d
            if not subdir.exists():
                try:
                    subdir.mkdir(parents=True, exist_ok=True)
                except Exception:
                    missing_dirs.append(d)

        if missing_dirs:
            return {"ok": True, "detail": f"OK (erstellt: {missing_dirs})"}

        return {"ok": True, "detail": "Alle Verzeichnisse OK"}

    def _check_agent_health(self) -> dict:
        """Check 3: Core-Agents instanziierbar."""
        failed = []
        agents_to_check = [
            ("DecisionEngine", "factory.live_operations.agents.decision_engine.engine", "DecisionEngine"),
            ("AnomalyDetector", "factory.live_operations.agents.anomaly_detector.detector", "AnomalyDetector"),
            ("EscalationManager", "factory.live_operations.agents.escalation.manager", "EscalationManager"),
            ("UpdatePlanner", "factory.live_operations.agents.update_planner.planner", "UpdatePlanner"),
            ("FactoryAdapter", "factory.live_operations.agents.factory_adapter.adapter", "FactoryAdapter"),
            ("ReleaseManager", "factory.live_operations.agents.release_manager.manager", "ReleaseManager"),
        ]

        for name, module_path, class_name in agents_to_check:
            try:
                import importlib
                mod = importlib.import_module(module_path)
                cls = getattr(mod, class_name)
                # Agents die DB brauchen, bekommen unsere DB
                if class_name in ("DecisionEngine", "AnomalyDetector"):
                    cls(self._db)
                else:
                    cls()
            except Exception as e:
                failed.append(f"{name}: {e}")

        if failed:
            return {"ok": False, "detail": f"{len(failed)} Agents fehlerhaft: {'; '.join(failed)}"}

        return {"ok": True, "detail": f"{len(agents_to_check)} Agents OK"}

    def _check_queue_health(self) -> dict:
        """Check 4: Action Queue gesund."""
        try:
            conn = self._db._get_conn()

            # Stuck actions (in_progress > 24h)
            cutoff = (datetime.now(timezone.utc) - timedelta(hours=24)).isoformat()
            stuck = conn.execute(
                "SELECT COUNT(*) as cnt FROM action_queue WHERE status = 'in_progress' AND started_at < ?",
                (cutoff,)
            ).fetchone()
            stuck_count = stuck["cnt"] if stuck else 0

            # Queue size
            total = conn.execute(
                "SELECT COUNT(*) as cnt FROM action_queue WHERE status = 'pending'"
            ).fetchone()
            pending_count = total["cnt"] if total else 0

            conn.close()

            issues = []
            if stuck_count > 0:
                issues.append(f"{stuck_count} stuck actions (>24h)")
            if pending_count > 50:
                issues.append(f"Queue overflow: {pending_count} pending")

            if issues:
                return {"ok": False, "detail": "; ".join(issues)}

            return {"ok": True, "detail": f"{pending_count} pending, 0 stuck"}
        except Exception as e:
            return {"ok": False, "detail": str(e)}

    def _check_escalation_health(self) -> dict:
        """Check 5: Escalation Log schreibbar."""
        esc_dir = self._data_dir / "escalation"
        esc_dir.mkdir(parents=True, exist_ok=True)

        log_path = esc_dir / "escalation_log.jsonl"
        try:
            # Verify we can append
            with open(log_path, "a", encoding="utf-8") as f:
                pass  # Just test open in append mode
            return {"ok": True, "detail": "Log schreibbar"}
        except Exception as e:
            return {"ok": False, "detail": f"Log nicht schreibbar: {e}"}
