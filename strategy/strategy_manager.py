# strategy_manager.py
# StrategyReportAgent — generates weekly strategic analysis reports.
# Aggregates trends, opportunities, radar, projects, costs, compliance, and memory
# into a structured report with executive summary, insights, risks, and actions.

import json
import os
from datetime import date, datetime

_DIR = os.path.dirname(__file__)
_REPORTS_PATH = os.path.join(_DIR, "weekly_reports.json")
_ROOT = os.path.dirname(_DIR)

VALID_STATUSES = ("draft", "review", "published", "archived")


def _load_json(path: str) -> dict:
    try:
        with open(path, encoding="utf-8") as f:
            return json.load(f)
    except (FileNotFoundError, json.JSONDecodeError):
        return {}


def _save_json(path: str, data: dict) -> None:
    os.makedirs(os.path.dirname(os.path.abspath(path)), exist_ok=True)
    with open(path, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)


def _load_store(rel_path: str, key: str) -> list[dict]:
    path = os.path.join(_ROOT, rel_path)
    try:
        with open(path, encoding="utf-8") as f:
            data = json.load(f)
        result = data.get(key, [])
        return result if isinstance(result, list) else []
    except (FileNotFoundError, json.JSONDecodeError, OSError, TypeError):
        return []


def _load_config(filename: str) -> dict:
    path = os.path.join(_ROOT, "config", filename)
    try:
        with open(path, encoding="utf-8") as f:
            data = json.load(f)
        return data if isinstance(data, dict) else {}
    except (FileNotFoundError, json.JSONDecodeError, OSError):
        return {}


def _load_memory() -> dict[str, list[dict]]:
    path = os.path.join(_ROOT, "memory", "memory_store.json")
    try:
        with open(path, encoding="utf-8") as f:
            data = json.load(f)
        return {k: v for k, v in data.items() if isinstance(v, list)} if isinstance(data, dict) else {}
    except (FileNotFoundError, json.JSONDecodeError, OSError, TypeError):
        return {}


def _week_label(d: date | None = None) -> str:
    """Return ISO week label like '2026-W11'."""
    d = d or date.today()
    return f"{d.isocalendar()[0]}-W{d.isocalendar()[1]:02d}"


class StrategyReportManager:
    """Manages weekly strategy reports for the AI App Factory."""

    def __init__(self):
        self._data = _load_json(_REPORTS_PATH)
        self._data.setdefault("reports", [])

    def save(self) -> None:
        _save_json(_REPORTS_PATH, self._data)

    @property
    def reports(self) -> list[dict]:
        return self._data["reports"]

    def _next_id(self) -> str:
        max_num = 0
        for r in self.reports:
            rid = r.get("report_id", "")
            if rid.startswith("STR-"):
                try:
                    max_num = max(max_num, int(rid.split("-")[1]))
                except (IndexError, ValueError):
                    pass
        return f"STR-{max_num + 1:03d}"

    # ── CRUD ──────────────────────────────────────────────────────────────

    def add_report(self, week: str, summary: str, top_opportunities: list[dict],
                   top_trends: list[dict], project_status: list[dict],
                   risks: list[dict], ai_usage: dict, recommended_actions: list[str],
                   kpis: dict, html_path: str = "") -> dict:
        """Create and persist a new weekly strategy report."""
        report = {
            "report_id": self._next_id(),
            "week": week,
            "summary": summary,
            "top_opportunities": top_opportunities,
            "top_trends": top_trends,
            "project_status": project_status,
            "risks": risks,
            "ai_usage": ai_usage,
            "recommended_actions": recommended_actions,
            "kpis": kpis,
            "html_path": html_path,
            "status": "published",
            "generated_at": datetime.utcnow().isoformat(timespec="seconds") + "Z",
        }
        self.reports.append(report)
        self.save()
        return report

    def get_report(self, report_id: str) -> dict | None:
        for r in self.reports:
            if r.get("report_id") == report_id:
                return r
        return None

    def by_week(self, week: str) -> dict | None:
        for r in self.reports:
            if r.get("week") == week:
                return r
        return None

    def latest(self) -> dict | None:
        return self.reports[-1] if self.reports else None

    def transition(self, report_id: str, new_status: str) -> dict | None:
        if new_status not in VALID_STATUSES:
            raise ValueError(f"Invalid status: {new_status}. Must be one of {VALID_STATUSES}")
        r = self.get_report(report_id)
        if not r:
            return None
        r["status"] = new_status
        self.save()
        return r


