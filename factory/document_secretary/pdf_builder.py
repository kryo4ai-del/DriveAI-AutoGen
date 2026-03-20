"""Professional PDF builder using HTML/CSS -> PDF conversion via Playwright.

Design: Dark navy/teal color scheme, clean typography, colored tables,
traffic light badges, title page, A4 print-optimized.
"""

import re
from datetime import date
from html import escape
from pathlib import Path

CSS = """
@page {
    size: A4;
    margin: 2cm 2.5cm;
}
:root {
    --primary: #1a1a2e;
    --secondary: #16213e;
    --accent: #0f3460;
    --highlight: #e94560;
    --success: #27ae60;
    --warning: #f39c12;
    --danger: #e74c3c;
    --bg-light: #f8f9fa;
    --bg-white: #ffffff;
    --text-primary: #2c3e50;
    --text-secondary: #7f8c8d;
    --border: #dee2e6;
}
body {
    font-family: 'Segoe UI', -apple-system, Roboto, 'Helvetica Neue', Arial, sans-serif;
    font-size: 10.5pt;
    line-height: 1.6;
    color: var(--text-primary);
}
.title-page {
    page-break-after: always;
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: center;
    min-height: 80vh;
    text-align: center;
}
.title-page h1 {
    font-size: 32pt;
    font-weight: 700;
    color: var(--primary);
    margin-bottom: 0.3em;
    letter-spacing: -0.5px;
    border: none;
}
.title-page .subtitle {
    font-size: 14pt;
    color: var(--text-secondary);
    margin-bottom: 2em;
}
.title-page .meta {
    font-size: 10pt;
    color: var(--text-secondary);
}
.title-page .divider {
    width: 80px;
    height: 3px;
    background: var(--accent);
    margin: 1.5em auto;
}
h1 {
    font-size: 20pt;
    color: var(--primary);
    border-bottom: 2px solid var(--accent);
    padding-bottom: 0.3em;
    margin-top: 1.5em;
    page-break-after: avoid;
}
h2 {
    font-size: 14pt;
    color: var(--secondary);
    margin-top: 1.2em;
    page-break-after: avoid;
}
h3 {
    font-size: 11pt;
    color: var(--accent);
    margin-top: 1em;
}
table {
    width: 100%;
    border-collapse: collapse;
    margin: 1em 0;
    font-size: 9.5pt;
}
th {
    background: var(--primary);
    color: white;
    padding: 8px 12px;
    text-align: left;
    font-weight: 600;
}
td {
    padding: 6px 12px;
    border-bottom: 1px solid var(--border);
}
tr:nth-child(even) {
    background: var(--bg-light);
}
.badge {
    display: inline-block;
    padding: 2px 10px;
    border-radius: 12px;
    font-size: 9pt;
    font-weight: 600;
    color: white;
}
.badge-green { background: var(--success); }
.badge-yellow { background: var(--warning); }
.badge-red { background: var(--danger); }
.kv-row {
    display: flex;
    margin: 0.3em 0;
}
.kv-key {
    font-weight: 600;
    min-width: 200px;
    color: var(--secondary);
}
.kv-value {
    flex: 1;
}
.highlight-box {
    background: var(--bg-light);
    border-left: 4px solid var(--accent);
    padding: 12px 16px;
    margin: 1em 0;
    border-radius: 0 4px 4px 0;
}
.recommendation {
    background: #eaf7ed;
    border: 1px solid var(--success);
    border-left: 4px solid var(--success);
    padding: 12px 16px;
    margin: 1em 0;
    border-radius: 0 4px 4px 0;
}
.recommendation.warning {
    background: #fef9e7;
    border-color: var(--warning);
}
.recommendation.danger {
    background: #fdedec;
    border-color: var(--danger);
}
.page-break { page-break-before: always; }
blockquote {
    border-left: 3px solid var(--accent);
    margin: 1em 0;
    padding: 0.5em 1em;
    color: var(--text-secondary);
    font-style: italic;
}
.footer {
    position: fixed;
    bottom: 0;
    left: 0;
    right: 0;
    text-align: center;
    font-size: 8pt;
    color: #999;
    padding: 0 2.5cm 1cm 2.5cm;
}
"""


def _esc(text: str) -> str:
    """HTML-escape text."""
    return escape(str(text))


def _badge(text: str) -> str:
    """Convert risk indicators to colored badge HTML."""
    t = text.strip()
    if any(g in t for g in ["🟢", "Gruen", "Grün", "Niedrig"]):
        label = re.sub(r"🟢\s*", "", t).strip() or "Gruen"
        return f'<span class="badge badge-green">{_esc(label)}</span>'
    if any(y in t for y in ["🟡", "Gelb", "Mittel"]):
        label = re.sub(r"🟡\s*", "", t).strip() or "Gelb"
        return f'<span class="badge badge-yellow">{_esc(label)}</span>'
    if any(r in t for r in ["🔴", "Rot", "Hoch", "Kritisch"]):
        label = re.sub(r"🔴\s*", "", t).strip() or "Rot"
        return f'<span class="badge badge-red">{_esc(label)}</span>'
    return _esc(t)


