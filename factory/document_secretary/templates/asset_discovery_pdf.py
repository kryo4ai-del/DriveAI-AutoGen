"""Asset-Discovery — Professional PDF of complete asset list."""

import json

import anthropic
from dotenv import load_dotenv

from factory.document_secretary.config import get_fallback_model

load_dotenv()


def generate(k5_data: dict, builder) -> None:
    """Populate builder with Asset Discovery content."""
    raw_md = k5_data.get("asset_discovery", "")
    content = _extract_content(raw_md)

    if not content.get("categories") and raw_md:
        _render_fallback(raw_md, builder)
        return

    # Summary
    builder.add_heading("Zusammenfassung", level=1)
    builder.add_key_value("Gesamtanzahl Assets", str(content.get("total_assets", "?")))
    builder.add_key_value("Launch-kritisch", str(content.get("launch_critical", "?")))
    builder.add_key_value("Statisch", str(content.get("static_count", "?")))
    builder.add_key_value("Dynamisch", str(content.get("dynamic_count", "?")))
    builder.add_key_value("Plattform-Varianten gesamt", str(content.get("total_variants", "?")))
    builder.add_key_value("Dark-Mode-Varianten noetig", str(content.get("dark_mode_count", "?")))
    builder.add_paragraph("")

    # Category overview
    cats = content.get("categories", [])
    if cats:
        builder.add_table(
            ["Kategorie", "Anzahl"],
            [[c.get("name", ""), str(len(c.get("assets", [])))] for c in cats],
        )

    # Per-category tables
    for cat in cats:
        builder.add_page_break()
        builder.add_heading(cat.get("name", ""), level=1)
        assets = cat.get("assets", [])
        if assets:
            builder.add_table(
                ["ID", "Asset", "Beschreibung", "Screen(s)", "Stat./Dyn.", "Varianten", "Dark Mode", "Launch-krit."],
                [
                    [
                        a.get("id", ""),
                        a.get("name", ""),
                        a.get("description", "")[:80],
                        a.get("screens", "")[:25],
                        a.get("static_dynamic", ""),
                        str(a.get("variants", 1)),
                        a.get("dark_mode", ""),
                        "JA" if a.get("launch_critical") else "nein",
                    ]
                    for a in assets
                ],
            )


def _render_fallback(md_text: str, builder) -> None:
    """Render raw Markdown as formatted PDF."""
    print("[DocumentSecretary] Using Markdown fallback for Asset Discovery...")
    for line in md_text.split("\n"):
        s = line.strip()
        if not s:
            continue
        if s.startswith("# "):
            builder.add_heading(s[2:], level=1)
        elif s.startswith("## "):
            builder.add_heading(s[3:], level=2)
        elif s.startswith("### "):
            builder.add_heading(s[4:], level=3)
        elif s.startswith("|") and "---|" not in s:
            cells = [c.strip() for c in s.split("|") if c.strip()]
            if cells:
                builder.add_paragraph(" | ".join(cells))
        else:
            builder.add_paragraph(s)


def _extract_content(raw_md: str) -> dict:
    if not raw_md.strip():
        return {}

    prompt = f"""Extrahiere die Asset-Discovery-Liste in strukturiertes JSON.

{raw_md[:16000]}

Antworte NUR in JSON (kein Markdown, keine Backticks):

{{
  "total_assets": 0,
  "launch_critical": 0,
  "static_count": 0,
  "dynamic_count": 0,
  "total_variants": 0,
  "dark_mode_count": 0,
  "categories": [
    {{
      "name": "App-Branding",
      "assets": [
        {{"id": "A001", "name": "...", "description": "...", "screens": "...", "static_dynamic": "statisch", "variants": 18, "dark_mode": "ja", "launch_critical": true}}
      ]
    }}
  ]
}}"""

    print("[DocumentSecretary] Extracting Asset Discovery content via Claude...")
    client = anthropic.Anthropic()
    response = client.messages.create(
        model=get_fallback_model(), max_tokens=16000,
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
        pass
    try:
        start = raw.index("{")
        end = raw.rindex("}") + 1
        return json.loads(raw[start:end])
    except (ValueError, json.JSONDecodeError):
        pass
    try:
        repaired = raw
        if repaired.count('"') % 2 != 0:
            repaired += '"'
        repaired += "]" * max(0, repaired.count("[") - repaired.count("]"))
        repaired += "}" * max(0, repaired.count("{") - repaired.count("}"))
        return json.loads(repaired)
    except json.JSONDecodeError:
        print("[DocumentSecretary] WARNING: Asset Discovery JSON parse failed")
        return {}
