"""Compliance Reports — Legal and regulatory risk tracking."""

import streamlit as st
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
from store_reader import StoreReader

st.set_page_config(page_title="Compliance", page_icon="⚖", layout="wide")
st.title("Compliance Reports")

reader = StoreReader()
reports = reader.compliance()

if not reports:
    st.info("No compliance reports yet.")
    st.stop()

RISK_ICONS = {"critical": "🔴", "high": "🟠", "medium": "🟡", "low": "🟢"}

col1, col2 = st.columns(2)
statuses = sorted({r.get("status", "unknown") for r in reports})
topics = sorted({r.get("topic", "unknown") for r in reports})

with col1:
    sel_status = st.selectbox("Status", ["all"] + statuses)
with col2:
    sel_topic = st.selectbox("Topic", ["all"] + topics)

filtered = reports
if sel_status != "all":
    filtered = [r for r in filtered if r.get("status") == sel_status]
if sel_topic != "all":
    filtered = [r for r in filtered if r.get("topic") == sel_topic]

st.caption(f"Showing {len(filtered)} of {len(reports)} reports")

for r in filtered:
    risk = r.get("risk_level", "low")
    icon = RISK_ICONS.get(risk, "⚪")
    with st.expander(f"{icon} {r.get('report_id', '?')} — {r.get('topic', 'Untitled')} ({risk})"):
        c1, c2, c3 = st.columns(3)
        c1.markdown(f"**Risk Level**: `{risk}`")
        c2.markdown(f"**Status**: `{r.get('status', '?')}`")
        c3.markdown(f"**Project**: `{r.get('project', '—')}`")

        if r.get("summary"):
            st.markdown(f"**Summary**: {r['summary']}")
        if r.get("possible_blockers"):
            st.markdown("**Possible Blockers**:")
            for b in r["possible_blockers"]:
                st.text(f"  - {b}")
        if r.get("recommended_next_step"):
            st.markdown(f"**Next Step**: {r['recommended_next_step']}")
        if r.get("external_review_needed"):
            st.warning("External review needed")
        if r.get("linked_idea_id"):
            st.markdown(f"**Linked Idea**: `{r['linked_idea_id']}`")
        if r.get("linked_spec_id"):
            st.markdown(f"**Linked Spec**: `{r['linked_spec_id']}`")
        if r.get("created_at"):
            st.caption(f"Created: {r['created_at']}")