class PdfBuilder:
    """Builds professional PDF documents via HTML/CSS."""

    def __init__(self, title: str, subtitle: str = ""):
        self.title = title
        self.subtitle = subtitle
        self.sections: list[str] = []
        self._add_title_page()

    def _add_title_page(self):
        today = date.today().strftime("%d. %B %Y")
        self.sections.append(f"""
<div class="title-page">
    <h1>{_esc(self.title)}</h1>
    <div class="divider"></div>
    <div class="subtitle">{_esc(self.subtitle)}</div>
    <div class="meta">Stand: {today}</div>
    <div class="meta" style="margin-top:0.5em;color:#aaa">DriveAI Swarm Factory</div>
</div>
""")

    def add_heading(self, text: str, level: int = 1):
        tag = f"h{min(level, 3)}"
        self.sections.append(f"<{tag}>{_esc(text)}</{tag}>")

    def add_paragraph(self, text: str):
        self.sections.append(f"<p>{_esc(text)}</p>")

    def add_key_value(self, key: str, value: str):
        self.sections.append(
            f'<div class="kv-row"><span class="kv-key">{_esc(key)}</span>'
            f'<span class="kv-value">{_esc(value)}</span></div>'
        )

    def add_table(self, headers: list[str], rows: list[list[str]]):
        html = "<table><thead><tr>"
        for h in headers:
            html += f"<th>{_esc(h)}</th>"
        html += "</tr></thead><tbody>"
        for row in rows:
            html += "<tr>"
            for cell in row:
                html += f"<td>{_esc(cell)}</td>"
            html += "</tr>"
        html += "</tbody></table>"
        self.sections.append(html)

    def add_traffic_light_table(self, headers: list[str], rows: list[list[str]], risk_col: int = 1):
        html = "<table><thead><tr>"
        for h in headers:
            html += f"<th>{_esc(h)}</th>"
        html += "</tr></thead><tbody>"
        for row in rows:
            html += "<tr>"
            for i, cell in enumerate(row):
                if i == risk_col:
                    html += f"<td>{_badge(cell)}</td>"
                else:
                    html += f"<td>{_esc(cell)}</td>"
            html += "</tr>"
        html += "</tbody></table>"
        self.sections.append(html)

    def add_highlight_box(self, text: str):
        self.sections.append(f'<div class="highlight-box">{_esc(text)}</div>')

    def add_recommendation(self, text: str, level: str = "success"):
        cls = "recommendation"
        if level in ("warning", "danger"):
            cls += f" {level}"
        self.sections.append(f'<div class="{cls}">{_esc(text)}</div>')

    def add_page_break(self):
        self.sections.append('<div class="page-break"></div>')

    def add_section_separator(self):
        self.sections.append('<hr style="border:none;border-top:1px solid #ddd;margin:1.5em 0">')

    def build_html(self) -> str:
        body = "\n".join(self.sections)
        return f"""<!DOCTYPE html>
<html lang="de">
<head>
<meta charset="utf-8">
<title>{_esc(self.title)}</title>
<style>{CSS}</style>
</head>
<body>
{body}
<div class="footer">DriveAI Swarm Factory — Vertraulich</div>
</body>
</html>"""

    def save_pdf(self, filepath: str) -> str:
        """Convert HTML to PDF via Playwright (Chromium)."""
        html = self.build_html()

        try:
            from playwright.sync_api import sync_playwright
            with sync_playwright() as p:
                browser = p.chromium.launch()
                page = browser.new_page()
                page.set_content(html, wait_until="networkidle")
                page.pdf(
                    path=filepath,
                    format="A4",
                    margin={"top": "2cm", "right": "2.5cm", "bottom": "2cm", "left": "2.5cm"},
                    print_background=True,
                )
                browser.close()
            return filepath
        except Exception as e:
            print(f"[PdfBuilder] WARNING: Playwright PDF failed — {e}")

        # Fallback: save HTML
        html_path = filepath.replace(".pdf", ".html")
        Path(html_path).write_text(html, encoding="utf-8")
        print(f"[PdfBuilder] Saved as HTML fallback: {html_path}")
        return html_path

    def save_html(self, filepath: str) -> str:
        """Save the raw HTML."""
        Path(filepath).write_text(self.build_html(), encoding="utf-8")
        return filepath
