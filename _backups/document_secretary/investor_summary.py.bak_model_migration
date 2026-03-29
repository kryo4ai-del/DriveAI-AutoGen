"""Investor Pitch Summary — Professional investment document."""

import json

import anthropic
from dotenv import load_dotenv

load_dotenv()


def generate(phase1_data: dict, phase2_data: dict, builder) -> None:
    """Populate builder with Investor Summary content."""
    content = _extract_content(phase1_data, phase2_data)

    sections = content.get("sections", [])
    for i, section in enumerate(sections, 1):
        builder.add_heading(f"{i}. {section.get('title', '')}", level=1)

        body = section.get("body", "")
        for para in body.split("\n\n"):
            para = para.strip()
            if para:
                builder.add_paragraph(para)

        table = section.get("table")
        if table and isinstance(table, dict):
            headers = table.get("headers", [])
            rows = table.get("rows", [])
            if headers and rows:
                risk_col = next((i for i, h in enumerate(headers) if "risiko" in h.lower() or "risk" in h.lower()), -1)
                if risk_col >= 0:
                    builder.add_traffic_light_table(headers, rows, risk_col=risk_col)
                else:
                    builder.add_table(headers, rows)

        highlight = section.get("highlight")
        if highlight:
            builder.add_highlight_box(highlight)

        if i < len(sections):
            builder.add_page_break()


def _extract_content(phase1_data: dict, phase2_data: dict) -> dict:
    """Extract investor-focused content from all reports."""
    prompt = f"""Du bist ein Investment-Analyst und erstellst ein professionelles Investment Summary.

Antworte NUR in JSON (kein Markdown, keine Backticks). Format:

{{
  "sections": [
    {{
      "title": "Executive Overview",
      "body": "... (Fliesstext, Absaetze durch doppelte Zeilenumbrueche getrennt)",
      "table": null oder {{"headers": ["Col1", "Col2"], "rows": [["val1", "val2"]]}},
      "highlight": null oder "... (ein Satz fuer Highlight-Box)"
    }},
    ... (8 Sections)
  ]
}}

Die 8 Sections:
1. Executive Overview (One-Liner, Marktchance, Differenzierung, Business Model)
2. Marktchance (Marktgroesse, Wachstum, Genre-Position, Structural Gap)
3. Wettbewerbslandschaft (Top 5 Competitors Tabelle, Feature-Vergleich, Moat)
4. Zielgruppe & Monetarisierung (Profil, Modell, Revenue-Prognose Tabelle, Unit Economics)
5. Go-to-Market Strategie (Plattform, Release-Phasen, Marketing, KPI-Targets)
6. Finanzuebersicht (Investment, Break-Even Tabelle, Monthly Burn, Worst-Case)
7. Risikoprofil (Ampel-Tabelle, Top 3 Risiken, Legal Status)
8. Team & Execution (DriveAI Factory, autonome Pipeline, Track Record)

## Phase 1 Reports
### Concept Brief
{phase1_data.get('concept_brief', '')[:4000]}

### Competitive Report
{phase1_data.get('competitive_report', '')[:3000]}

### Audience Profile
{phase1_data.get('audience_profile', '')[:2000]}

### Risk Assessment
{phase1_data.get('risk_assessment', '')[:3000]}

## Phase 2 Reports
### Platform Strategy
{phase2_data.get('platform_strategy', '')[:3000]}

### Monetization Report
{phase2_data.get('monetization_report', '')[:3000]}

### Marketing Strategy
{phase2_data.get('marketing_strategy', '')[:2000]}

### Release Plan
{phase2_data.get('release_plan', '')[:2000]}

### Cost Calculation
{phase2_data.get('cost_calculation', '')[:3000]}"""

    print("[DocumentSecretary] Extracting Investor Summary content via Claude...")
    client = anthropic.Anthropic()
    response = client.messages.create(
        model="claude-sonnet-4-6",
        max_tokens=8000,
        messages=[{"role": "user", "content": prompt}],
    )

    return _parse_json(response.content[0].text)


def _parse_json(raw: str) -> dict:
    raw = raw.strip()
    if raw.startswith("```"):
        raw = raw.split("\n", 1)[1]
    if raw.endswith("```"):
        raw = raw.rsplit("```", 1)[0]
    raw = raw.strip()

    try:
        return json.loads(raw)
    except json.JSONDecodeError as e:
        print(f"[DocumentSecretary] WARNING: JSON parse error — {e}")
        try:
            repaired = raw
            if repaired.count('"') % 2 != 0:
                repaired += '"'
            repaired += "]" * max(0, repaired.count("[") - repaired.count("]"))
            repaired += "}" * max(0, repaired.count("{") - repaired.count("}"))
            return json.loads(repaired)
        except json.JSONDecodeError:
            return {"sections": [{"title": "Investment Summary", "body": raw[:6000], "table": None, "highlight": None}]}
