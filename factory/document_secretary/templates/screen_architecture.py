"""Screen Architecture — Professional PDF of screens, flows and edge cases."""

import json

import anthropic
from dotenv import load_dotenv

from factory.document_secretary.config import get_fallback_model

load_dotenv()


def generate(k4_data: dict, builder) -> None:
    """Populate builder with Screen Architecture content."""
    content = _extract_content(k4_data)

    # Fallback: if JSON extraction failed, render raw Markdown
    raw_md = content.get("_raw_md", "")
    if raw_md and not content.get("screens") and not content.get("flows"):
        _render_raw_markdown(raw_md, builder)
        return

    # Screen overview
    builder.add_heading("Screen-Uebersicht", level=1)
    screens = content.get("screens", [])
    if screens:
        builder.add_table(
            ["ID", "Screen", "Typ", "Zweck", "States"],
            [[s.get("id", ""), s.get("name", ""), s.get("type", ""),
              s.get("purpose", "")[:80], ", ".join(s.get("states", []))] for s in screens],
        )
    builder.add_paragraph(f"Phase-A Screens: {content.get('phase_a_count', len(screens))}, Phase-B Screens: {content.get('phase_b_count', 0)}")

    # Navigation hierarchy
    builder.add_page_break()
    builder.add_heading("Navigation & Hierarchie", level=1)
    nav = content.get("navigation", {})
    tabs = nav.get("tabs", [])
    if tabs:
        builder.add_heading("Tab-Bar", level=2)
        for tab in tabs:
            builder.add_paragraph(f"- {tab.get('label', '')}: {tab.get('screen_id', '')} — {', '.join(tab.get('subscreens', []))}")

    modals = nav.get("modals", [])
    if modals:
        builder.add_heading("Modale Screens", level=2)
        builder.add_paragraph(", ".join(modals))

    overlays = nav.get("overlays", [])
    if overlays:
        builder.add_heading("Overlays", level=2)
        builder.add_paragraph(", ".join(overlays))

    # User Flows
    builder.add_page_break()
    builder.add_heading("User Flows", level=1)
    flows = content.get("flows", [])
    for f in flows:
        builder.add_heading(f"{f.get('id', '')}: {f.get('name', '')}", level=2)
        builder.add_key_value("Screens", " -> ".join(f.get("screens", [])))
        builder.add_key_value("Taps bis Ziel", str(f.get("taps", "?")))
        if f.get("time_budget"):
            builder.add_key_value("Zeitbudget", f["time_budget"])
        if f.get("fallback"):
            builder.add_highlight_box(f"Fallback: {f['fallback']}")
        builder.add_paragraph("")

    # Edge Cases
    builder.add_page_break()
    builder.add_heading("Edge Cases", level=1)
    edges = content.get("edge_cases", [])
    if edges:
        builder.add_table(
            ["Situation", "Betroffene Screens", "Verhalten"],
            [[e.get("situation", ""), e.get("affected", ""), e.get("behavior", "")] for e in edges],
        )

    # Phase B Screens
    phase_b = content.get("phase_b_screens", [])
    if phase_b:
        builder.add_page_break()
        builder.add_heading("Phase-B Screens (geplant)", level=1)
        builder.add_table(
            ["ID", "Screen", "Zweck", "Platzhalter in Phase A"],
            [[s.get("id", ""), s.get("name", ""), s.get("purpose", ""), s.get("placeholder", "")] for s in phase_b],
        )

    # Tap-Count
    taps = content.get("tap_count", [])
    if taps:
        builder.add_heading("Tap-Count Zusammenfassung", level=1)
        rows = []
        for t in taps:
            status = t.get("status", "ok")
            icon = "OK" if status == "ok" else "UEBER"
            rows.append([t.get("flow", ""), str(t.get("taps", "?")), f"max {t.get('target', '?')}", icon])
        builder.add_table(["Flow", "Taps", "Ziel", "Status"], rows)


