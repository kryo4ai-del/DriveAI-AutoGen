"""Live Operations Cycle Orchestrator.

Drei Zyklen:
  1. Decision Cycle (6h):  Metriken -> Health Score -> Decision Engine -> Eskalation
  2. Anomaly Scan (30min):  Schnellcheck aller Apps auf Ausreisser
  3. Execution Path:        Pending Actions -> Briefing -> Factory -> Release

Kann als Daemon oder Single-Run laufen.
"""

import time
import threading
from datetime import datetime, timezone
from typing import Optional

from .app_registry.database import AppRegistryDB
from .agents.decision_engine.engine import DecisionEngine
from .agents.decision_engine.action_queue import ActionQueueManager
from .agents.decision_engine.cooling import CoolingManager
from .agents.anomaly_detector.detector import AnomalyDetector
from .agents.anomaly_detector.rollback import RollbackManager
from .agents.escalation.manager import EscalationManager
from .agents.update_planner.planner import UpdatePlanner
from .agents.factory_adapter.adapter import FactoryAdapter
from .agents.release_manager.manager import ReleaseManager
from .self_healing.health_monitor import SystemHealthMonitor
from .self_healing.healer import SelfHealer
from .self_healing.utilities import ErrorLog


# ------------------------------------------------------------------
# Cycle timing (seconds)
# ------------------------------------------------------------------
DECISION_CYCLE_SECONDS = 6 * 3600   # 6 hours
ANOMALY_CYCLE_SECONDS = 30 * 60     # 30 minutes


