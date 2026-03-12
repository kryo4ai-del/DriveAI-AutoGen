"""Strategy Reports — Weekly strategic analysis of the AI App Factory."""

import streamlit as st
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
from store_reader import StoreReader

st.set_page_config(page_title="Strategy — Factory Control Center", page_icon="🎯", layout="wide")

st.title("Strategy Reports")
reader = StoreReader()

reports = reader.strategy_reports()

st.caption(f"{len(reports)} reports generated")

# ═══════════════════════════════════════════════════════════════════════
# LATEST REPORT
# ═══════════════════════════════════════════════════════════════════════
if not reports:
    st.info(
        "No strategy reports yet. Generate one with:\n\n"
        "```python\npython -m strategy.strategy_manager\n```\n\n"
        "Reports are generated weekly (Sunday) and cover all factory signals."
    )
    st.stop()

latest = reports[-1]

st.subheader(f"Latest Report — {latest.get('week', '?')}")

# KPI row
kpis = latest.get("kpis", {})
cols = st.columns(8)
cols[0].metric("Projects", kpis.get("projects", 0))
cols[1].metric("Active", kpis.get("active_projects", 0))
cols[2].metric("Ideas", kpis.get("ideas_total", 0))
cols[3].metric("Inbox", kpis.get("ideas_inbox", 0))
cols[4].metric("Opportunities", kpis.get("opportunities", 0))
cols[5].metric("Trends", kpis.get("trends", 0))
cols[6].metric("Radar Hits", kpis.get("radar_hits", 0))
cols[7].metric("Compliance", kpis.get("compliance_reports", 0))

# Executive Summary
st.markdown("---")
st.subheader("Executive Summary")
st.markdown(f"> {latest.get('summary', 'No summary available.')}")

# ═══════════════════════════════════════════════════════════════════════
# TOP OPPORTUNITIES
# ═══════════════════════════════════════════════════════════════════════
st.markdown("---")
st.subheader("Strategic Opportunities")

top_opps = latest.get("top_opportunities", [])
if top_opps:
    for o in top_opps:
        rel = o.get("relevance", "?")
        rel_str = str(rel)
        if rel_str in ("critical",):
            icon = "🔴"
        elif rel_str in ("high",) or (rel_str.endswith("%") and int(rel_str.replace("%", "0") or "0") >= 70):
            icon = "🟠"
        elif rel_str in ("medium",):
            icon = "🟡"
        else:
            icon = "🟢"
        source = o.get("source", "?")
        st.text(f"  {icon} {o.get('id', '?')}: {o.get('title', '?')[:50]} [{o.get('status', '?')}] — {source}")
else:
    st.caption("No opportunities in this report.")

# ═══════════════════════════════════════════════════════════════════════
# TOP TRENDS
# ═══════════════════════════════════════════════════════════════════════
st.markdown("---")
st.subheader("Emerging Trends")

top_trends = latest.get("top_trends", [])
if top_trends:
    for t in top_trends:
        rel = t.get("relevance", "?")
        rel_str = str(rel)
        if rel_str.endswith("%"):
            try:
                pct = int(rel_str.replace("%", ""))
                icon = "🔴" if pct >= 70 else ("🟡" if pct >= 40 else "🟢")
            except ValueError:
                icon = "⚪"
        else:
            icon = "⚪"
        st.text(f"  {icon} {t.get('id', '?')}: {t.get('title', '?')[:50]} [{rel}] — {t.get('category', '?')}")
else:
    st.caption("No trends in this report.")

# ═══════════════════════════════════════════════════════════════════════
# PROJECT STATUS
# ═══════════════════════════════════════════════════════════════════════
st.markdown("---")
st.subheader("Project Status")

project_status = latest.get("project_status", [])
if project_status:
    for p in project_status:
        active_icon = "🟢" if p.get("active") else "⚪"
        blocked = " BLOCKED" if p.get("blocked") else ""
        blocked_color = " 🚫" if p.get("blocked") else ""
        st.text(
            f"  {active_icon} {p.get('id', '?')}: {p.get('name', '?')} — {p.get('platform', '?')} "
            f"[{p.get('status', '?')}] — {p.get('specs', 0)} specs, {p.get('plans', 0)} plans, "
            f"{p.get('ideas', 0)} ideas{blocked_color}"
        )
