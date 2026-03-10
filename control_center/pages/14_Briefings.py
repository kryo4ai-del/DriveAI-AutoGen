"""Daily Briefings — Executive morning summaries from factory data."""

import streamlit as st
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
from store_reader import StoreReader

st.set_page_config(page_title="Briefings — Factory Control Center", page_icon="📋", layout="wide")

st.title("Daily Briefings")
reader = StoreReader()

briefings = reader.briefings()
st.caption(f"{len(briefings)} briefings archived")

if not briefings:
    st.info(
        "No briefings generated yet. Run the Daily Briefing Agent to generate an executive summary:\n\n"
        "```bash\npython -m briefings.daily_briefing\n```"
    )
    st.stop()

# Show most recent first
briefings_sorted = list(reversed(briefings))

# --- Latest Briefing ---
latest = briefings_sorted[0]
st.subheader(f"Latest: {latest.get('briefing_date', '?')} — {latest.get('briefing_id', '?')}")

# KPIs
kpis = latest.get("kpis", {})
if kpis:
    kpi_cols = st.columns(7)
    kpi_cols[0].metric("Projects", kpis.get("projects", 0))
    kpi_cols[1].metric("Ideas", kpis.get("ideas", 0))
    kpi_cols[2].metric("Inbox", kpis.get("ideas_inbox", 0))
    kpi_cols[3].metric("Plans", kpis.get("plans", 0))
    kpi_cols[4].metric("Trends", kpis.get("trends", 0))
    kpi_cols[5].metric("Alerts", len(latest.get("sections", {}).get("alerts", [])))
    kpi_cols[6].metric("Memory", kpis.get("memory_entries", 0))

# Executive Summary
sections = latest.get("sections", {})
summary = sections.get("executive_summary", [])
if summary:
    for line in summary:
        st.markdown(f"**{line}**")

# Actions
actions = latest.get("actions", [])
if actions:
    st.markdown("---")
    st.markdown("**Actions Today**")
    for i, action in enumerate(actions, 1):
        st.markdown(f"{i}. {action}")

# HTML preview link
html_path_rel = latest.get("html_path", "")
if html_path_rel:
    html_full = reader.root / html_path_rel
    if html_full.exists():
        st.markdown("---")
        html_content = html_full.read_text(encoding="utf-8")
        st.components.v1.html(html_content, height=800, scrolling=True)

# --- Alerts ---
alerts = sections.get("alerts", [])
if alerts:
    st.markdown("---")
    st.subheader(f"Alerts ({len(alerts)})")
    SEV_ICONS = {"critical": "🔴", "high": "🟠", "medium": "🟡", "low": "🟢"}
    for a in alerts:
        icon = SEV_ICONS.get(a.get("severity", ""), "⚪")
        st.text(f"  {icon} [{a.get('type', '?')}] {a.get('id', '?')}: {a.get('title', '?')}")

# --- Section Details (collapsed) ---
for section_key, section_label in [
    ("new_ideas", "Ideas in Inbox"),
    ("trends", "AI Trends"),
    ("opportunities", "Opportunities"),
    ("projects", "Projects"),
    ("compliance", "Compliance"),
    ("accessibility", "Accessibility"),
    ("improvements", "Factory Improvements"),
]:
    items = sections.get(section_key, [])
    if items:
        with st.expander(f"{section_label} ({len(items)})"):
            for item in items:
                parts = [f"{k}: {v}" for k, v in item.items()]
                st.text(f"  {' | '.join(parts)}")

# --- Briefing Archive ---
if len(briefings_sorted) > 1:
    st.markdown("---")
    st.subheader("Archive")
    for b in briefings_sorted[1:]:
        bid = b.get("briefing_id", "?")
        bdate = b.get("briefing_date", "?")
        b_kpis = b.get("kpis", {})
        b_alerts = len(b.get("sections", {}).get("alerts", []))
        b_actions = len(b.get("actions", []))
        status = b.get("status", "?")

        with st.expander(f"{bid} — {bdate} [{status}]"):
            c1, c2, c3, c4 = st.columns(4)
            c1.metric("Projects", b_kpis.get("projects", 0))
            c2.metric("Ideas", b_kpis.get("ideas", 0))
            c3.metric("Alerts", b_alerts)
            c4.metric("Actions", b_actions)
            for action in b.get("actions", []):
                st.text(f"  - {action}")
