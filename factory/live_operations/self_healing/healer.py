"""Self-Healer — repariert bekannte Probleme automatisch.

Healing Actions:
1. cleanup_stuck_actions — Stuck Actions zuruecksetzen
2. repair_data_dirs — Fehlende Verzeichnisse erstellen
3. reset_corrupted_scores — NULL/Invalid Scores reparieren
4. compact_escalation_log — Uebergrosse Logs trimmen
5. repair_orphaned_records — Verwaiste DB-Records entfernen
"""

import json
from datetime import datetime, timezone, timedelta
from pathlib import Path
from typing import Optional

from factory.live_operations.app_registry.database import AppRegistryDB
from factory.live_operations.self_healing.utilities import ErrorLog

_PREFIX = "[Self-Healer]"

# Maximale Groesse fuer Escalation Log (Zeilen)
MAX_ESCALATION_LOG_LINES = 5000


class SelfHealer:
    """Repariert bekannte Probleme im Live Operations System."""

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
        self._healed_count: int = 0

    # ------------------------------------------------------------------
    # Public API
    # ------------------------------------------------------------------

    def heal_all(self) -> dict:
        """Fuehrt alle Healing-Actions aus.

        Returns:
            { "healed_at": str, "actions": { name: result }, "total_healed": int }
        """
        actions = {}
        total = 0

        healers = [
            ("cleanup_stuck_actions", self.cleanup_stuck_actions),
            ("repair_data_dirs", self.repair_data_dirs),
            ("reset_corrupted_scores", self.reset_corrupted_scores),
            ("compact_escalation_log", self.compact_escalation_log),
            ("repair_orphaned_records", self.repair_orphaned_records),
        ]

        for name, fn in healers:
            try:
                result = fn()
                actions[name] = result
                healed = result.get("healed", 0)
                total += healed
                if healed > 0:
                    self._error_log.log(name, f"{healed} items healed", action="healed", resolved=True)
                    print(f"{_PREFIX} {name}: {healed} repariert")
            except Exception as e:
                actions[name] = {"ok": False, "error": str(e)}
                self._error_log.log(name, str(e), action="heal_failed")
                print(f"{_PREFIX} {name}: FEHLER - {e}")

        self._healed_count += total

        return {
            "healed_at": datetime.now(timezone.utc).isoformat(),
            "actions": actions,
            "total_healed": total,
            "cumulative_healed": self._healed_count,
        }

    def heal_from_check(self, health_check: dict) -> dict:
        """Gezielte Heilung basierend auf Health Check Ergebnissen."""
        targeted = {}
        checks = health_check.get("checks", {})

        # Queue problems -> cleanup stuck
        if not checks.get("queue_health", {}).get("ok", True):
            targeted["cleanup_stuck_actions"] = self.cleanup_stuck_actions()

        # Data dir problems -> repair dirs
        if not checks.get("data_directory", {}).get("ok", True):
            targeted["repair_data_dirs"] = self.repair_data_dirs()

        # DB problems -> try corrupted scores
        if checks.get("db_connectivity", {}).get("ok", True):
            # DB is reachable, try data repairs
            targeted["reset_corrupted_scores"] = self.reset_corrupted_scores()

        total = sum(r.get("healed", 0) for r in targeted.values())
        self._healed_count += total

        return {
            "healed_at": datetime.now(timezone.utc).isoformat(),
            "targeted_actions": targeted,
            "total_healed": total,
        }

    # ------------------------------------------------------------------
    # Healing Actions
    # ------------------------------------------------------------------

    def cleanup_stuck_actions(self) -> dict:
        """Setzt Actions zurueck die > 24h in_progress sind."""
        conn = self._db._get_conn()
        cutoff = (datetime.now(timezone.utc) - timedelta(hours=24)).isoformat()

        stuck = conn.execute(
            "SELECT action_id, app_id FROM action_queue "
            "WHERE status = 'in_progress' AND started_at < ?",
            (cutoff,)
        ).fetchall()

        healed = 0
        for row in stuck:
            conn.execute(
                "UPDATE action_queue SET status = 'pending', started_at = NULL WHERE action_id = ?",
                (row["action_id"],)
            )
            healed += 1

        conn.commit()
        conn.close()

        return {"ok": True, "healed": healed, "detail": f"{healed} stuck actions zurueckgesetzt"}

    def repair_data_dirs(self) -> dict:
        """Erstellt fehlende Datenverzeichnisse."""
        required = [
            "briefings", "submissions", "releases", "escalation",
            "synthetic", "benchmarks", "insights",
        ]
        created = 0
        for d in required:
            target = self._data_dir / d
            if not target.exists():
                target.mkdir(parents=True, exist_ok=True)
                created += 1

        return {"ok": True, "healed": created, "detail": f"{created} Verzeichnisse erstellt"}

    def reset_corrupted_scores(self) -> dict:
        """Repariert Apps mit NULL oder ungueltigen Health Scores."""
        conn = self._db._get_conn()

        # Find corrupted
        corrupted = conn.execute(
            "SELECT app_id FROM apps WHERE health_score IS NULL "
            "OR health_score < 0 OR health_score > 100 "
            "OR health_zone IS NULL "
            "OR health_zone NOT IN ('green', 'yellow', 'red')"
        ).fetchall()

        healed = 0
        for row in corrupted:
            # Set to safe defaults
            conn.execute(
                "UPDATE apps SET health_score = 50.0, health_zone = 'yellow', "
                "updated_at = ? WHERE app_id = ?",
                (datetime.now(timezone.utc).isoformat(), row["app_id"])
            )
            healed += 1

        conn.commit()
        conn.close()

        return {"ok": True, "healed": healed, "detail": f"{healed} corrupted scores repariert"}

    def compact_escalation_log(self) -> dict:
        """Trimmt Escalation Log wenn es zu gross wird."""
        log_path = self._data_dir / "escalation" / "escalation_log.jsonl"
        if not log_path.exists():
            return {"ok": True, "healed": 0, "detail": "Kein Log vorhanden"}

        try:
            lines = log_path.read_text(encoding="utf-8").strip().split("\n")
            original = len(lines)

            if original <= MAX_ESCALATION_LOG_LINES:
                return {"ok": True, "healed": 0, "detail": f"Log OK ({original} Zeilen)"}

            # Keep latest entries
            trimmed = lines[-MAX_ESCALATION_LOG_LINES:]
            log_path.write_text("\n".join(trimmed) + "\n", encoding="utf-8")

            removed = original - len(trimmed)
            return {"ok": True, "healed": removed, "detail": f"{removed} alte Zeilen entfernt ({original} -> {len(trimmed)})"}
        except Exception as e:
            return {"ok": False, "healed": 0, "error": str(e)}

    def repair_orphaned_records(self) -> dict:
        """Entfernt verwaiste Records aus der DB."""
        conn = self._db._get_conn()
        healed = 0

        # Orphaned health records
        result = conn.execute("""
            DELETE FROM health_score_history
            WHERE app_id NOT IN (SELECT app_id FROM apps)
        """)
        healed += result.rowcount

        # Orphaned action queue entries
        result = conn.execute("""
            DELETE FROM action_queue
            WHERE app_id NOT IN (SELECT app_id FROM apps)
        """)
        healed += result.rowcount

        # Orphaned release history
        result = conn.execute("""
            DELETE FROM release_history
            WHERE app_id NOT IN (SELECT app_id FROM apps)
        """)
        healed += result.rowcount

        conn.commit()
        conn.close()

        return {"ok": True, "healed": healed, "detail": f"{healed} orphaned records entfernt"}

    # ------------------------------------------------------------------
    # Status
    # ------------------------------------------------------------------

    def get_status(self) -> dict:
        return {
            "cumulative_healed": self._healed_count,
            "error_log_size": self._error_log.total,
            "unresolved": len(self._error_log.get_unresolved()),
        }
