# analyzer.py
# Factory Improvement Analyzer — inspects all monitoring signals and generates
# improvement proposals. Read-only analysis of existing stores, writes only
# to the improvement_proposals store.

from __future__ import annotations

import os
import sys
from datetime import date, datetime, timedelta

# Allow imports from project root
_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if _ROOT not in sys.path:
    sys.path.insert(0, _ROOT)

from improvements.improvement_manager import ImprovementManager


def _load_store(rel_path: str, key: str) -> list[dict]:
    """Load a JSON store list, returning [] on any failure."""
    import json
    path = os.path.join(_ROOT, rel_path)
    try:
        with open(path, encoding="utf-8") as f:
            data = json.load(f)
        result = data.get(key, [])
        return result if isinstance(result, list) else []
    except (FileNotFoundError, json.JSONDecodeError, OSError, TypeError):
        return []


def _load_memory() -> dict[str, list[dict]]:
    """Load agent memory store."""
    import json
    path = os.path.join(_ROOT, "memory", "memory_store.json")
    try:
        with open(path, encoding="utf-8") as f:
            data = json.load(f)
        if not isinstance(data, dict):
            return {}
        return {k: v for k, v in data.items() if isinstance(v, list)}
    except (FileNotFoundError, json.JSONDecodeError, OSError, TypeError):
        return {}


def _existing_titles(manager: ImprovementManager) -> set[str]:
    """Get set of existing proposal titles to avoid duplicates."""
    return {p.get("title", "") for p in manager.proposals}


def analyze_and_propose() -> list[dict]:
    """
    Run all signal analyzers and generate improvement proposals.
    Returns list of newly created proposals.
    """
    manager = ImprovementManager()
    existing = _existing_titles(manager)
    created: list[dict] = []

    def _propose(title: str, **kwargs) -> dict | None:
        """Add proposal if title doesn't already exist."""
        if title in existing:
            return None
        p = manager.add_proposal(title=title, **kwargs)
        existing.add(title)
        created.append(p)
        return p

    # --- Analyze Watch Events ---
    watch_events = _load_store("watch/watch_events.json", "events")
    _analyze_watch_events(watch_events, _propose)

    # --- Analyze Compliance ---
    compliance = _load_store("compliance/compliance_reports.json", "reports")
    _analyze_compliance(compliance, _propose)

    # --- Analyze Accessibility ---
    a11y = _load_store("accessibility/accessibility_reports.json", "reports")
    _analyze_accessibility(a11y, _propose)

    # --- Analyze Orchestration Blockers ---
    plans = _load_store("orchestration/orchestration_plan_store.json", "plans")
    _analyze_orchestration(plans, _propose)

    # --- Analyze Opportunities ---
    opportunities = _load_store("opportunities/opportunity_store.json", "opportunities")
    _analyze_opportunities(opportunities, _propose)

    # --- Analyze Memory for Patterns ---
    memory = _load_memory()
    _analyze_memory(memory, _propose)

    return created


def _analyze_watch_events(events: list[dict], propose) -> None:
    """Detect improvement signals from watch events."""
    active = [e for e in events if e.get("status") not in ("resolved", "dismissed")]

    # Unresolved critical/high events → factory needs faster response
    critical_unresolved = [e for e in active if e.get("severity") in ("critical", "high")]
    if len(critical_unresolved) >= 3:
        propose(
            title="Multiple unresolved critical watch events",
            summary=f"{len(critical_unresolved)} critical/high watch events remain unresolved. "
                    "Consider adding automated triage or escalation.",
            category="automation",
            severity="high",
            affected_systems=["watch", "orchestration"],
            recommended_action="Add automated severity-based triage rules or escalation thresholds",
            detected_from="watch_events",
        )

    # SDK/tooling updates sitting unresolved
    sdk_events = [e for e in active if e.get("category") in ("sdk_requirement", "tooling_update")]
    for evt in sdk_events:
        propose(
            title=f"SDK/Tooling update: {evt.get('title', '?')}",
            summary=evt.get("summary", evt.get("title", "")),
            category="sdk_update",
            severity=evt.get("severity", "medium"),
            affected_systems=evt.get("affected_projects", []),
            recommended_action=evt.get("recommended_action", "Evaluate and apply update"),
            detected_from=f"watch_events/{evt.get('event_id', '?')}",
        )

    # Model updates
    model_events = [e for e in active if e.get("category") == "model_update"]
    for evt in model_events:
        propose(
            title=f"AI model update: {evt.get('title', '?')}",
            summary=evt.get("summary", evt.get("title", "")),
            category="model_update",
            severity=evt.get("severity", "medium"),
            affected_systems=evt.get("affected_projects", []),
            recommended_action=evt.get("recommended_action", "Evaluate new model for integration"),
            detected_from=f"watch_events/{evt.get('event_id', '?')}",
        )

    # Security changes
    security_events = [e for e in active if e.get("category") == "security_change"]
    for evt in security_events:
        propose(
            title=f"Security update required: {evt.get('title', '?')}",
            summary=evt.get("summary", evt.get("title", "")),
            category="security",
            severity=evt.get("severity", "high"),
            affected_systems=evt.get("affected_projects", []),
            recommended_action=evt.get("recommended_action", "Apply security patch or update"),
            detected_from=f"watch_events/{evt.get('event_id', '?')}",
        )


