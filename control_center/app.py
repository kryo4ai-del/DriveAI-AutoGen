"""
Factory Control Center — Overview & Insights Dashboard
Lightweight Streamlit dashboard for the AI App Factory.
"""

import streamlit as st
from datetime import datetime, timezone

st.set_page_config(
    page_title="AI App Factory — Control Center",
    page_icon="🏭",
    layout="wide",
    initial_sidebar_state="expanded",
)

# --- Sidebar ---
st.sidebar.title("AI App Factory")
st.sidebar.caption("Factory Control Center v1")
st.sidebar.markdown("---")

from store_reader import StoreReader

reader = StoreReader()

# Sidebar: system info
toggles = reader.agent_toggles()
agent_count = len(toggles) if toggles else 0
active_agents = sum(1 for v in toggles.values() if v) if toggles else 0
st.sidebar.markdown(f"**Agents**: {active_agents}/{agent_count} active")
st.sidebar.markdown(f"**Data root**: `{reader.root_path}`")
st.sidebar.markdown(f"**Last store update**: {reader.latest_store_update()}")

if not reader.factory_root_valid():
    st.sidebar.error("Factory root not found — check FACTORY_ROOT env or volume mount.")

st.sidebar.markdown("---")
st.sidebar.caption(f"Loaded: {datetime.now(timezone.utc).strftime('%Y-%m-%d %H:%M UTC')}")

# --- Load all stores ---
ideas = reader.ideas()
projects = reader.projects()
specs = reader.specs()
content = reader.content()
watch = reader.watch_events()
a11y = reader.accessibility()
compliance = reader.compliance()
opportunities = reader.opportunities()
orchestration = reader.orchestration()
bootstrap = reader.bootstrap()

# --- Header ---
st.title("AI App Factory — Control Center")

# --- System Health ---
health = reader.store_health()
stores_found = sum(1 for h in health.values() if h["exists"])
stores_total = len(health)

if stores_found == stores_total:
    st.success(f"All {stores_total} data stores connected.")
elif stores_found > 0:
    st.warning(f"{stores_found}/{stores_total} data stores found. Some stores may not exist yet.")
else:
    st.error("No data stores found. Check factory root path or volume mount.")

st.markdown("---")

# --- KPI Row ---
st.subheader("Factory Overview")

cols = st.columns(5)
cols[0].metric("Agents", f"{active_agents}")
cols[1].metric("Projects", len(projects))
cols[2].metric("Ideas", len(ideas))
cols[3].metric("Specs", len(specs))
cols[4].metric("Plans", len(orchestration))

cols2 = st.columns(5)
cols2[0].metric("Opportunities", len(opportunities))
cols2[1].metric("Watch Events", len(watch))
cols2[2].metric("Compliance", len(compliance))
cols2[3].metric("Accessibility", len(a11y))
cols2[4].metric("Content", len(content))

# =====================================================================
# ALERTS & INSIGHTS
# =====================================================================
st.markdown("---")

# Pre-compute alert lists
high_prio_ideas = [i for i in ideas if i.get("priority") == "now"]
blocked_ideas = [i for i in ideas if i.get("status") == "blocked"]
high_risk_compliance = [c for c in compliance if c.get("risk_level") in ("critical", "high")]
ext_review_compliance = [c for c in compliance if c.get("external_review_needed") and c.get("status") not in ("dismissed", "accepted")]
critical_watch = [w for w in watch if w.get("severity") in ("critical", "high") and w.get("status") not in ("resolved", "dismissed")]
blocked_specs = [s for s in specs if s.get("status") == "rejected"]
blocked_plans = [p for p in orchestration if p.get("readiness_status") == "blocked"]
executing_plans = [p for p in orchestration if p.get("status") == "executing"]
open_a11y = [r for r in a11y if r.get("status") in ("new", "acknowledged") and r.get("severity") in ("critical", "high")]
active_opps = [o for o in opportunities if o.get("status") in ("new", "evaluated", "accepted")]

