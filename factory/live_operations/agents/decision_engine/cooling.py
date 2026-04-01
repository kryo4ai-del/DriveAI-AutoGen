"""Cooling Manager -- verwaltet Cooling Periods nach Aktionen.

Nach jeder ausgefuehrten Aktion geht die App in eine Cooling Period.
Waehrend der Cooling Period werden keine neuen Entscheidungen getroffen.
"""

from datetime import datetime, timezone
from typing import Optional

from ...app_registry.database import AppRegistryDB
from . import config


class CoolingManager:
    """Verwaltet Cooling Periods ueber die App Registry."""

    def __init__(self, registry_db: Optional[AppRegistryDB] = None) -> None:
        self.db = registry_db or AppRegistryDB()

    def start_cooling(self, app_id: str, action_type: str) -> bool:
        """Cooling Period starten basierend auf Action Type."""
        duration_hours = config.COOLING_DURATIONS.get(action_type, 0)
        if duration_hours <= 0:
            print(f"[Cooling Manager] No cooling for action type '{action_type}'")
            return False

        try:
            self.db.set_cooling(app_id, action_type, duration_hours)
            print(f"[Cooling Manager] Started {action_type} cooling for {app_id} ({duration_hours}h)")
            return True
        except Exception as e:
            print(f"[Cooling Manager] Failed to start cooling: {e}")
            return False

    def is_cooling(self, app_id: str) -> bool:
        """Ist App in Cooling?"""
        try:
            return self.db.is_cooling(app_id)
        except Exception:
            return False

    def get_cooling_info(self, app_id: str) -> Optional[dict]:
        """Cooling Details (type, remaining_hours)."""
        try:
            info = self.db.get_cooling_info(app_id)
            if info:
                remaining_sec = info.get("remaining_seconds", 0)
                info["remaining_hours"] = round(remaining_sec / 3600, 1)
            return info
        except Exception:
            return None

    def get_remaining_hours(self, app_id: str) -> float:
        """Verbleibende Stunden."""
        info = self.get_cooling_info(app_id)
        if info:
            return info.get("remaining_hours", 0)
        return 0

    def clear_expired_cooling(self) -> int:
        """Abgelaufene Cooling Periods aufraeumen.

        Note: AppRegistryDB.get_cooling_info() already auto-clears expired
        cooling periods. This method explicitly checks all apps.
        """
        try:
            apps = self.db.get_all_apps()
        except Exception:
            return 0

        cleared = 0
        for app in apps:
            app_id = app.get("app_id", "")
            cooling_until = app.get("cooling_until")
            if not cooling_until:
                continue
            # get_cooling_info auto-clears expired
            info = self.db.get_cooling_info(app_id)
            if info is None and cooling_until:
                # Was expired and got cleared
                cleared += 1

        if cleared > 0:
            print(f"[Cooling Manager] Cleared {cleared} expired cooling periods")
        return cleared

    def override_cooling(self, app_id: str, reason: str = "") -> bool:
        """CEO-Override: Cooling vorzeitig beenden."""
        try:
            self.db.update_app(app_id, {"cooling_until": None, "cooling_type": None})
            label = f" ({reason})" if reason else ""
            print(f"[Cooling Manager] Override: Cooling for {app_id} ended{label}")
            return True
        except Exception as e:
            print(f"[Cooling Manager] Override failed: {e}")
            return False

    def get_all_cooling(self) -> list:
        """Alle Apps mit aktiver Cooling Period."""
        result = []
        try:
            apps = self.db.get_all_apps()
        except Exception:
            return result

        for app in apps:
            if self.is_cooling(app.get("app_id", "")):
                info = self.get_cooling_info(app["app_id"])
                if info:
                    info["app_id"] = app["app_id"]
                    info["app_name"] = app.get("app_name", "")
                    result.append(info)
        return result
