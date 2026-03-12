# daily_briefing.py
# Daily Briefing Agent — collects factory signals and generates an executive briefing.
# Read-only analysis of all stores, writes briefing record + optional HTML output.

from __future__ import annotations

import os
import sys
from datetime import date

_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if _ROOT not in sys.path:
    sys.path.insert(0, _ROOT)

from briefings.briefing_manager import BriefingManager


def _load_store(rel_path: str, key: str) -> list[dict]:
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
    import json
    path = os.path.join(_ROOT, "memory", "memory_store.json")
    try:
        with open(path, encoding="utf-8") as f:
            data = json.load(f)
        return {k: v for k, v in data.items() if isinstance(v, list)} if isinstance(data, dict) else {}
    except (FileNotFoundError, json.JSONDecodeError, OSError, TypeError):
        return {}


def _load_config(filename: str) -> dict:
    import json
    path = os.path.join(_ROOT, "config", filename)
    try:
        with open(path, encoding="utf-8") as f:
            data = json.load(f)
        return data if isinstance(data, dict) else {}
    except (FileNotFoundError, json.JSONDecodeError, OSError):
        return {}


def generate_briefing() -> dict:
    """
    Generate a daily executive briefing from all factory signals.
    Returns the briefing record dict.
    """
    today = date.today().isoformat()
    manager = BriefingManager()

    # Skip if already generated today
    existing = manager.by_date(today)
    if existing:
        return existing

    # --- Load all stores ---
    ideas = _load_store("factory/ideas/idea_store.json", "ideas")
    projects = _load_store("factory/projects/project_registry.json", "projects")
    specs = _load_store("factory/specs/spec_store.json", "specs")
    opportunities = _load_store("opportunities/opportunity_store.json", "opportunities")
    watch_events = _load_store("watch/watch_events.json", "events")
    compliance = _load_store("compliance/compliance_reports.json", "reports")
    a11y = _load_store("accessibility/accessibility_reports.json", "reports")
    orchestration = _load_store("orchestration/orchestration_plan_store.json", "plans")
    improvements = _load_store("improvements/improvement_proposals.json", "proposals")
    trends = _load_store("trends/trend_store.json", "trends")
    content = _load_store("content/content_store.json", "content")
    bootstrap = _load_store("bootstrap/project_store.json", "projects")
    radar_sources = _load_store("radar/radar_sources.json", "sources")
    radar_hits = _load_store("radar/radar_hits.json", "hits")
    cost_usage = _load_store("costs/cost_usage.json", "usage")
    memory = _load_memory()
    toggles = _load_config("agent_toggles.json")
    cost_budgets = _load_config("cost_budgets.json")

    # --- Compute KPIs ---
    active_agents = sum(1 for v in toggles.values() if v) if toggles else 0
    total_agents = len(toggles) if toggles else 0
    active_projects = [p for p in projects if p.get("active")]
    memory_total = sum(len(v) for v in memory.values())

    kpis = {
        "agents": f"{active_agents}/{total_agents}",
        "projects": len(projects),
        "active_projects": len(active_projects),
        "ideas": len(ideas),
        "ideas_inbox": sum(1 for i in ideas if i.get("status") == "inbox"),
        "specs": len(specs),
        "plans": len(orchestration),
        "opportunities": len(opportunities),
        "trends": len(trends),
        "improvements": len(improvements),
        "watch_events": len(watch_events),
        "compliance": len(compliance),
        "a11y": len(a11y),
        "radar_sources": len(radar_sources),
        "radar_hits": len(radar_hits),
        "ai_cost_requests": len(cost_usage),
        "memory_entries": memory_total,
    }

    # --- Build sections ---
    sections = {}

    # Executive Summary
    alerts = []
    critical_watch = [w for w in watch_events if w.get("severity") in ("critical", "high") and w.get("status") not in ("resolved", "dismissed")]
    high_compliance = [c for c in compliance if c.get("risk_level") in ("critical", "high") and c.get("status") not in ("dismissed", "accepted")]
    blocked_plans = [p for p in orchestration if p.get("readiness_status") == "blocked"]
    critical_a11y = [r for r in a11y if r.get("severity") in ("critical", "high") and r.get("status") in ("new", "acknowledged")]
    high_prio_ideas = [i for i in ideas if i.get("priority") == "now"]

    total_alerts = len(critical_watch) + len(high_compliance) + len(blocked_plans) + len(critical_a11y) + len(high_prio_ideas)

    summary_lines = []
    if total_alerts > 0:
        summary_lines.append(f"{total_alerts} items need attention today.")
    else:
        summary_lines.append("No urgent items. Factory running smoothly.")

    summary_lines.append(f"{len(active_projects)} active projects, {kpis['ideas_inbox']} ideas in inbox, {len(orchestration)} plans.")
    sections["executive_summary"] = summary_lines

    # New Ideas
    inbox_ideas = [i for i in ideas if i.get("status") == "inbox"]
    sections["new_ideas"] = [
        {"id": i.get("id", "?"), "title": i.get("title", "?"), "priority": i.get("priority", "?"),
         "source": i.get("source", "?"), "project": i.get("project", "—")}
        for i in inbox_ideas[:10]
    ]

    # Trends & Opportunities
    active_trends = [t for t in trends if t.get("status") not in ("dismissed", "expired")]
    active_opps = [o for o in opportunities if o.get("status") in ("new", "evaluated", "accepted")]
    sections["trends"] = [
        {"id": t.get("trend_id", "?"), "title": t.get("title", "?"),
         "relevance": f"{t.get('relevance_score', 0):.0%}", "category": t.get("category", "?")}
        for t in sorted(active_trends, key=lambda x: x.get("relevance_score", 0), reverse=True)[:5]
    ]
    sections["opportunities"] = [
        {"id": o.get("opportunity_id", "?"), "title": o.get("title", "?"),
         "relevance": o.get("market_relevance", "?"), "status": o.get("status", "?")}
        for o in active_opps[:5]
    ]

    # Radar Hits
    active_radar = [h for h in radar_hits if h.get("status") not in ("dismissed", "expired")]
    promotable_radar = [
        h for h in radar_hits
        if h.get("status") in ("evaluated", "promising")
        and h.get("relevance_score", 0) >= 0.7
    ]
    sections["radar"] = [
        {"id": h.get("hit_id", "?"), "title": h.get("title", "?"),
         "relevance": f"{h.get('relevance_score', 0):.0%}", "category": h.get("category", "?"),
         "status": h.get("status", "?")}
        for h in sorted(active_radar, key=lambda x: x.get("relevance_score", 0), reverse=True)[:5]
    ]

    # AI Costs
    today_cost_entries = [u for u in cost_usage if u.get("timestamp", "").startswith(today)]
    ai_today_cost = sum(u.get("estimated_cost", 0) for u in today_cost_entries)
    ai_today_tokens = sum(u.get("total_tokens", 0) for u in today_cost_entries)
    ai_total_cost = sum(u.get("estimated_cost", 0) for u in cost_usage)
    # Top agents by cost
    agent_costs: dict[str, float] = {}
    for u in cost_usage:
        a = u.get("agent_name", "unknown")
        agent_costs[a] = agent_costs.get(a, 0) + u.get("estimated_cost", 0)
    top_agents = sorted(agent_costs.items(), key=lambda x: -x[1])[:3]

    sections["ai_costs"] = {
        "today_cost": f"${ai_today_cost:.4f}",
        "today_tokens": ai_today_tokens,
        "total_cost": f"${ai_total_cost:.4f}",
        "total_requests": len(cost_usage),
        "top_agents": [{"agent": a, "cost": f"${c:.4f}"} for a, c in top_agents],
    }

    # Budget alerts
    daily_budget = cost_budgets.get("daily_budget", 0)
    monthly_budget = cost_budgets.get("monthly_budget", 0)
    if daily_budget and ai_today_cost > daily_budget:
        alert_items.append({"type": "ai_cost", "severity": "high",
                            "id": "BUDGET", "title": f"Daily AI budget exceeded: ${ai_today_cost:.4f} / ${daily_budget:.2f}"})

    kpis["ai_cost_today"] = f"${ai_today_cost:.4f}"
    kpis["ai_tokens_today"] = ai_today_tokens

    # Project Status
    sections["projects"] = [
        {"id": p.get("id", "?"), "name": p.get("name", "?"), "platform": p.get("platform", "?"),
         "status": p.get("status", "?"), "active": p.get("active", False)}
        for p in projects
    ]

    # Alerts & Risks
    alert_items = []
    for w in critical_watch:
        alert_items.append({"type": "watch", "severity": w.get("severity", "?"),
                            "id": w.get("event_id", "?"), "title": w.get("title", "?")})
    for c in high_compliance:
        alert_items.append({"type": "compliance", "severity": c.get("risk_level", "?"),
                            "id": c.get("report_id", "?"), "title": c.get("topic", "?")})
    for p in blocked_plans:
        alert_items.append({"type": "orchestration", "severity": "high",
                            "id": p.get("plan_id", "?"), "title": f"{p.get('project', '?')} — blocked"})
    for r in critical_a11y:
        alert_items.append({"type": "accessibility", "severity": r.get("severity", "?"),
                            "id": r.get("report_id", "?"), "title": f"{r.get('issue_type', '?')} in {r.get('file', '?')}"})
    for i in high_prio_ideas:
        alert_items.append({"type": "idea", "severity": "high",
                            "id": i.get("id", "?"), "title": i.get("title", "?")})
    # Sort: critical first, then high
    alert_items.sort(key=lambda x: 0 if x["severity"] == "critical" else 1)
    sections["alerts"] = alert_items

    # Compliance & Legal
    active_compliance = [c for c in compliance if c.get("status") not in ("dismissed", "accepted")]
    sections["compliance"] = [
        {"id": c.get("report_id", "?"), "topic": c.get("topic", "?"),
         "risk": c.get("risk_level", "?"), "status": c.get("status", "?"),
         "ext_review": c.get("external_review_needed", False)}
        for c in active_compliance[:8]
    ]

    # Accessibility
    open_a11y = [r for r in a11y if r.get("status") in ("new", "acknowledged")]
    sections["accessibility"] = [
        {"id": r.get("report_id", "?"), "issue": r.get("issue_type", "?"),
         "severity": r.get("severity", "?"), "file": r.get("file", "?"),
         "project": r.get("project", "?")}
        for r in open_a11y[:8]
    ]

    # Factory Improvements
    active_improvements = [p for p in improvements if p.get("status") not in ("completed", "rejected", "deferred")]
    sections["improvements"] = [
        {"id": p.get("proposal_id", "?"), "title": p.get("title", "?"),
         "category": p.get("category", "?"), "severity": p.get("severity", "?")}
        for p in active_improvements[:8]
    ]

    # Strategy Report reference
    strategy_reports = _load_store("strategy/weekly_reports.json", "reports")
    if strategy_reports:
        latest_strategy = strategy_reports[-1]
        sections["strategy"] = {
            "report_id": latest_strategy.get("report_id", "?"),
            "week": latest_strategy.get("week", "?"),
            "risks": len(latest_strategy.get("risks", [])),
            "actions": len(latest_strategy.get("recommended_actions", [])),
            "status": latest_strategy.get("status", "?"),
        }
    kpis["strategy_reports"] = len(strategy_reports)

    # Research Reports reference
    research_reports = _load_store("research/research_reports.json", "reports")
    high_conf_research = [
        r for r in research_reports
        if r.get("confidence", 0) >= 0.7 and r.get("status") not in ("archived", "superseded")
    ]
    if research_reports:
        latest_research = research_reports[-1]
        sections["research"] = {
            "total": len(research_reports),
            "high_confidence": len(high_conf_research),
            "latest_id": latest_research.get("research_id", "?"),
            "latest_topic": latest_research.get("topic", "?"),
            "latest_confidence": latest_research.get("confidence", 0),
        }
    kpis["research_reports"] = len(research_reports)

    # --- Generate Actions ---
    actions = _generate_actions(
        inbox_ideas, critical_watch, high_compliance, blocked_plans,
        critical_a11y, active_improvements, active_trends, active_opps,
        promotable_radar
    )

    # --- Save briefing ---
    from briefings.html_renderer import render_html
    html_content = render_html(today, kpis, sections, actions)

    html_dir = os.path.join(_ROOT, "briefings", "html")
    os.makedirs(html_dir, exist_ok=True)
    html_path = os.path.join(html_dir, f"briefing_{today}.html")
    with open(html_path, "w", encoding="utf-8") as f:
        f.write(html_content)

    briefing = manager.add_briefing(
        briefing_date=today,
        sections=sections,
        kpis=kpis,
        actions=actions,
        html_path=f"briefings/html/briefing_{today}.html",
    )

    return briefing


