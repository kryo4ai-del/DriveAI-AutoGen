"""Specs — View implementation specifications."""

import streamlit as st
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
from store_reader import StoreReader

st.set_page_config(page_title="Specs — Factory Control Center", page_icon="📋", layout="wide")

st.title("Specs")
reader = StoreReader()
specs = reader.specs()

st.caption(f"{len(specs)} total specs")

if not specs:
    st.info("No specs created yet. Create specs from prioritized ideas.")
    st.stop()

# Filters
col1, col2 = st.columns(2)
statuses = sorted({s.get("status", "unknown") for s in specs})
spec_projects = sorted({s.get("project", "—") for s in specs})

with col1:
    sel_status = st.selectbox("Status", ["all"] + statuses)
with col2:
    sel_project = st.selectbox("Project", ["all"] + spec_projects)

filtered = specs
if sel_status != "all":
    filtered = [s for s in filtered if s.get("status") == sel_status]
if sel_project != "all":
    filtered = [s for s in filtered if s.get("project", "—") == sel_project]

st.markdown("---")
st.caption(f"Showing {len(filtered)} of {len(specs)} specs")

for spec in filtered:
    with st.expander(f"{spec.get('spec_id', '?')} — {spec.get('title', 'Untitled')}"):
        c1, c2, c3, c4 = st.columns(4)
        c1.markdown(f"**Status**: `{spec.get('status', '?')}`")
        c2.markdown(f"**Priority**: `{spec.get('priority', '—')}`")
        c3.markdown(f"**Type**: `{spec.get('type', '—')}`")
        c4.markdown(f"**Project**: `{spec.get('project', '—')}`")

        if spec.get("linked_idea_id"):
            st.markdown(f"**Linked Idea**: `{spec['linked_idea_id']}`")
        if spec.get("goal"):
            st.markdown(f"**Goal**: {spec['goal']}")
        if spec.get("summary"):
            st.markdown(f"**Summary**: {spec['summary']}")

        if spec.get("in_scope"):
            st.markdown("**In Scope**:")
            for item in spec["in_scope"]:
                st.text(f"  - {item}")

        if spec.get("out_of_scope"):
            st.markdown("**Out of Scope**:")
            for item in spec["out_of_scope"]:
                st.text(f"  - {item}")

        if spec.get("acceptance_criteria"):
            st.markdown("**Acceptance Criteria**:")
            for ac in spec["acceptance_criteria"]:
                st.text(f"  - {ac}")

        if spec.get("suggested_template"):
            st.markdown(f"**Suggested Template**: `{spec['suggested_template']}`")
        if spec.get("suggested_agents"):
            st.markdown(f"**Suggested Agents**: {', '.join(spec['suggested_agents'])}")
        if spec.get("created_at"):
            st.caption(f"Created: {spec['created_at']}")
