"""
Activity Feed — aggregates events from all factory stores into a normalized
chronological feed. Read-only, derived from existing JSON stores.
"""

from __future__ import annotations
from store_reader import StoreReader


# Event type labels mapped from store status
IDEA_EVENTS = {
    "inbox": "Idea Created",
    "classified": "Idea Classified",
    "prioritized": "Idea Prioritized",
    "spec-ready": "Idea Spec-Ready",
    "done": "Idea Completed",
    "blocked": "Idea Blocked",
    "parked": "Idea Parked",
}

SPEC_EVENTS = {
    "draft": "Spec Drafted",
    "review": "Spec In Review",
    "approved": "Spec Approved",
    "in-progress": "Spec In Progress",
    "done": "Spec Completed",
    "rejected": "Spec Rejected",
}

PLAN_EVENTS = {
    "draft": "Plan Created",
    "approved": "Plan Approved",
    "executing": "Plan Executing",
    "completed": "Plan Completed",
    "cancelled": "Plan Cancelled",
}

TYPE_ICONS = {
    "ideas": "💡",
    "specs": "📋",
    "orchestration": "🎯",
    "opportunities": "🔍",
    "watch_events": "👁",
    "compliance": "⚖️",
    "accessibility": "♿",
    "content": "📝",
    "bootstrap": "🚀",
    "projects": "📦",
}

SEVERITY_ICONS = {
    "critical": "🔴",
    "high": "🟠",
    "medium": "🟡",
    "low": "🟢",
    "info": "⚪",
}


