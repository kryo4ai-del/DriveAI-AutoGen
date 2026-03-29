"""Asset-Strategie — Professional PDF with style guide, sourcing, and handover protocol."""

import json
import re

import anthropic
from dotenv import load_dotenv

from factory.document_secretary.config import get_fallback_model

load_dotenv()


def generate(k5_data: dict, builder) -> None:
    """Populate builder with Asset Strategy content."""
    raw_md = k5_data.get("asset_strategy", "")
    content = _extract_content(raw_md)

    if not content.get("style_guide") and raw_md:
        _render_fallback(raw_md, builder)
        return

    style = content.get("style_guide", {})

    # Color palette with colored elements
    palette = style.get("color_palette", {})
    if palette:
        builder.add_heading("Farbpalette", level=1)
        rows = []
        for key, val in palette.items():
            if isinstance(val, dict):
                hex_val = val.get("hex", "#000000")
                rows.append([val.get("name", key), hex_val, val.get("usage", "")])
        if rows:
            builder.add_table(["Name", "Hex", "Verwendung"], rows)

    # Typography
    typo = style.get("typography", {})
    if typo:
        builder.add_heading("Typografie", level=1)
        rows = []
        for key, val in typo.items():
            if isinstance(val, dict):
                rows.append([val.get("name", ""), val.get("usage", ""), val.get("weight", ""), val.get("license", "")])
        if rows:
            builder.add_table(["Font", "Verwendung", "Gewicht", "Lizenz"], rows)

    # Illustration, Icon, Animation styles
    for section_key, heading in [("illustration_style", "Illustrations-Stil"), ("icon_style", "Icon-Stil"), ("animation_style", "Animations-Stil")]:
        section = style.get(section_key, {})
        if section:
            builder.add_heading(heading, level=2)
            for k, v in section.items():
                builder.add_key_value(k, str(v))

    # Sourcing table
    sourcing = content.get("sourcing", [])
    if sourcing:
        builder.add_page_break()
        builder.add_heading("Beschaffungsstrategie", level=1)
        builder.add_table(
            ["ID", "Asset", "Quelle", "Format", "Kosten", "Prioritaet", "Repo-Pfad"],
            [
                [
                    s.get("id", ""), s.get("name", ""), s.get("source", ""),
                    s.get("format", "")[:30],
                    f"{s.get('cost', 0)} EUR" if isinstance(s.get("cost"), (int, float)) else str(s.get("cost", "")),
                    s.get("priority", ""), s.get("repo_path", ""),
                ]
                for s in sourcing
            ],
        )

    # Format requirements
    formats = content.get("format_requirements", [])
    if formats:
        builder.add_page_break()
        builder.add_heading("Technische Format-Anforderungen", level=1)
        builder.add_table(
            ["Asset-Typ", "Format", "Aufloesung", "Hinweise"],
            [[f.get("type", ""), f.get("format", ""), f.get("resolution", ""), f.get("notes", "")] for f in formats],
        )

    # Budget
    budget = content.get("budget", {})
    if budget:
        builder.add_heading("Budget-Check", level=1)
        builder.add_key_value("Geschaetzte Gesamtkosten", f"{budget.get('total', '?')} EUR")
        builder.add_key_value("Status", str(budget.get("status", "?")))

    # Handover
    handover = content.get("handover", {})
    if handover:
        builder.add_heading("Asset-Uebergabe-Protokoll", level=1)
        builder.add_key_value("Ordnerstruktur", str(handover.get("directory", "")))
        builder.add_key_value("Naming-Convention", str(handover.get("naming", "")))
        checklist = handover.get("checklist", [])
        if checklist:
            builder.add_heading("Delivery-Checkliste", level=2)
            for item in checklist:
                builder.add_paragraph(f"[ ] {item}")


def _render_fallback(md_text: str, builder) -> None:
    """Render raw Markdown as formatted PDF."""
    print("[DocumentSecretary] Using Markdown fallback for Asset Strategy...")
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
        elif s.startswith("- "):
            builder.add_paragraph(s)
        else:
            builder.add_paragraph(s)


def _extract_content(raw_md: str) -> dict:
    if not raw_md.strip():
        return {}

    prompt = f"""Extrahiere die Asset-Strategie in strukturiertes JSON.

{raw_md[:16000]}

Antworte NUR in JSON (kein Markdown, keine Backticks):

{{
  "style_guide": {{
    "color_palette": {{
      "primary": {{"name": "...", "hex": "#...", "usage": "..."}},
      "secondary": {{"name": "...", "hex": "#...", "usage": "..."}}
    }},
    "typography": {{
      "primary": {{"name": "...", "usage": "...", "weight": "...", "license": "..."}},
      "secondary": {{"name": "...", "usage": "...", "weight": "...", "license": "..."}}
    }},
    "illustration_style": {{"style": "...", "description": "..."}},
    "icon_style": {{"style": "...", "library": "..."}},
    "animation_style": {{"duration_ms": 300, "easing": "..."}}
  }},
  "sourcing": [
    {{"id": "A001", "name": "...", "source": "Custom/Stock/AI/Free", "format": "...", "cost": 350, "priority": "Launch-kritisch", "repo_path": "assets/..."}}
  ],
  "format_requirements": [
    {{"type": "Sprites", "format": "PNG", "resolution": "2x Retina", "notes": "..."}}
  ],
  "budget": {{"total": 0, "status": "im_budget/ueber_budget"}},
  "handover": {{
    "directory": "assets/ mit Unterordnern",
    "naming": "lowercase_snake_case",
    "checklist": ["Alle Launch-kritischen Assets geliefert", "..."]
  }}
}}

Extrahiere so viele Details wie moeglich. Bei der sourcing-Liste: maximal die ersten 50 Eintraege."""

    print("[DocumentSecretary] Extracting Asset Strategy content via Claude...")
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
        print("[DocumentSecretary] WARNING: Asset Strategy JSON parse failed")
        return {}
