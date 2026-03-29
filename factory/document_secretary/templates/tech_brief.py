"""Technical Brief — Development architecture and timeline document."""

import json

import anthropic
from dotenv import load_dotenv

from factory.document_secretary.config import get_fallback_model

load_dotenv()


def generate(phase1_data: dict, phase2_data: dict, builder) -> None:
    """Populate builder with Tech Brief content."""
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
                builder.add_table(headers, rows)

        if i < len(sections):
            builder.add_page_break()


def _extract_content(phase1_data: dict, phase2_data: dict) -> dict:
    """Extract tech-focused content from reports."""
    prompt = f"""Du bist ein Technical Lead und erstellst ein Technical Brief fuer ein Entwicklungsteam.

Antworte NUR in JSON (kein Markdown, keine Backticks). Format:

{{
  "sections": [
    {{
      "title": "Produkt-Zusammenfassung",
      "body": "... (Fliesstext, Absaetze durch doppelte Zeilenumbrueche getrennt)",
      "table": null oder {{"headers": ["Col1", "Col2"], "rows": [["val1", "val2"]]}}
    }},
    ... (7 Sections)
  ]
}}

Die 7 Sections:
1. Produkt-Zusammenfassung (Core Mechanic, Game Loop, 3-Layer-Architektur, AI-Personalisierung)
2. Tech-Stack Entscheidung (Unity, AI-Ansatz, Backend, Analytics — mit Begruendung)
3. Plattform-spezifische Anforderungen (iOS ATT, Android Play Store, Cross-Platform)
4. KI-Architektur (Level-Generierung, Behavioral Tracking, Latenz-Ziele, Privacy Pipeline)
5. Entwicklungs-Phasen (Phase A MVP + KI-PoC, Phase B Full Production — Tabelle mit Meilensteinen)
6. Infrastruktur (Cloud Hosting, Scaling, Monitoring, CI/CD)
7. Technische Risiken (AI Performance, Cross-Platform, Datenschutz — Tabelle: Risiko, Impact, Mitigation)

## Concept Brief
{phase1_data.get('concept_brief', '')[:4000]}

## Platform Strategy
{phase2_data.get('platform_strategy', '')[:4000]}

## Release Plan
{phase2_data.get('release_plan', '')[:3000]}

## Risk Assessment
{phase1_data.get('risk_assessment', '')[:2000]}"""

    print("[DocumentSecretary] Extracting Tech Brief content via Claude...")
    client = anthropic.Anthropic()
    response = client.messages.create(
        model=get_fallback_model(),
        max_tokens=6000,
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
            return {"sections": [{"title": "Technical Brief", "body": raw[:6000], "table": None}]}
