"""Activity Feed — Chronological event feed across all factory stores."""

import streamlit as st
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
from store_reader import StoreReader
from activity_feed import build_feed, get_source_stores, get_projects, get_severities, SEVERITY_ICONS

st.set_page_config(page_title="Activity Feed — Factory Control Center", page_icon="📰", layout="wide")

st.title("Activity Feed")
reader = StoreReader()

# Build full feed (larger limit for dedicated page)
all_events = build_feed(reader, limit=100)

st.caption(f"{len(all_events)} events across all stores")

if not all_events:
    st.info("No activity recorded yet. Events appear here as ideas, specs, plans, and other items are created.")
    st.stop()

# --- Filters ---
col1, col2, col3 = st.columns(3)

sources = get_source_stores(all_events)
feed_projects = get_projects(all_events)
severities = get_severities(all_events)

with col1:
    sel_source = st.selectbox("Source", ["all"] + sources)
with col2:
    sel_project = st.selectbox("Project", ["all"] + feed_projects)
with col3:
    sel_severity = st.selectbox("Severity / Priority", ["all"] + severities)

filtered = all_events
if sel_source != "all":
    filtered = [e for e in filtered if e["source_store"] == sel_source]
if sel_project != "all":
    filtered = [e for e in filtered if e["project"] == sel_project]
if sel_severity != "all":
    filtered = [e for e in filtered if e["severity"] == sel_severity]

st.markdown("---")
st.caption(f"Showing {len(filtered)} of {len(all_events)} events")

# --- Feed Display ---
prev_date = None

for event in filtered:
    # Date separator
    event_date = event["timestamp"][:10] if len(event["timestamp"]) >= 10 else event["timestamp"]
    if event_date != prev_date:
        st.markdown(f"### {event_date}")
        prev_date = event_date

    # Severity indicator
    sev = event["severity"]
    sev_icon = SEVERITY_ICONS.get(sev, "")

    # Build event line
    icon = event["icon"]
    ref = event["ref_id"]
    title = event["title"][:60]
    event_type = event["event_type"]
    project = event["project"]

    with st.container():
        c1, c2 = st.columns([1, 4])
        with c1:
            st.caption(f"{event['timestamp']}")
        with c2:
            project_badge = f"  `{project}`" if project != "—" else ""
            severity_badge = f"  {sev_icon} `{sev}`" if sev != "—" and sev_icon else ""
            st.markdown(f"{icon} **{event_type}** — `{ref}` {title}{project_badge}{severity_badge}")
