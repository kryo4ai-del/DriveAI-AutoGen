"""Migration: Create agent.json files from static AGENT_REGISTRY.

Reads the current static list and writes agent.json files next to each agent's .py file.
Run once: python -m factory.migrate_agent_identities
"""

import json
from pathlib import Path

# Import the static registry
from factory.agent_registry import AGENT_REGISTRY

PROJECT_ROOT = Path(__file__).resolve().parents[1]  # DriveAI-AutoGen/


def migrate():
    created = 0
    skipped = 0

    for agent in AGENT_REGISTRY:
        agent_file = agent.get("file", "")
        if not agent_file:
            print(f"  SKIP {agent['id']}: no file path")
            skipped += 1
            continue

        agent_path = PROJECT_ROOT / agent_file

        # Determine target directory and filename
        if agent_path.is_file():
            target_dir = agent_path.parent
            stem = agent_path.stem  # e.g. "trend_scout"
        elif agent_path.is_dir():
            target_dir = agent_path
            stem = agent_path.name
        else:
            # File doesn't exist — still create the json at expected location
            target_dir = agent_path.parent if "." in agent_path.name else agent_path
            stem = agent_path.stem if "." in agent_path.name else agent_path.name

        target_dir.mkdir(parents=True, exist_ok=True)

        # Always use agent_{stem}.json to avoid collisions
        json_name = f"agent_{stem}.json"

        json_path = target_dir / json_name

        # Don't overwrite existing
        if json_path.exists():
            print(f"  EXISTS {agent['id']}: {json_path.relative_to(PROJECT_ROOT)}")
            skipped += 1
            continue

        # Build agent.json content (only the identity fields, no internal _source stuff)
        identity = {
            "id": agent["id"],
            "name": agent["name"],
            "role": agent["role"],
            "department": agent["department"],
            "status": agent["status"],
        }

        # Optional fields
        for key in ["chapter", "task_type", "model_tier", "default_model", "provider",
                     "routing", "uses_web", "description"]:
            val = agent.get(key)
            if val is not None:
                identity[key] = val

        # py_file relative to target dir
        if agent_path.is_file():
            identity["py_file"] = agent_path.name

        json_path.write_text(json.dumps(identity, indent=2, ensure_ascii=False), encoding="utf-8")
        print(f"  CREATED {agent['id']}: {json_path.relative_to(PROJECT_ROOT)}")
        created += 1

    print(f"\n=== Migration Complete: {created} created, {skipped} skipped ===")


if __name__ == "__main__":
    print("=== Agent Identity Migration ===")
    migrate()
