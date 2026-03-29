"""Config Consistency Checker.

Prueft die Konsistenz zwischen:
- agent_roles.json (zentrale Rollen-Definition)
- agent_toggles.json (An/Aus-Schalter)
- agent_registry.json (Master-Registry)
- Tatsaechliche agent*.json Dateien im Dateisystem

Findet:
- Tote Agents (in Roles aber keine Datei)
- Verwaiste Agents (Datei existiert aber nicht in Roles)
- Toggle-Mismatches (Toggle fuer nicht existierende Rolle)
- Registry-Drifts (Registry nicht synchron mit Dateien)
- Fehlende Pflichtfelder in agent.json

Rein deterministisch, kein LLM.
"""

import json
import logging
from pathlib import Path

logger = logging.getLogger(__name__)

PROJECT_ROOT = Path(__file__).resolve().parents[3]

REQUIRED_AGENT_FIELDS = {"id", "name", "role", "status"}


def check_consistency(config: dict) -> dict:
    """Run all consistency checks and return findings."""
    findings = []

    roles = _load_json(PROJECT_ROOT / "config" / "agent_roles.json", {})
    toggles = _load_json(PROJECT_ROOT / "config" / "agent_toggles.json", {})
    registry = _load_json(PROJECT_ROOT / "factory" / "agent_registry.json", {"agents": []})
    registry_agents = registry.get("agents", [])

    # Collect all agent*.json files from filesystem
    agent_files = _find_agent_files()

    # --- Check 1: Roles without matching agent file ---
    agent_ids_in_files = set()
    for af in agent_files:
        data = _load_json(af, {})
        if data.get("id"):
            agent_ids_in_files.add(data["id"])

    # Map role keys to see what's referenced
    role_keys = set(roles.keys())
    toggle_keys = set(toggles.keys())

    # --- Check 2: Toggles without matching role ---
    orphan_toggles = toggle_keys - role_keys
    for t in sorted(orphan_toggles):
        findings.append({
            "type": "orphan_toggle",
            "severity": "yellow",
            "message": f"Toggle '{t}' hat keine Rolle in agent_roles.json",
            "key": t,
        })

    # --- Check 3: Roles without toggle ---
    roles_without_toggle = role_keys - toggle_keys
    for r in sorted(roles_without_toggle):
        findings.append({
            "type": "missing_toggle",
            "severity": "yellow",
            "message": f"Rolle '{r}' hat keinen Toggle in agent_toggles.json",
            "key": r,
        })

    # --- Check 4: Agent files with missing required fields ---
    for af in agent_files:
        data = _load_json(af, {})
        rel = af.relative_to(PROJECT_ROOT).as_posix()
        missing = REQUIRED_AGENT_FIELDS - set(data.keys())
        if missing:
            findings.append({
                "type": "missing_fields",
                "severity": "yellow",
                "message": f"{rel}: Fehlende Pflichtfelder: {', '.join(sorted(missing))}",
                "file": rel,
                "missing": sorted(missing),
            })

    # --- Check 5: Registry vs filesystem drift ---
    registry_sources = {a.get("_source", "").replace("\\", "/") for a in registry_agents if a.get("_source")}
    filesystem_rels = {af.relative_to(PROJECT_ROOT).as_posix() for af in agent_files}

    # Files in filesystem but not in registry
    unregistered = filesystem_rels - registry_sources
    # Filter out agent_registry.json itself and config files
    unregistered = {u for u in unregistered if not u.startswith("config/") and u != "factory/agent_registry.json"}
    if unregistered:
        findings.append({
            "type": "unregistered_agents",
            "severity": "yellow",
            "message": f"{len(unregistered)} Agent-Dateien nicht in agent_registry.json: {', '.join(sorted(list(unregistered)[:5]))}",
            "files": sorted(unregistered),
            "count": len(unregistered),
        })

    # Entries in registry but file doesn't exist
    for agent in registry_agents:
        source = agent.get("_source", "").replace("\\", "/")
        if source and not (PROJECT_ROOT / source).exists():
            findings.append({
                "type": "ghost_registry_entry",
                "severity": "red",
                "message": f"Registry-Eintrag '{agent.get('name', '?')}' zeigt auf fehlende Datei: {source}",
                "agent_id": agent.get("id"),
                "missing_file": source,
            })

    # --- Check 6: Duplicate agent IDs ---
    id_map = {}
    for af in agent_files:
        data = _load_json(af, {})
        aid = data.get("id")
        if aid:
            rel = af.relative_to(PROJECT_ROOT).as_posix()
            id_map.setdefault(aid, []).append(rel)
    for aid, paths in id_map.items():
        if len(paths) > 1:
            findings.append({
                "type": "duplicate_agent_id",
                "severity": "red",
                "message": f"Agent-ID '{aid}' existiert in {len(paths)} Dateien: {', '.join(paths[:5])}",
                "agent_id": aid,
                "files": paths,
            })

    # --- Check 7: Inactive agents still referenced ---
    disabled_roles = {k for k, v in toggles.items() if v is False}
    for agent in registry_agents:
        if agent.get("status") == "active":
            # Check if any toggle matches this agent name pattern
            name_lower = agent.get("name", "").lower().replace(" ", "_")
            for dr in disabled_roles:
                if dr in name_lower or name_lower in dr:
                    findings.append({
                        "type": "toggle_status_mismatch",
                        "severity": "yellow",
                        "message": f"Agent '{agent.get('name')}' ist active aber Toggle '{dr}' ist deaktiviert",
                        "agent_id": agent.get("id"),
                        "toggle": dr,
                    })

    # Summary stats
    total_roles = len(role_keys)
    total_toggles = len(toggle_keys)
    total_files = len(agent_files)
    total_registry = len(registry_agents)

    logger.info("Consistency check: %d roles, %d toggles, %d files, %d registry, %d findings",
                total_roles, total_toggles, total_files, total_registry, len(findings))

    return {
        "findings": findings,
        "stats": {
            "total_roles": total_roles,
            "total_toggles": total_toggles,
            "total_agent_files": total_files,
            "total_registry_entries": total_registry,
            "finding_count": len(findings),
        },
    }


def _find_agent_files() -> list:
    """Find all agent*.json files in the project."""
    files = []
    for pattern in ("**/agent.json", "**/agent_*.json"):
        for f in PROJECT_ROOT.glob(pattern):
            # Skip node_modules, .git, quarantine, output dirs
            rel = f.relative_to(PROJECT_ROOT).as_posix()
            if any(skip in rel for skip in ("node_modules/", ".git/", "quarantine/", "/output/")):
                continue
            # Skip the master registry itself
            if rel == "factory/agent_registry.json":
                continue
            files.append(f)
    return sorted(set(files))


def _load_json(path: Path, fallback):
    """Load JSON file with fallback."""
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except Exception:
        return fallback