def _analyze_compliance(reports: list[dict], propose) -> None:
    """Detect improvement signals from compliance findings."""
    active = [r for r in reports if r.get("status") not in ("dismissed", "accepted")]

    # Blocked compliance items → architecture needs attention
    blocked = [r for r in active if r.get("status") == "blocked"]
    if blocked:
        topics = list({r.get("topic", "?") for r in blocked})
        propose(
            title="Compliance blockers need resolution",
            summary=f"{len(blocked)} compliance reports are blocking progress. "
                    f"Topics: {', '.join(topics[:5])}.",
            category="compliance",
            severity="high",
            affected_systems=[r.get("project", "?") for r in blocked],
            recommended_action="Resolve compliance blockers before continuing development",
            detected_from="compliance",
        )

    # External review needed but not yet done
    ext_review = [r for r in active if r.get("external_review_needed") and r.get("status") == "new"]
    if ext_review:
        propose(
            title="Pending external compliance reviews",
            summary=f"{len(ext_review)} compliance reports require external review but haven't been started.",
            category="compliance",
            severity="medium",
            affected_systems=[r.get("project", "?") for r in ext_review],
            recommended_action="Schedule external legal/compliance review",
            detected_from="compliance",
        )

    # High concentration of one topic → systemic issue
    topic_counts: dict[str, int] = {}
    for r in active:
        t = r.get("topic", "unknown")
        topic_counts[t] = topic_counts.get(t, 0) + 1
    for topic, count in topic_counts.items():
        if count >= 3:
            propose(
                title=f"Recurring compliance topic: {topic}",
                summary=f"{count} active compliance reports on '{topic}' suggest a systemic issue. "
                        "Consider adding automated compliance checks for this area.",
                category="automation",
                severity="medium",
                affected_systems=["compliance"],
                recommended_action=f"Add automated pre-check for {topic} during spec/plan creation",
                detected_from="compliance",
            )


def _analyze_accessibility(reports: list[dict], propose) -> None:
    """Detect improvement signals from accessibility findings."""
    open_reports = [r for r in reports if r.get("status") in ("new", "acknowledged")]

    # Critical a11y issues
    critical = [r for r in open_reports if r.get("severity") == "critical"]
    if critical:
        issue_types = list({r.get("issue_type", "?") for r in critical})
        propose(
            title="Critical accessibility issues open",
            summary=f"{len(critical)} critical accessibility issues remain open. "
                    f"Types: {', '.join(issue_types[:5])}.",
            category="accessibility",
            severity="critical",
            affected_systems=[r.get("project", "?") for r in critical],
            recommended_action="Prioritize fixing critical a11y issues for compliance and usability",
            detected_from="accessibility",
        )

    # Repeated issue types → need reusable component or lint rule
    type_counts: dict[str, int] = {}
    for r in open_reports:
        t = r.get("issue_type", "unknown")
        type_counts[t] = type_counts.get(t, 0) + 1
    for issue_type, count in type_counts.items():
        if count >= 3:
            propose(
                title=f"Recurring a11y issue: {issue_type}",
                summary=f"{count} open reports for '{issue_type}'. "
                        "Consider adding a reusable accessible component or lint rule.",
                category="tooling",
                severity="medium",
                affected_systems=["accessibility"],
                recommended_action=f"Create reusable component or lint rule for {issue_type}",
                detected_from="accessibility",
            )


