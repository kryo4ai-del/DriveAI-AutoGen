"""CEO Strategic Roadbook — THE strategic document PDF."""

import anthropic
from dotenv import load_dotenv

load_dotenv()


def generate(k6_data: dict, builder) -> None:
    """Populate builder with CEO Strategic Roadbook content."""
    raw_md = k6_data.get("ceo_strategic_roadbook", "")
    if not raw_md.strip():
        builder.add_heading("CEO Strategic Roadbook", level=1)
        builder.add_paragraph("Keine Daten vorhanden.")
        return

    # Extract executive summary for highlight box
    exec_summary = _extract_section(raw_md, "Executive Summary", 500)
    if exec_summary:
        builder.add_highlight_box(exec_summary)
        builder.add_paragraph("")

    # Render full content
    print("[DocumentSecretary] Rendering CEO Strategic Roadbook from Markdown...")
    _render_roadbook_md(raw_md, builder)


def _extract_section(md: str, heading: str, max_chars: int) -> str:
    lines = md.split("\n")
    capture = False
    result = []
    for line in lines:
        if heading.lower() in line.lower() and "#" in line:
            capture = True
            continue
        if capture:
            if line.startswith("## ") and heading.lower() not in line.lower():
                break
            if line.strip():
                result.append(line.strip())
    text = " ".join(result)
    return text[:max_chars] if text else ""


def _render_roadbook_md(md_text: str, builder) -> None:
    lines = md_text.split("\n")
    in_table = False
    table_headers = []
    table_rows = []

    for line in lines:
        s = line.strip()

        if not s:
            if in_table and table_headers and table_rows:
                builder.add_table(table_headers, table_rows)
                table_headers = []
                table_rows = []
                in_table = False
            continue

        if s.startswith("|") and "---" in s:
            continue

        if s.startswith("|"):
            cells = [c.strip() for c in s.split("|") if c.strip()]
            if not in_table:
                table_headers = cells
                in_table = True
            else:
                table_rows.append(cells)
            continue

        if in_table and table_headers:
            if table_rows:
                builder.add_table(table_headers, table_rows)
            table_headers = []
            table_rows = []
            in_table = False

        if s.startswith("# "):
            builder.add_page_break()
            builder.add_heading(s[2:], level=1)
        elif s.startswith("## "):
            builder.add_heading(s[3:], level=2)
        elif s.startswith("### "):
            builder.add_heading(s[4:], level=3)
        elif "Empfehlung" in s and ("GO" in s or "KILL" in s):
            builder.add_recommendation(s, level="success" if "GO" in s else "danger")
        elif "\U0001f534" in s or "Blocker" in s:
            builder.add_recommendation(s, level="danger")
        elif "\U0001f7e1" in s or "Warnung" in s:
            builder.add_recommendation(s, level="warning")
        elif s.startswith("- ") or s.startswith("* "):
            builder.add_paragraph(s)
        elif s == "---":
            continue
        else:
            builder.add_paragraph(s)

    if in_table and table_headers and table_rows:
        builder.add_table(table_headers, table_rows)
