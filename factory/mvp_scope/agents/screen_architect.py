"""Screen-Architect — Kapitel 4 MVP & Feature Scope

Role: Creates complete screen architecture, navigation, 7 user flows,
edge cases and tap-count analysis based on Phase A features.
Input: Prioritized features + Concept Brief + Marketing concept.
Output: Screen architecture document.
"""

import json

import anthropic
from dotenv import load_dotenv

from factory.mvp_scope.config import AGENT_MODEL_MAP

load_dotenv()

AGENT_NAME = "ScreenArchitect"


def run(feature_prioritization: str, all_reports: dict) -> str:
    """Create complete screen architecture with flows and edge cases."""
    client = anthropic.Anthropic()
    model = AGENT_MODEL_MAP["screen_architect"]

    concept_brief = all_reports.get("concept_brief", "")[:5000]
    marketing = all_reports.get("marketing_strategy", "")[:3000]

    # Call 1: Screens + Navigation + Hierarchy
    print(f"[{AGENT_NAME}] Building screen architecture (Call 1/2)...")
    arch = _build_screens(client, model, feature_prioritization, concept_brief, marketing)
    screens = arch.get("screens", [])
    phase_b_screens = arch.get("phase_b_screens", [])
    hierarchy = arch.get("hierarchy", {})
    print(f"[{AGENT_NAME}] -> {len(screens)} screens defined, {len(phase_b_screens)} Phase-B screens")

    # Call 2: User Flows + Edge Cases + Tap-Count
    screens_json = json.dumps(arch, ensure_ascii=False, indent=1)[:8000]
    print(f"[{AGENT_NAME}] Building user flows + edge cases (Call 2/2)...")
    flows_data = _build_flows(client, model, screens_json, concept_brief)
    flows = flows_data.get("flows", [])
    edge_cases = flows_data.get("edge_cases", [])
    tap_summary = flows_data.get("tap_count_summary", [])
    print(f"[{AGENT_NAME}] -> {len(flows)} flows, {len(edge_cases)} edge cases")

    title = all_reports.get("idea_title", "App")
    return _format_markdown(title, screens, hierarchy, phase_b_screens, flows, edge_cases, tap_summary)


def _build_screens(client, model: str, features: str, concept: str, marketing: str) -> dict:
    """Call 1: Define screens, hierarchy, navigation."""
    prompt = f"""Du bist ein UX-Architekt fuer Mobile Apps und Games.

Erstelle die vollstaendige Screen-Architektur fuer das Phase-A MVP basierend auf den priorisierten Features.

## Phase-A Features (priorisiert)
{features[:12000]}

## Concept Brief (fuer Onboarding-Flow und Core Loop)
{concept}

## Marketing-Konzept (fuer Social-Sharing UX)
{marketing}

Antworte NUR in JSON (kein Markdown, keine Backticks):

{{
  "screens": [
    {{
      "id": "S001",
      "name": "Splash / Loading",
      "type": "Hauptscreen",
      "purpose": "App-Start, Asset-Loading",
      "features": [],
      "ui_elements": ["Logo-Animation", "Progress-Bar"],
      "states": ["Normal", "Slow-Connection"]
    }}
  ],
  "hierarchy": {{
    "main_tabs": ["S004", "S005", "S008", "S010", "S012"],
    "tab_labels": ["Home", "Puzzle", "Story", "Social", "Shop"],
    "subscreens": {{"S004": ["S017"]}},
    "modals": ["S002", "S014"],
    "overlays": ["S016"]
  }},
  "phase_b_screens": [
    {{
      "id": "S020",
      "name": "Live-Ops Event-Hub",
      "purpose": "Saisonale Events",
      "depends_on": "Phase-B Feature-Set",
      "placeholder_in_phase_a": "Coming Soon Badge"
    }}
  ]
}}

REGELN:
- Jeder Screen hat eine eindeutige ID (S001, S002, ...)
- Typ: Hauptscreen, Subscreen, Modal, Overlay
- Features: Liste der Feature-IDs (F001, F002...) die auf diesem Screen sichtbar sind
- States: Mindestens Normal + relevante Alternativ-Zustaende (Leer, Lade, Fehler, Offline)
- Hauptnavigation als Tab-Bar mit max 5 Tabs
- Phase-B Screens separat markieren mit Platzhalter-Hinweis
- Erwarte 15-25 Screens fuer Phase A"""

    response = client.messages.create(
        model=model, max_tokens=8000,
        messages=[{"role": "user", "content": prompt}],
    )
    return _parse_json(response.content[0].text, {"screens": [], "hierarchy": {}, "phase_b_screens": []})


