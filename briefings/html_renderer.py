# html_renderer.py
# Renders daily briefing data into a professional HTML email layout.

from __future__ import annotations


_SEVERITY_COLORS = {
    "critical": "#dc3545",
    "high": "#fd7e14",
    "medium": "#ffc107",
    "low": "#28a745",
    "info": "#6c757d",
}

_STATUS_COLORS = {
    "active": "#28a745",
    "planning": "#17a2b8",
    "released": "#6f42c1",
    "paused": "#6c757d",
    "archived": "#6c757d",
}


def _sev_badge(severity: str) -> str:
    color = _SEVERITY_COLORS.get(severity, "#6c757d")
    return (f'<span style="background:{color};color:#fff;padding:2px 8px;'
            f'border-radius:3px;font-size:12px;font-weight:600;">{severity}</span>')


def _kpi_card(label: str, value, color: str = "#0d6efd") -> str:
    return (
        f'<td style="text-align:center;padding:12px 16px;background:#f8f9fa;border-radius:8px;">'
        f'<div style="font-size:28px;font-weight:700;color:{color};">{value}</div>'
        f'<div style="font-size:12px;color:#6c757d;margin-top:4px;">{label}</div></td>'
    )


def render_html(briefing_date: str, kpis: dict, sections: dict, actions: list[str]) -> str:
    """Render a complete HTML briefing email."""
    alerts = sections.get("alerts", [])
    alert_count = len(alerts)
    alert_color = "#dc3545" if alert_count > 0 else "#28a745"

    html_parts = [
        '<!DOCTYPE html><html><head><meta charset="utf-8">',
        '<meta name="viewport" content="width=device-width,initial-scale=1">',
        '</head>',
        '<body style="margin:0;padding:0;background:#f0f2f5;font-family:-apple-system,BlinkMacSystemFont,\'Segoe UI\',Roboto,sans-serif;">',
        '<div style="max-width:680px;margin:0 auto;background:#fff;">',

        # Header
        f'<div style="background:linear-gradient(135deg,#1a1a2e 0%,#16213e 100%);padding:32px 24px;color:#fff;">',
        f'<h1 style="margin:0;font-size:24px;font-weight:700;">AI App Factory — Daily Briefing</h1>',
        f'<p style="margin:8px 0 0;opacity:0.8;font-size:14px;">{briefing_date}</p>',
        '</div>',

        # KPI Cards
        '<div style="padding:24px;">',
        '<table style="width:100%;border-collapse:separate;border-spacing:8px;"><tr>',
        _kpi_card("Projects", kpis.get("projects", 0)),
        _kpi_card("Ideas", kpis.get("ideas", 0)),
        _kpi_card("Inbox", kpis.get("ideas_inbox", 0), "#fd7e14" if kpis.get("ideas_inbox", 0) > 0 else "#6c757d"),
        _kpi_card("Alerts", alert_count, alert_color),
        '</tr><tr>',
        _kpi_card("Agents", kpis.get("agents", "0")),
        _kpi_card("Trends", kpis.get("trends", 0)),
        _kpi_card("Plans", kpis.get("plans", 0)),
        _kpi_card("Memory", kpis.get("memory_entries", 0)),
        '</tr></table>',
        '</div>',
    ]

    # Executive Summary
    summary = sections.get("executive_summary", [])
    if summary:
        html_parts.append(_section_header("Executive Summary", "#1a1a2e"))
        html_parts.append('<div style="padding:0 24px 16px;">')
        for line in summary:
            html_parts.append(f'<p style="margin:4px 0;font-size:15px;color:#333;">{line}</p>')
        html_parts.append('</div>')

    # Actions You Should Take Today
    if actions:
        html_parts.append(_section_header("Actions Today", "#dc3545"))
        html_parts.append('<div style="padding:0 24px 16px;">')
        html_parts.append('<ol style="margin:0;padding-left:24px;">')
        for action in actions:
            html_parts.append(f'<li style="margin:6px 0;font-size:14px;color:#333;">{action}</li>')
        html_parts.append('</ol></div>')

    # Alerts & Risks
    if alerts:
        html_parts.append(_section_header(f"Alerts & Risks ({len(alerts)})", "#dc3545"))
        html_parts.append(_table_start(["Type", "ID", "Title", "Severity"]))
        for a in alerts:
            html_parts.append(_table_row([
                a.get("type", "?"),
                f'<code>{a.get("id", "?")}</code>',
                a.get("title", "?"),
                _sev_badge(a.get("severity", "?")),
            ]))
        html_parts.append('</table></div>')

    # Project Status
    proj_list = sections.get("projects", [])
    if proj_list:
        html_parts.append(_section_header("Project Status", "#0d6efd"))
        html_parts.append(_table_start(["Project", "Platform", "Status"]))
        for p in proj_list:
            active_dot = '<span style="color:#28a745;">&#9679;</span>' if p.get("active") else '<span style="color:#ccc;">&#9679;</span>'
            status = p.get("status", "?")
            s_color = _STATUS_COLORS.get(status, "#6c757d")
            status_badge = f'<span style="color:{s_color};font-weight:600;">{status}</span>'
            html_parts.append(_table_row([
                f'{active_dot} {p.get("name", "?")}',
                p.get("platform", "?"),
                status_badge,
            ]))
        html_parts.append('</table></div>')

    # New Ideas
    new_ideas = sections.get("new_ideas", [])
    if new_ideas:
        html_parts.append(_section_header(f"Ideas in Inbox ({len(new_ideas)})", "#fd7e14"))
        html_parts.append(_table_start(["ID", "Title", "Priority", "Source"]))
        for i in new_ideas:
            prio = i.get("priority", "?")
            prio_color = "#dc3545" if prio == "now" else ("#fd7e14" if prio == "next" else "#6c757d")
            html_parts.append(_table_row([
                f'<code>{i.get("id", "?")}</code>',
                i.get("title", "?"),
                f'<span style="color:{prio_color};font-weight:600;">{prio}</span>',
                i.get("source", "?"),
            ]))
        html_parts.append('</table></div>')

    # Trends
    trend_list = sections.get("trends", [])
    if trend_list:
        html_parts.append(_section_header("AI Trends", "#6f42c1"))
        html_parts.append(_table_start(["ID", "Title", "Relevance", "Category"]))
        for t in trend_list:
            rel = t.get("relevance", "?")
            html_parts.append(_table_row([
                f'<code>{t.get("id", "?")}</code>',
                t.get("title", "?"),
                f'<strong>{rel}</strong>',
                t.get("category", "?"),
            ]))
        html_parts.append('</table></div>')

    # Opportunities
    opp_list = sections.get("opportunities", [])
    if opp_list:
        html_parts.append(_section_header("Opportunities", "#20c997"))
        html_parts.append(_table_start(["ID", "Title", "Relevance", "Status"]))
        for o in opp_list:
            html_parts.append(_table_row([
                f'<code>{o.get("id", "?")}</code>',
                o.get("title", "?"),
                o.get("relevance", "?"),
                o.get("status", "?"),
            ]))
        html_parts.append('</table></div>')

    # Compliance
    comp_list = sections.get("compliance", [])
    if comp_list:
        html_parts.append(_section_header("Compliance & Legal", "#e83e8c"))
        html_parts.append(_table_start(["ID", "Topic", "Risk", "Status", "Ext. Review"]))
        for c in comp_list:
            html_parts.append(_table_row([
                f'<code>{c.get("id", "?")}</code>',
                c.get("topic", "?"),
                _sev_badge(c.get("risk", "?")),
                c.get("status", "?"),
                "Yes" if c.get("ext_review") else "—",
            ]))
        html_parts.append('</table></div>')

    # Accessibility
    a11y_list = sections.get("accessibility", [])
    if a11y_list:
        html_parts.append(_section_header("Accessibility", "#17a2b8"))
        html_parts.append(_table_start(["ID", "Issue", "Severity", "File"]))
        for r in a11y_list:
            html_parts.append(_table_row([
                f'<code>{r.get("id", "?")}</code>',
                r.get("issue", "?"),
                _sev_badge(r.get("severity", "?")),
                f'<code>{r.get("file", "?")}</code>',
            ]))
        html_parts.append('</table></div>')

    # Factory Improvements
    imp_list = sections.get("improvements", [])
    if imp_list:
        html_parts.append(_section_header("Factory Improvements", "#28a745"))
        html_parts.append(_table_start(["ID", "Title", "Category", "Severity"]))
        for p in imp_list:
            html_parts.append(_table_row([
                f'<code>{p.get("id", "?")}</code>',
                p.get("title", "?"),
                p.get("category", "?"),
                _sev_badge(p.get("severity", "?")),
            ]))
        html_parts.append('</table></div>')

    # Footer
    html_parts.extend([
        '<div style="padding:24px;text-align:center;border-top:1px solid #e9ecef;">',
        '<p style="margin:0;font-size:12px;color:#6c757d;">',
        f'AI App Factory — Daily Briefing &middot; {briefing_date}',
        '</p></div>',
        '</div></body></html>',
    ])

    return "\n".join(html_parts)


def _section_header(title: str, color: str) -> str:
    return (
        f'<div style="padding:12px 24px;margin-top:8px;'
        f'border-left:4px solid {color};background:#f8f9fa;">'
        f'<h2 style="margin:0;font-size:16px;color:{color};">{title}</h2>'
        f'</div>'
    )


def _table_start(headers: list[str]) -> str:
    cols = "".join(
        f'<th style="text-align:left;padding:8px 12px;border-bottom:2px solid #dee2e6;'
        f'font-size:12px;color:#6c757d;font-weight:600;">{h}</th>'
        for h in headers
    )
    return (
        '<div style="padding:0 24px 16px;overflow-x:auto;">'
        '<table style="width:100%;border-collapse:collapse;font-size:13px;">'
        f'<tr>{cols}</tr>'
    )


def _table_row(cells: list[str]) -> str:
    cols = "".join(
        f'<td style="padding:8px 12px;border-bottom:1px solid #f0f0f0;">{c}</td>'
        for c in cells
    )
    return f'<tr>{cols}</tr>'
