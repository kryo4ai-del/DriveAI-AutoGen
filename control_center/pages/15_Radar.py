"""Opportunity Radar — External signal intake and evaluation dashboard."""

import streamlit as st
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
from store_reader import StoreReader

st.set_page_config(page_title="Opportunity Radar — Factory Control Center", page_icon="📡", layout="wide")

st.title("Opportunity Radar")
reader = StoreReader()

sources = reader.radar_sources()
hits = reader.radar_hits()

st.caption(f"{len(sources)} sources configured | {len(hits)} radar hits")

# ═══════════════════════════════════════════════════════════════════════
# OVERVIEW METRICS
# ═══════════════════════════════════════════════════════════════════════
active_hits = [h for h in hits if h.get("status") not in ("dismissed", "expired")]
high_rel = [h for h in active_hits if h.get("relevance_score", 0) >= 0.7]
promising = [h for h in hits if h.get("status") == "promising"]
promotable = [
    h for h in hits
    if h.get("status") in ("evaluated", "promising")
    and h.get("relevance_score", 0) >= 0.7
]
enabled_sources = [s for s in sources if s.get("enabled", True)]

metric_cols = st.columns(6)
metric_cols[0].metric("Sources", len(sources))
metric_cols[1].metric("Enabled", len(enabled_sources))
metric_cols[2].metric("Total Hits", len(hits))
metric_cols[3].metric("Active", len(active_hits))
metric_cols[4].metric("High Relevance", len(high_rel))
metric_cols[5].metric("Promotable", len(promotable))

# ═══════════════════════════════════════════════════════════════════════
# PROMOTABLE HITS (should become opportunities)
# ═══════════════════════════════════════════════════════════════════════
if promotable:
    st.markdown("---")
    st.subheader("Promotable Hits (ready for opportunity creation)")
    for h in sorted(promotable, key=lambda x: x.get("relevance_score", 0), reverse=True):
        rel = h.get("relevance_score", 0)
        st.markdown(
            f"- **{h.get('hit_id', '?')}**: {h.get('title', '?')} "
            f"— `{rel:.0%}` relevance | `{h.get('category', '?')}` | `{h.get('status', '?')}`"
        )

# ═══════════════════════════════════════════════════════════════════════
# CONFIGURED SOURCES
# ═══════════════════════════════════════════════════════════════════════
st.markdown("---")
st.subheader("Configured Sources")

if not sources:
    st.info(
        "No radar sources configured yet. Add sources via RadarManager:\n\n"
        "```python\nfrom radar.radar_manager import RadarManager\n"
        "mgr = RadarManager()\n"
        "mgr.add_source('Product Hunt', 'product_hunt', url='https://producthunt.com')\n```"
    )
else:
    # Group by category
    cat_groups: dict[str, list[dict]] = {}
    for s in sources:
        cat = s.get("category", "manual")
        cat_groups.setdefault(cat, []).append(s)

    for cat, cat_sources in sorted(cat_groups.items()):
        with st.expander(f"{cat.replace('_', ' ').title()} ({len(cat_sources)})"):
            for s in cat_sources:
                enabled_icon = "🟢" if s.get("enabled", True) else "⚪"
                url_text = f" — [{s['url']}]({s['url']})" if s.get("url") else ""
                st.markdown(f"{enabled_icon} **{s.get('source_id', '?')}**: {s.get('name', '?')}{url_text}")
                if s.get("notes"):
                    st.caption(f"  {s['notes']}")

# ═══════════════════════════════════════════════════════════════════════
# RADAR HITS
# ═══════════════════════════════════════════════════════════════════════
st.markdown("---")
st.subheader("Radar Hits")

if not hits:
    st.info(
        "No radar hits recorded yet. Add hits via RadarManager:\n\n"
        "```python\nfrom radar.radar_manager import RadarManager\n"
        "mgr = RadarManager()\n"
        "mgr.add_hit('AI-powered finance tracker', 'new_product',\n"
        "            source_id='RSRC-001', summary='Trending on PH...',\n"
        "            relevance_score=0.8)\n```"
    )
    st.stop()

# Filters
col1, col2, col3 = st.columns(3)

hit_categories = sorted({h.get("category", "?") for h in hits})
hit_statuses = sorted({h.get("status", "?") for h in hits})

with col1:
    sel_category = st.selectbox("Category", ["all"] + hit_categories)
with col2:
    sel_status = st.selectbox("Status", ["all"] + hit_statuses)
with col3:
    min_relevance = st.slider("Min Relevance", 0.0, 1.0, 0.0, 0.05)

filtered = hits
if sel_category != "all":
    filtered = [h for h in filtered if h.get("category") == sel_category]
if sel_status != "all":
    filtered = [h for h in filtered if h.get("status") == sel_status]
if min_relevance > 0:
    filtered = [h for h in filtered if h.get("relevance_score", 0) >= min_relevance]

# Sort by relevance descending
filtered.sort(key=lambda h: h.get("relevance_score", 0), reverse=True)

st.caption(f"Showing {len(filtered)} of {len(hits)} hits")

# Category breakdown
cat_counts: dict[str, int] = {}
for h in active_hits:
    c = h.get("category", "general")
    cat_counts[c] = cat_counts.get(c, 0) + 1
if cat_counts:
    breakdown_cols = st.columns(min(len(cat_counts), 6))
    for i, (cat, count) in enumerate(sorted(cat_counts.items(), key=lambda x: -x[1])):
        breakdown_cols[i % len(breakdown_cols)].metric(cat.replace("_", " ").title(), count)

st.markdown("---")

# Hit Cards
RELEVANCE_ICONS = {"high": "🔴", "medium": "🟡", "low": "🟢"}
STATUS_ICONS = {
    "new": "🆕", "evaluated": "🔍", "promising": "⭐",
    "opportunity_created": "💡", "dismissed": "❌", "expired": "⏳",
}

for h in filtered:
    hid = h.get("hit_id", "?")
    title = h.get("title", "Untitled")
    relevance = h.get("relevance_score", 0)
    status = h.get("status", "?")
    category = h.get("category", "?")

    if relevance >= 0.7:
        rel_icon = RELEVANCE_ICONS["high"]
    elif relevance >= 0.4:
        rel_icon = RELEVANCE_ICONS["medium"]
    else:
        rel_icon = RELEVANCE_ICONS["low"]

    status_icon = STATUS_ICONS.get(status, "")

    with st.expander(f"{rel_icon} {hid}: {title} — {relevance:.0%} [{status}]"):
        c1, c2, c3 = st.columns(3)
        c1.markdown(f"**Category**: `{category}`")
        c2.markdown(f"**Relevance**: {rel_icon} `{relevance:.0%}`")
        c3.markdown(f"**Status**: {status_icon} `{status}`")

        if h.get("summary"):
            st.markdown(f"**Summary**: {h['summary']}")

        if h.get("source_id"):
            # Try to resolve source name
            source_name = h["source_id"]
            for s in sources:
                if s.get("source_id") == h["source_id"]:
                    source_name = f"{s.get('name', '?')} ({h['source_id']})"
                    break
            st.markdown(f"**Source**: `{source_name}`")

        if h.get("potential_products"):
            st.markdown(f"**Potential Products**: {', '.join(h['potential_products'])}")

        if h.get("potential_platforms"):
            st.markdown(f"**Potential Platforms**: {', '.join(h['potential_platforms'])}")

        if h.get("notes"):
            st.markdown(f"**Notes**: {h['notes']}")

        if h.get("detected_at"):
            st.caption(f"Detected: {h['detected_at']}")
