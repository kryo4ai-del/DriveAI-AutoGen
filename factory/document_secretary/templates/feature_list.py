"""Feature-Liste — Professional PDF of complete feature list with tech-stack check."""

import json

import anthropic
from dotenv import load_dotenv

from factory.document_secretary.config import get_fallback_model

load_dotenv()


def generate(k4_data: dict, builder) -> None:
    """Populate builder with Feature-Liste content."""
    content = _extract_content(k4_data)

    # Summary
    builder.add_heading("Zusammenfassung", level=1)
    builder.add_key_value("Gesamtanzahl Features", str(content.get("total_features", "?")))
    builder.add_key_value("Tech-Stack kompatibel", str(content.get("compatible", "?")))
    builder.add_key_value("Mit Warnung", str(content.get("warnings", "?")))
    builder.add_key_value("Inkompatibel", str(content.get("incompatible", "?")))
    builder.add_paragraph("")

    # Category overview table
    cats = content.get("categories", [])
    if cats:
        builder.add_table(
            ["Kategorie", "Anzahl"],
            [[c.get("name", ""), str(len(c.get("features", [])))] for c in cats],
        )

    # Per-category tables
    for cat in cats:
        builder.add_page_break()
        builder.add_heading(cat.get("name", ""), level=1)
        features = cat.get("features", [])
        if features:
            builder.add_table(
                ["ID", "Feature", "Beschreibung", "Quelle", "Tech-Status"],
                [
                    [
                        f.get("id", ""),
                        f.get("name", ""),
                        f.get("description", "")[:120],
                        f.get("source", ""),
                        f"{f.get('tech_status', '')} {f.get('tech_note', '')}",
                    ]
                    for f in features
                ],
            )

    # Conflicts
    conflicts = content.get("conflicts", [])
    if conflicts:
        builder.add_page_break()
        builder.add_heading("Tech-Stack Konflikte", level=1)
        builder.add_table(
            ["ID", "Feature", "Problem", "Loesung"],
            [[c.get("id", ""), c.get("name", ""), c.get("problem", ""), c.get("solution", "")] for c in conflicts],
        )


def _extract_content(k4_data: dict) -> dict:
    prompt = f"""Extrahiere die Feature-Liste aus folgendem Markdown in strukturiertes JSON.

{k4_data.get('feature_list', '')[:16000]}

Antworte NUR in JSON (kein Markdown, keine Backticks):

{{
  "app_name": "...",
  "total_features": 0,
  "compatible": 0,
  "warnings": 0,
  "incompatible": 0,
  "categories": [
    {{
      "name": "Core Gameplay",
      "features": [
        {{"id": "F001", "name": "...", "description": "...", "source": "...", "tech_status": "ok/warnung", "tech_note": "..."}}
      ]
    }}
  ],
  "conflicts": [
    {{"id": "...", "name": "...", "problem": "...", "solution": "..."}}
  ]
}}"""

    print("[DocumentSecretary] Extracting Feature-Liste content via Claude...")
    client = anthropic.Anthropic()
    response = client.messages.create(
        model=get_fallback_model(), max_tokens=8000,
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
    except json.JSONDecodeError:
        try:
            repaired = raw
            if repaired.count('"') % 2 != 0:
                repaired += '"'
            repaired += "]" * max(0, repaired.count("[") - repaired.count("]"))
            repaired += "}" * max(0, repaired.count("{") - repaired.count("}"))
            return json.loads(repaired)
        except json.JSONDecodeError:
            return {"total_features": 0, "compatible": 0, "warnings": 0, "incompatible": 0, "categories": [], "conflicts": []}
