"""Orchestration Plans — Execution planning and delivery tracker."""

import streamlit as st
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
from store_reader import StoreReader

st.set_page_config(page_title="Orchestration — Factory Control Center", page_icon="🎯", layout="wide")

STATUS_ICONS = {"draft": "📝", "approved": "✅", "executing": "⚡", "completed": "🏁", "cancelled": "❌"}

st.title("Orchestration Plans")
reader = StoreReader()
plans = reader.orchestration()

st.caption(f"{len(plans)} total orchestration plans")

if not plans:
    st.info("No orchestration plans yet. The AutonomousProjectOrchestrator creates these.")
    st.stop()

# Filters
col1, col2 = st.columns(2)
statuses = sorted({p.get("status", "unknown") for p in plans})
plan_projects = sorted({p.get("project", "—") for p in plans})

with col1:
    sel_status = st.selectbox("Status", ["all"] + statuses)
with col2:
    sel_project = st.selectbox("Project", ["all"] + plan_projects)

filtered = plans
if sel_status != "all":
    filtered = [p for p in filtered if p.get("status") == sel_status]
if sel_project != "all":
    filtered = [p for p in filtered if p.get("project", "—") == sel_project]

st.markdown("---")
st.caption(f"Showing {len(filtered)} of {len(plans)} plans")

for plan in filtered:
    status = plan.get("status", "draft")
    icon = STATUS_ICONS.get(status, "📝")
    with st.expander(f"{icon} {plan.get('plan_id', '?')} — {plan.get('project', '?')} [{status}]"):
        c1, c2, c3 = st.columns(3)
        c1.markdown(f"**Status**: `{status}`")
        c2.markdown(f"**Readiness**: `{plan.get('readiness_status', '—')}`")
        c3.markdown(f"**Phase**: `{plan.get('recommended_phase', '—')}`")

        if plan.get("suggested_next_run_type"):
            st.markdown(f"**Next Run Type**: `{plan['suggested_next_run_type']}`")

        if plan.get("selected_agents"):
            st.markdown(f"**Selected Agents**: {', '.join(plan['selected_agents'])}")

        if plan.get("linked_spec_ids"):
            st.markdown(f"**Linked Specs**: {', '.join(plan['linked_spec_ids'])}")

        if plan.get("execution_steps"):
            st.markdown("**Execution Steps**:")
            for i, step in enumerate(plan["execution_steps"], 1):
                st.text(f"  {i}. {step}")

        if plan.get("blockers"):
            st.markdown("**Blockers**:")
            for b in plan["blockers"]:
                st.text(f"  - {b}")

        if plan.get("risks"):
            st.markdown("**Risks**:")
            for r in plan["risks"]:
                st.text(f"  - {r}")

        if plan.get("notes"):
            st.markdown(f"**Notes**: {plan['notes']}")
        if plan.get("created_at"):
            st.caption(f"Created: {plan['created_at']}")
