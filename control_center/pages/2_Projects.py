"""Projects — View registered projects and bootstrapped projects."""

import streamlit as st
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
from store_reader import StoreReader

st.set_page_config(page_title="Projects", page_icon="📦", layout="wide")
st.title("Projects")

reader = StoreReader()

# --- Registered Projects ---
st.subheader("Registered Projects")
projects = reader.projects()

if projects:
    for p in projects:
        active = p.get("active", False)
        icon = "🟢" if active else "⚪"
        with st.expander(f"{icon} {p.get('name', p.get('id', '?'))} — {p.get('platform', '?')}"):
            c1, c2, c3 = st.columns(3)
            c1.markdown(f"**ID**: `{p.get('id', '?')}`")
            c2.markdown(f"**Platform**: `{p.get('platform', '?')}`")
            c3.markdown(f"**Status**: `{p.get('status', '?')}`")
            if p.get("description"):
                st.markdown(f"**Description**: {p['description']}")
            if p.get("notes"):
                st.markdown(f"**Notes**: {p['notes']}")
else:
    st.info("No projects registered.")

# --- Bootstrapped Projects ---
st.markdown("---")
st.subheader("Bootstrapped Projects")
bootstrap = reader.bootstrap()

if bootstrap:
    for bp in bootstrap:
        with st.expander(f"{bp.get('project_id', '?')} — {bp.get('name', 'Untitled')}"):
            c1, c2, c3 = st.columns(3)
            c1.markdown(f"**Category**: `{bp.get('category', '?')}`")
            c2.markdown(f"**Platform**: `{bp.get('platform', '?')}`")
            c3.markdown(f"**Status**: `{bp.get('status', '?')}`")

            if bp.get("secondary_platforms"):
                st.markdown(f"**Secondary Platforms**: {', '.join(bp['secondary_platforms'])}")
            if bp.get("linked_idea"):
                st.markdown(f"**Linked Idea**: `{bp['linked_idea']}`")
            if bp.get("description"):
                st.markdown(f"**Description**: {bp['description']}")
            if bp.get("created_at"):
                st.caption(f"Created: {bp['created_at']}")
else:
    st.info("No bootstrapped projects.")