total_alerts = (
    len(high_prio_ideas) + len(blocked_ideas) + len(high_risk_compliance)
    + len(ext_review_compliance) + len(critical_watch) + len(blocked_plans)
    + len(open_a11y)
)

# --- Alerts Banner ---
if total_alerts > 0:
    st.error(f"**{total_alerts} items need attention**")
else:
    st.info("No urgent items right now.")

# =====================================================================
# HIGH PRIORITY & BLOCKED
# =====================================================================
st.subheader("Alerts & Blocked Items")

alert_left, alert_right = st.columns(2)

with alert_left:
    # High Priority Ideas
    if high_prio_ideas:
        st.markdown("**Ideas — priority: now**")
        for idea in high_prio_ideas:
            st.text(f"  🔴 {idea.get('id', '?')}: {idea.get('title', '?')} [{idea.get('status', '?')}]")

    # Blocked Ideas
    if blocked_ideas:
        st.markdown("**Ideas — blocked**")
        for idea in blocked_ideas:
            st.text(f"  🚫 {idea.get('id', '?')}: {idea.get('title', '?')}")

    # Blocked Orchestration Plans
    if blocked_plans:
        st.markdown("**Orchestration — blocked plans**")
        for p in blocked_plans:
            blockers = p.get("blockers", [])
            blocker_text = f" ({', '.join(blockers[:2])})" if blockers else ""
            st.text(f"  🚫 {p.get('plan_id', '?')}: {p.get('project', '?')}{blocker_text}")

    # Executing Plans
    if executing_plans:
        st.markdown("**Orchestration — currently executing**")
        for p in executing_plans:
            st.text(f"  ⚡ {p.get('plan_id', '?')}: {p.get('project', '?')} — {p.get('recommended_phase', '?')}")

    if not (high_prio_ideas or blocked_ideas or blocked_plans or executing_plans):
        st.caption("No idea or plan alerts.")

with alert_right:
    # High Risk Compliance
    if high_risk_compliance:
        st.markdown("**Compliance — high/critical risk**")
        for r in high_risk_compliance:
            icon = "🔴" if r.get("risk_level") == "critical" else "🟠"
            st.text(f"  {icon} {r.get('report_id', '?')}: {r.get('topic', '?')} [{r.get('status', '?')}]")

    # External Review Needed
    if ext_review_compliance:
        st.markdown("**Compliance — external review needed**")
        for r in ext_review_compliance:
            st.text(f"  ⚠️ {r.get('report_id', '?')}: {r.get('topic', '?')}")

    # Critical Watch Events
    if critical_watch:
        st.markdown("**Watch Events — high/critical**")
        for w in critical_watch:
            icon = "🔴" if w.get("severity") == "critical" else "🟠"
            deadline = f" (deadline: {w['deadline']})" if w.get("deadline") else ""
            st.text(f"  {icon} {w.get('event_id', '?')}: {w.get('title', '?')}{deadline}")

    # Critical A11Y
    if open_a11y:
        st.markdown("**Accessibility — high/critical open issues**")
        for r in open_a11y:
            icon = "🔴" if r.get("severity") == "critical" else "🟠"
            st.text(f"  {icon} {r.get('report_id', '?')}: {r.get('issue_type', '?')} in {r.get('file', '?')}")

    if not (high_risk_compliance or ext_review_compliance or critical_watch or open_a11y):
        st.caption("No compliance, watch, or accessibility alerts.")

# =====================================================================
# PROJECT READINESS
# =====================================================================
st.markdown("---")
st.subheader("Project Readiness")