else:
    st.caption("No projects in this report.")

# ═══════════════════════════════════════════════════════════════════════
# RISK OVERVIEW
# ═══════════════════════════════════════════════════════════════════════
st.markdown("---")
st.subheader("Risk Overview")

risks = latest.get("risks", [])
if risks:
    for r in risks:
        sev = r.get("severity", "?")
        icon = "🔴" if sev == "critical" else ("🟠" if sev == "high" else "🟡")
        st.text(f"  {icon} [{sev.upper()}] {r.get('type', '?')}: {r.get('id', '?')} — {r.get('title', '?')}")
else:
    st.success("No active risks. Factory running clean.")

# ═══════════════════════════════════════════════════════════════════════
# AI USAGE
# ═══════════════════════════════════════════════════════════════════════
st.markdown("---")
st.subheader("AI Usage Overview")

ai_usage = latest.get("ai_usage", {})
if ai_usage:
    ai_cols = st.columns(4)
    ai_cols[0].metric("Week Cost", ai_usage.get("week_cost", "$0"))
    ai_cols[1].metric("Week Tokens", f"{ai_usage.get('week_tokens', 0):,}")
    ai_cols[2].metric("Week Requests", ai_usage.get("week_requests", 0))
    ai_cols[3].metric("Total Cost", ai_usage.get("total_cost", "$0"))

    models = ai_usage.get("models_used", {})
    if models:
        st.markdown("**Models used this week:**")
        for model, cost in models.items():
            st.text(f"  ${cost:.4f}  {model}")

# ═══════════════════════════════════════════════════════════════════════
# RECOMMENDED ACTIONS
# ═══════════════════════════════════════════════════════════════════════
st.markdown("---")
st.subheader("Recommended Actions")

actions = latest.get("recommended_actions", [])
if actions:
    for i, action in enumerate(actions, 1):
        st.text(f"  {i}. {action}")
else:
    st.caption("No actions recommended.")

# ═══════════════════════════════════════════════════════════════════════
# HTML REPORT LINK
# ═══════════════════════════════════════════════════════════════════════
html_path = latest.get("html_path", "")
if html_path:
    st.markdown("---")
    st.caption(f"HTML report: `{html_path}`")

# ═══════════════════════════════════════════════════════════════════════
# HISTORICAL REPORTS
# ═══════════════════════════════════════════════════════════════════════
if len(reports) > 1:
    st.markdown("---")
    with st.expander(f"Historical Reports ({len(reports) - 1} previous)"):
        for r in reversed(reports[:-1]):
            r_kpis = r.get("kpis", {})
            r_risks = r.get("risks", [])
            r_actions = r.get("recommended_actions", [])
            risk_count = len(r_risks)
            risk_icon = "🔴" if risk_count > 3 else ("🟡" if risk_count > 0 else "🟢")
            st.text(
                f"  {r.get('report_id', '?')}  {r.get('week', '?')}  "
                f"P:{r_kpis.get('projects', 0)} I:{r_kpis.get('ideas_total', 0)} "
                f"O:{r_kpis.get('opportunities', 0)} T:{r_kpis.get('trends', 0)}  "
                f"{risk_icon} {risk_count} risks  {len(r_actions)} actions  "
                f"[{r.get('status', '?')}]"
            )

# ═══════════════════════════════════════════════════════════════════════
# REPORT METADATA
# ═══════════════════════════════════════════════════════════════════════
st.markdown("---")
meta_cols = st.columns(3)
meta_cols[0].caption(f"Report ID: {latest.get('report_id', '?')}")
meta_cols[1].caption(f"Generated: {latest.get('generated_at', '?')}")
meta_cols[2].caption(f"Status: {latest.get('status', '?')}")
