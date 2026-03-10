"""Watch Events — Ecosystem monitoring dashboard."""

import streamlit as st
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
from store_reader import StoreReader

st.set_page_config(page_title="Watch Events — Factory Control Center", page_icon="👁", layout="wide")

SEVERITY_ICONS = {"critical": "🔴", "high": "🟠", "medium": "🟡", "low": "🟢", "info": "⚪"}

st.title("Watch Events")
reader = StoreReader()
events = reader.watch_events()

st.caption(f"{len(events)} total watch events")

if not events:
    st.info("No watch events tracked yet. The ChangeWatchAgent monitors ecosystem changes.")
    st.stop()

# Filters
col1, col2 = st.columns(2)
statuses = sorted({e.get("status", "unknown") for e in events})
severities = sorted({e.get("severity", "unknown") for e in events})

with col1:
    sel_status = st.selectbox("Status", ["all"] + statuses)
with col2:
    sel_severity = st.selectbox("Severity", ["all"] + severities)

filtered = events
if sel_status != "all":
    filtered = [e for e in filtered if e.get("status") == sel_status]
if sel_severity != "all":
    filtered = [e for e in filtered if e.get("severity") == sel_severity]

st.markdown("---")
st.caption(f"Showing {len(filtered)} of {len(events)} events")

for event in filtered:
    sev = event.get("severity", "info")
    icon = SEVERITY_ICONS.get(sev, "⚪")
    with st.expander(f"{icon} {event.get('event_id', '?')} — {event.get('title', 'Untitled')}"):
        c1, c2, c3 = st.columns(3)
        c1.markdown(f"**Severity**: `{sev}`")
        c2.markdown(f"**Status**: `{event.get('status', '?')}`")
        c3.markdown(f"**Category**: `{event.get('category', '—')}`")

        if event.get("summary"):
            st.markdown(f"**Summary**: {event['summary']}")
        if event.get("affected_projects"):
            st.markdown(f"**Affected Projects**: {', '.join(event['affected_projects'])}")
        if event.get("affected_platforms"):
            st.markdown(f"**Affected Platforms**: {', '.join(event['affected_platforms'])}")
        if event.get("recommended_action"):
            st.markdown(f"**Recommended Action**: {event['recommended_action']}")
        if event.get("deadline"):
            st.markdown(f"**Deadline**: `{event['deadline']}`")
        if event.get("source"):
            st.markdown(f"**Source**: `{event['source']}`")
        if event.get("detected_at"):
            st.caption(f"Detected: {event['detected_at']}")
