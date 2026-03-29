"""Legal & Compliance Summary — Document for legal counsel."""

import json

import anthropic
from dotenv import load_dotenv

from factory.document_secretary.config import get_fallback_model

load_dotenv()

LEGAL_DISCLAIMER = "KI-basierte Ersteinschaetzung — keine Rechtsberatung"


def generate(phase1_data: dict, phase2_data: dict, builder) -> None:
    """Populate builder with Legal Summary content."""
    # Disclaimer at the top
    builder.add_highlight_box(
        "WICHTIGER HINWEIS: Dieser Report ist eine KI-basierte Ersteinschaetzung "
        "und ersetzt keine rechtsverbindliche Beratung durch zugelassene Rechtsanwaelte."
    )

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
                risk_col = next((i for i, h in enumerate(headers) if "risiko" in h.lower() or "ampel" in h.lower() or "status" in h.lower()), -1)
                if risk_col >= 0:
                    builder.add_traffic_light_table(headers, rows, risk_col=risk_col)
                else:
                    builder.add_table(headers, rows)

        actions = section.get("actions")
        if actions:
            builder.add_recommendation(actions, level="warning")

        if i < len(sections):
            builder.add_page_break()


def _extract_content(phase1_data: dict, phase2_data: dict) -> dict:
    """Extract legal-focused content from reports."""
    prompt = f"""Du bist ein Legal-Analyst und erstellst eine Compliance-Zusammenfassung zur Vorlage bei Rechtsberatung.

Antworte NUR in JSON (kein Markdown, keine Backticks). Format:

{{
  "sections": [
    {{
      "title": "Uebersicht identifizierte Rechtsfelder",
      "body": "... (Fliesstext)",
      "table": null oder {{"headers": ["Rechtsfeld", "Risiko-Status", "Geschaetzte Kosten", "Zeitaufwand"], "rows": [...]}},
      "actions": null oder "... (erforderliche Massnahmen)"
    }},
    ... (8 Sections)
  ]
}}

Die 8 Sections:
1. Uebersicht identifizierte Rechtsfelder (Ampel-Tabelle aller Felder, Gesamtkosten-Spanne, Timeline)
2. Datenschutz DSGVO / COPPA (Anforderungen, AI Behavioral Tracking Implikationen, Massnahmen)
3. Monetarisierung & Gluecksspielrecht (EU-weit + laenderspezifisch, Bewertung des Modells)
4. AI-generierter Content — Urheberrecht (Rechtslage, kommerzielle Nutzung, IP-Schutz)
5. App Store Compliance (Apple ATT, IAP-Regeln, Google Play, plattformspezifisch)
6. Jugendschutz & Altersfreigabe (USK/PEGI/IARC Einstufung, Social Features)
7. Markenrecht (Recherche-Status, empfohlene Massnahmen)
8. Handlungsmatrix (Tabelle: Feld, Prioritaet, Aktion, Verantwortlich, Frist, Kosten — sortiert nach Prioritaet)

## Legal Report
{phase1_data.get('legal_report', '')[:5000]}

## Risk Assessment
{phase1_data.get('risk_assessment', '')[:5000]}

## Platform Strategy (fuer plattformspezifische Anforderungen)
{phase2_data.get('platform_strategy', '')[:2000]}

## Concept Brief (fuer Kontext)
{phase1_data.get('concept_brief', '')[:2000]}"""

    print("[DocumentSecretary] Extracting Legal Summary content via Claude...")
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
            return {"sections": [{"title": "Legal Summary", "body": raw[:6000], "table": None, "actions": None}]}
