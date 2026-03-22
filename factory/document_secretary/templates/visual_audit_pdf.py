"""Visual Audit Report — THE most important PDF for the Review Gate."""

import anthropic
from dotenv import load_dotenv

load_dotenv()


def generate(k5_data: dict, builder) -> None:
    """Populate builder with Visual Audit content.

    This is always rendered from raw Markdown because the visual_consistency.md
    is too large and complex for reliable JSON extraction. Markdown rendering
    ensures nothing is lost.
    """
    raw_md = k5_data.get("visual_consistency", "")
    if not raw_md.strip():
        builder.add_heading("Visual Audit Report", level=1)
        builder.add_paragraph("Keine Daten vorhanden.")
        return

    # Extract counts for executive summary
    red = raw_md.count("\U0001f534")
    yellow = raw_md.count("\U0001f7e1")
    green = raw_md.count("\U0001f7e2")
    warn = raw_md.count("\u26a0\ufe0f")

    # Disclaimer
    builder.add_highlight_box(
        "WICHTIG: Dieses Dokument ist die Basis fuer das Human Review Gate. "
        "Alle Blocker und KI-Warnungen MUESSEN geprueft werden."
    )

    # Executive Summary
    builder.add_heading("Executive Summary", level=1)
    builder.add_table(
        ["Rating", "Anzahl", "Bedeutung"],
        [
            ["\U0001f534 Blocker", str(red), "App funktioniert nicht ohne Loesung"],
            ["\u26a0\ufe0f KI-Warnung", str(warn), "Entwicklungs-KI wird wahrscheinlich falsch generieren"],
            ["\U0001f7e1 Schlechte UX", str(yellow), "Funktioniert, wirkt unprofessionell"],
            ["\U0001f7e2 Nice-to-have", str(green), "Verbesserung, nicht kritisch"],
        ],
    )
    builder.add_paragraph("")

    # Render the full report as formatted Markdown sections
    print("[DocumentSecretary] Rendering Visual Audit Report from Markdown...")
    _render_structured_md(raw_md, builder)


def _render_structured_md(md_text: str, builder) -> None:
    """Render Markdown with special handling for audit-specific elements."""
    lines = md_text.split("\n")
    in_table = False
    table_headers = []
    table_rows = []

    for line in lines:
        s = line.strip()

        # Empty line — flush table if active
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
                # First row = header
                table_headers = cells
                in_table = True
            else:
                table_rows.append(cells)
            continue

        # Flush any open table
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
        # KI-Warnung highlight
        elif "\u26a0\ufe0f" in s and ("KI" in s or "Warnung" in s or "Anweisung" in s):
            builder.add_recommendation(s, level="warning")
        # Blocker highlight
        elif "\U0001f534" in s and ("Blocker" in s or "MUSS" in s or "kritisch" in s.lower()):
            builder.add_recommendation(s, level="danger")
        # Horizontal rules / separators
        elif s == "---" or s == "—  —  —":
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
