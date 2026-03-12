"""AI Costs — Model routing, usage tracking, and budget monitoring."""

import streamlit as st
import sys
from datetime import date
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
from store_reader import StoreReader

st.set_page_config(page_title="AI Costs — Factory Control Center", page_icon="💰", layout="wide")

st.title("AI Cost Monitor")
reader = StoreReader()

usage = reader.cost_usage()
summaries = reader.cost_summaries()
budgets = reader.cost_budgets()
routing = reader.model_routing()

today = date.today().isoformat()
today_usage = [u for u in usage if u.get("timestamp", "").startswith(today)]
month_prefix = today[:7]
month_usage = [u for u in usage if u.get("timestamp", "").startswith(month_prefix)]

# ═══════════════════════════════════════════════════════════════════════
# BUDGET STATUS
# ═══════════════════════════════════════════════════════════════════════
daily_budget = budgets.get("daily_budget", 0)
monthly_budget = budgets.get("monthly_budget", 0)

today_cost = sum(u.get("estimated_cost", 0) for u in today_usage)
today_tokens = sum(u.get("total_tokens", 0) for u in today_usage)
month_cost = sum(u.get("estimated_cost", 0) for u in month_usage)
month_tokens = sum(u.get("total_tokens", 0) for u in month_usage)
total_cost = sum(u.get("estimated_cost", 0) for u in usage)
total_tokens = sum(u.get("total_tokens", 0) for u in usage)

# Budget alerts
alerts = []
if daily_budget and today_cost > daily_budget:
    alerts.append(f"DAILY BUDGET EXCEEDED: ${today_cost:.4f} / ${daily_budget:.2f}")
elif daily_budget and daily_budget > 0 and (today_cost / daily_budget) >= 0.8:
    alerts.append(f"Daily budget 80%+ used: ${today_cost:.4f} / ${daily_budget:.2f}")
if monthly_budget and month_cost > monthly_budget:
    alerts.append(f"MONTHLY BUDGET EXCEEDED: ${month_cost:.4f} / ${monthly_budget:.2f}")
elif monthly_budget and monthly_budget > 0 and (month_cost / monthly_budget) >= 0.8:
    alerts.append(f"Monthly budget 80%+ used: ${month_cost:.4f} / ${monthly_budget:.2f}")

if alerts:
    for alert in alerts:
        st.error(alert)

# ═══════════════════════════════════════════════════════════════════════
# KPI ROW
# ═══════════════════════════════════════════════════════════════════════
st.subheader("Overview")
cols = st.columns(6)
cols[0].metric("Today Cost", f"${today_cost:.4f}")
cols[1].metric("Today Tokens", f"{today_tokens:,}")
cols[2].metric("Month Cost", f"${month_cost:.4f}")
cols[3].metric("Month Tokens", f"{month_tokens:,}")
cols[4].metric("Total Cost", f"${total_cost:.4f}")
cols[5].metric("Total Requests", len(usage))

# Budget gauges
if daily_budget or monthly_budget:
    st.markdown("---")
    st.subheader("Budget Status")
    budget_cols = st.columns(2)
    with budget_cols[0]:
        if daily_budget:
            pct = min(100, (today_cost / daily_budget) * 100) if daily_budget else 0
            color = "🔴" if pct >= 100 else ("🟡" if pct >= 80 else "🟢")
            st.markdown(f"**Daily Budget**: {color} ${today_cost:.4f} / ${daily_budget:.2f} ({pct:.0f}%)")
            st.progress(min(1.0, pct / 100))
        else:
            st.caption("No daily budget configured")
    with budget_cols[1]:
        if monthly_budget:
            pct = min(100, (month_cost / monthly_budget) * 100) if monthly_budget else 0
            color = "🔴" if pct >= 100 else ("🟡" if pct >= 80 else "🟢")
            st.markdown(f"**Monthly Budget**: {color} ${month_cost:.4f} / ${monthly_budget:.2f} ({pct:.0f}%)")
            st.progress(min(1.0, pct / 100))
        else:
            st.caption("No monthly budget configured")

# ═══════════════════════════════════════════════════════════════════════
# COST BREAKDOWN
# ═══════════════════════════════════════════════════════════════════════
if not usage:
    st.markdown("---")
    st.info(
        "No AI usage recorded yet. The CostManager logs usage when agents run:\n\n"
        "```python\nfrom costs.cost_manager import CostManager\n"
        "mgr = CostManager()\n"
        "mgr.log_usage('swift_developer', 'gpt-4o-mini', 'code_generation',\n"
        "              prompt_tokens=1500, completion_tokens=800, estimated_cost=0.0007)\n```"
    )
    st.stop()