def _generate_actions(inbox_ideas, critical_watch, high_compliance, blocked_plans,
                      critical_a11y, active_improvements, active_trends, active_opps,
                      promotable_radar=None) -> list[str]:
    """Generate prioritized action items for the day."""
    actions = []

    if critical_watch:
        actions.append(f"Review {len(critical_watch)} critical/high watch events")
    if high_compliance:
        ext = sum(1 for c in high_compliance if c.get("external_review_needed"))
        actions.append(f"Address {len(high_compliance)} high-risk compliance items" +
                       (f" ({ext} need external review)" if ext else ""))
    if blocked_plans:
        actions.append(f"Unblock {len(blocked_plans)} orchestration plans")
    if critical_a11y:
        actions.append(f"Fix {len(critical_a11y)} critical/high accessibility issues")
    if inbox_ideas:
        actions.append(f"Triage {len(inbox_ideas)} ideas in inbox")
    if active_improvements:
        high_imp = sum(1 for p in active_improvements if p.get("severity") in ("critical", "high"))
        if high_imp:
            actions.append(f"Evaluate {high_imp} high-priority improvement proposals")
    if active_trends:
        high_trends = sum(1 for t in active_trends if t.get("relevance_score", 0) >= 0.7)
        if high_trends:
            actions.append(f"Review {high_trends} high-relevance AI trends")
    if active_opps:
        new_opps = sum(1 for o in active_opps if o.get("status") == "new")
        if new_opps:
            actions.append(f"Evaluate {new_opps} new opportunities")
    if promotable_radar:
        actions.append(f"Promote {len(promotable_radar)} radar hits to opportunities")

    if not actions:
        actions.append("No urgent actions today — review dashboard for updates")

    return actions