def generate_weekly_report(target_date: date | None = None) -> dict:
    """
    Generate a weekly strategy report from all factory signals.
    Runs once per week (Sunday). Returns the report record.
    """
    target_date = target_date or date.today()
    week = _week_label(target_date)
    manager = StrategyReportManager()

    # Skip if already generated this week
    existing = manager.by_week(week)
    if existing:
        return existing

    # ── Load all stores ──────────────────────────────────────────────
    ideas = _load_store("factory/ideas/idea_store.json", "ideas")
    projects = _load_store("factory/projects/project_registry.json", "projects")
    specs = _load_store("factory/specs/spec_store.json", "specs")
    opportunities = _load_store("opportunities/opportunity_store.json", "opportunities")
    watch_events = _load_store("watch/watch_events.json", "events")
    compliance = _load_store("compliance/compliance_reports.json", "reports")
    orchestration = _load_store("orchestration/orchestration_plan_store.json", "plans")
    improvements = _load_store("improvements/improvement_proposals.json", "proposals")
    trends = _load_store("trends/trend_store.json", "trends")
    radar_hits = _load_store("radar/radar_hits.json", "hits")
    cost_usage = _load_store("costs/cost_usage.json", "usage")
    memory = _load_memory()
    toggles = _load_config("agent_toggles.json")
    cost_budgets = _load_config("cost_budgets.json")

    # ── KPIs ─────────────────────────────────────────────────────────
    active_agents = sum(1 for v in toggles.values() if v) if toggles else 0
    total_agents = len(toggles) if toggles else 0
    active_projects = [p for p in projects if p.get("active")]
    inbox_ideas = [i for i in ideas if i.get("status") == "inbox"]
    memory_total = sum(len(v) for v in memory.values())

    kpis = {
        "agents": f"{active_agents}/{total_agents}",
        "projects": len(projects),
        "active_projects": len(active_projects),
        "ideas_total": len(ideas),
        "ideas_inbox": len(inbox_ideas),
        "specs": len(specs),
        "opportunities": len(opportunities),
        "trends": len(trends),
        "radar_hits": len(radar_hits),
        "improvements": len(improvements),
        "watch_events": len(watch_events),
        "compliance_reports": len(compliance),
        "cost_requests": len(cost_usage),
        "memory_entries": memory_total,
    }

    # ── Executive Summary ────────────────────────────────────────────
    critical_watch = [w for w in watch_events if w.get("severity") in ("critical", "high") and w.get("status") not in ("resolved", "dismissed")]
    high_compliance = [c for c in compliance if c.get("risk_level") in ("critical", "high") and c.get("status") not in ("dismissed", "accepted")]
    blocked_plans = [p for p in orchestration if p.get("readiness_status") == "blocked"]

    alert_count = len(critical_watch) + len(high_compliance) + len(blocked_plans)

    summary_parts = [f"Week {week} Strategy Report for the AI App Factory."]
    summary_parts.append(f"{len(active_projects)} active projects, {len(inbox_ideas)} ideas in inbox, {len(orchestration)} orchestration plans.")
    if alert_count:
        summary_parts.append(f"{alert_count} items need attention: {len(critical_watch)} watch events, {len(high_compliance)} compliance issues, {len(blocked_plans)} blocked plans.")
    else:
        summary_parts.append("No critical alerts. Factory running smoothly.")
    summary = " ".join(summary_parts)

    # ── Top Opportunities ────────────────────────────────────────────
    active_opps = [o for o in opportunities if o.get("status") in ("new", "evaluated", "accepted")]
    top_opportunities = [
        {
            "id": o.get("opportunity_id", "?"),
            "title": o.get("title", "?"),
            "relevance": o.get("market_relevance", "?"),
            "status": o.get("status", "?"),
            "source": o.get("source", "?"),
        }
        for o in sorted(active_opps, key=lambda x: {"critical": 4, "high": 3, "medium": 2, "low": 1}.get(x.get("market_relevance", ""), 0), reverse=True)[:5]
    ]

    # Include promotable radar hits as opportunity signals
    promotable_radar = [
        h for h in radar_hits
        if h.get("status") in ("evaluated", "promising")
        and h.get("relevance_score", 0) >= 0.7
    ]
    for h in promotable_radar[:3]:
        top_opportunities.append({
            "id": h.get("hit_id", "?"),
            "title": h.get("title", "?"),
            "relevance": f"{h.get('relevance_score', 0):.0%}",
            "status": f"radar: {h.get('status', '?')}",
            "source": h.get("source_name", "radar"),
        })

    # ── Top Trends ───────────────────────────────────────────────────
    active_trends = [t for t in trends if t.get("status") not in ("dismissed", "expired")]
    top_trends = [
        {
            "id": t.get("trend_id", "?"),
            "title": t.get("title", "?"),
            "relevance": f"{t.get('relevance_score', 0):.0%}",
            "category": t.get("category", "?"),
            "status": t.get("status", "?"),
        }
        for t in sorted(active_trends, key=lambda x: x.get("relevance_score", 0), reverse=True)[:5]
    ]

    # ── Project Status ───────────────────────────────────────────────
    project_status = []
    for p in projects:
        pid = p.get("id", "?")
        proj_specs = [s for s in specs if s.get("project") == pid]
        proj_plans = [pl for pl in orchestration if pl.get("project") == pid]
        proj_ideas = [i for i in ideas if i.get("project") == pid]

        project_status.append({
            "id": pid,
            "name": p.get("name", pid),
            "platform": p.get("platform", "?"),
            "status": p.get("status", "?"),
            "active": p.get("active", False),
            "specs": len(proj_specs),
            "plans": len(proj_plans),
            "ideas": len(proj_ideas),
            "blocked": any(pl.get("readiness_status") == "blocked" for pl in proj_plans),
        })

    # ── Risk Overview ────────────────────────────────────────────────
    risks = []
    for c in high_compliance:
        risks.append({
            "type": "compliance",
            "severity": c.get("risk_level", "?"),
            "id": c.get("report_id", "?"),
            "title": c.get("topic", "?"),
            "ext_review": c.get("external_review_needed", False),
        })
    for w in critical_watch:
        risks.append({
            "type": "watch_event",
            "severity": w.get("severity", "?"),
            "id": w.get("event_id", "?"),
            "title": w.get("title", "?"),
            "deadline": w.get("deadline", ""),
        })
    for p in blocked_plans:
        risks.append({
            "type": "blocked_plan",
            "severity": "high",
            "id": p.get("plan_id", "?"),
            "title": f"{p.get('project', '?')} — plan blocked",
            "blockers": p.get("blockers", []),
        })
    # Sort: critical first
    risks.sort(key=lambda x: 0 if x["severity"] == "critical" else 1)

    # ── AI Usage Overview ────────────────────────────────────────────
    week_start = target_date.isocalendar()
    # Compute weekly cost from last 7 days
    from datetime import timedelta
    week_start_date = target_date - timedelta(days=6)
    week_usage = [
        u for u in cost_usage
        if u.get("timestamp", "")[:10] >= week_start_date.isoformat()
        and u.get("timestamp", "")[:10] <= target_date.isoformat()
    ]
    week_cost = round(sum(u.get("estimated_cost", 0) for u in week_usage), 4)
    week_tokens = sum(u.get("total_tokens", 0) for u in week_usage)
    total_cost = round(sum(u.get("estimated_cost", 0) for u in cost_usage), 4)

    # Cost by model this week
    model_costs: dict[str, float] = {}
    for u in week_usage:
        m = u.get("model_used", "unknown")
        model_costs[m] = round(model_costs.get(m, 0) + u.get("estimated_cost", 0), 6)

    ai_usage = {
        "week_cost": f"${week_cost:.4f}",
        "week_tokens": week_tokens,
        "week_requests": len(week_usage),
        "total_cost": f"${total_cost:.4f}",
        "total_requests": len(cost_usage),
        "models_used": dict(sorted(model_costs.items(), key=lambda x: -x[1])),
        "daily_budget": cost_budgets.get("daily_budget", 0),
        "monthly_budget": cost_budgets.get("monthly_budget", 0),
    }

    # ── Research Insights ─────────────────────────────────────────────
    research_reports = _load_store("research/research_reports.json", "reports")
    high_conf_research = [
        r for r in research_reports
        if r.get("confidence", 0) >= 0.7 and r.get("status") not in ("archived", "superseded")
    ]
    kpis["research_reports"] = len(research_reports)
    kpis["research_high_confidence"] = len(high_conf_research)

    # ── Recommended Actions ──────────────────────────────────────────
    actions = _generate_strategy_actions(
        inbox_ideas, active_opps, active_trends, promotable_radar,
        high_compliance, critical_watch, blocked_plans, improvements, active_projects
    )

    # ── Generate HTML ────────────────────────────────────────────────
    from strategy.html_report import render_strategy_html
    html_content = render_strategy_html(
        week=week,
        summary=summary,
        kpis=kpis,
        top_opportunities=top_opportunities,
        top_trends=top_trends,
        project_status=project_status,
        risks=risks,
        ai_usage=ai_usage,
        actions=actions,
    )

    html_dir = os.path.join(_DIR, "html")
    os.makedirs(html_dir, exist_ok=True)
    html_path = os.path.join(html_dir, f"strategy_{week}.html")
    with open(html_path, "w", encoding="utf-8") as f:
        f.write(html_content)

    # ── Save report ──────────────────────────────────────────────────
    report = manager.add_report(
        week=week,
        summary=summary,
        top_opportunities=top_opportunities,
        top_trends=top_trends,
        project_status=project_status,
        risks=risks,
        ai_usage=ai_usage,
        recommended_actions=actions,
        kpis=kpis,
        html_path=f"strategy/html/strategy_{week}.html",
    )

    return report


