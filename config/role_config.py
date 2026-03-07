# role_config.py
# Loads agent role configuration from agent_roles.json.

import json
import os

_ROLES_PATH = os.path.join(os.path.dirname(__file__), "agent_roles.json")

_FALLBACK_ROLE = {
    "description": "AI assistant agent for the DriveAI project.",
    "system_message": "You are an AI assistant for the DriveAI iOS project.",
}

_cache: dict | None = None


def load_agent_roles() -> dict:
    """Load and cache agent_roles.json. Returns empty dict on failure."""
    global _cache
    if _cache is not None:
        return _cache
    try:
        with open(_ROLES_PATH, encoding="utf-8") as f:
            _cache = json.load(f)
    except (FileNotFoundError, json.JSONDecodeError):
        _cache = {}
    return _cache


def get_agent_role(agent_name: str) -> dict:
    """
    Return {"description": ..., "system_message": ...} for the given agent.
    Falls back to _FALLBACK_ROLE if the agent is not found.
    """
    roles = load_agent_roles()
    role = roles.get(agent_name)
    if not role or not isinstance(role, dict):
        return dict(_FALLBACK_ROLE)
    return {
        "description": role.get("description") or _FALLBACK_ROLE["description"],
        "system_message": role.get("system_message") or _FALLBACK_ROLE["system_message"],
    }
