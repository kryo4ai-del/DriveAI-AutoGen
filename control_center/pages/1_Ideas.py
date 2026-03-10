"""Ideas — View and filter all factory ideas."""

import streamlit as st
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
from store_reader import StoreReader

st.set_page_config(page_title="Ideas — Factory Control Center", page_icon="💡", layout="wide")

st.title("Ideas")
reader = StoreReader()
ideas = reader.ideas()

st.caption(f"{len(ideas)} total ideas")

if not ideas:
    st.info("No ideas in the factory yet. Use the Factory CLI or Claude to add ideas.")
    st.stop()

# Filters
col1, col2, col3 = st.columns(3)
statuses = sorted({i.get("status", "unknown") for i in ideas})
priorities = sorted({i.get("priority", "—") for i in ideas})
idea_projects = sorted({i.get("project", "—") for i in ideas})

with col1:
    sel_status = st.selectbox("Status", ["all"] + statuses)
with col2:
    sel_priority = st.selectbox("Priority", ["all"] + priorities)
with col3:
    sel_project = st.selectbox("Project", ["all"] + idea_projects)

filtered = ideas
if sel_status != "all":
    filtered = [i for i in filtered if i.get("status") == sel_status]
if sel_priority != "all":
    filtered = [i for i in filtered if i.get("priority", "—") == sel_priority]
if sel_project != "all":
    filtered = [i for i in filtered if i.get("project", "—") == sel_project]

st.markdown("---")
st.caption(f"Showing {len(filtered)} of {len(ideas)} ideas")

for idea in filtered:
    with st.expander(f"{idea.get('id', '?')} — {idea.get('title', 'Untitled')}"):
        c1, c2, c3, c4 = st.columns(4)
        c1.markdown(f"**Status**: `{idea.get('status', '?')}`")
        c2.markdown(f"**Priority**: `{idea.get('priority', '—')}`")
        c3.markdown(f"**Scope**: `{idea.get('scope', '—')}`")
        c4.markdown(f"**Project**: `{idea.get('project', '—')}`")

        st.markdown(f"**Type**: `{idea.get('type', '—')}`  |  **Source**: `{idea.get('source', '—')}`")

        if idea.get("raw_idea"):
            st.markdown(f"**Description**: {idea['raw_idea']}")
        if idea.get("notes"):
            st.markdown(f"**Notes**: {idea['notes']}")
        if idea.get("created_at"):
            st.caption(f"Created: {idea['created_at']}")
