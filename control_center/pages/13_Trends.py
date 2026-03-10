"""AI Trends — Detected AI trends and auto-generated idea candidates."""

import streamlit as st
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
from store_reader import StoreReader

st.set_page_config(page_title="AI Trends — Factory Control Center", page_icon="📡", layout="wide")

st.title("AI Trend Scanner")
reader = StoreReader()

trends = reader.trends()
st.caption(f"{len(trends)} detected trends")

if not trends:
    st.info(
        "No AI trends detected yet. The Trend Scanner analyzes watch events, opportunities, "
        "and agent memory to identify emerging AI patterns and automatically generate app ideas."
    )
    st.stop()

# --- Filters ---
col1, col2, col3 = st.columns(3)

categories = sorted({t.get("category", "?") for t in trends})
statuses = sorted({t.get("status", "?") for t in trends})

with col1:
    sel_category = st.selectbox("Category", ["all"] + categories)
with col2:
    sel_status = st.selectbox("Status", ["all"] + statuses)
with col3:
    min_relevance = st.slider("Min Relevance", 0.0, 1.0, 0.0, 0.05)

filtered = trends
if sel_category != "all":
    filtered = [t for t in filtered if t.get("category") == sel_category]
if sel_status != "all":
    filtered = [t for t in filtered if t.get("status") == sel_status]
if min_relevance > 0:
    filtered = [t for t in filtered if t.get("relevance_score", 0) >= min_relevance]

# Sort by relevance descending
filtered.sort(key=lambda t: t.get("relevance_score", 0), reverse=True)

st.markdown("---")

# --- Summary ---
st.subheader("Overview")
active = [t for t in trends if t.get("status") not in ("dismissed", "expired")]
high_rel = [t for t in active if t.get("relevance_score", 0) >= 0.7]
ideas_generated = [t for t in trends if t.get("status") == "idea_generated"]

summary_cols = st.columns(5)
summary_cols[0].metric("Total", len(trends))
summary_cols[1].metric("Active", len(active))
summary_cols[2].metric("High Relevance", len(high_rel))
summary_cols[3].metric("Ideas Generated", len(ideas_generated))
summary_cols[4].metric("Actionable", sum(1 for t in trends if t.get("status") in ("detected", "evaluated")))

# Category breakdown
cat_counts = {}
for t in active:
    c = t.get("category", "general")
    cat_counts[c] = cat_counts.get(c, 0) + 1
if cat_counts:
    cat_cols = st.columns(min(len(cat_counts), 5))
    for i, (cat, count) in enumerate(sorted(cat_counts.items(), key=lambda x: -x[1])):
        cat_cols[i % len(cat_cols)].metric(cat.replace("_", " ").title(), count)

st.markdown("---")
st.caption(f"Showing {len(filtered)} of {len(trends)} trends")

# --- Trend Cards ---
RELEVANCE_ICONS = {
    "high": "🔴",    # >= 0.7
    "medium": "🟡",  # >= 0.4
    "low": "🟢",     # < 0.4
}

STATUS_ICONS = {
    "detected": "📡", "evaluated": "🔍", "idea_generated": "💡",
    "dismissed": "❌", "expired": "⏳",
}

for t in filtered:
    tid = t.get("trend_id", "?")
    title = t.get("title", "Untitled")
    relevance = t.get("relevance_score", 0)
    status = t.get("status", "?")
    category = t.get("category", "?")

    if relevance >= 0.7:
        rel_icon = RELEVANCE_ICONS["high"]
    elif relevance >= 0.4:
        rel_icon = RELEVANCE_ICONS["medium"]
    else:
        rel_icon = RELEVANCE_ICONS["low"]

    status_icon = STATUS_ICONS.get(status, "")

    with st.expander(f"{rel_icon} {tid}: {title} — {relevance:.0%} [{status}]"):
        c1, c2, c3 = st.columns(3)
        c1.markdown(f"**Category**: `{category}`")
        c2.markdown(f"**Relevance**: {rel_icon} `{relevance:.0%}`")
        c3.markdown(f"**Status**: {status_icon} `{status}`")

        if t.get("summary"):
            st.markdown(f"**Summary**: {t['summary']}")

        if t.get("potential_app_categories"):
            st.markdown(f"**Potential Platforms**: {', '.join(t['potential_app_categories'])}")

        if t.get("detected_from"):
            st.markdown(f"**Detected From**: `{t['detected_from']}`")

        if t.get("linked_idea_id"):
            st.markdown(f"**Linked Idea**: `{t['linked_idea_id']}`")

        if t.get("notes"):
            st.markdown(f"**Notes**: {t['notes']}")

        if t.get("detected_at"):
            st.caption(f"Detected: {t['detected_at']}")
