"""Central Gate API — generic, schema-based gate system for all Factory departments.

Gates are JSON files in factory/hq/gates/pending/ (open) and decided/ (resolved).
Any department can create gates with custom types, options, and context.
The Dashboard renders them dynamically from the JSON schema.
"""

import json
import logging
import time
from datetime import datetime, timezone
from pathlib import Path

logger = logging.getLogger(__name__)

GATES_DIR = Path(__file__).parent / "gates"
PENDING_DIR = GATES_DIR / "pending"
DECIDED_DIR = GATES_DIR / "decided"


def create_gate(
    project: str,
    gate_type: str,
    category: str,
    title: str,
    description: str,
    severity: str,
    options: list,
    source_department: str,
    source_agent: str,
    platform: str = None,
    context: dict = None,
    recommendation: dict = None,
    notes_field: bool = True,
    notes_placeholder: str = "Anmerkungen oder Auflagen (optional)...",
) -> str:
    """Create a new gate. Returns gate_id."""
    assert severity in ("info", "warning", "blocking"), f"Invalid severity: {severity}"
    assert 2 <= len(options) <= 5, f"Options must be 2-5, got {len(options)}"
    for opt in options:
        assert all(k in opt for k in ("id", "label", "color")), f"Option missing fields: {opt}"
        assert opt["color"] in ("green", "orange", "yellow", "red", "blue"), f"Invalid color: {opt['color']}"

    ts = datetime.now(timezone.utc).strftime("%Y%m%d_%H%M%S")
    gate_id = f"gate_{ts}_{project}_{gate_type}"

    gate = {
        "gate_id": gate_id,
        "project": project,
        "platform": platform,
        "gate_type": gate_type,
        "category": category,
        "title": title,
        "description": description,
        "severity": severity,
        "created_at": datetime.now(timezone.utc).isoformat(),
        "source_department": source_department,
        "source_agent": source_agent,
        "context": context or {},
        "options": options,
        "notes_field": notes_field,
        "notes_placeholder": notes_placeholder,
        "recommendation": recommendation,
        "status": "pending",
        "decided_at": None,
        "decision": None,
        "decision_notes": None,
    }

    PENDING_DIR.mkdir(parents=True, exist_ok=True)
    (PENDING_DIR / f"{gate_id}.json").write_text(
        json.dumps(gate, indent=2, ensure_ascii=False), encoding="utf-8"
    )
    logger.info("Gate created: %s (%s)", gate_id, title)
    return gate_id


def decide_gate(gate_id: str, decision: str, notes: str = "") -> dict:
    """Set decision for a gate. Moves from pending/ to decided/."""
    pf = PENDING_DIR / f"{gate_id}.json"
    if not pf.exists():
        raise FileNotFoundError(f"Gate not found: {gate_id}")

    gate = json.loads(pf.read_text(encoding="utf-8"))
    valid = [o["id"] for o in gate["options"]]
    assert decision in valid, f"Invalid decision '{decision}'. Valid: {valid}"

    gate["status"] = "decided"
    gate["decided_at"] = datetime.now(timezone.utc).isoformat()
    gate["decision"] = decision
    gate["decision_notes"] = notes

    DECIDED_DIR.mkdir(parents=True, exist_ok=True)
    (DECIDED_DIR / f"{gate_id}.json").write_text(
        json.dumps(gate, indent=2, ensure_ascii=False), encoding="utf-8"
    )
    pf.unlink()

    # Update project registry (non-blocking)
    try:
        from factory.project_registry import update_project_gate
        update_project_gate(gate["project"], gate["gate_type"], decision, notes)
    except Exception:
        pass

    logger.info("Gate decided: %s → %s", gate_id, decision)
    return gate


def get_pending_gates(project: str = None, category: str = None,
                       platform: str = None, severity: str = None) -> list:
    """All pending gates, optionally filtered."""
    gates = []
    if not PENDING_DIR.exists():
        return gates
    for gf in PENDING_DIR.glob("gate_*.json"):
        try:
            g = json.loads(gf.read_text(encoding="utf-8"))
        except Exception:
            continue
        if project and g.get("project") != project:
            continue
        if category and g.get("category") != category:
            continue
        if platform and g.get("platform") != platform:
            continue
        if severity and g.get("severity") != severity:
            continue
        gates.append(g)

    order = {"blocking": 0, "warning": 1, "info": 2}
    gates.sort(key=lambda g: (order.get(g.get("severity", "info"), 9), g.get("created_at", "")))
    return gates


def get_gate(gate_id: str) -> dict:
    """Read a single gate (pending or decided)."""
    for d in [PENDING_DIR, DECIDED_DIR]:
        f = d / f"{gate_id}.json"
        if f.exists():
            return json.loads(f.read_text(encoding="utf-8"))
    raise FileNotFoundError(f"Gate not found: {gate_id}")


def get_gate_decision(gate_id: str):
    """Check if a gate has been decided. Returns dict or None."""
    try:
        g = get_gate(gate_id)
        if g["status"] == "decided":
            return {"decision": g["decision"], "notes": g.get("decision_notes", "")}
    except FileNotFoundError:
        pass
    return None


def wait_for_decision(gate_id: str, poll_interval: int = 30, timeout: int = 86400) -> dict:
    """Poll until a decision is made. Used by pipeline agents."""
    start = time.time()
    while time.time() - start < timeout:
        result = get_gate_decision(gate_id)
        if result:
            return result
        time.sleep(poll_interval)
    raise TimeoutError(f"Gate {gate_id} not decided within {timeout}s")