def _build_flows(client, model: str, screens_json: str, concept: str) -> dict:
    """Call 2: User flows, edge cases, tap-count."""
    prompt = f"""Du bist ein UX-Architekt fuer Mobile Apps und Games.

Basierend auf der Screen-Architektur, erstelle die User Flows, Edge Cases und Tap-Count-Analyse.

## Screen-Architektur
{screens_json}

## Concept Brief (Onboarding: 60 Sekunden, Core Loop)
{concept}

Antworte NUR in JSON (kein Markdown, keine Backticks):

{{
  "flows": [
    {{
      "id": "Flow1",
      "name": "Onboarding (Erst-Start)",
      "screens": ["S001", "S002", "S003"],
      "description": "App oeffnen -> Consent -> Onboarding-Match -> Home",
      "taps_to_goal": 2,
      "time_budget": "60 Sekunden",
      "fallback": "Bei Consent-Nein: generische Levels"
    }}
  ],
  "edge_cases": [
    {{
      "situation": "Consent komplett abgelehnt",
      "affected_screens": ["S002"],
      "expected_behavior": "Generische Levels, kein Tracking"
    }}
  ],
  "tap_count_summary": [
    {{"flow": "Onboarding -> Core Loop", "taps": 2, "target": 3, "status": "ok"}}
  ]
}}

ERSTELLE GENAU 7 FLOWS:
1. Onboarding (Erst-Start) — App oeffnen bis erster Core Loop
2. Core Loop (wiederkehrend) — Home bis Match-Ende
3. Erster Kauf — Home bis Kauf-Bestaetigung
4. Social Challenge — Home bis Challenge gesendet
5. Battle-Pass — Home bis Pass-Fortschritt
6. Rewarded Ad — Trigger im Match bis Reward
7. Consent (Detail) — Splash bis Routing

EDGE CASES: Mindestens 7 Situationen (Offline, KI-Fehler, Kauf-Fehler, COPPA, Push abgelehnt, Server-Ausfall, leerer Zustand)

TAP-COUNT: Ziel max 3 Taps bis Core Loop / Kauf. Jeder Flow mit taps und target."""

    response = client.messages.create(
        model=model, max_tokens=8000,
        messages=[{"role": "user", "content": prompt}],
    )
    return _parse_json(response.content[0].text, {"flows": [], "edge_cases": [], "tap_count_summary": []})


def _parse_json(raw: str, fallback: dict) -> dict:
    """Parse JSON with robust fallback."""
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
        result = json.loads(repaired)
        print(f"[{AGENT_NAME}] JSON repaired successfully")
        return result
    except json.JSONDecodeError:
        pass

    print(f"[{AGENT_NAME}] WARNING: JSON parse failed — using fallback")
    return fallback


