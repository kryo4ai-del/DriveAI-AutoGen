"""Feasibility Gate Creator.

Creates CEO gates when a feasibility check finds gaps.
Uses the existing gate system (factory/hq/gates/).
"""

import json
from datetime import datetime
from pathlib import Path

_ROOT = Path(__file__).resolve().parent.parent.parent.parent
_GATES_DIR = _ROOT / "factory" / "hq" / "gates"


def create_feasibility_gate(slug: str, result: dict) -> str | None:
    """Create a feasibility gate for CEO decision.

    Args:
        slug: Project slug.
        result: FeasibilityChecker result dict.

    Returns:
        Gate ID or None if no gate needed.
    """
    overall = result.get("overall_status", "")
    if overall == "feasible":
        return None  # No gate needed

    gaps = result.get("capability_gaps", [])
    score = result.get("score", 0.0)
    blocking = [g for g in gaps if g.get("severity") == "blocking"]
    summary_text = result.get("summary", "")

    gate_id = f"feasibility_{slug}_{datetime.now().strftime('%Y%m%d_%H%M%S')}"

    if overall == "partially_feasible":
        gate = _build_partial_gate(slug, gate_id, score, blocking, gaps, summary_text, result)
    else:
        gate = _build_blocked_gate(slug, gate_id, score, blocking, gaps, summary_text, result)

    # Save gate
    _GATES_DIR.mkdir(parents=True, exist_ok=True)
    gate_file = _GATES_DIR / f"{gate_id}.json"
    gate_file.write_text(
        json.dumps(gate, indent=2, ensure_ascii=False, default=str),
        encoding="utf-8",
    )

    # Also update project.json gates
    try:
        from factory.shared.project_registry import update_gate
        update_gate(slug, "feasibility_gate", "pending",
                    f"Feasibility: {overall} (score={score})")
    except Exception:
        pass

    print(f"[FeasibilityGate] Created: {gate_id} ({overall})")
    return gate_id


def _build_partial_gate(slug, gate_id, score, blocking, gaps, summary, result):
    """Build gate for partially_feasible projects."""
    blocked_features = []
    for g in blocking:
        blocked_features.extend(g.get("required_by", []))

    gap_names = [g.get("capability", "?") for g in gaps]

    return {
        "gate_id": gate_id,
        "project": slug,
        "gate_type": "feasibility_partial",
        "category": "production",
        "title": f"Feasibility: {slug} -- {summary}",
        "description": (
            f"Feasibility Score: {score}\n"
            f"Fehlende Capabilities: {', '.join(gap_names)}\n"
            f"Betroffene Features: {', '.join(blocked_features[:5])}"
        ),
        "severity": "warning",
        "status": "pending",
        "created_at": datetime.now().isoformat(),
        "options": [
            {
                "id": "proceed_reduced",
                "label": "Ohne fehlende Features starten",
                "color": "green",
                "description": f"Features {', '.join(blocked_features[:3])} werden uebersprungen",
            },
            {
                "id": "park",
                "label": "Projekt parken",
                "color": "orange",
                "description": "Warten bis Capabilities verfuegbar sind",
            },
            {
                "id": "adjust_roadbook",
                "label": "Roadbook anpassen",
                "color": "blue",
                "description": "Neues Roadbook mit nur machbaren Features",
            },
            {
                "id": "kill",
                "label": "Projekt stoppen",
                "color": "red",
            },
        ],
        "source_department": "factory/hq/capabilities",
        "source_agent": "feasibility_checker",
        "context": {
            "score": score,
            "overall_status": result.get("overall_status"),
            "capability_gaps": gaps,
            "blocked_features": blocked_features,
            "report_path": result.get("report_path"),
        },
        "recommendation": {
            "option_id": "proceed_reduced",
            "reasoning": f"Score {score} -- die meisten Features sind machbar.",
        },
    }


def _build_blocked_gate(slug, gate_id, score, blocking, gaps, summary, result):
    """Build gate for not_feasible projects."""
    gap_names = [g.get("capability", "?") for g in gaps]

    return {
        "gate_id": gate_id,
        "project": slug,
        "gate_type": "feasibility_blocked",
        "category": "production",
        "title": f"Feasibility: {slug} -- NICHT MACHBAR",
        "description": (
            f"Feasibility Score: {score}\n"
            f"Kritische Luecken: {', '.join(gap_names)}\n"
            f"Produktion kann nicht starten."
        ),
        "severity": "blocking",
        "status": "pending",
        "created_at": datetime.now().isoformat(),
        "options": [
            {
                "id": "park",
                "label": "Projekt parken (orange)",
                "color": "orange",
                "description": "Warten bis Capabilities eingebaut werden",
            },
            {
                "id": "kill",
                "label": "Projekt stoppen",
                "color": "red",
            },
            {
                "id": "redesign",
                "label": "Redesign anfordern",
                "color": "blue",
                "description": "Zurueck an Swarm Factory mit angepassten Constraints",
            },
        ],
        "source_department": "factory/hq/capabilities",
        "source_agent": "feasibility_checker",
        "context": {
            "score": score,
            "overall_status": result.get("overall_status"),
            "capability_gaps": gaps,
            "report_path": result.get("report_path"),
        },
        "recommendation": {
            "option_id": "park",
            "reasoning": f"Score {score} -- zu viele fehlende Capabilities fuer Produktion.",
        },
    }
