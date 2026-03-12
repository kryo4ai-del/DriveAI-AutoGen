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

# --- AI Costs (special section — dict, not list) ---
ai_costs_data = sections.get("ai_costs", {})
if ai_costs_data:
    with st.expander("AI Costs"):
        st.text(f"  Today: {ai_costs_data.get('today_cost', '$0')} | Tokens: {ai_costs_data.get('today_tokens', 0):,}")
        st.text(f"  Total: {ai_costs_data.get('total_cost', '$0')} | Requests: {ai_costs_data.get('total_requests', 0)}")
        top_agents = ai_costs_data.get("top_agents", [])
        if top_agents:
            st.text("  Top agents:")
            for ta in top_agents:
                st.text(f"    {ta.get('cost', '$0')}  {ta.get('agent', '?')}")

# --- Strategy Report (special section — dict, not list) ---
strategy_data = sections.get("strategy", {})
if strategy_data:
    with st.expander("Strategy Report"):
        st.text(f"  Report: {strategy_data.get('report_id', '?')} | Week: {strategy_data.get('week', '?')}")
        st.text(f"  Risks: {strategy_data.get('risks', 0)} | Actions: {strategy_data.get('actions', 0)} | Status: {strategy_data.get('status', '?')}")

# --- Research (special section — dict, not list) ---
research_data = sections.get("research", {})
if research_data:
    with st.expander("Research Reports"):
        st.text(f"  Total: {research_data.get('total', 0)} | High Confidence: {research_data.get('high_confidence', 0)}")
        st.text(f"  Latest: {research_data.get('latest_id', '?')} — {research_data.get('latest_topic', '?')} (conf: {research_data.get('latest_confidence', 0):.0%})")

# --- Section Details (collapsed) ---
for section_key, section_label in [
    ("new_ideas", "Ideas in Inbox"),
    ("trends", "AI Trends"),
    ("opportunities", "Opportunities"),
    ("radar", "Opportunity Radar"),
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
