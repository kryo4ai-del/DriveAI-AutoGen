"""
Factory Control Center — Main App
Lightweight Streamlit dashboard for the AI App Factory.
"""

import streamlit as st
from pathlib import Path

st.set_page_config(
    page_title="Factory Control Center",
    page_icon="🏭",
    layout="wide",
    initial_sidebar_state="expanded",
)

# --- Sidebar ---
st.sidebar.title("Factory Control Center")
st.sidebar.caption("AI App Factory — v1")

# --- Main: Overview ---
st.title("Factory Control Center")
st.markdown("---")

# Load all stores
from store_reader import StoreReader

reader = StoreReader()

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

# --- KPI Row ---
cols = st.columns(5)
cols[0].metric("Agents", 20)
cols[1].metric("Projects", len(projects))
cols[2].metric("Ideas", len(ideas))
cols[3].metric("Specs", len(specs))
cols[4].metric("Orchestration Plans", len(orchestration))

cols2 = st.columns(5)
cols2[0].metric("Opportunities", len(opportunities))
cols2[1].metric("Watch Events", len(watch))
cols2[2].metric("Compliance Reports", len(compliance))
cols2[3].metric("A11Y Reports", len(a11y))
cols2[4].metric("Content Items", len(content))

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
        st.info("No ideas yet.")

    st.subheader("Compliance by Risk Level")
    if compliance:
        risk_counts = {}
        for r in compliance:
            level = r.get("risk_level", "unknown")
            risk_counts[level] = risk_counts.get(level, 0) + 1
        for level in ["critical", "high", "medium", "low"]:
            if level in risk_counts:
                st.text(f"  {level}: {risk_counts[level]}")
    else:
        st.info("No compliance reports.")

with right:
    st.subheader("Active Projects")
    if projects:
        for p in projects:
            active = p.get("active", False)
            icon = "🟢" if active else "⚪"
            st.text(f"  {icon} {p.get('name', p.get('id', '?'))} — {p.get('platform', '?')} — {p.get('status', '?')}")
    else:
        st.info("No projects registered.")

    st.subheader("Orchestration Plans")
    if orchestration:
        for plan in orchestration:
            st.text(f"  {plan.get('plan_id', '?')} — {plan.get('project', '?')} — {plan.get('status', '?')}")
    else:
        st.info("No orchestration plans.")

# --- Recent / High Priority ---
st.markdown("---")
st.subheader("High Priority Items")

high_prio_ideas = [i for i in ideas if i.get("priority") == "now"]
high_risk_compliance = [c for c in compliance if c.get("risk_level") in ("critical", "high")]
critical_watch = [w for w in watch if w.get("severity") in ("critical", "high")]

if high_prio_ideas or high_risk_compliance or critical_watch:
    if high_prio_ideas:
        st.markdown("**Ideas (priority: now)**")
        for idea in high_prio_ideas:
            st.text(f"  {idea.get('id', '?')}: {idea.get('title', '?')} [{idea.get('status', '?')}]")

    if high_risk_compliance:
        st.markdown("**Compliance (high/critical risk)**")
        for r in high_risk_compliance:
            st.text(f"  {r.get('report_id', '?')}: {r.get('topic', '?')} — {r.get('risk_level', '?')} [{r.get('status', '?')}]")

    if critical_watch:
        st.markdown("**Watch Events (high/critical)**")
        for w in critical_watch:
            st.text(f"  {w.get('event_id', '?')}: {w.get('title', '?')} — {w.get('severity', '?')} [{w.get('status', '?')}]")
else:
    st.info("No high-priority items right now.")
