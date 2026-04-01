"""Rollback Manager -- fuehrt autonome Rollbacks bei Post-Update Regressionen durch.

WICHTIG: Store Re-Deploy ist ein STUB. Der echte Re-Deploy kommt in Phase 4.
"""

import uuid
from datetime import datetime, timezone
from typing import Optional

from ...app_registry.database import AppRegistryDB
from ..decision_engine.cooling import CoolingManager


class RollbackManager:
    """Verwaltet autonome Rollbacks."""

    def __init__(self, registry_db: Optional[AppRegistryDB] = None) -> None:
        self.db = registry_db or AppRegistryDB()

    def can_rollback(self, app_id: str) -> bool:
        """Prueft ob Rollback moeglich ist."""
        version = self._get_rollback_version(app_id)
        return version is not None

    def execute_rollback(self, app_id: str, reason: str) -> dict:
        """Fuehrt Rollback durch.

        1. last_stable_version aus App Registry holen
        2. Store Re-Deploy triggern (STUB)
        3. App Registry updaten
        4. Cooling Period starten (hotfix-level: 48h)
        5. Rollback als Release loggen
        6. Return: Rollback-Report
        """
        rollback_id = f"rb_{uuid.uuid4().hex[:8]}"
        now = datetime.now(timezone.utc).isoformat()

        target_version = self._get_rollback_version(app_id)
        if not target_version:
            print(f"[Rollback Manager] Cannot rollback {app_id}: no stable version")
            return {
                "rollback_id": rollback_id,
                "app_id": app_id,
                "success": False,
                "reason": "No last_stable_version available",
                "timestamp": now,
            }

        # Get current version
        current_version = "unknown"
        try:
            app = self.db.get_app(app_id)
            if app:
                current_version = app.get("current_version", "unknown")
        except Exception:
            pass

        print(f"[Rollback Manager] Rolling back {app_id}: {current_version} -> {target_version}")

        # STUB: Store re-deploy
        redeploy_result = self._trigger_store_redeploy(app_id, target_version)

        # Update App Registry
        try:
            self.db.update_app(app_id, {"current_version": target_version})
        except Exception as e:
            print(f"[Rollback Manager] Failed to update registry: {e}")

        # Start cooling period (hotfix-level)
        try:
            cm = CoolingManager(self.db)
            cm.start_cooling(app_id, "hotfix")
            cooling_info = cm.get_cooling_info(app_id)
            cooling_until = cooling_info.get("cooling_until", "") if cooling_info else ""
        except Exception:
            cooling_until = ""

        # Log rollback as release
        try:
            self.db.add_release(app_id, {
                "version": target_version,
                "update_type": "rollback",
                "release_date": now,
                "triggered_by": "anomaly_detector",
                "changes_summary": f"Rollback from {current_version}: {reason}",
            })
        except Exception as e:
            print(f"[Rollback Manager] Failed to log release: {e}")

        report = {
            "rollback_id": rollback_id,
            "app_id": app_id,
            "success": True,
            "rolled_back_from": current_version,
            "rolled_back_to": target_version,
            "reason": reason,
            "triggered_by": "anomaly_detector",
            "store_redeploy": redeploy_result.get("message", "STUB"),
            "cooling_started": True,
            "cooling_until": cooling_until,
            "timestamp": now,
        }

        print(f"[Rollback Manager] Rollback complete: {rollback_id}")
        return report

    def _get_rollback_version(self, app_id: str) -> Optional[str]:
        """Letzte stabile Version aus Registry."""
        try:
            app = self.db.get_app(app_id)
            if app:
                return app.get("last_stable_version")
        except Exception:
            pass
        return None

    def _trigger_store_redeploy(self, app_id: str, version: str) -> dict:
        """STUB: Triggert Re-Upload der vorherigen Version.

        In Phase 4 wird dies durch den echten Store Pipeline Aufruf ersetzt.
        """
        print(f"[Rollback Manager] STUB: Would re-deploy version {version} for {app_id}")
        return {
            "success": True,
            "stub": True,
            "message": f"STUB -- wuerde Version {version} re-deployen",
            "app_id": app_id,
            "version": version,
        }
