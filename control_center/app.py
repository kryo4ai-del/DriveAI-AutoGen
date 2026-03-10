"""
Factory Control Center — Overview
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

st.markdown("---")

# --- Status Breakdown ---
left, right = st.columns(2)

with left:
    st.subheader("Ideas by Status")
    if ideas:
        status_counts = {}
        for idea in ideas:
            s = idea.get("status", "unknown")
            status_counts[s] = status_counts.get(s, 0) + 1
        for status, count in sorted(status_counts.items()):
            st.text(f"  {status}: {count}")
    else:
        st.caption("No ideas yet.")

    st.subheader("Compliance by Risk Level")
    if compliance:
        risk_counts = {}
        for r in compliance:
            level = r.get("risk_level", "unknown")
            risk_counts[level] = risk_counts.get(level, 0) + 1
        for level in ["critical", "high", "medium", "low"]:
            if level in risk_counts:
                icon = {"critical": "🔴", "high": "🟠", "medium": "🟡", "low": "🟢"}.get(level, "⚪")
                st.text(f"  {icon} {level}: {risk_counts[level]}")
    else:
        st.caption("No compliance reports.")

with right:
    st.subheader("Active Projects")
    if projects:
        for p in projects:
            active = p.get("active", False)
            icon = "🟢" if active else "⚪"
            st.text(f"  {icon} {p.get('name', p.get('id', '?'))} — {p.get('platform', '?')} — {p.get('status', '?')}")
    else:
        st.caption("No projects registered.")

    st.subheader("Orchestration Plans")
    if orchestration:
        status_icons = {"draft": "📝", "approved": "✅", "executing": "⚡", "completed": "🏁", "cancelled": "❌"}
        for plan in orchestration:
            s = plan.get("status", "draft")
            icon = status_icons.get(s, "📝")
            st.text(f"  {icon} {plan.get('plan_id', '?')} — {plan.get('project', '?')} [{s}]")
    else:
        st.caption("No orchestration plans.")

# --- High Priority ---
st.markdown("---")
st.subheader("High Priority Items")

high_prio_ideas = [i for i in ideas if i.get("priority") == "now"]
high_risk_compliance = [c for c in compliance if c.get("risk_level") in ("critical", "high")]
critical_watch = [w for w in watch if w.get("severity") in ("critical", "high")]
blocked_plans = [p for p in orchestration if p.get("readiness_status") == "blocked"]

has_alerts = high_prio_ideas or high_risk_compliance or critical_watch or blocked_plans

if has_alerts:
    if high_prio_ideas:
        st.markdown("**Ideas — priority: now**")
        for idea in high_prio_ideas:
            st.text(f"  {idea.get('id', '?')}: {idea.get('title', '?')} [{idea.get('status', '?')}]")

    if high_risk_compliance:
        st.markdown("**Compliance — high/critical risk**")
        for r in high_risk_compliance:
            st.text(f"  {r.get('report_id', '?')}: {r.get('topic', '?')} — {r.get('risk_level', '?')} [{r.get('status', '?')}]")

    if critical_watch:
        st.markdown("**Watch Events — high/critical severity**")
        for w in critical_watch:
            st.text(f"  {w.get('event_id', '?')}: {w.get('title', '?')} — {w.get('severity', '?')} [{w.get('status', '?')}]")

    if blocked_plans:
        st.markdown("**Orchestration — blocked plans**")
        for p in blocked_plans:
            st.text(f"  {p.get('plan_id', '?')}: {p.get('project', '?')} — blocked")
else:
    st.caption("No high-priority items right now.")

# --- Data Store Health ---
st.markdown("---")
with st.expander("Data Store Health"):
    for name, info in health.items():
        icon = "🟢" if info["exists"] else "🔴"
        st.text(f"  {icon} {name}: {info['count']} items — modified {info['last_modified']} — {info['path']}")
