# agent_toggle_config.py
# Loads agent enable/disable state from agent_toggles.json.

import json
import os

_TOGGLES_PATH = os.path.join(os.path.dirname(__file__), "agent_toggles.json")

# Canonical agent order used everywhere for consistent output
ALL_AGENTS = [
    "driveai_lead",
    "product_strategist",
    "roadmap_agent",
    "ios_architect",
    "swift_developer",
    "reviewer",
    "bug_hunter",
    "refactor_agent",
    "test_generator",
    "content_script_agent",
    "change_watch_agent",
    "accessibility_agent",
    "opportunity_agent",
]

# These agents are always force-enabled regardless of config or CLI flags
CORE_AGENTS = {"driveai_lead", "swift_developer"}


def load_agent_toggles() -> dict[str, bool]:
    """
    Load agent_toggles.json. Returns all-enabled defaults on any failure.
    """
    try:
        with open(_TOGGLES_PATH, encoding="utf-8") as f:
            data = json.load(f)
        if not isinstance(data, dict):
            return {name: True for name in ALL_AGENTS}
        return {name: bool(data.get(name, True)) for name in ALL_AGENTS}
    except (FileNotFoundError, json.JSONDecodeError):
        return {name: True for name in ALL_AGENTS}


def resolve_agent_toggles(
    overrides: dict[str, bool] | None = None,
) -> tuple[list[str], list[str]]:
    """
    Load toggles from JSON, apply overrides, force-enable core agents.

    Returns:
        (active_agents, disabled_agents) — both as ordered lists.

    Core agents (driveai_lead, swift_developer) are always force-enabled.
    """
    toggles = load_agent_toggles()

    if overrides:
        for name, state in overrides.items():
            if name in toggles:
                toggles[name] = state

    # Core agents are always on
    for name in CORE_AGENTS:
        toggles[name] = True

    active = [n for n in ALL_AGENTS if toggles[n]]
    disabled = [n for n in ALL_AGENTS if not toggles[n]]
    return active, disabled


def is_agent_enabled(agent_name: str, overrides: dict[str, bool] | None = None) -> bool:
    active, _ = resolve_agent_toggles(overrides)
    return agent_name in active
