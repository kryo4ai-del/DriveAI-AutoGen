"""
Store Reader — reads all factory JSON stores.
Handles the path resolution for both local dev and Docker deployment.
"""

import json
import os
from pathlib import Path


def _find_factory_root() -> Path:
    """
    Resolve the factory root directory.
    Priority:
      1. FACTORY_ROOT env var (set in Docker)
      2. Parent of control_center/ (local dev)
    """
    env_root = os.environ.get("FACTORY_ROOT")
    if env_root:
        return Path(env_root)
    return Path(__file__).resolve().parent.parent


class StoreReader:
    """Read-only access to all factory JSON stores."""

    def __init__(self):
        self.root = _find_factory_root()

    def _load(self, rel_path: str, key: str) -> list[dict]:
        path = self.root / rel_path
        if not path.exists():
            return []
        try:
            data = json.loads(path.read_text(encoding="utf-8"))
            return data.get(key, [])
        except (json.JSONDecodeError, KeyError):
            return []

    def ideas(self) -> list[dict]:
        return self._load("factory/ideas/idea_store.json", "ideas")

    def projects(self) -> list[dict]:
        return self._load("factory/projects/project_registry.json", "projects")

    def specs(self) -> list[dict]:
        return self._load("factory/specs/spec_store.json", "specs")

    def content(self) -> list[dict]:
        return self._load("content/content_store.json", "content")

    def watch_events(self) -> list[dict]:
        return self._load("watch/watch_events.json", "events")

    def accessibility(self) -> list[dict]:
        return self._load("accessibility/accessibility_reports.json", "reports")

    def compliance(self) -> list[dict]:
        return self._load("compliance/compliance_reports.json", "reports")

    def opportunities(self) -> list[dict]:
        return self._load("opportunities/opportunity_store.json", "opportunities")

    def orchestration(self) -> list[dict]:
        return self._load("orchestration/orchestration_plan_store.json", "plans")

    def bootstrap(self) -> list[dict]:
        return self._load("bootstrap/project_store.json", "projects")

    def agent_toggles(self) -> dict:
        path = self.root / "config" / "agent_toggles.json"
        if not path.exists():
            return {}
        try:
            return json.loads(path.read_text(encoding="utf-8"))
        except (json.JSONDecodeError, KeyError):
            return {}

    def agent_roles(self) -> dict:
        path = self.root / "config" / "agent_roles.json"
        if not path.exists():
            return {}
        try:
            return json.loads(path.read_text(encoding="utf-8"))
        except (json.JSONDecodeError, KeyError):
            return {}