def _generate_strategy_actions(inbox_ideas, active_opps, active_trends,
                                promotable_radar, high_compliance, critical_watch,
                                blocked_plans, improvements, active_projects) -> list[str]:
    """Generate prioritized strategic action items."""
    actions = []

    # Critical risks first
    if critical_watch:
        actions.append(f"Resolve {len(critical_watch)} critical/high watch events before next cycle")
    if high_compliance:
        ext = sum(1 for c in high_compliance if c.get("external_review_needed"))
        msg = f"Address {len(high_compliance)} high-risk compliance items"
        if ext:
            msg += f" ({ext} need external review)"
        actions.append(msg)
    if blocked_plans:
        actions.append(f"Unblock {len(blocked_plans)} orchestration plans to resume progress")

    # Growth opportunities
    if active_opps:
        new_opps = [o for o in active_opps if o.get("status") == "new"]
        if new_opps:
            actions.append(f"Evaluate {len(new_opps)} new opportunities for implementation potential")
    if promotable_radar:
        actions.append(f"Promote {len(promotable_radar)} high-relevance radar hits to opportunities")
    if active_trends:
        high_trends = [t for t in active_trends if t.get("relevance_score", 0) >= 0.7]
        if high_trends:
            actions.append(f"Review {len(high_trends)} high-relevance trends for idea generation")

    # Pipeline health
    if inbox_ideas:
        actions.append(f"Triage {len(inbox_ideas)} ideas in inbox — classify and prioritize")

    active_improvements = [p for p in improvements if p.get("status") not in ("completed", "rejected", "deferred")]
    high_imp = [p for p in active_improvements if p.get("severity") in ("critical", "high")]
    if high_imp:
        actions.append(f"Implement {len(high_imp)} high-priority factory improvements")

    if not active_projects:
        actions.append("No active projects — bootstrap or activate at least one project")

    if not actions:
        actions.append("Factory running smoothly — focus on growth and new opportunities")

    return actions


if __name__ == "__main__":
    report = generate_weekly_report()
    rid = report.get("report_id", "?")
    week = report.get("week", "?")
    actions = report.get("recommended_actions", [])
    kpis = report.get("kpis", {})
    html = report.get("html_path", "")

    print(f"Strategy Report: {rid} ({week})")
    print(f"  Projects: {kpis.get('projects', 0)} | Ideas: {kpis.get('ideas_total', 0)} | Opportunities: {kpis.get('opportunities', 0)}")
    print(f"  Risks: {len(report.get('risks', []))} | Trends: {kpis.get('trends', 0)}")
    print(f"  Actions:")
    for a in actions:
        print(f"    - {a}")
    if html:
        print(f"  HTML: {html}")
