"""Marketing Konzept — Standalone document for marketing agencies."""

import json

import anthropic
from dotenv import load_dotenv

load_dotenv()


def generate(phase1_data: dict, phase2_data: dict, docx_builder) -> None:
    """Populate the docx builder with a complete Marketing Konzept."""
    content = _extract_content(phase1_data, phase2_data)

    chapters = content.get("chapters", [])
    for i, chapter in enumerate(chapters, 1):
        docx_builder.add_heading(f"{i}. {chapter.get('title', '')}", level=1)

        body = chapter.get("body", "")
        for paragraph in body.split("\n\n"):
            paragraph = paragraph.strip()
            if not paragraph:
                continue
            # Check if it's a sub-heading
            if paragraph.startswith("### "):
                docx_builder.add_heading(paragraph.lstrip("#").strip(), level=3)
            elif paragraph.startswith("## "):
                docx_builder.add_heading(paragraph.lstrip("#").strip(), level=2)
            else:
                docx_builder.add_paragraph(paragraph)

        # Add table if present
        table_data = chapter.get("table")
        if table_data and isinstance(table_data, dict):
            headers = table_data.get("headers", [])
            rows = table_data.get("rows", [])
            if headers and rows:
                docx_builder.add_table(headers, rows)

        if i < len(chapters):
            docx_builder.add_page_break()


def _extract_content(phase1_data: dict, phase2_data: dict) -> dict:
    """Use Claude to structure a complete Marketing Konzept from all reports."""
    prompt = f"""Du bist eine Marketing-Beraterin und erstellst ein professionelles Marketing-Konzept-Dokument.

Erstelle aus den folgenden Reports ein vollstaendiges Marketing-Konzept mit 13 Kapiteln.

Antworte NUR in JSON (kein Markdown, keine Backticks). Format:

{{
  "app_name": "...",
  "chapters": [
    {{
      "title": "Produkt-Uebersicht",
      "body": "... (Fliesstext, Absaetze durch doppelte Zeilenumbrueche getrennt)",
      "table": null oder {{"headers": ["Col1", "Col2"], "rows": [["val1", "val2"]]}}
    }},
    ... (13 Kapitel)
  ]
}}

Die 13 Kapitel:
1. Produkt-Uebersicht (aus Concept Brief — kurz und praegnant)
2. Zielgruppe (aus Audience Profile)
3. Marktanalyse & Wettbewerb (aus Competitive Report)
4. Marketing-Kanal-Strategie (aus Marketing Strategy)
5. App Store Optimization (aus Marketing Strategy)
6. Social Media Plan (aus Marketing Strategy — mit Tabelle: Kanal, Content-Typ, Frequenz, Ziel)
7. Influencer-Strategie (aus Marketing Strategy)
8. Paid User Acquisition (aus Marketing Strategy — mit Budget-Tabelle)
9. Pre-Launch Plan (aus Marketing Strategy)
10. Launch-Strategie (aus Marketing + Release Plan)
11. Post-Launch Plan (aus Marketing Strategy)
12. Budget-Uebersicht (aus Marketing Strategy + Cost Calculation — mit Tabelle)
13. KPIs & Erfolgsmessung (aus Release Plan — mit KPI-Tabelle)

## Phase 1 Reports

### Concept Brief
{phase1_data.get('concept_brief', '')[:3000]}

### Competitive Report
{phase1_data.get('competitive_report', '')[:3000]}

### Audience Profile
{phase1_data.get('audience_profile', '')[:3000]}

## Phase 2 Reports

### Marketing Strategy
{phase2_data.get('marketing_strategy', '')[:5000]}

### Release Plan
{phase2_data.get('release_plan', '')[:3000]}

### Cost Calculation
{phase2_data.get('cost_calculation', '')[:3000]}"""

    print("[DocumentSecretary] Extracting Marketing Konzept content via Claude...")
    client = anthropic.Anthropic()
    response = client.messages.create(
        model="claude-sonnet-4-6",
        max_tokens=16000,
        messages=[{"role": "user", "content": prompt}],
    )

    raw = response.content[0].text.strip()
    if raw.startswith("```"):
        raw = raw.split("\n", 1)[1]
    if raw.endswith("```"):
        raw = raw.rsplit("```", 1)[0]
    raw = raw.strip()

    try:
        return json.loads(raw)
    except json.JSONDecodeError as e:
        print(f"[DocumentSecretary] WARNING: JSON parse error — {e}")
        # Try to fix common JSON issues: truncated strings
        try:
            # Attempt repair: close any open strings and structures
            repaired = raw
            if repaired.count('"') % 2 != 0:
                repaired += '"'
            # Close open arrays/objects
            open_braces = repaired.count("{") - repaired.count("}")
            open_brackets = repaired.count("[") - repaired.count("]")
            repaired += "]" * max(0, open_brackets)
            repaired += "}" * max(0, open_braces)
            result = json.loads(repaired)
            print(f"[DocumentSecretary] JSON repaired successfully")
            return result
        except json.JSONDecodeError:
            pass
        # Final fallback: create a single-chapter doc from raw text
        print(f"[DocumentSecretary] Using raw text fallback")
        return {
            "app_name": "Unknown",
            "chapters": [{"title": "Marketing-Konzept", "body": raw[:8000], "table": None}],
        }
