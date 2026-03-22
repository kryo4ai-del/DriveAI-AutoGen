"""Design Vision — THE creative reference PDF. More visual, more inspirational."""

import anthropic
from dotenv import load_dotenv

load_dotenv()


def generate(k45_data: dict, builder) -> None:
    """Populate builder with Design Vision content.

    Renders from Markdown directly — the design_vision_document.md is already
    well-structured and too large for reliable JSON extraction.
    """
    raw_md = k45_data.get("design_vision_document", "")
    if not raw_md.strip():
        builder.add_heading("Design Vision", level=1)
        builder.add_paragraph("Keine Daten vorhanden.")
        return

    # Extract design briefing for special rendering
    briefing_text = _extract_briefing(raw_md)
    if briefing_text:
        builder.add_recommendation(briefing_text, level="success")
        builder.add_paragraph("")

    # Render the full document
    print("[DocumentSecretary] Rendering Design Vision from Markdown...")
    _render_design_md(raw_md, builder)


def _extract_briefing(md_text: str) -> str:
    """Extract the Design-Briefing section text."""
    lines = md_text.split("\n")
    in_briefing = False
    briefing_lines = []
    for line in lines:
        if "Design-Briefing" in line and "#" in line:
            in_briefing = True
            continue
        if in_briefing:
            if line.startswith("---") or (line.startswith("#") and "Design-Briefing" not in line):
                break
            if line.strip():
                briefing_lines.append(line.strip())
    return " ".join(briefing_lines)[:800] if briefing_lines else ""


def _render_design_md(md_text: str, builder) -> None:
    """Render Markdown with special handling for design-specific elements."""
    lines = md_text.split("\n")
    in_table = False
    table_headers = []
    table_rows = []
    skip_briefing = False

    for line in lines:
        s = line.strip()

        # Skip the briefing section (already rendered above)
        if "Design-Briefing" in s and "#" in s:
            skip_briefing = True
            continue
        if skip_briefing:
            if s.startswith("---") or (s.startswith("# ") and "Design-Briefing" not in s):
                skip_briefing = False
            else:
                continue

        if not s:
            if in_table and table_headers and table_rows:
                builder.add_table(table_headers, table_rows)
                table_headers = []
                table_rows = []
                in_table = False
            continue

        # Table separator
        if s.startswith("|") and "---" in s:
            continue

        # Table row
        if s.startswith("|"):
            cells = [c.strip() for c in s.split("|") if c.strip()]
            if not in_table:
                table_headers = cells
                in_table = True
            else:
                table_rows.append(cells)
            continue

        # Flush open table
        if in_table and table_headers:
            if table_rows:
                builder.add_table(table_headers, table_rows)
            table_headers = []
            table_rows = []
            in_table = False

        # Headings
        if s.startswith("# "):
            builder.add_page_break()
            builder.add_heading(s[2:], level=1)
        elif s.startswith("## "):
            builder.add_heading(s[3:], level=2)
        elif s.startswith("### "):
            builder.add_heading(s[4:], level=3)
        # VERBOTEN / Anti-Standard highlights
        elif "VERBOTEN" in s or "VERBOTE" in s or "Anti-Standard" in s:
            builder.add_recommendation(s, level="danger")
        # PFLICHT highlights
        elif "PFLICHT" in s and "##" not in s:
            builder.add_recommendation(s, level="warning")
        # Wow-Moment highlights
        elif "Wow-Moment" in s and "##" not in s and "|" not in s:
            builder.add_highlight_box(s)
        # Checkliste
        elif s.startswith("- [ ]") or s.startswith("- [x]"):
            builder.add_paragraph(s)
        # Horizontal rules
        elif s == "---":
            continue
        # Bullet points
        elif s.startswith("- ") or s.startswith("* "):
            builder.add_paragraph(s)
        # Bold key-value
        elif s.startswith("**") and ":" in s:
            builder.add_paragraph(s)
        else:
            builder.add_paragraph(s)

    # Flush final table
    if in_table and table_headers and table_rows:
        builder.add_table(table_headers, table_rows)
