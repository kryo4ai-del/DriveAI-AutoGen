# config/platform_role_resolver.py
# Resolves agent roles based on the target platform.

import json
import os

_PLATFORM_ROLES_DIR = os.path.join(os.path.dirname(__file__), "platform_roles")

# Agents whose system messages should be fully replaced or heavily augmented
_PLATFORM_SPECIFIC_AGENTS = frozenset({
    "ios_architect", "swift_developer", "test_generator",
    "android_architect", "kotlin_developer",
    "web_architect", "web_developer", "webapp_developer",
})

# Agents that get a context prefix but keep their core role
_PLATFORM_AGNOSTIC_AGENTS = frozenset({
    "driveai_lead", "reviewer", "bug_hunter", "refactor_agent",
    "creative_director", "ux_psychology", "product_strategist",
    "roadmap_agent", "content_script_agent", "change_watch_agent",
    "accessibility_agent", "opportunity_agent", "legal_risk_agent",
    "project_bootstrap_agent", "autonomous_project_orchestrator",
})


class PlatformRoleResolver:
    """Resolves agent roles based on the target platform.

    Takes a base agent role (from agent_roles.json) and enhances it
    with platform-specific instructions from platform_roles/<platform>.json.
    """

    def __init__(self, platform: str = "ios"):
        self.platform = platform
        self._config: dict = {}
        self._load()

    def _load(self):
        path = os.path.join(_PLATFORM_ROLES_DIR, f"{self.platform}.json")
        if os.path.isfile(path):
            with open(path, encoding="utf-8") as f:
                self._config = json.load(f)
        else:
            # Fallback: no platform file → use ios defaults
            ios_path = os.path.join(_PLATFORM_ROLES_DIR, "ios.json")
            if os.path.isfile(ios_path):
                with open(ios_path, encoding="utf-8") as f:
                    self._config = json.load(f)

    @property
    def context_line(self) -> str:
        return self._config.get("context_line", "")

    @property
    def task_prefix(self) -> str:
        return self._config.get("task_prefix", "")

    @property
    def language(self) -> str:
        return self._config.get("language", "swift")

    @property
    def framework(self) -> str:
        return self._config.get("framework", "swiftui")

    def resolve_role(self, agent_name: str, base_system_message: str) -> str:
        """Enhance a base system message with platform-specific context.

        For platform-specific agents: replace or heavily augment the system message.
        For platform-agnostic agents: prepend a context line.
        """
        overrides = self._config.get("role_overrides", {})

        # Check if this agent has a specific override
        if agent_name in overrides:
            override = overrides[agent_name]

            # Full replacement
            if "system_message_replace" in override:
                return override["system_message_replace"]

            # Append to existing
            if "system_message_append" in override:
                return base_system_message + override["system_message_append"]

        # Platform-agnostic agents get a context prefix
        ctx = self.context_line
        if ctx and agent_name not in _PLATFORM_SPECIFIC_AGENTS:
            return f"{ctx}\n\n{base_system_message}"

        return base_system_message

    def get_agent_name_for_platform(self, base_agent_name: str) -> str:
        """Map base agent name to platform-specific name if override exists."""
        overrides = self._config.get("role_overrides", {})
        if base_agent_name in overrides:
            override = overrides[base_agent_name]
            if "rename" in override:
                return override["rename"]
        return base_agent_name

    def get_task_with_platform_prefix(self, task: str) -> str:
        """Prepend platform build target instructions to a task."""
        prefix = self.task_prefix
        if prefix:
            return prefix + task
        return task
