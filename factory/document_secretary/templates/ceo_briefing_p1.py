"""CEO Briefing Phase 1 — Executive Summary + Detail Reports."""

import json

import anthropic
from dotenv import load_dotenv

load_dotenv()


def generate(phase1_data: dict, docx_builder) -> None:
    """Populate the docx builder with Phase 1 CEO Briefing content."""
    # 1. Call Claude to extract structured content
    content = _extract_content(phase1_data)

    # 2. Executive Summary
    docx_builder.add_heading("Executive Summary", level=1)

    docx_builder.add_key_value("Idee", content.get("one_liner", ""))
    docx_builder.add_key_value("Gesamtrisiko", content.get("risk_rating", ""))
    docx_builder.add_key_value("Empfehlung", content.get("recommendation", ""))
    docx_builder.add_paragraph("")

    docx_builder.add_paragraph(content.get("executive_summary", ""))

    docx_builder.add_page_break()

    # 3. Detail sections
    docx_builder.add_heading("Detail-Erklaerungen", level=1)

    steps = content.get("steps", [])
    for i, step in enumerate(steps, 1):
        docx_builder.add_heading(f"{i}. {step.get('title', '')}", level=2)

        docx_builder.add_heading("Was wurde gemacht", level=3)
        docx_builder.add_paragraph(step.get("what_was_done", ""))

        docx_builder.add_heading("Kernergebnisse", level=3)
        findings = step.get("key_findings", "")
        for line in findings.split("\n"):
            line = line.strip().lstrip("-•").strip()
            if line:
                docx_builder.add_paragraph(f"• {line}")

        docx_builder.add_heading("Bedeutung fuer die Entscheidung", level=3)
        docx_builder.add_paragraph(step.get("meaning", ""))

        docx_builder.add_heading("Datenluecken & Risiken", level=3)
        docx_builder.add_paragraph(step.get("watch_out", ""))

        if i < len(steps):
            docx_builder.add_section_separator()


def _extract_content(phase1_data: dict) -> dict:
    """Use Claude to extract structured content from Phase 1 reports."""
    prompt = f"""Du bist die Executive Assistentin des CEOs der DriveAI Swarm Factory.
Erstelle aus den folgenden 6 Agent-Reports ein CEO Briefing.

Antworte NUR in JSON (kein Markdown, keine Backticks). Format:

{{
  "app_name": "...",
  "one_liner": "...",
  "executive_summary": "... (300-500 Woerter, deutsch, professionell)",
  "recommendation": "GO / GO mit Auflagen / KILL",
  "risk_rating": "Gruen/Gelb/Rot",
  "steps": [
    {{
      "title": "Trend-Analyse",
      "what_was_done": "... (2-3 Saetze)",
      "key_findings": "... (3-5 Bullet Points als String mit Zeilenumbruechen)",
      "meaning": "... (2-3 Saetze: Was bedeutet das fuer die Entscheidung)",
      "watch_out": "... (1-2 Saetze: Datenluecken, Risiken, Unsicherheiten)"
    }},
    ... (6 Steps: Trend-Analyse, Wettbewerbsanalyse, Zielgruppen-Analyse, Concept Brief, Rechtliche Analyse, Risiko-Bewertung)
  ]
}}

## Report 1: Trend-Report
{phase1_data.get('trend_report', '')[:4000]}

## Report 2: Competitive-Report
{phase1_data.get('competitive_report', '')[:4000]}

## Report 3: Zielgruppen-Profil
{phase1_data.get('audience_profile', '')[:3000]}

## Report 4: Concept Brief
{phase1_data.get('concept_brief', '')[:5000]}

## Report 5: Legal-Report
{phase1_data.get('legal_report', '')[:4000]}

## Report 6: Risk-Assessment
{phase1_data.get('risk_assessment', '')[:4000]}"""

    print("[DocumentSecretary] Extracting Phase 1 content via Claude...")
    client = anthropic.Anthropic()
    response = client.messages.create(
        model="claude-sonnet-4-6",
        max_tokens=8000,
        messages=[{"role": "user", "content": prompt}],
    )

    raw = response.content[0].text.strip()
    # Strip markdown code fences if present
    if raw.startswith("```"):
        raw = raw.split("\n", 1)[1]
    if raw.endswith("```"):
        raw = raw.rsplit("```", 1)[0]
    raw = raw.strip()

    try:
        return json.loads(raw)
    except json.JSONDecodeError as e:
        print(f"[DocumentSecretary] WARNING: JSON parse error — {e}")
        return {
            "app_name": "Unknown",
            "one_liner": "",
            "executive_summary": raw[:2000],
            "recommendation": "",
            "risk_rating": "",
            "steps": [],
        }