def _extract_content(k4_data: dict) -> dict:
    raw_md = k4_data.get('screen_architecture', '')
    if not raw_md.strip():
        print("[DocumentSecretary] WARNING: screen_architecture is empty")
        return {"_raw_md": "", "screens": [], "navigation": {}, "flows": [], "edge_cases": [], "phase_b_screens": [], "tap_count": []}

    prompt = f"""Extrahiere die Screen-Architektur aus folgendem Report in strukturiertes JSON.
Der Report kann ein Mix aus tabellarischem und Markdown-Content sein — extrahiere ALLES.

## Report
{raw_md[:16000]}

Antworte NUR in JSON (kein Markdown, keine Backticks):

{{
  "phase_a_count": 0,
  "phase_b_count": 0,
  "screens": [
    {{"id": "S001", "name": "...", "type": "Hauptscreen", "purpose": "...", "states": ["Normal", "..."]}}
  ],
  "navigation": {{
    "tabs": [{{"label": "Home", "screen_id": "S004", "subscreens": ["S017"]}}],
    "modals": ["S002"],
    "overlays": ["S016"]
  }},
  "flows": [
    {{"id": "Flow1", "name": "Onboarding", "screens": ["S001", "S002"], "taps": 2, "time_budget": "60s", "fallback": "..."}}
  ],
  "edge_cases": [
    {{"situation": "Consent abgelehnt", "affected": "S002, Gameplay", "behavior": "Generische Levels"}}
  ],
  "phase_b_screens": [
    {{"id": "S020", "name": "...", "purpose": "...", "placeholder": "Coming Soon"}}
  ],
  "tap_count": [
    {{"flow": "Onboarding -> Core Loop", "taps": 2, "target": 3, "status": "ok"}}
  ]
}}

Extrahiere ALLES was im Report steht — Screens, Flows, Edge Cases, Tap-Count.
Wenn ein Abschnitt fehlt, setze ein leeres Array."""

    print("[DocumentSecretary] Extracting Screen Architecture content via Claude...")
    client = anthropic.Anthropic()
    response = client.messages.create(
        model=get_fallback_model(), max_tokens=8000,
        messages=[{"role": "user", "content": prompt}],
    )
    result = _parse_json(response.content[0].text)

    # If JSON parse produced empty/unusable data, store raw MD for fallback rendering
    if not result.get("screens") and not result.get("flows"):
        print("[DocumentSecretary] WARNING: JSON extraction produced empty data — using raw Markdown fallback")
        result["_raw_md"] = raw_md
    return result


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
    # Try extracting JSON between first { and last }
    try:
        start = raw.index("{")
        end = raw.rindex("}") + 1
        return json.loads(raw[start:end])
    except (ValueError, json.JSONDecodeError):
        pass
    # Repair attempt
    try:
        repaired = raw
        if repaired.count('"') % 2 != 0:
            repaired += '"'
        repaired += "]" * max(0, repaired.count("[") - repaired.count("]"))
        repaired += "}" * max(0, repaired.count("{") - repaired.count("}"))
        return json.loads(repaired)
    except json.JSONDecodeError:
        print("[DocumentSecretary] WARNING: All JSON parse attempts failed")
        return {"screens": [], "navigation": {}, "flows": [], "edge_cases": [], "phase_b_screens": [], "tap_count": []}


def _render_raw_markdown(md_text: str, builder) -> None:
    """Fallback: Render raw Markdown as formatted PDF sections."""
    print("[DocumentSecretary] Rendering raw Markdown fallback...")
    for line in md_text.split("\n"):
        stripped = line.strip()
        if not stripped:
            continue
        if stripped.startswith("# "):
            builder.add_heading(stripped[2:], level=1)
        elif stripped.startswith("## "):
            builder.add_heading(stripped[3:], level=2)
        elif stripped.startswith("### "):
            builder.add_heading(stripped[4:], level=3)
        elif stripped.startswith("|") and "---|" not in stripped:
            # Table row — render as paragraph (tables need full context)
            cells = [c.strip() for c in stripped.split("|") if c.strip()]
            if cells:
                builder.add_paragraph(" | ".join(cells))
        elif stripped.startswith("- ") or stripped.startswith("* "):
            builder.add_paragraph(stripped)
        else:
            builder.add_paragraph(stripped)