if projects or bootstrap:
    all_projects = []

    # Registered projects
    for p in projects:
        pid = p.get("id", "?")
        name = p.get("name", pid)
        platform = p.get("platform", "?")
        status = p.get("status", "?")
        active = p.get("active", False)

        # Count linked items
        proj_ideas = [i for i in ideas if i.get("project") == pid]
        proj_specs = [s for s in specs if s.get("project") == pid]
        proj_plans = [pl for pl in orchestration if pl.get("project") == pid]
        proj_compliance = [c for c in compliance if c.get("project") == pid]
        proj_a11y = [r for r in a11y if r.get("project") == pid]

        inbox_ideas = sum(1 for i in proj_ideas if i.get("status") == "inbox")
        open_specs = sum(1 for s in proj_specs if s.get("status") in ("draft", "review", "approved", "in-progress"))
        active_plans = sum(1 for pl in proj_plans if pl.get("status") in ("draft", "approved", "executing"))
        open_compliance = sum(1 for c in proj_compliance if c.get("status") not in ("dismissed", "accepted"))
        open_a11y_count = sum(1 for r in proj_a11y if r.get("status") in ("new", "acknowledged"))

        all_projects.append({
            "name": name, "pid": pid, "platform": platform, "status": status,
            "active": active, "type": "registered",
            "ideas": len(proj_ideas), "inbox": inbox_ideas,
            "specs": len(proj_specs), "open_specs": open_specs,
            "plans": len(proj_plans), "active_plans": active_plans,
            "compliance": open_compliance, "a11y": open_a11y_count,
        })

    # Bootstrapped projects
    for bp in bootstrap:
        all_projects.append({
            "name": bp.get("name", "?"), "pid": bp.get("project_id", "?"),
            "platform": bp.get("platform", "?"), "status": bp.get("status", "?"),
            "active": bp.get("status") not in ("paused", "archived"), "type": "bootstrapped",
            "ideas": 0, "inbox": 0, "specs": 0, "open_specs": 0,
            "plans": 0, "active_plans": 0, "compliance": 0, "a11y": 0,
        })

    for proj in all_projects:
        active_icon = "🟢" if proj["active"] else "⚪"
        type_badge = "" if proj["type"] == "registered" else " (bootstrapped)"

        with st.expander(f"{active_icon} {proj['name']} — {proj['platform']} — {proj['status']}{type_badge}"):
            c1, c2, c3, c4 = st.columns(4)
            c1.metric("Ideas", proj["ideas"], f"{proj['inbox']} inbox" if proj["inbox"] else None)
            c2.metric("Specs", proj["specs"], f"{proj['open_specs']} open" if proj["open_specs"] else None)
            c3.metric("Plans", proj["plans"], f"{proj['active_plans']} active" if proj["active_plans"] else None)
            c4.metric("Open Issues", proj["compliance"] + proj["a11y"],
                       f"{proj['compliance']} compliance, {proj['a11y']} a11y" if (proj["compliance"] or proj["a11y"]) else None)
else:
    st.caption("No projects registered or bootstrapped.")

# =====================================================================
# IDEA PIPELINE
# =====================================================================
st.markdown("---")
st.subheader("Idea Pipeline")

if ideas:
    # Status flow counts
    pipeline_statuses = ["inbox", "classified", "prioritized", "spec-ready", "done", "blocked", "parked"]
    status_counts = {}
    for idea in ideas:
        s = idea.get("status", "unknown")
        status_counts[s] = status_counts.get(s, 0) + 1

    pipeline_cols = st.columns(len(pipeline_statuses))
    for i, status in enumerate(pipeline_statuses):
        count = status_counts.get(status, 0)
        pipeline_cols[i].metric(status, count)
else:
    st.caption("No ideas in the pipeline.")

# =====================================================================
# RECENT ACTIVITY (sorted by created_at/detected_at)
# =====================================================================
st.markdown("---")
st.subheader("Recent Activity")

# Collect recent items from all stores with timestamps
recent_items = []

for idea in ideas:
    if idea.get("created_at"):
        recent_items.append({
            "date": idea["created_at"],
            "type": "Idea",
            "id": idea.get("id", "?"),
            "title": idea.get("title", "?"),
            "status": idea.get("status", "?"),
        })

for spec in specs:
    if spec.get("created_at"):
        recent_items.append({
            "date": spec["created_at"],
            "type": "Spec",
            "id": spec.get("spec_id", "?"),
            "title": spec.get("title", "?"),
            "status": spec.get("status", "?"),
        })