class CycleOrchestrator:
    """Orchestriert die Live Operations Zyklen."""

    def __init__(self, registry_db: Optional[AppRegistryDB] = None) -> None:
        self.db = registry_db or AppRegistryDB()

        # Phase 3 Agents
        self.decision_engine = DecisionEngine(self.db)
        self.anomaly_detector = AnomalyDetector(self.db)
        self.rollback_manager = RollbackManager(self.db)
        self.action_queue = ActionQueueManager(self.db)
        self.cooling_manager = CoolingManager(self.db)
        self.escalation_manager = EscalationManager()

        # Phase 4 Agents (Execution)
        self.update_planner = UpdatePlanner()
        self.factory_adapter = FactoryAdapter()
        self.release_manager = ReleaseManager(db=self.db)

        # Phase 6: Self-Healing
        self._error_log = ErrorLog()
        self.health_monitor = SystemHealthMonitor(
            registry_db=self.db, error_log=self._error_log
        )
        self.self_healer = SelfHealer(
            registry_db=self.db, error_log=self._error_log
        )

        # State
        self._running = False
        self._last_decision_cycle = None
        self._last_anomaly_scan = None
        self._last_execution_run = None
        self._decision_count = 0
        self._anomaly_count = 0
        self._execution_count = 0

    # ------------------------------------------------------------------
    # Public API
    # ------------------------------------------------------------------

    def run_decision_cycle(self) -> dict:
        """Fuehrt einen vollstaendigen Decision Cycle aus.

        0. Pre-Cycle Health Check + Self-Healing
        1. Stale Actions aufraeumen
        2. Abgelaufene Coolings loeschen
        3. Alle Apps evaluieren
        4. Eskalationen verarbeiten
        """
        start = datetime.now(timezone.utc)
        print(f"\n{'='*60}")
        print(f"[Orchestrator] DECISION CYCLE #{self._decision_count + 1}")
        print(f"[Orchestrator] Started: {start.isoformat()}")
        print(f"{'='*60}")

        # 0. Pre-Cycle Health Check
        health = self._run_pre_cycle_check("decision_cycle")

        # 1. Maintenance
        stale = self.action_queue.cleanup_stale_actions()
        self.cooling_manager.clear_expired_cooling()

        # 2. Evaluate all apps
        eval_result = self.decision_engine.evaluate_all()
        results = eval_result.get("results", {})

        # 3. Process escalations
        escalations = []
        for app_id, decision in results.items():
            if decision.get("error"):
                continue
            esc = self.escalation_manager.escalate_from_decision(decision)
            if esc:
                escalations.append(esc)

        # 4. Summary
        self._last_decision_cycle = start.isoformat()
        self._decision_count += 1
        duration = (datetime.now(timezone.utc) - start).total_seconds()

        actions = sum(1 for r in results.values()
                      if r.get("action_type", "none") != "none")
        esc_count = len(escalations)

        summary = {
            "cycle_type": "decision",
            "cycle_number": self._decision_count,
            "started_at": start.isoformat(),
            "duration_seconds": round(duration, 1),
            "apps_evaluated": len(results),
            "actions_created": actions,
            "escalations": esc_count,
            "stale_cleaned": stale,
            "pre_cycle_health": health,
        }

        print(f"\n[Orchestrator] Decision Cycle #{self._decision_count} complete")
        print(f"  Apps: {len(results)} | Actions: {actions} | "
              f"Escalations: {esc_count} | Duration: {duration:.1f}s")

        return summary

    def run_anomaly_scan(self) -> dict:
        """Fuehrt einen Anomaly Scan aus.

        0. Pre-Cycle Health Check + Self-Healing
        1. Alle Apps scannen
        2. Bei Fund: Auto-Rollback wenn moeglich
        3. Eskalation verarbeiten
        """
        start = datetime.now(timezone.utc)
        self._anomaly_count += 1
        print(f"\n[Orchestrator] ANOMALY SCAN #{self._anomaly_count}")

        # 0. Pre-Cycle Health Check
        health = self._run_pre_cycle_check("anomaly_scan")

        # 1. Scan
        anomalies = self.anomaly_detector.scan_all()

        # 2. Process each anomaly
        escalations = []
        rollbacks = []
        for anomaly in anomalies:
            app_id = anomaly.get("app_id", "")

            # Auto-rollback?
            rollback_report = None
            if anomaly.get("can_auto_rollback"):
                rollback_report = self.rollback_manager.execute_rollback(
                    app_id, anomaly.get("detail", "Anomaly detected")
                )
                if rollback_report and rollback_report.get("success"):
                    rollbacks.append(rollback_report)

            # Escalation
            esc = self.escalation_manager.escalate_from_anomaly(anomaly, rollback_report)
            if esc:
                escalations.append(esc)

        # 3. Summary
        self._last_anomaly_scan = start.isoformat()
        duration = (datetime.now(timezone.utc) - start).total_seconds()

        summary = {
            "cycle_type": "anomaly_scan",
            "scan_number": self._anomaly_count,
            "started_at": start.isoformat(),
            "duration_seconds": round(duration, 1),
            "anomalies_found": len(anomalies),
            "rollbacks_executed": len(rollbacks),
            "escalations": len(escalations),
            "pre_cycle_health": health,
        }

        if anomalies:
            print(f"  Found {len(anomalies)} anomalies | "
                  f"Rollbacks: {len(rollbacks)} | Escalations: {len(escalations)}")
        else:
            print(f"  No anomalies detected ({duration:.1f}s)")

        return summary

    def run_execution_path(self) -> dict:
        """Fuehrt den Execution Path aus.

        1. Pending Actions aus der Queue holen
        2. Fuer jede: Briefing erstellen (UpdatePlanner)
        3. An Factory uebergeben (FactoryAdapter)
        4. Release verarbeiten (ReleaseManager) — nur fuer completed submissions

        Returns:
            Summary dict mit Counts.
        """
        start = datetime.now(timezone.utc)
        self._execution_count += 1
        print(f"\n[Orchestrator] EXECUTION PATH #{self._execution_count}")

        # 1. Get pending actions
        pending = self.action_queue.get_queue(status="pending")
        print(f"  Pending actions: {len(pending)}")

        briefings_created = 0
        submissions_created = 0
        releases_processed = 0
        errors = []

        for action in pending:
            action_id = action.get("action_id", "?")
            app_id = action.get("app_id", "unknown")
            action_type = action.get("action_type", "patch")

            try:
                # 2. Create Briefing
                app_info = self.db.get_app(app_id) if self.db else None
                briefing = self.update_planner.create_briefing(action, app_info)
                briefings_created += 1
                print(f"  [{app_id}] Briefing: {briefing['briefing_id']}")

                # Mark action as in_progress
                self.action_queue.start_action(action_id)

                # 3. Submit to Factory
                submission = self.factory_adapter.submit_briefing(briefing)
                submissions_created += 1
                print(f"  [{app_id}] Submission: {submission['submission_id']} [{submission['status']}]")

                # 4. Simulate Factory completion (STUB: auto-accept + complete)
                sid = submission["submission_id"]
                self.factory_adapter.update_status(sid, "accepted", "Factory auto-accept (STUB)")
                self.factory_adapter.update_status(sid, "in_progress", "Build gestartet (STUB)")
                self.factory_adapter.update_status(sid, "completed", "Build fertig (STUB)")

                # 5. Process Release
                # Build release context from DB or defaults
                health_score = 50.0
                if app_info:
                    health_score = app_info.get("health_score", 50.0) or 50.0

                release_context = {
                    "health_score": health_score,
                    "active_anomalies": 0,
                    "cooling_active": False,
                    "has_briefing": True,
                    "has_submission": True,
                }

                release = self.release_manager.process_release(submission, release_context)
                if release["status"] == "released":
                    releases_processed += 1
                    self.action_queue.complete_action(action_id)
                    print(f"  [{app_id}] Release: {release['release_id']} -> v{release['target_version']}")
                else:
                    print(f"  [{app_id}] Release blocked: {release['status']} - {release.get('error', '')}")

            except Exception as e:
                errors.append(f"{app_id}: {e}")
                print(f"  [{app_id}] ERROR: {e}")

        # Summary
        self._last_execution_run = start.isoformat()
        duration = (datetime.now(timezone.utc) - start).total_seconds()

        summary = {
            "cycle_type": "execution",
            "execution_number": self._execution_count,
            "started_at": start.isoformat(),
            "duration_seconds": round(duration, 1),
            "pending_actions": len(pending),
            "briefings_created": briefings_created,
            "submissions_created": submissions_created,
            "releases_processed": releases_processed,
            "errors": errors,
        }

        print(f"\n  Execution #{self._execution_count} complete: "
              f"{briefings_created} briefings, {submissions_created} submissions, "
              f"{releases_processed} releases ({duration:.1f}s)")

        return summary

    def get_submissions(self, app_id: str | None = None) -> list:
        """Liste aller Factory Submissions."""
        return self.factory_adapter.list_submissions(app_id=app_id)

    def get_releases(self, app_id: str | None = None) -> list:
        """Liste aller Releases."""
        return self.release_manager.list_releases(app_id=app_id)

    def get_briefings(self, app_id: str | None = None) -> list:
        """Liste aller Briefings."""
        return self.update_planner.list_briefings(app_id=app_id)

    def check_cooling(self, app_id: str | None = None) -> list:
        """Cooling-Status aller Apps oder einer bestimmten."""
        if app_id:
            info = self.cooling_manager.get_cooling_info(app_id)
            return [info] if info else []
        return self.cooling_manager.get_all_cooling()

    def get_status(self) -> dict:
        """Aktueller Status des Orchestrators."""
        return {
            "running": self._running,
            "last_decision_cycle": self._last_decision_cycle,
            "last_anomaly_scan": self._last_anomaly_scan,
            "last_execution_run": self._last_execution_run,
            "decision_cycles_completed": self._decision_count,
            "anomaly_scans_completed": self._anomaly_count,
            "execution_runs_completed": self._execution_count,
            "next_decision_cycle_seconds": DECISION_CYCLE_SECONDS,
            "next_anomaly_scan_seconds": ANOMALY_CYCLE_SECONDS,
        }

    # ------------------------------------------------------------------
    # Continuous Mode
    # ------------------------------------------------------------------

    def start_continuous(self) -> None:
        """Startet Endlosschleife mit beiden Zyklen.

        Decision Cycle: alle 6h
        Anomaly Scan: alle 30min
        """
        self._running = True
        print(f"\n[Orchestrator] Starting continuous mode")
        print(f"  Decision Cycle: every {DECISION_CYCLE_SECONDS // 3600}h")
        print(f"  Anomaly Scan: every {ANOMALY_CYCLE_SECONDS // 60}min")

        # Run initial decision cycle
        self.run_decision_cycle()

        # Start anomaly scan thread
        anomaly_thread = threading.Thread(target=self._anomaly_loop, daemon=True)
        anomaly_thread.start()

        # Decision cycle loop (main thread)
        try:
            while self._running:
                time.sleep(DECISION_CYCLE_SECONDS)
                if self._running:
                    self.run_decision_cycle()
        except KeyboardInterrupt:
            print("\n[Orchestrator] Stopped by user")
            self._running = False

    def stop(self) -> None:
        """Stoppt den Orchestrator."""
        self._running = False
        print("[Orchestrator] Stop requested")

    # ------------------------------------------------------------------
    # Internal
    # ------------------------------------------------------------------

    def _run_pre_cycle_check(self, cycle_name: str) -> dict:
        """Pre-Cycle Health Check — prueft System und heilt bei Bedarf.

        Returns:
            Health-Summary mit optionalem Healing-Ergebnis.
        """
        try:
            check = self.health_monitor.run_health_check()
            if not check["all_ok"]:
                print(f"  [Health] {len(check['warnings'])} warnings, "
                      f"{len(check['errors'])} errors -> healing")
                heal_result = self.self_healer.heal_from_check(check)
                return {
                    "healthy": False,
                    "healed": heal_result.get("total_healed", 0),
                    "warnings": check["warnings"],
                }
            return {"healthy": True, "healed": 0, "warnings": []}
        except Exception as e:
            print(f"  [Health] Check failed: {e} (continuing anyway)")
            self._error_log.log("pre_cycle_check", str(e), action="logged")
            return {"healthy": None, "error": str(e)}

    def get_health_status(self) -> dict:
        """Aktueller Health-Status des Systems."""
        return {
            "health_check": self.health_monitor.run_health_check(),
            "healer_status": self.self_healer.get_status(),
            "error_log": {
                "total": self._error_log.total,
                "unresolved": len(self._error_log.get_unresolved()),
                "recent": self._error_log.get_recent(5),
            },
        }

    def _anomaly_loop(self) -> None:
        """Anomaly Scan Endlosschleife (laeuft in eigenem Thread)."""
        while self._running:
            time.sleep(ANOMALY_CYCLE_SECONDS)
            if self._running:
                try:
                    self.run_anomaly_scan()
                except Exception as e:
                    print(f"[Orchestrator] Anomaly scan error: {e}")