st.markdown("---")

# Cost by Agent
st.subheader("Cost by Agent")
agent_costs: dict[str, float] = {}
agent_tokens: dict[str, int] = {}
for u in usage:
    agent = u.get("agent_name", "unknown")
    agent_costs[agent] = agent_costs.get(agent, 0) + u.get("estimated_cost", 0)
    agent_tokens[agent] = agent_tokens.get(agent, 0) + u.get("total_tokens", 0)
agent_sorted = sorted(agent_costs.items(), key=lambda x: -x[1])

if agent_sorted:
    for agent, cost in agent_sorted[:10]:
        tokens = agent_tokens.get(agent, 0)
        st.text(f"  ${cost:.4f}  {tokens:>10,} tokens  {agent}")

# Cost by Model
st.markdown("---")
st.subheader("Cost by Model")
model_costs: dict[str, float] = {}
model_counts: dict[str, int] = {}
for u in usage:
    model = u.get("model_used", "unknown")
    model_costs[model] = model_costs.get(model, 0) + u.get("estimated_cost", 0)
    model_counts[model] = model_counts.get(model, 0) + 1
model_sorted = sorted(model_costs.items(), key=lambda x: -x[1])

if model_sorted:
    for model, cost in model_sorted:
        count = model_counts.get(model, 0)
        st.text(f"  ${cost:.4f}  {count:>5} requests  {model}")

# Cost by Project
st.markdown("---")
st.subheader("Cost by Project")
project_costs: dict[str, float] = {}
for u in usage:
    proj = u.get("project", "unknown")
    project_costs[proj] = project_costs.get(proj, 0) + u.get("estimated_cost", 0)
project_sorted = sorted(project_costs.items(), key=lambda x: -x[1])

if project_sorted:
    for proj, cost in project_sorted:
        st.text(f"  ${cost:.4f}  {proj}")

# ═══════════════════════════════════════════════════════════════════════
# MODEL ROUTING
# ═══════════════════════════════════════════════════════════════════════
st.markdown("---")
st.subheader("Model Routing Rules")

if routing:
    local_routes = {t: r for t, r in routing.items() if r.get("provider") == "ollama"}
    api_routes = {t: r for t, r in routing.items() if r.get("provider") != "ollama"}

    route_cols = st.columns(2)
    with route_cols[0]:
        st.markdown(f"**Local (Ollama)** — {len(local_routes)} tasks")
        for task, route in sorted(local_routes.items()):
            st.text(f"  {task:25s} → {route.get('model', '?')}")
    with route_cols[1]:
        st.markdown(f"**API (OpenAI)** — {len(api_routes)} tasks")
        for task, route in sorted(api_routes.items()):
            st.text(f"  {task:25s} → {route.get('model', '?')}")
else:
    st.caption("No custom routing rules configured. Using default routes from ModelRouter.")
    st.info(
        "Default routing prefers local models (Ollama) for classification, summarization, "
        "trend analysis, scoring, labeling, and extraction. GPT is used for planning, "
        "code generation, code review, architecture, and other complex tasks."
    )

# ═══════════════════════════════════════════════════════════════════════
# RECENT USAGE LOG
# ═══════════════════════════════════════════════════════════════════════
st.markdown("---")
st.subheader("Recent Usage")

recent = list(reversed(usage[-20:]))
for u in recent:
    cost = u.get("estimated_cost", 0)
    tokens = u.get("total_tokens", 0)
    ts = u.get("timestamp", "?")[:16]
    st.text(
        f"  {ts}  ${cost:.4f}  {tokens:>8,}tk  "
        f"{u.get('agent_name', '?'):25s}  {u.get('model_used', '?'):20s}  "
        f"{u.get('task_type', '?')}"
    )

# ═══════════════════════════════════════════════════════════════════════
# DAILY SUMMARIES
# ═══════════════════════════════════════════════════════════════════════
if summaries:
    st.markdown("---")
    with st.expander(f"Daily Summaries ({len(summaries)})"):
        for s in reversed(summaries):
            st.text(
                f"  {s.get('date', '?')}  ${s.get('total_cost', 0):.4f}  "
                f"{s.get('total_tokens', 0):,} tokens  {s.get('total_requests', 0)} requests  "
                f"top: {s.get('top_agent', '—')}"
            )
