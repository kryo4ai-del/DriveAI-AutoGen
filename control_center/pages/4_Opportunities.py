"""Opportunities — View discovered opportunities."""

import streamlit as st
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
from store_reader import StoreReader

st.set_page_config(page_title="Opportunities — Factory Control Center", page_icon="🔍", layout="wide")

st.title("Opportunities")
reader = StoreReader()
opps = reader.opportunities()

st.caption(f"{len(opps)} total opportunities")

if not opps:
    st.info("No opportunities discovered yet. The OpportunityAgent finds these during pipeline runs.")
    st.stop()

# Filters
col1, col2 = st.columns(2)
statuses = sorted({o.get("status", "unknown") for o in opps})
categories = sorted({o.get("category", "unknown") for o in opps})

with col1:
    sel_status = st.selectbox("Status", ["all"] + statuses)
with col2:
    sel_cat = st.selectbox("Category", ["all"] + categories)

filtered = opps
if sel_status != "all":
    filtered = [o for o in filtered if o.get("status") == sel_status]
if sel_cat != "all":
    filtered = [o for o in filtered if o.get("category") == sel_cat]

st.markdown("---")
st.caption(f"Showing {len(filtered)} of {len(opps)} opportunities")

for opp in filtered:
    with st.expander(f"{opp.get('opportunity_id', '?')} — {opp.get('title', 'Untitled')}"):
        c1, c2, c3 = st.columns(3)
        c1.markdown(f"**Status**: `{opp.get('status', '?')}`")
        c2.markdown(f"**Relevance**: `{opp.get('market_relevance', '—')}`")
        c3.markdown(f"**Complexity**: `{opp.get('complexity', '—')}`")

        st.markdown(f"**Category**: `{opp.get('category', '—')}`")
        if opp.get("summary"):
            st.markdown(f"**Summary**: {opp['summary']}")
        if opp.get("potential_products"):
            st.markdown(f"**Products**: {', '.join(opp['potential_products'])}")
        if opp.get("suggested_next_step"):
            st.markdown(f"**Next Step**: {opp['suggested_next_step']}")
        if opp.get("linked_watch_event"):
            st.markdown(f"**Linked Watch Event**: `{opp['linked_watch_event']}`")
        if opp.get("detected_at"):
            st.caption(f"Detected: {opp['detected_at']}")