def _analyze_orchestration(plans: list[dict], propose) -> None:
    """Detect improvement signals from orchestration plans."""
    blocked = [p for p in plans if p.get("readiness_status") == "blocked"]

    if blocked:
        all_blockers = []
        for p in blocked:
            all_blockers.extend(p.get("blockers", []))
        unique_blockers = list(set(all_blockers))[:5]

        propose(
            title="Orchestration plans blocked",
            summary=f"{len(blocked)} orchestration plans are blocked. "
                    f"Common blockers: {', '.join(unique_blockers) if unique_blockers else 'unspecified'}.",
            category="architecture",
            severity="high",
            affected_systems=[p.get("project", "?") for p in blocked],
            recommended_action="Resolve blockers to unblock project execution",
            detected_from="orchestration",
        )

    # Plans stuck in draft for too long
    drafts = [p for p in plans if p.get("status") == "draft"]
    if len(drafts) >= 3:
        propose(
            title="Multiple orchestration plans stuck in draft",
            summary=f"{len(drafts)} plans are still in draft status. "
                    "Consider automated plan validation or readiness checks.",
            category="automation",
            severity="low",
            affected_systems=["orchestration"],
            recommended_action="Add automated plan readiness validation step",
            detected_from="orchestration",
        )


def _analyze_opportunities(opportunities: list[dict], propose) -> None:
    """Detect improvement signals from opportunity records."""
    # High-relevance opportunities not yet acted on
    stale = [
        o for o in opportunities
        if o.get("status") == "new" and o.get("market_relevance") in ("critical", "high")
    ]
    if stale:
        propose(
            title="High-relevance opportunities awaiting evaluation",
            summary=f"{len(stale)} high/critical relevance opportunities are still in 'new' status.",
            category="general",
            severity="medium",
            affected_systems=["opportunities"],
            recommended_action="Evaluate and decide on high-relevance opportunities",
            detected_from="opportunities",
        )


def _analyze_memory(memory: dict[str, list[dict]], propose) -> None:
    """Detect improvement signals from agent memory patterns."""
    if not memory:
        return

    # Look for repeated keywords in implementation notes that suggest missing abstractions
    impl_notes = memory.get("implementation_notes", [])

    # Count keyword patterns that suggest reusable components
    pattern_keywords = {
        "duplicate": "automation",
        "repeated": "automation",
        "boilerplate": "tooling",
        "workaround": "architecture",
        "hack": "architecture",
        "temporary": "architecture",
        "hardcoded": "tooling",
        "manual": "automation",
    }

    keyword_hits: dict[str, int] = {}
    for note in impl_notes:
        text = note.get("note", "").lower()
        for keyword in pattern_keywords:
            if keyword in text:
                keyword_hits[keyword] = keyword_hits.get(keyword, 0) + 1

    for keyword, count in keyword_hits.items():
        if count >= 5:
            category = pattern_keywords[keyword]
            propose(
                title=f"Recurring pattern in implementation: '{keyword}'",
                summary=f"The keyword '{keyword}' appeared in {count} implementation notes, "
                        f"suggesting an area for improvement.",
                category=category,
                severity="low",
                affected_systems=["factory"],
                recommended_action=f"Review implementation notes mentioning '{keyword}' and "
                                   "consider creating reusable components or automation",
                detected_from="memory/implementation_notes",
            )

    # Architecture notes mentioning "missing" or "needed"
    arch_notes = memory.get("architecture_notes", [])
    missing_refs = [
        n for n in arch_notes
        if any(kw in n.get("note", "").lower() for kw in ("missing", "needed", "should add", "should create"))
    ]
    if len(missing_refs) >= 3:
        propose(
            title="Architecture gaps identified by agents",
            summary=f"{len(missing_refs)} architecture notes reference missing components or needed additions.",
            category="architecture",
            severity="medium",
            affected_systems=["factory"],
            recommended_action="Review architecture notes for missing components and plan additions",
            detected_from="memory/architecture_notes",
        )


if __name__ == "__main__":
    proposals = analyze_and_propose()
    if proposals:
        print(f"Generated {len(proposals)} new improvement proposals:")
        for p in proposals:
            print(f"  {p['proposal_id']}: [{p['severity']}] {p['title']}")
    else:
        print("No new improvement proposals generated.")
