"""Content — Marketing copy, video scripts, release notes."""

import streamlit as st
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
from store_reader import StoreReader

st.set_page_config(page_title="Content — Factory Control Center", page_icon="📝", layout="wide")

st.title("Content")
reader = StoreReader()
content = reader.content()

st.caption(f"{len(content)} total content items")

if not content:
    st.info("No content items yet. The ContentScriptAgent generates marketing copy, scripts, and release notes.")
    st.stop()

# Filters
col1, col2 = st.columns(2)
statuses = sorted({c.get("status", "unknown") for c in content})
types = sorted({c.get("type", "unknown") for c in content})

with col1:
    sel_status = st.selectbox("Status", ["all"] + statuses)
with col2:
    sel_type = st.selectbox("Type", ["all"] + types)

filtered = content
if sel_status != "all":
    filtered = [c for c in filtered if c.get("status") == sel_status]
if sel_type != "all":
    filtered = [c for c in filtered if c.get("type") == sel_type]

st.markdown("---")
st.caption(f"Showing {len(filtered)} of {len(content)} items")

for item in filtered:
    with st.expander(f"{item.get('content_id', '?')} — {item.get('title', 'Untitled')}"):
        c1, c2, c3 = st.columns(3)
        c1.markdown(f"**Status**: `{item.get('status', '?')}`")
        c2.markdown(f"**Type**: `{item.get('type', '—')}`")
        c3.markdown(f"**Project**: `{item.get('project', '—')}`")

        if item.get("audience"):
            st.markdown(f"**Audience**: {item['audience']}")
        if item.get("tone"):
            st.markdown(f"**Tone**: `{item['tone']}`")
        if item.get("summary"):
            st.markdown(f"**Summary**: {item['summary']}")
        if item.get("draft"):
            st.markdown("**Draft**:")
            st.text_area("", value=item["draft"], height=200, disabled=True, key=item.get("content_id", "draft"))
        if item.get("linked_spec_id"):
            st.markdown(f"**Linked Spec**: `{item['linked_spec_id']}`")
        if item.get("created_at"):
            st.caption(f"Created: {item['created_at']}")
