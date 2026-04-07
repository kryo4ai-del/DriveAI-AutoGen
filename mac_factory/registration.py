"""
DriveAI Mac Factory — Agent Self-Registration

Registers all Mac agents with the Windows central registry on startup.
Falls back to local registration_pending.json if Windows unreachable.
"""

import json
import socket
from pathlib import Path
from datetime import datetime, timezone


MAC_AGENTS = [
    {
        "agent_id": "MAC-01",
        "name": "Mac Supervisor",
        "department": "mac_factory",
        "role": "orchestrator",
        "description": "Autonomous iOS build supervisor",
        "model": "deterministic",
        "tier": "none",
        "status": "active",
        "location": "mac",
        "endpoint": "",
        "capabilities": ["ios_build", "ios_repair", "ios_archive", "pre_build_cleanup"]
    },
    {
        "agent_id": "MAC-02",
        "name": "Swift Code Generator",
        "department": "mac_factory",
        "role": "code_generator",
        "model": "claude-sonnet-4-6",
        "tier": "tier2",
        "status": "active",
        "location": "mac",
        "endpoint": "",
        "capabilities": ["swift_generation", "roadbook_parsing"]
    },
    {
        "agent_id": "MAC-03",
        "name": "Error Analyzer",
        "department": "mac_factory",
        "role": "analyzer",
        "model": "deterministic",
        "tier": "none",
        "status": "active",
        "location": "mac",
        "endpoint": "",
        "capabilities": ["error_analysis", "corruption_detection", "duplicate_detection"]
    },
    {
        "agent_id": "MAC-04",
        "name": "Repair Executor",
        "department": "mac_factory",
        "role": "repair",
        "model": "claude-sonnet-4-6",
        "tier": "tier2",
        "status": "active",
        "location": "mac",
        "endpoint": "",
        "capabilities": ["repair_tier1", "repair_tier2", "deep_repair", "quarantine"]
    },
    {
        "agent_id": "MAC-05",
        "name": "Pre-Build Cleanup",
        "department": "mac_factory",
        "role": "cleanup",
        "model": "deterministic",
        "tier": "none",
        "status": "active",
        "location": "mac",
        "endpoint": "",
        "capabilities": ["pre_build_cleanup", "import_mapping", "dedup"]
    },
    {
        "agent_id": "MAC-06",
        "name": "Archive Manager",
        "department": "mac_factory",
        "role": "archive",
        "model": "deterministic",
        "tier": "none",
        "status": "active",
        "location": "mac",
        "endpoint": "",
        "capabilities": ["archive", "export_ipa", "testflight_upload"]
    }
]


def register_with_central(server_port: int = 8420, windows_url: str = ""):
    """
    Registers all Mac agents with the Windows central registry.
    Falls back to local file if Windows unreachable.
    """
    try:
        hostname = socket.gethostname()
        local_ip = socket.gethostbyname(hostname)
    except Exception:
        local_ip = "0.0.0.0"

    endpoint = f"http://{local_ip}:{server_port}"

    for agent in MAC_AGENTS:
        agent["endpoint"] = endpoint
        agent["last_registered"] = datetime.now(timezone.utc).isoformat()

    if windows_url:
        try:
            import requests
            resp = requests.post(
                f"{windows_url}/agents/register",
                json={"agents": MAC_AGENTS},
                timeout=10
            )
            if resp.status_code == 200:
                print(f"[Registration] Registered {len(MAC_AGENTS)} agents with Windows")
                return True
        except Exception as e:
            print(f"[Registration] Could not reach Windows ({e}) - saving locally")

    _save_local_registration()
    return False


def _save_local_registration():
    reg_file = Path(__file__).parent / "registration_pending.json"
    data = {
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "agents": MAC_AGENTS,
        "status": "pending"
    }
    try:
        with open(reg_file, "w") as f:
            json.dump(data, f, indent=2)
        print(f"[Registration] Saved {len(MAC_AGENTS)} agents locally (pending sync)")
    except Exception as e:
        print(f"[Registration] Local save failed: {e}")


def get_registered_agents() -> list:
    return MAC_AGENTS


def print_agents():
    print(f"\n[Mac Factory] Registered Agents ({len(MAC_AGENTS)}):")
    for a in MAC_AGENTS:
        model_info = a['model'] if a['model'] != 'deterministic' else 'no LLM'
        print(f"  {a['agent_id']}: {a['name']} ({a['role']}, {model_info})")
    print()