def build_feed(reader: StoreReader, limit: int = 50) -> list[dict]:
    """
    Build a normalized activity feed from all factory stores.

    Each entry:
      event_type:   str  — human-readable label (e.g. "Idea Created")
      source_store: str  — which store (e.g. "ideas")
      ref_id:       str  — item ID (e.g. "IDEA-001")
      title:        str  — item title or summary
      project:      str  — linked project or "—"
      severity:     str  — severity/priority/risk level or "—"
      status:       str  — current status
      timestamp:    str  — ISO date string for sorting
      icon:         str  — emoji icon
    """
    events: list[dict] = []

    # --- Ideas ---
    for idea in reader.ideas():
        status = idea.get("status", "unknown")
        events.append({
            "event_type": IDEA_EVENTS.get(status, f"Idea {status.title()}"),
            "source_store": "ideas",
            "ref_id": idea.get("id", "?"),
            "title": idea.get("title", "Untitled"),
            "project": idea.get("project", "—"),
            "severity": idea.get("priority", "—"),
            "status": status,
            "timestamp": idea.get("created_at", ""),
            "icon": TYPE_ICONS["ideas"],
        })

    # --- Specs ---
    for spec in reader.specs():
        status = spec.get("status", "unknown")
        events.append({
            "event_type": SPEC_EVENTS.get(status, f"Spec {status.title()}"),
            "source_store": "specs",
            "ref_id": spec.get("spec_id", "?"),
            "title": spec.get("title", "Untitled"),
            "project": spec.get("project", "—"),
            "severity": spec.get("priority", "—"),
            "status": status,
            "timestamp": spec.get("created_at", ""),
            "icon": TYPE_ICONS["specs"],
        })

    # --- Orchestration Plans ---
    for plan in reader.orchestration():
        status = plan.get("status", "unknown")
        events.append({
            "event_type": PLAN_EVENTS.get(status, f"Plan {status.title()}"),
            "source_store": "orchestration",
            "ref_id": plan.get("plan_id", "?"),
            "title": f"{plan.get('project', '?')} — {plan.get('recommended_phase', '?')}",
            "project": plan.get("project", "—"),
            "severity": plan.get("readiness_status", "—"),
            "status": status,
            "timestamp": plan.get("created_at", ""),
            "icon": TYPE_ICONS["orchestration"],
        })

    # --- Opportunities ---
    for opp in reader.opportunities():
        status = opp.get("status", "unknown")
        label = {
            "new": "Opportunity Detected",
            "evaluated": "Opportunity Evaluated",
            "accepted": "Opportunity Accepted",
            "idea_created": "Opportunity → Idea",
            "rejected": "Opportunity Rejected",
            "deferred": "Opportunity Deferred",
        }.get(status, f"Opportunity {status.title()}")
        events.append({
            "event_type": label,
            "source_store": "opportunities",
            "ref_id": opp.get("opportunity_id", "?"),
            "title": opp.get("title", "Untitled"),
            "project": ", ".join(opp.get("potential_products", [])) or "—",
            "severity": opp.get("market_relevance", "—"),
            "status": status,
            "timestamp": opp.get("detected_at", ""),
            "icon": TYPE_ICONS["opportunities"],
        })

    # --- Watch Events ---
    for w in reader.watch_events():
        status = w.get("status", "unknown")
        label = {
            "new": "Watch Alert",
            "acknowledged": "Watch Acknowledged",
            "in-progress": "Watch In Progress",
            "resolved": "Watch Resolved",
            "dismissed": "Watch Dismissed",
        }.get(status, f"Watch {status.title()}")
        events.append({
            "event_type": label,
            "source_store": "watch_events",
            "ref_id": w.get("event_id", "?"),
            "title": w.get("title", "Untitled"),
            "project": ", ".join(w.get("affected_projects", [])) or "—",
            "severity": w.get("severity", "—"),
            "status": status,
            "timestamp": w.get("detected_at", ""),
            "icon": TYPE_ICONS["watch_events"],
        })

    # --- Compliance ---
    for r in reader.compliance():
        status = r.get("status", "unknown")
        label = {
            "new": "Compliance Warning",
            "reviewed": "Compliance Reviewed",
            "mitigated": "Compliance Mitigated",
            "accepted": "Compliance Risk Accepted",
            "blocked": "Compliance Blocker",
            "dismissed": "Compliance Dismissed",
        }.get(status, f"Compliance {status.title()}")
        events.append({
            "event_type": label,
            "source_store": "compliance",
            "ref_id": r.get("report_id", "?"),
            "title": r.get("topic", "Untitled"),
            "project": r.get("project", "—"),
            "severity": r.get("risk_level", "—"),
            "status": status,
            "timestamp": r.get("created_at", ""),
            "icon": TYPE_ICONS["compliance"],
        })

    # --- Accessibility ---
    for r in reader.accessibility():
        status = r.get("status", "unknown")
        label = {
            "new": "Accessibility Warning",
            "acknowledged": "Accessibility Acknowledged",
            "fixed": "Accessibility Fixed",
            "wont_fix": "Accessibility Won't Fix",
            "false_positive": "Accessibility False Positive",
        }.get(status, f"Accessibility {status.title()}")
        events.append({
            "event_type": label,
            "source_store": "accessibility",
            "ref_id": r.get("report_id", "?"),
            "title": f"{r.get('issue_type', '?')} in {r.get('file', '?')}",
            "project": r.get("project", "—"),
            "severity": r.get("severity", "—"),
            "status": status,
            "timestamp": r.get("detected_at", ""),
            "icon": TYPE_ICONS["accessibility"],
        })

    # --- Content ---
    for c in reader.content():
        status = c.get("status", "unknown")
        label = {
            "draft": "Content Draft Created",
            "review": "Content In Review",
            "approved": "Content Approved",
            "published": "Content Published",
            "archived": "Content Archived",
        }.get(status, f"Content {status.title()}")
        events.append({
            "event_type": label,
            "source_store": "content",
            "ref_id": c.get("content_id", "?"),
            "title": c.get("title", "Untitled"),
            "project": c.get("project", "—"),
            "severity": "—",
            "status": status,
            "timestamp": c.get("created_at", ""),
            "icon": TYPE_ICONS["content"],
        })

    # --- Bootstrap ---
    for bp in reader.bootstrap():
        status = bp.get("status", "unknown")
        label = {
            "created": "Project Bootstrapped",
            "planning": "Project Planning",
            "in_development": "Project In Development",
            "mvp_complete": "Project MVP Complete",
            "released": "Project Released",
            "paused": "Project Paused",
            "archived": "Project Archived",
        }.get(status, f"Project {status.title()}")
        events.append({
            "event_type": label,
            "source_store": "bootstrap",
            "ref_id": bp.get("project_id", "?"),
            "title": bp.get("name", "Untitled"),
            "project": bp.get("name", "—"),
            "severity": "—",
            "status": status,
            "timestamp": bp.get("created_at", ""),
            "icon": TYPE_ICONS["bootstrap"],
        })

    # Sort by timestamp descending, filter out items without timestamp
    events = [e for e in events if e["timestamp"]]
    events.sort(key=lambda e: e["timestamp"], reverse=True)

    return events[:limit]


def get_source_stores(events: list[dict]) -> list[str]:
    """Get unique source stores from feed events."""
    return sorted({e["source_store"] for e in events})


def get_projects(events: list[dict]) -> list[str]:
    """Get unique project names from feed events."""
    return sorted({e["project"] for e in events if e["project"] != "—"})


def get_severities(events: list[dict]) -> list[str]:
    """Get unique severity values from feed events."""
    return sorted({e["severity"] for e in events if e["severity"] != "—"})