def _format_markdown(title: str, screens: list, hierarchy: dict, phase_b: list,
                     flows: list, edge_cases: list, tap_summary: list) -> str:
    """Format screen architecture as structured Markdown."""
    lines = [f"# Screen-Architektur: {title}", ""]

    # Screen overview table
    lines.append(f"## Screen-Uebersicht ({len(screens)} Screens)")
    lines.append("")
    lines.append("| ID | Screen | Typ | Zweck | Features | States |")
    lines.append("|---|---|---|---|---|---|")
    for s in screens:
        features = ", ".join(s.get("features", [])[:5])
        if len(s.get("features", [])) > 5:
            features += ", ..."
        states = ", ".join(s.get("states", []))
        lines.append(
            f"| {s.get('id', '')} | {s.get('name', '')} | {s.get('type', '')} | "
            f"{s.get('purpose', '')} | {features} | {states} |"
        )
    lines.append("")

    # Hierarchy
    lines.append("## Screen-Hierarchie")
    lines.append("")
    tabs = hierarchy.get("main_tabs", [])
    labels = hierarchy.get("tab_labels", [])
    if tabs and labels:
        lines.append("### Tab-Bar Navigation")
        for tab_id, label in zip(tabs, labels):
            lines.append(f"- **{label}** ({tab_id})")
            subs = hierarchy.get("subscreens", {}).get(tab_id, [])
            for sub in subs:
                lines.append(f"  - {sub}")
        lines.append("")

    modals = hierarchy.get("modals", [])
    if modals:
        lines.append(f"### Modals: {', '.join(modals)}")
    overlays = hierarchy.get("overlays", [])
    if overlays:
        lines.append(f"### Overlays: {', '.join(overlays)}")
    lines.append("")

    # User Flows
    lines.append(f"## User Flows ({len(flows)} Flows)")
    lines.append("")
    for f in flows:
        lines.append(f"### {f.get('id', '')}: {f.get('name', '')}")
        screen_seq = " -> ".join(f.get("screens", []))
        lines.append(f"**Screens:** {screen_seq}")
        lines.append(f"**Beschreibung:** {f.get('description', '')}")
        lines.append(f"**Taps bis Ziel:** {f.get('taps_to_goal', '?')}")
        if f.get("time_budget"):
            lines.append(f"**Zeitbudget:** {f['time_budget']}")
        if f.get("fallback"):
            lines.append(f"**Fallback:** {f['fallback']}")
        lines.append("")

    # Edge Cases
    lines.append(f"## Edge Cases ({len(edge_cases)} Situationen)")
    lines.append("")
    lines.append("| Situation | Betroffene Screens | Erwartetes Verhalten |")
    lines.append("|---|---|---|")
    for ec in edge_cases:
        affected = ", ".join(ec.get("affected_screens", []))
        lines.append(
            f"| {ec.get('situation', '')} | {affected} | {ec.get('expected_behavior', '')} |"
        )
    lines.append("")

    # Phase B Screens
    if phase_b:
        lines.append(f"## Phase-B Screens ({len(phase_b)} geplant)")
        lines.append("")
        lines.append("| ID | Screen | Zweck | Platzhalter in Phase A |")
        lines.append("|---|---|---|---|")
        for s in phase_b:
            lines.append(
                f"| {s.get('id', '')} | {s.get('name', '')} | "
                f"{s.get('purpose', '')} | {s.get('placeholder_in_phase_a', '')} |"
            )
        lines.append("")

    # Tap-Count Summary
    if tap_summary:
        lines.append("## Tap-Count Zusammenfassung")
        lines.append("")
        lines.append("| Flow | Taps | Ziel | Status |")
        lines.append("|---|---|---|---|")
        for t in tap_summary:
            status = t.get("status", "ok")
            icon = "✅" if status == "ok" else "⚠️"
            lines.append(
                f"| {t.get('flow', '')} | {t.get('taps', '?')} | "
                f"max {t.get('target', '?')} | {icon} {status} |"
            )
        lines.append("")

    # Summary
    lines.append("## Zusammenfassung")
    lines.append(f"- **Phase-A Screens:** {len(screens)}")
    lines.append(f"- **Phase-B Screens:** {len(phase_b)}")
    lines.append(f"- **User Flows:** {len(flows)}")
    lines.append(f"- **Edge Cases:** {len(edge_cases)}")
    all_ok = all(t.get("status") == "ok" for t in tap_summary)
    lines.append(f"- **Tap-Count:** {'Alle im Ziel ✅' if all_ok else 'Einige ueber Ziel ⚠️'}")

    return "\n".join(lines)
