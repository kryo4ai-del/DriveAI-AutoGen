"""CD Technical Roadbook — THE technical build plan PDF. Largest document."""

import anthropic
from dotenv import load_dotenv

load_dotenv()


def generate(k6_data: dict, builder) -> None:
    """Populate builder with CD Technical Roadbook content."""
    raw_md = k6_data.get("cd_technical_roadbook", "")
    if not raw_md.strip():
        builder.add_heading("Creative Director Technical Roadbook", level=1)
        builder.add_paragraph("Keine Daten vorhanden.")
        return

    # Extract design briefing for highlight
    briefing = _extract_briefing(raw_md)
    if briefing:
        builder.add_recommendation(briefing, level="success")
        builder.add_paragraph("")

    print("[DocumentSecretary] Rendering CD Technical Roadbook from Markdown...")
    _render_cd_md(raw_md, builder)


def _extract_briefing(md: str) -> str:
    lines = md.split("\n")
    in_briefing = False
    result = []
    for line in lines:
        if "Design-Briefing" in line and "#" in line:
            in_briefing = True
            continue
        if in_briefing:
            if line.startswith("##") and "Design-Briefing" not in line:
                break
            if line.startswith("---"):
                break
            if line.strip():
                result.append(line.strip())
    return " ".join(result)[:600] if result else ""


def _render_cd_md(md_text: str, builder) -> None:
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
        elif "VERBOTEN" in s or "VERBOTE" in s:
            builder.add_recommendation(s, level="danger")
        elif "PFLICHT" in s and "#" not in s:
            builder.add_recommendation(s, level="warning")
        elif "Wow-Moment" in s and "#" not in s and "|" not in s:
            builder.add_highlight_box(s)
        elif "\u26a0\ufe0f" in s and ("KI" in s or "Warnung" in s):
            builder.add_recommendation(s, level="warning")
        elif s.startswith("- [ ]") or s.startswith("- [x]"):
            builder.add_paragraph(s)
        elif s.startswith("- ") or s.startswith("* "):
            builder.add_paragraph(s)
        elif s == "---":
            continue
        else:
            builder.add_paragraph(s)

    if in_table and table_headers and table_rows:
        builder.add_table(table_headers, table_rows)
