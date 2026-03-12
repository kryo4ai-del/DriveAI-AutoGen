"""
Store Reader — reads all factory JSON stores.
Handles path resolution for both local dev and Docker deployment.
Designed for robustness: missing files, empty stores, and malformed JSON
are handled gracefully — never raises exceptions to the caller.
"""

import json
import os
from datetime import datetime, timezone
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

    STORE_MAP = {
        "ideas": ("factory/ideas/idea_store.json", "ideas"),
        "projects": ("factory/projects/project_registry.json", "projects"),
        "specs": ("factory/specs/spec_store.json", "specs"),
        "content": ("content/content_store.json", "content"),
        "watch_events": ("watch/watch_events.json", "events"),
        "accessibility": ("accessibility/accessibility_reports.json", "reports"),
        "compliance": ("compliance/compliance_reports.json", "reports"),
        "opportunities": ("opportunities/opportunity_store.json", "opportunities"),
        "orchestration": ("orchestration/orchestration_plan_store.json", "plans"),
        "bootstrap": ("bootstrap/project_store.json", "projects"),
        "improvements": ("improvements/improvement_proposals.json", "proposals"),
        "trends": ("trends/trend_store.json", "trends"),
        "briefings": ("briefings/briefing_store.json", "briefings"),
        "radar_sources": ("radar/radar_sources.json", "sources"),
        "radar_hits": ("radar/radar_hits.json", "hits"),
        "cost_usage": ("costs/cost_usage.json", "usage"),
        "cost_summaries": ("costs/cost_summary.json", "summaries"),
        "strategy_reports": ("strategy/weekly_reports.json", "reports"),
        "graph_nodes": ("research_graph/graph_nodes.json", "nodes"),
        "graph_edges": ("research_graph/graph_edges.json", "edges"),
        "research_reports": ("research/research_reports.json", "reports"),
    }

    def __init__(self):
        self.root = _find_factory_root()

    @property
    def root_path(self) -> str:
        return str(self.root)

    def _load(self, rel_path: str, key: str) -> list[dict]:
        path = self.root / rel_path
        if not path.exists():
            return []
        try:
            text = path.read_text(encoding="utf-8").strip()
            if not text:
                return []
            data = json.loads(text)
            result = data.get(key, [])
            return result if isinstance(result, list) else []
        except (json.JSONDecodeError, KeyError, OSError, TypeError):
            return []

    def _store_mtime(self, rel_path: str) -> datetime | None:
        path = self.root / rel_path
        if not path.exists():
            return None
        try:
            return datetime.fromtimestamp(path.stat().st_mtime, tz=timezone.utc)
        except OSError:
            return None

    # --- Store accessors ---

    def ideas(self) -> list[dict]:
        return self._load(*self.STORE_MAP["ideas"])

    def projects(self) -> list[dict]:
        return self._load(*self.STORE_MAP["projects"])

    def specs(self) -> list[dict]:
        return self._load(*self.STORE_MAP["specs"])

    def content(self) -> list[dict]:
        return self._load(*self.STORE_MAP["content"])

    def watch_events(self) -> list[dict]:
        return self._load(*self.STORE_MAP["watch_events"])

    def accessibility(self) -> list[dict]:
        return self._load(*self.STORE_MAP["accessibility"])

    def compliance(self) -> list[dict]:
        return self._load(*self.STORE_MAP["compliance"])

    def opportunities(self) -> list[dict]:
        return self._load(*self.STORE_MAP["opportunities"])

    def orchestration(self) -> list[dict]:
        return self._load(*self.STORE_MAP["orchestration"])

    def bootstrap(self) -> list[dict]:
        return self._load(*self.STORE_MAP["bootstrap"])

    def improvements(self) -> list[dict]:
        return self._load(*self.STORE_MAP["improvements"])

    def trends(self) -> list[dict]:
        return self._load(*self.STORE_MAP["trends"])

    def briefings(self) -> list[dict]:
        return self._load(*self.STORE_MAP["briefings"])

    def radar_sources(self) -> list[dict]:
        return self._load(*self.STORE_MAP["radar_sources"])

    def radar_hits(self) -> list[dict]:
        return self._load(*self.STORE_MAP["radar_hits"])

    def cost_usage(self) -> list[dict]:
        return self._load(*self.STORE_MAP["cost_usage"])

    def cost_summaries(self) -> list[dict]:
        return self._load(*self.STORE_MAP["cost_summaries"])

    def strategy_reports(self) -> list[dict]:
        return self._load(*self.STORE_MAP["strategy_reports"])

    def graph_nodes(self) -> list[dict]:
        return self._load(*self.STORE_MAP["graph_nodes"])

    def graph_edges(self) -> list[dict]:
        return self._load(*self.STORE_MAP["graph_edges"])

    def research_reports(self) -> list[dict]:
        return self._load(*self.STORE_MAP["research_reports"])

    def cost_budgets(self) -> dict:
        path = self.root / "config" / "cost_budgets.json"
        if not path.exists():
            return {}
        try:
            data = json.loads(path.read_text(encoding="utf-8"))
            return data if isinstance(data, dict) else {}
        except (json.JSONDecodeError, OSError):
            return {}

    def model_routing(self) -> dict:
        path = self.root / "config" / "model_routing.json"
        if not path.exists():
            return {}
        try:
            data = json.loads(path.read_text(encoding="utf-8"))
            return data.get("routes", {}) if isinstance(data, dict) else {}
        except (json.JSONDecodeError, OSError):
            return {}

    # --- Memory accessor ---

    def memory(self) -> dict[str, list[dict]]:
        """Load agent memory store. Returns dict with category keys, each a list of entries."""
        path = self.root / "memory" / "memory_store.json"
        if not path.exists():
            return {}
        try:
            text = path.read_text(encoding="utf-8").strip()
            if not text:
                return {}
            data = json.loads(text)
            if not isinstance(data, dict):
                return {}
            # Only return categories that are lists of dicts
            return {k: v for k, v in data.items() if isinstance(v, list)}
        except (json.JSONDecodeError, OSError, TypeError):
            return {}

    def memory_mtime(self) -> str:
        mtime = self._store_mtime("memory/memory_store.json")
        return mtime.strftime("%Y-%m-%d %H:%M UTC") if mtime else "—"

    # --- Config accessors ---

    def agent_toggles(self) -> dict:
        path = self.root / "config" / "agent_toggles.json"
        if not path.exists():
            return {}
        try:
            data = json.loads(path.read_text(encoding="utf-8"))
            return data if isinstance(data, dict) else {}
        except (json.JSONDecodeError, OSError):
            return {}

    def agent_roles(self) -> dict:
        path = self.root / "config" / "agent_roles.json"
        if not path.exists():
            return {}
        try:
            data = json.loads(path.read_text(encoding="utf-8"))
            return data if isinstance(data, dict) else {}
        except (json.JSONDecodeError, OSError):
            return {}

    # --- Health / meta ---

    def store_health(self) -> dict[str, dict]:
        """Return health info for each store: exists, count, last_modified."""
        result = {}
        for name, (rel_path, key) in self.STORE_MAP.items():
            path = self.root / rel_path
            exists = path.exists()
            items = self._load(rel_path, key) if exists else []
            mtime = self._store_mtime(rel_path)
            result[name] = {
                "exists": exists,
                "count": len(items),
                "last_modified": mtime.strftime("%Y-%m-%d %H:%M UTC") if mtime else "—",
                "path": rel_path,
            }
        return result

    def factory_root_valid(self) -> bool:
        """Check if the factory root looks like a valid DriveAI-AutoGen repo."""
        markers = ["config/agent_toggles.json", "factory/ideas/idea_store.json", "main.py"]
        return any((self.root / m).exists() for m in markers)

    def latest_store_update(self) -> str:
        """Return the most recent modification timestamp across all stores."""
        latest = None
        for _, (rel_path, _) in self.STORE_MAP.items():
            mtime = self._store_mtime(rel_path)
            if mtime and (latest is None or mtime > latest):
                latest = mtime
        if latest:
            return latest.strftime("%Y-%m-%d %H:%M UTC")
        return "—"
