"""Live Operations Tools fuer den HQ Assistant.

Gibt dem Assistant Zugriff auf Live Ops Daten:
- Escalation Log abfragen
- Action Queue Status
- Health Scores
- Cooling Status
"""

import os
import json
from typing import Optional


def get_escalation_recent(limit: int = 10) -> list:
    """Letzte Eskalationen fuer den Assistant."""
    try:
        from factory.live_operations.agents.escalation.manager import EscalationManager
        mgr = EscalationManager()
        return mgr.get_recent(limit)
    except Exception as e:
        return [{"error": str(e)}]


def get_escalation_stats() -> dict:
    """Eskalations-Statistiken."""
    try:
        from factory.live_operations.agents.escalation.manager import EscalationManager
        mgr = EscalationManager()
        return mgr.log.get_stats()
    except Exception as e:
        return {"error": str(e)}


def get_ceo_pending() -> list:
    """Offene CEO-Eskalationen."""
    try:
        from factory.live_operations.agents.escalation.manager import EscalationManager
        mgr = EscalationManager()
        return mgr.get_ceo_pending()
    except Exception as e:
        return [{"error": str(e)}]


def get_action_queue_status(app_id: str = None) -> dict:
    """Action Queue Status fuer eine App oder alle."""
    try:
        from factory.live_operations.agents.decision_engine.action_queue import ActionQueueManager
        queue = ActionQueueManager()
        pending = queue.get_queue(app_id, status="pending")
        in_progress = queue.get_queue(app_id, status="in_progress")
        return {
            "pending_count": len(pending),
            "in_progress_count": len(in_progress),
            "pending": pending[:5],
            "in_progress": in_progress[:3],
        }
    except Exception as e:
        return {"error": str(e)}


def get_app_health(app_id: str) -> dict:
    """Health Score und Zone fuer eine App."""
    try:
        from factory.live_operations.app_registry.database import AppRegistryDB
        db = AppRegistryDB()
        app = db.get_app(app_id)
        if not app:
            return {"error": f"App {app_id} not found"}
        return {
            "app_id": app_id,
            "health_score": app.get("health_score", 0),
            "health_zone": app.get("health_zone", "unknown"),
            "current_version": app.get("current_version", "?"),
        }
    except Exception as e:
        return {"error": str(e)}


def get_cooling_status(app_id: str = None) -> list:
    """Cooling Status fuer eine App oder alle."""
    try:
        from factory.live_operations.agents.decision_engine.cooling import CoolingManager
        cm = CoolingManager()
        if app_id:
            info = cm.get_cooling_info(app_id)
            return [info] if info else []
        return cm.get_all_cooling()
    except Exception as e:
        return [{"error": str(e)}]


# Tool registry for HQ Assistant integration
LIVEOPS_TOOLS = {
    "liveops_escalation_recent": {
        "function": get_escalation_recent,
        "description": "Zeigt die letzten Eskalationen an",
        "parameters": {"limit": "int (default 10)"},
    },
    "liveops_escalation_stats": {
        "function": get_escalation_stats,
        "description": "Eskalations-Statistiken (Anzahl nach Level, Quelle)",
        "parameters": {},
    },
    "liveops_ceo_pending": {
        "function": get_ceo_pending,
        "description": "Offene CEO-Eskalationen die Aufmerksamkeit brauchen",
        "parameters": {},
    },
    "liveops_action_queue": {
        "function": get_action_queue_status,
        "description": "Action Queue Status (pending/in_progress)",
        "parameters": {"app_id": "str (optional)"},
    },
    "liveops_app_health": {
        "function": get_app_health,
        "description": "Health Score und Zone einer App",
        "parameters": {"app_id": "str"},
    },
    "liveops_cooling_status": {
        "function": get_cooling_status,
        "description": "Cooling Status (aktive Cooling Periods)",
        "parameters": {"app_id": "str (optional)"},
    },
}
