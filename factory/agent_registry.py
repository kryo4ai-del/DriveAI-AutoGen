"""Central Agent Registry — Auto-Discovery from agent*.json files.

Scans known directories for agent.json / agent_*.json identity files.
Falls back to static FALLBACK_REGISTRY if no files found.
"""

import json
import logging
from pathlib import Path

logger = logging.getLogger(__name__)

PROJECT_ROOT = Path(__file__).resolve().parents[1]  # DriveAI-AutoGen/

# Directories to scan for agent*.json files
SCAN_ROOTS = [
    "agents",
    "factory/pre_production/agents",
    "factory/pre_production",
    "factory/market_strategy/agents",
    "factory/mvp_scope/agents",
    "factory/design_vision/agents",
    "factory/visual_audit/agents",
    "factory/roadbook_assembly/agents",
    "factory/document_secretary",
    "factory/hq",
    "factory/hq/assistant",
    "factory/pipeline",
    "factory/mac_bridge",
    "factory/lines/ios",
    "factory/lines/android",
    "factory/lines/web",
    "factory/lines/unity",
    "factory",
    "factory/asset_forge",
    "factory/motion_forge",
    "factory/sound_forge",
    "factory/scene_forge",
    "factory/qa_forge",
    "factory/store_prep",
    "factory/store",
    "factory/signing",
    "factory/integration",
    "factory/evolution_loop",
    "factory/name_gate",
    "factory/brain",
    "factory/brain/memory",
    "factory/live_operations/test_harness",
    "factory/live_operations/self_healing",
    "factory/live_operations/reporting",
    "mac_agent",
    "mac_agent/repair",
    "briefings",
]

_CACHED_AGENTS = None


def _discover_dirs() -> set:
    """Build set of all directories to scan."""
    dirs = set()
    for d in SCAN_ROOTS:
        full = PROJECT_ROOT / d
        if full.exists() and full.is_dir():
            dirs.add(full)

    # Also scan factory/hq/** recursively (catches new departments)
    hq = PROJECT_ROOT / "factory" / "hq"
    if hq.exists():
        for sub in hq.rglob("*"):
            if sub.is_dir() and "__pycache__" not in str(sub) and "node_modules" not in str(sub):
                dirs.add(sub)

    # Also scan factory/**/agents/ dirs (and their subdirectories)
    factory = PROJECT_ROOT / "factory"
    if factory.exists():
        for ad in factory.rglob("agents"):
            if ad.is_dir() and "__pycache__" not in str(ad):
                dirs.add(ad)
                for sub in ad.iterdir():
                    if sub.is_dir() and "__pycache__" not in str(sub):
                        dirs.add(sub)

    return dirs


def _scan_for_agents() -> list:
    """Scan all directories for agent*.json files."""
    agents = []
    seen_ids = set()

    for scan_dir in sorted(_discover_dirs()):
        for jf in scan_dir.glob("agent*.json"):
            if not jf.name.startswith("agent") or jf.suffix != ".json":
                continue
            # Skip agent_registry.json itself
            if jf.name == "agent_registry.json":
                continue
            try:
                data = json.loads(jf.read_text(encoding="utf-8"))
                if not isinstance(data, dict):
                    continue
                # Must have required fields
                if not all(k in data for k in ("id", "name", "role", "department", "status")):
                    continue
                if data["id"] in seen_ids:
                    continue
                seen_ids.add(data["id"])
                data["_source"] = str(jf.relative_to(PROJECT_ROOT))
                agents.append(data)
            except (json.JSONDecodeError, OSError, ValueError):
                continue

    agents.sort(key=lambda a: (a.get("department", ""), a.get("id", "")))
    return agents


def _get_registry(force_refresh: bool = False) -> list:
    global _CACHED_AGENTS
    if _CACHED_AGENTS is None or force_refresh:
        scanned = _scan_for_agents()
        if scanned:
            _CACHED_AGENTS = scanned
        else:
            logger.warning("No agent.json files found — using fallback")
            _CACHED_AGENTS = _load_fallback()
    return _CACHED_AGENTS


def _load_fallback() -> list:
    """Load from static agent_registry.json if it exists."""
    fallback = PROJECT_ROOT / "factory" / "agent_registry.json"
    if fallback.exists():
        try:
            data = json.loads(fallback.read_text(encoding="utf-8"))
            return data.get("agents", [])
        except Exception:
            pass
    return []


def refresh():
    """Invalidate cache — next call rescans."""
    global _CACHED_AGENTS
    _CACHED_AGENTS = None


# ── Public API ──

def get_all_agents() -> list:
    return _get_registry()

def get_active_agents() -> list:
    return [a for a in _get_registry() if a["status"] == "active"]

def get_agents_by_department(department: str) -> list:
    return [a for a in _get_registry() if a["department"] == department]

def get_agents_by_provider(provider: str) -> list:
    return [a for a in _get_registry() if a.get("provider") == provider]

def get_agents_by_chapter(chapter: str) -> list:
    return [a for a in _get_registry() if a.get("chapter") and chapter.lower() in str(a["chapter"]).lower()]

def get_agent_by_id(agent_id: str) -> dict:
    for a in _get_registry():
        if a["id"] == agent_id:
            return a
    return None

def get_summary() -> dict:
    all_a = _get_registry()
    active = [a for a in all_a if a["status"] == "active"]
    disabled = [a for a in all_a if a["status"] == "disabled"]
    planned = [a for a in all_a if a["status"] == "planned"]
    by_dept, by_provider, by_model = {}, {}, {}
    for a in all_a:
        by_dept[a["department"]] = by_dept.get(a["department"], 0) + 1
        p = a.get("provider") or "none"
        by_provider[p] = by_provider.get(p, 0) + 1
        m = a.get("default_model") or "none"
        by_model[m] = by_model.get(m, 0) + 1
    return {
        "total": len(all_a), "active": len(active),
        "disabled": len(disabled), "planned": len(planned),
        "by_department": by_dept, "by_provider": by_provider, "by_model": by_model,
    }

def export_json(path: str = None):
    """Export scanned registry as JSON for Dashboard."""
    if path is None:
        path = str(PROJECT_ROOT / "factory" / "agent_registry.json")
    Path(path).write_text(json.dumps({
        "agents": _get_registry(force_refresh=True),
        "summary": get_summary(),
    }, indent=2, ensure_ascii=False), encoding="utf-8")
    return path
