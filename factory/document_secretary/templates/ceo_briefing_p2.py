"""CEO Briefing Phase 2 — Strategy & Positioning Executive Summary."""

import json

import anthropic
from dotenv import load_dotenv

load_dotenv()


def generate(phase2_data: dict, docx_builder) -> None:
    """Populate the docx builder with Phase 2 CEO Briefing content."""
    content = _extract_content(phase2_data)

    # Executive Summary
    docx_builder.add_heading("Executive Summary", level=1)

    docx_builder.add_key_value("Plattform-Entscheidung", content.get("platform_decision", ""))
    docx_builder.add_key_value("Monetarisierung", content.get("monetization_model", ""))
    docx_builder.add_key_value("Marketing-Budget Q1", content.get("marketing_budget_q1", ""))
    docx_builder.add_key_value("Gesamtbudget bis Launch", content.get("total_budget", ""))
    docx_builder.add_key_value("Break-Even", content.get("break_even", ""))
    docx_builder.add_key_value("Worst-Case Exposure", content.get("worst_case", ""))
    docx_builder.add_paragraph("")

    docx_builder.add_paragraph(content.get("executive_summary", ""))

    docx_builder.add_page_break()

    # Detail sections
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


def _extract_content(phase2_data: dict) -> dict:
    """Use Claude to extract structured content from Phase 2 reports."""
    prompt = f"""Du bist die Executive Assistentin des CEOs der DriveAI Swarm Factory.
Erstelle aus den folgenden 5 Phase-2-Reports ein CEO Briefing.

Antworte NUR in JSON (kein Markdown, keine Backticks). Format:

{{
  "app_name": "...",
  "platform_decision": "... (1 Satz)",
  "monetization_model": "... (1 Satz)",
  "marketing_budget_q1": "... EUR",
  "total_budget": "... EUR",
  "break_even": "Monat ...",
  "worst_case": "... EUR",
  "executive_summary": "... (300-500 Woerter, deutsch, professionell)",
  "steps": [
    {{
      "title": "Plattform-Strategie",
      "what_was_done": "... (2-3 Saetze)",
      "key_findings": "... (3-5 Bullet Points als String mit Zeilenumbruechen)",
      "meaning": "... (2-3 Saetze)",
      "watch_out": "... (1-2 Saetze)"
    }},
    ... (5 Steps: Plattform-Strategie, Monetarisierung, Marketing-Strategie, Release-Plan, Kosten-Kalkulation)
  ]
}}

## Report 1: Plattform-Strategie
{phase2_data.get('platform_strategy', '')[:4000]}

## Report 2: Monetarisierungs-Report
{phase2_data.get('monetization_report', '')[:4000]}

## Report 3: Marketing-Strategie
{phase2_data.get('marketing_strategy', '')[:5000]}

## Report 4: Release-Plan
{phase2_data.get('release_plan', '')[:4000]}

## Report 5: Kosten-Kalkulation
{phase2_data.get('cost_calculation', '')[:4000]}"""

    print("[DocumentSecretary] Extracting Phase 2 content via Claude...")
    client = anthropic.Anthropic()
    response = client.messages.create(
        model="claude-sonnet-4-6",
        max_tokens=8000,
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
        return {
            "app_name": "Unknown",
            "platform_decision": "",
            "monetization_model": "",
            "marketing_budget_q1": "",
            "total_budget": "",
            "break_even": "",
            "worst_case": "",
            "executive_summary": raw[:2000],
            "steps": [],
        }
