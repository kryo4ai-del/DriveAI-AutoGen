"""Accessibility Reports — A11Y findings tracker."""

import streamlit as st
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
from store_reader import StoreReader

st.set_page_config(page_title="Accessibility", page_icon="♿", layout="wide")
st.title("Accessibility Reports")

reader = StoreReader()
reports = reader.accessibility()

if not reports:
    st.info("No accessibility reports yet.")
    st.stop()

SEVERITY_ICONS = {"critical": "🔴", "high": "🟠", "medium": "🟡", "low": "🟢", "info": "⚪"}

col1, col2 = st.columns(2)
statuses = sorted({r.get("status", "unknown") for r in reports})
types = sorted({r.get("issue_type", "unknown") for r in reports})

with col1:
    sel_status = st.selectbox("Status", ["all"] + statuses)
with col2:
    sel_type = st.selectbox("Issue Type", ["all"] + types)

filtered = reports
if sel_status != "all":
    filtered = [r for r in filtered if r.get("status") == sel_status]
if sel_type != "all":
    filtered = [r for r in filtered if r.get("issue_type") == sel_type]

st.caption(f"Showing {len(filtered)} of {len(reports)} reports")

for r in filtered:
    sev = r.get("severity", "info")
    icon = SEVERITY_ICONS.get(sev, "⚪")
    with st.expander(f"{icon} {r.get('report_id', '?')} — {r.get('issue_type', '?')} in {r.get('file', '?')}"):
        c1, c2, c3 = st.columns(3)
        c1.markdown(f"**Severity**: `{sev}`")
        c2.markdown(f"**Status**: `{r.get('status', '?')}`")
        c3.markdown(f"**Project**: `{r.get('project', '—')}`")

        if r.get("description"):
            st.markdown(f"**Description**: {r['description']}")
        if r.get("recommendation"):
            st.markdown(f"**Recommendation**: {r['recommendation']}")
        if r.get("file"):
            st.markdown(f"**File**: `{r['file']}`")
        if r.get("detected_at"):
            st.caption(f"Detected: {r['detected_at']}")