def to_sheets_row(briefing: dict) -> dict:
    """
    Convert a briefing record to a flat dict suitable for Google Sheets row append.
    """
    kpis = briefing.get("kpis", {})
    sections = briefing.get("sections", {})
    actions = briefing.get("actions", [])
    alerts = sections.get("alerts", [])

    return {
        "date": briefing.get("briefing_date", ""),
        "briefing_id": briefing.get("briefing_id", ""),
        "agents": kpis.get("agents", ""),
        "projects": kpis.get("projects", 0),
        "active_projects": kpis.get("active_projects", 0),
        "ideas": kpis.get("ideas", 0),
        "ideas_inbox": kpis.get("ideas_inbox", 0),
        "specs": kpis.get("specs", 0),
        "plans": kpis.get("plans", 0),
        "opportunities": kpis.get("opportunities", 0),
        "trends": kpis.get("trends", 0),
        "improvements": kpis.get("improvements", 0),
        "watch_events": kpis.get("watch_events", 0),
        "compliance": kpis.get("compliance", 0),
        "a11y": kpis.get("a11y", 0),
        "radar_sources": kpis.get("radar_sources", 0),
        "radar_hits": kpis.get("radar_hits", 0),
        "ai_cost_today": kpis.get("ai_cost_today", "$0"),
        "ai_tokens_today": kpis.get("ai_tokens_today", 0),
        "memory_entries": kpis.get("memory_entries", 0),
        "strategy_reports": kpis.get("strategy_reports", 0),
        "research_reports": kpis.get("research_reports", 0),
        "total_alerts": len(alerts),
        "critical_alerts": sum(1 for a in alerts if a.get("severity") == "critical"),
        "summary": " | ".join(sections.get("executive_summary", [])),
        "actions": " | ".join(actions),
        "status": briefing.get("status", ""),
    }


if __name__ == "__main__":
    briefing = generate_briefing()
    bid = briefing.get("briefing_id", "?")
    bdate = briefing.get("briefing_date", "?")
    actions = briefing.get("actions", [])
    kpis = briefing.get("kpis", {})
    html = briefing.get("html_path", "")

    print(f"Daily Briefing: {bid} ({bdate})")
    print(f"  Projects: {kpis.get('projects', 0)} | Ideas: {kpis.get('ideas', 0)} | Alerts: {len(briefing.get('sections', {}).get('alerts', []))}")
    print(f"  Actions:")
    for a in actions:
        print(f"    - {a}")
    if html:
        print(f"  HTML: {html}")

    # Show sheets row format
    row = to_sheets_row(briefing)
    print(f"\n  Sheets row keys: {list(row.keys())}")
