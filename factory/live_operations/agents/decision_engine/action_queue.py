"""Action Queue Manager -- verwaltet priorisierte Aktions-Queue.

Entscheidungen werden nicht sofort ausgefuehrt sondern in eine
priorisierte Queue geschrieben. Pro App maximal 1 in_progress,
keine Duplikate gleichen Typs, Stale-Cleanup nach 7 Tagen.
"""

import uuid
from datetime import datetime, timezone, timedelta
from typing import Optional

from ...app_registry.database import AppRegistryDB


STALE_DAYS = 7  # Actions aelter als 7 Tage -> cancelled


class ActionQueueManager:
    """Verwaltet die Action Queue in der App Registry."""

    def __init__(self, registry_db: Optional[AppRegistryDB] = None) -> None:
        self.db = registry_db or AppRegistryDB()

    # ------------------------------------------------------------------
    # Enqueue
    # ------------------------------------------------------------------

    def enqueue(self, decision: dict) -> Optional[str]:
        """Entscheidung in Queue schreiben, returns action_id oder None bei Duplicate."""
        app_id = decision.get("app_id", "")
        action_type = decision.get("action_type", "none")

        if action_type == "none":
            return None

        # Duplicate check
        if self._check_duplicate(app_id, action_type):
            print(f"[Action Queue] Duplicate {action_type} for {app_id} -- skipped")
            return None

        severity = decision.get("data_summary", {}).get("max_severity", 0)
        recommendation = decision.get("recommendation", "")

        action_data = {
            "action_type": action_type,
            "severity_score": severity,
            "status": "pending",
            "briefing_document": recommendation,
        }

        try:
            action_id = self.db.add_action(app_id, action_data)
            print(f"[Action Queue] Enqueued {action_type} for {app_id} (severity={severity:.1f}, id={action_id})")
            return action_id
        except Exception as e:
            print(f"[Action Queue] Failed to enqueue: {e}")
            return None

    # ------------------------------------------------------------------
    # Queue Access
    # ------------------------------------------------------------------

    def get_next_action(self, app_id: str = None) -> Optional[dict]:
        """Hoechste Prioritaet aus Queue holen."""
        queue = self._prioritize_queue(app_id, status="pending")
        return queue[0] if queue else None

    def get_pending_count(self, app_id: str = None) -> int:
        """Anzahl offener Actions."""
        queue = self.get_queue(app_id, status="pending")
        return len(queue)

    def get_queue(self, app_id: str = None, status: str = "pending") -> list:
        """Queue anzeigen, gefiltert nach App und Status."""
        if status == "pending":
            try:
                return self.db.get_pending_actions(app_id)
            except Exception:
                return []

        # For non-pending statuses, query via _get_conn()
        try:
            conn = self.db._get_conn()
            if app_id:
                rows = conn.execute(
                    "SELECT * FROM action_queue WHERE app_id = ? AND status = ? ORDER BY severity_score DESC",
                    (app_id, status)
                ).fetchall()
            else:
                rows = conn.execute(
                    "SELECT * FROM action_queue WHERE status = ? ORDER BY severity_score DESC",
                    (status,)
                ).fetchall()
            conn.close()
            return [dict(r) for r in rows]
        except Exception:
            return []

    # ------------------------------------------------------------------
    # Status Updates
    # ------------------------------------------------------------------

    def start_action(self, action_id: str) -> bool:
        """Status auf 'in_progress' setzen."""
        try:
            self.db.update_action_status(action_id, "in_progress")
            print(f"[Action Queue] Started action {action_id}")
            return True
        except Exception as e:
            print(f"[Action Queue] Failed to start {action_id}: {e}")
            return False

    def complete_action(self, action_id: str, result: dict = None) -> bool:
        """Status auf 'completed' setzen."""
        try:
            self.db.update_action_status(action_id, "completed")
            print(f"[Action Queue] Completed action {action_id}")
            return True
        except Exception as e:
            print(f"[Action Queue] Failed to complete {action_id}: {e}")
            return False

    def cancel_action(self, action_id: str, reason: str = "") -> bool:
        """Status auf 'cancelled' setzen."""
        try:
            self.db.update_action_status(action_id, "cancelled")
            label = f" ({reason})" if reason else ""
            print(f"[Action Queue] Cancelled action {action_id}{label}")
            return True
        except Exception as e:
            print(f"[Action Queue] Failed to cancel {action_id}: {e}")
            return False

    # ------------------------------------------------------------------
    # Maintenance
    # ------------------------------------------------------------------

    def cleanup_stale_actions(self) -> int:
        """Actions aelter als 7 Tage mit Status 'pending' -> cancelled."""
        try:
            cutoff = (datetime.now(timezone.utc) - timedelta(days=STALE_DAYS)).isoformat()
            conn = self.db._get_conn()
            stale = conn.execute(
                "SELECT action_id FROM action_queue WHERE status = 'pending' AND created_at < ?",
                (cutoff,)
            ).fetchall()
            conn.close()

            count = 0
            for row in stale:
                aid = row["action_id"] if isinstance(row, dict) else row[0]
                self.cancel_action(aid, "stale")
                count += 1

            if count > 0:
                print(f"[Action Queue] Cleaned up {count} stale actions")
            return count
        except Exception as e:
            print(f"[Action Queue] Cleanup error: {e}")
            return 0

    # ------------------------------------------------------------------
    # Internal
    # ------------------------------------------------------------------

    def _check_duplicate(self, app_id: str, action_type: str) -> bool:
        """Verhindert doppelte Actions gleichen Typs fuer gleiche App."""
        try:
            pending = self.db.get_pending_actions(app_id)
            for action in pending:
                if action.get("action_type") == action_type:
                    return True
        except Exception:
            pass
        return False

    def _prioritize_queue(self, app_id: str = None, status: str = "pending") -> list:
        """Queue nach Severity sortiert zurueckgeben."""
        queue = self.get_queue(app_id, status)
        queue.sort(key=lambda a: a.get("severity_score", 0), reverse=True)
        return queue
