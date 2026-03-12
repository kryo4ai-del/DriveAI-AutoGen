"""Research Reports — AutoResearchAgent insights for the AI App Factory."""

import streamlit as st
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
from store_reader import StoreReader

st.set_page_config(page_title="Research — Factory Control Center", page_icon="🔬", layout="wide")

st.title("Research Reports")
reader = StoreReader()

reports = reader.research_reports()

st.caption(f"{len(reports)} reports")

# ═══════════════════════════════════════════════════════════════════════
# EMPTY STATE
# ═══════════════════════════════════════════════════════════════════════
if not reports:
    st.info(
        "No research reports yet. Generate them with:\n\n"
        "```python\npython -m research.auto_research\n```\n\n"
        "The AutoResearchAgent analyzes trends, radar hits, opportunities, "
        "and the knowledge graph to produce research insights."
    )
    st.stop()

# ═══════════════════════════════════════════════════════════════════════
# KPI ROW
# ═══════════════════════════════════════════════════════════════════════
st.subheader("Overview")

published = [r for r in reports if r.get("status") == "published"]
high_conf = [r for r in reports if r.get("confidence", 0) >= 0.7 and r.get("status") not in ("archived", "superseded")]

# Category counts
cat_counts: dict[str, int] = {}
for r in reports:
    c = r.get("category", "general")
    cat_counts[c] = cat_counts.get(c, 0) + 1

# Technology counts
tech_counts: dict[str, int] = {}
for r in reports:
    for t in r.get("technologies", []):
        tech_counts[t] = tech_counts.get(t, 0) + 1

cols = st.columns(5)
cols[0].metric("Total Reports", len(reports))
cols[1].metric("Published", len(published))
cols[2].metric("High Confidence", len(high_conf))
cols[3].metric("Categories", len(cat_counts))
cols[4].metric("Technologies", len(tech_counts))

# ═══════════════════════════════════════════════════════════════════════
# CATEGORY BREAKDOWN
# ═══════════════════════════════════════════════════════════════════════
st.markdown("---")
st.subheader("Reports by Category")

CAT_ICONS = {
    "technology_research": "🔧",
    "tool_discovery": "🔍",
    "architecture_comparison": "🏗️",
    "product_opportunity": "🎯",
    "ai_model_evaluation": "🤖",
    "market_analysis": "📊",
    "general": "📌",
}

cat_sorted = sorted(cat_counts.items(), key=lambda x: -x[1])
cat_cols = st.columns(min(len(cat_sorted), 7))
for i, (cat, count) in enumerate(cat_sorted[:7]):
    icon = CAT_ICONS.get(cat, "📌")
    cat_cols[i % 7].metric(f"{icon} {cat.replace('_', ' ').title()}", count)

# ═══════════════════════════════════════════════════════════════════════
# HIGH CONFIDENCE REPORTS
# ═══════════════════════════════════════════════════════════════════════
if high_conf:
    st.markdown("---")
    st.subheader("High Confidence Insights")

    for r in sorted(high_conf, key=lambda x: -x.get("confidence", 0))[:8]:
        icon = CAT_ICONS.get(r.get("category", ""), "📌")
        conf = r.get("confidence", 0)
        conf_bar = "🟢" if conf >= 0.8 else "🟡"

        with st.expander(f"{icon} {r.get('research_id', '?')}: {r.get('topic', '?')} — {conf_bar} {conf:.0%}"):
            st.markdown(f"**Category**: {r.get('category', '?')} | **Status**: {r.get('status', '?')} | **Generated**: {r.get('generated_at', '?')[:10]}")
            st.markdown(f"**Summary**: {r.get('summary', '—')}")

            recs = r.get("recommendations", [])
            if recs:
                st.markdown("**Recommendations**:")
                for rec in recs:
                    st.text(f"  → {rec}")

            techs = r.get("technologies", [])
            if techs:
                st.caption(f"Technologies: {', '.join(techs)}")

            signals = r.get("source_signals", [])
            if signals:
                st.caption(f"Signals: {', '.join(signals[:5])}")

# ═══════════════════════════════════════════════════════════════════════
# ALL REPORTS
# ═══════════════════════════════════════════════════════════════════════
st.markdown("---")
st.subheader("All Reports")

# Filter controls
filter_col1, filter_col2 = st.columns(2)
with filter_col1:
    selected_category = st.selectbox(
        "Filter by category",
        ["(all)"] + [c for c, _ in cat_sorted],
    )
with filter_col2:
    selected_status = st.selectbox(
        "Filter by status",
        ["(all)", "published", "draft", "review", "archived", "superseded"],
    )

filtered = reports
if selected_category != "(all)":
    filtered = [r for r in filtered if r.get("category") == selected_category]
if selected_status != "(all)":
    filtered = [r for r in filtered if r.get("status") == selected_status]

st.caption(f"Showing {len(filtered)} of {len(reports)} reports")

for r in reversed(filtered):
    icon = CAT_ICONS.get(r.get("category", ""), "📌")
    conf = r.get("confidence", 0)
    conf_icon = "🟢" if conf >= 0.7 else ("🟡" if conf >= 0.4 else "⚪")

    with st.expander(f"{icon} {r.get('research_id', '?')}: {r.get('topic', '?')} — {conf_icon} {conf:.0%} [{r.get('status', '?')}]"):
        st.markdown(f"**Category**: {r.get('category', '?')} | **Status**: {r.get('status', '?')} | **Generated**: {r.get('generated_at', '?')[:10]}")
        st.markdown(f"**Summary**: {r.get('summary', '—')}")

        recs = r.get("recommendations", [])
        if recs:
            st.markdown("**Recommendations**:")
            for rec in recs:
                st.text(f"  → {rec}")

        techs = r.get("technologies", [])
        if techs:
            st.caption(f"Technologies: {', '.join(techs)}")

        signals = r.get("source_signals", [])
        if signals:
            st.caption(f"Signals: {', '.join(signals[:8])}")

        rel_trends = r.get("related_trends", [])
        rel_opps = r.get("related_opportunities", [])
        rel_radar = r.get("related_radar", [])
        if rel_trends or rel_opps or rel_radar:
            parts = []
            if rel_trends:
                parts.append(f"Trends: {', '.join(rel_trends[:3])}")
            if rel_opps:
                parts.append(f"Opportunities: {', '.join(rel_opps[:3])}")
            if rel_radar:
                parts.append(f"Radar: {', '.join(rel_radar[:3])}")
            st.caption(f"Related: {' | '.join(parts)}")

        if r.get("notes"):
            st.caption(f"Notes: {r['notes']}")

# ═══════════════════════════════════════════════════════════════════════
# TECHNOLOGY LANDSCAPE
# ═══════════════════════════════════════════════════════════════════════
if tech_counts:
    st.markdown("---")
    st.subheader("Technology Landscape")

    tech_sorted = sorted(tech_counts.items(), key=lambda x: -x[1])
    for tech, count in tech_sorted[:15]:
        st.text(f"  🔧 {tech:30s} {count:>3} mentions")
