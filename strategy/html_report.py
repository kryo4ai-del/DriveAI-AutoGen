# html_report.py
# Renders a professional HTML strategy report for the AI App Factory.
# Sections: Executive Summary, Opportunities, Trends, Projects, Risks, AI Usage, Actions.

from datetime import datetime


def render_strategy_html(
    week: str,
    summary: str,
    kpis: dict,
    top_opportunities: list[dict],
    top_trends: list[dict],
    project_status: list[dict],
    risks: list[dict],
    ai_usage: dict,
    actions: list[str],
) -> str:
    """Render full strategy report as standalone HTML."""
    generated = datetime.utcnow().strftime("%Y-%m-%d %H:%M UTC")

    # ── KPI cards ────────────────────────────────────────────────────
    kpi_items = [
        ("Projects", kpis.get("projects", 0)),
        ("Active", kpis.get("active_projects", 0)),
        ("Ideas", kpis.get("ideas_total", 0)),
        ("Inbox", kpis.get("ideas_inbox", 0)),
        ("Opportunities", kpis.get("opportunities", 0)),
        ("Trends", kpis.get("trends", 0)),
        ("Radar Hits", kpis.get("radar_hits", 0)),
        ("Compliance", kpis.get("compliance_reports", 0)),
    ]
    kpi_html = "\n".join(
        f'<div class="kpi"><span class="kpi-value">{v}</span><span class="kpi-label">{k}</span></div>'
        for k, v in kpi_items
    )

    # ── Opportunities table ──────────────────────────────────────────
    opp_rows = ""
    for o in top_opportunities:
        rel = o.get("relevance", "?")
        color = _relevance_color(rel)
        opp_rows += f"""<tr>
            <td>{o.get('id', '?')}</td>
            <td>{o.get('title', '?')}</td>
            <td style="color:{color};font-weight:600">{rel}</td>
            <td>{o.get('status', '?')}</td>
            <td>{o.get('source', '?')}</td>
        </tr>"""

    # ── Trends table ─────────────────────────────────────────────────
    trend_rows = ""
    for t in top_trends:
        rel = t.get("relevance", "?")
        color = _relevance_color(rel)
        trend_rows += f"""<tr>
            <td>{t.get('id', '?')}</td>
            <td>{t.get('title', '?')}</td>
            <td style="color:{color};font-weight:600">{rel}</td>
            <td>{t.get('category', '?')}</td>
            <td>{t.get('status', '?')}</td>
        </tr>"""

    # ── Projects table ───────────────────────────────────────────────
    project_rows = ""
    for p in project_status:
        active_badge = '<span style="color:#22c55e">Active</span>' if p.get("active") else '<span style="color:#94a3b8">Inactive</span>'
        blocked_badge = ' <span style="color:#ef4444;font-weight:600">BLOCKED</span>' if p.get("blocked") else ""
        project_rows += f"""<tr>
            <td>{p.get('id', '?')}</td>
            <td>{p.get('name', '?')}</td>
            <td>{p.get('platform', '?')}</td>
            <td>{active_badge}{blocked_badge}</td>
            <td>{p.get('specs', 0)}</td>
            <td>{p.get('plans', 0)}</td>
            <td>{p.get('ideas', 0)}</td>
        </tr>"""

    # ── Risks ────────────────────────────────────────────────────────
    risk_rows = ""
    for r in risks:
        sev = r.get("severity", "?")
        sev_color = "#ef4444" if sev == "critical" else "#f59e0b" if sev == "high" else "#94a3b8"
        risk_rows += f"""<tr>
            <td><span style="color:{sev_color};font-weight:700">{sev.upper()}</span></td>
            <td>{r.get('type', '?')}</td>
            <td>{r.get('id', '?')}</td>
            <td>{r.get('title', '?')}</td>
        </tr>"""

    # ── AI Usage ─────────────────────────────────────────────────────
    models_html = ""
    models_used = ai_usage.get("models_used", {})
    for model, cost in models_used.items():
        models_html += f"<li>{model}: ${cost:.4f}</li>"

    # ── Actions ──────────────────────────────────────────────────────
    actions_html = "\n".join(f"<li>{a}</li>" for a in actions)

    return f"""<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Strategy Report — {week}</title>
<style>
  :root {{
    --bg: #0f172a; --surface: #1e293b; --border: #334155;
    --text: #e2e8f0; --muted: #94a3b8; --accent: #3b82f6;
    --green: #22c55e; --yellow: #eab308; --red: #ef4444; --orange: #f59e0b;
  }}
  * {{ margin: 0; padding: 0; box-sizing: border-box; }}
  body {{ font-family: 'Segoe UI', system-ui, sans-serif; background: var(--bg); color: var(--text); padding: 2rem; line-height: 1.6; }}
  .container {{ max-width: 1100px; margin: 0 auto; }}
  h1 {{ font-size: 1.8rem; margin-bottom: 0.25rem; }}
  h2 {{ font-size: 1.3rem; color: var(--accent); margin: 2rem 0 1rem; border-bottom: 1px solid var(--border); padding-bottom: 0.5rem; }}
  .meta {{ color: var(--muted); font-size: 0.85rem; margin-bottom: 1.5rem; }}
  .summary {{ background: var(--surface); border-left: 4px solid var(--accent); padding: 1rem 1.25rem; border-radius: 0 8px 8px 0; margin-bottom: 1.5rem; }}
  .kpi-grid {{ display: grid; grid-template-columns: repeat(auto-fill, minmax(120px, 1fr)); gap: 0.75rem; margin-bottom: 1.5rem; }}
  .kpi {{ background: var(--surface); border-radius: 8px; padding: 0.75rem; text-align: center; }}
  .kpi-value {{ display: block; font-size: 1.5rem; font-weight: 700; color: var(--accent); }}
  .kpi-label {{ display: block; font-size: 0.75rem; color: var(--muted); text-transform: uppercase; letter-spacing: 0.5px; }}
  table {{ width: 100%; border-collapse: collapse; background: var(--surface); border-radius: 8px; overflow: hidden; margin-bottom: 1rem; }}
  th {{ background: var(--border); text-align: left; padding: 0.6rem 0.75rem; font-size: 0.8rem; text-transform: uppercase; letter-spacing: 0.5px; color: var(--muted); }}
  td {{ padding: 0.5rem 0.75rem; border-bottom: 1px solid var(--border); font-size: 0.9rem; }}
  tr:last-child td {{ border-bottom: none; }}
  .actions {{ background: var(--surface); border-radius: 8px; padding: 1rem 1.25rem; }}
  .actions li {{ margin-bottom: 0.5rem; padding-left: 0.5rem; }}
  .actions li::marker {{ color: var(--accent); }}
  .ai-usage {{ display: grid; grid-template-columns: 1fr 1fr; gap: 1rem; }}
  .ai-card {{ background: var(--surface); border-radius: 8px; padding: 1rem; }}
  .ai-card h3 {{ font-size: 0.9rem; color: var(--muted); margin-bottom: 0.5rem; }}
  .ai-card .value {{ font-size: 1.4rem; font-weight: 700; color: var(--green); }}
  .no-data {{ color: var(--muted); font-style: italic; padding: 1rem; }}
  ul {{ padding-left: 1.5rem; }}
  footer {{ margin-top: 2rem; padding-top: 1rem; border-top: 1px solid var(--border); color: var(--muted); font-size: 0.75rem; text-align: center; }}
</style>
</head>
<body>
<div class="container">
  <h1>Strategy Report — {week}</h1>
  <div class="meta">Generated {generated} | AI App Factory</div>

  <h2>Executive Summary</h2>
  <div class="summary">{summary}</div>

  <h2>System Metrics</h2>
  <div class="kpi-grid">{kpi_html}</div>

  <h2>Strategic Opportunities</h2>
  {"<table><tr><th>ID</th><th>Title</th><th>Relevance</th><th>Status</th><th>Source</th></tr>" + opp_rows + "</table>" if opp_rows else '<p class="no-data">No active opportunities.</p>'}

  <h2>Emerging Trends</h2>
  {"<table><tr><th>ID</th><th>Title</th><th>Relevance</th><th>Category</th><th>Status</th></tr>" + trend_rows + "</table>" if trend_rows else '<p class="no-data">No active trends.</p>'}

  <h2>Project Status</h2>
  {"<table><tr><th>ID</th><th>Name</th><th>Platform</th><th>Status</th><th>Specs</th><th>Plans</th><th>Ideas</th></tr>" + project_rows + "</table>" if project_rows else '<p class="no-data">No projects registered.</p>'}

  <h2>Risk Overview</h2>
  {"<table><tr><th>Severity</th><th>Type</th><th>ID</th><th>Title</th></tr>" + risk_rows + "</table>" if risk_rows else '<p class="no-data">No active risks. Factory running clean.</p>'}

  <h2>AI Usage Overview</h2>
  <div class="ai-usage">
    <div class="ai-card">
      <h3>This Week</h3>
      <div class="value">{ai_usage.get('week_cost', '$0')}</div>
      <div style="color:var(--muted);font-size:0.85rem">{ai_usage.get('week_tokens', 0):,} tokens | {ai_usage.get('week_requests', 0)} requests</div>
    </div>
    <div class="ai-card">
      <h3>All Time</h3>
      <div class="value">{ai_usage.get('total_cost', '$0')}</div>
      <div style="color:var(--muted);font-size:0.85rem">{ai_usage.get('total_requests', 0)} total requests</div>
    </div>
  </div>
  {f'<div style="margin-top:0.75rem"><strong style="color:var(--muted);font-size:0.85rem">Models used this week:</strong><ul style="margin-top:0.25rem">{models_html}</ul></div>' if models_html else ''}

  <h2>Recommended Actions</h2>
  <div class="actions">
    <ol>{actions_html}</ol>
  </div>

  <footer>AI App Factory — Weekly Strategy Report | {week} | Auto-generated</footer>
</div>
</body>
</html>"""


def _relevance_color(rel: str) -> str:
    """Map relevance labels or percentages to colors."""
    rel_lower = rel.lower() if isinstance(rel, str) else ""
    if rel_lower in ("critical",) or (rel_lower.endswith("%") and _parse_pct(rel_lower) >= 70):
        return "#ef4444"
    if rel_lower in ("high",) or (rel_lower.endswith("%") and _parse_pct(rel_lower) >= 50):
        return "#f59e0b"
    if rel_lower in ("medium",) or (rel_lower.endswith("%") and _parse_pct(rel_lower) >= 30):
        return "#eab308"
    return "#94a3b8"


def _parse_pct(s: str) -> float:
    try:
        return float(s.replace("%", ""))
    except ValueError:
        return 0