for plan in orchestration:
    if plan.get("created_at"):
        recent_items.append({
            "date": plan["created_at"],
            "type": "Plan",
            "id": plan.get("plan_id", "?"),
            "title": plan.get("project", "?"),
            "status": plan.get("status", "?"),
        })

for opp in opportunities:
    if opp.get("detected_at"):
        recent_items.append({
            "date": opp["detected_at"],
            "type": "Opportunity",
            "id": opp.get("opportunity_id", "?"),
            "title": opp.get("title", "?"),
            "status": opp.get("status", "?"),
        })

for w in watch:
    if w.get("detected_at"):
        recent_items.append({
            "date": w["detected_at"],
            "type": "Watch",
            "id": w.get("event_id", "?"),
            "title": w.get("title", "?"),
            "status": w.get("status", "?"),
        })

for r in compliance:
    if r.get("created_at"):
        recent_items.append({
            "date": r["created_at"],
            "type": "Compliance",
            "id": r.get("report_id", "?"),
            "title": r.get("topic", "?"),
            "status": r.get("status", "?"),
        })

for r in a11y:
    if r.get("detected_at"):
        recent_items.append({
            "date": r["detected_at"],
            "type": "A11Y",
            "id": r.get("report_id", "?"),
            "title": f"{r.get('issue_type', '?')} in {r.get('file', '?')}",
            "status": r.get("status", "?"),
        })

for c in content:
    if c.get("created_at"):
        recent_items.append({
            "date": c["created_at"],
            "type": "Content",
            "id": c.get("content_id", "?"),
            "title": c.get("title", "?"),
            "status": c.get("status", "?"),
        })

# Sort by date descending, show latest 15
recent_items.sort(key=lambda x: x["date"], reverse=True)
recent_items = recent_items[:15]

if recent_items:
    for item in recent_items:
        type_icons = {
            "Idea": "💡", "Spec": "📋", "Plan": "🎯", "Opportunity": "🔍",
            "Watch": "👁", "Compliance": "⚖️", "A11Y": "♿", "Content": "📝",
        }
        icon = type_icons.get(item["type"], "📌")
        st.text(f"  {item['date']}  {icon} {item['type']:11s}  {item['id']:12s}  {item['title'][:50]}  [{item['status']}]")
else:
    st.caption("No recent activity found.")

# =====================================================================
# OPPORTUNITIES & WATCH SUMMARY
# =====================================================================
st.markdown("---")
opp_col, watch_col = st.columns(2)

with opp_col:
    st.subheader("Opportunities")
    if active_opps:
        for opp in active_opps[:8]:
            relevance_icons = {"critical": "🔴", "high": "🟠", "medium": "🟡", "low": "🟢"}
            icon = relevance_icons.get(opp.get("market_relevance", ""), "⚪")
            st.text(f"  {icon} {opp.get('opportunity_id', '?')}: {opp.get('title', '?')[:40]} [{opp.get('status', '?')}]")
    else:
        st.caption("No active opportunities.")

with watch_col:
    st.subheader("Watch Events")
    active_watch = [w for w in watch if w.get("status") not in ("resolved", "dismissed")]
    if active_watch:
        sev_icons = {"critical": "🔴", "high": "🟠", "medium": "🟡", "low": "🟢", "info": "⚪"}
        for w in active_watch[:8]:
            icon = sev_icons.get(w.get("severity", ""), "⚪")
            deadline = f" — {w['deadline']}" if w.get("deadline") else ""
            st.text(f"  {icon} {w.get('event_id', '?')}: {w.get('title', '?')[:40]}{deadline}")
    else:
        st.caption("No active watch events.")

# =====================================================================
# DATA STORE HEALTH (collapsed)
# =====================================================================
st.markdown("---")
with st.expander("Data Store Health"):
    for name, info in health.items():
        icon = "🟢" if info["exists"] else "🔴"
        st.text(f"  {icon} {name}: {info['count']} items — modified {info['last_modified']} — {info['path']}")
