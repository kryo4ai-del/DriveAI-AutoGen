"""Feature-Priorisierung — Kapitel 4 MVP & Feature Scope

Role: Prioritizes features into Phase A (Soft-Launch) and Phase B (Full Production)
plus Backlog, with budget check and dependency graph.
Input: Feature list + KPIs + Budget.
Output: Prioritized feature map.
"""

import json

from dotenv import load_dotenv

from factory.mvp_scope.config import PHASE_A_BUDGET, PHASE_B_BUDGET, KPI_TARGETS

load_dotenv()

AGENT_NAME = "FeaturePrioritization"


def _call_llm(prompt: str, system: str = "", max_tokens: int = 8000, agent_name: str = "unknown", profile: str = "standard") -> str:
    """Call LLM via TheBrain with Anthropic fallback."""
    try:
        from factory.brain.model_provider import get_model, get_router
        selection = get_model(profile=profile, expected_output_tokens=max_tokens)
        router = get_router()

        messages = []
        if system:
            messages.append({"role": "system", "content": system})
        messages.append({"role": "user", "content": prompt})

        response = router.call(
            model_id=selection["model"],
            provider=selection["provider"],
            messages=messages,
            max_tokens=max_tokens,
        )

        if response.error:
            raise RuntimeError(response.error)

        cost_str = f", Cost: ${response.cost_usd:.4f}" if response.cost_usd else ""
        print(f"[{agent_name}] {selection['model']} ({selection['provider']}){cost_str}")
        return response.content

    except Exception as e:
        print(f"[{agent_name}] TheBrain failed ({e}), falling back to Anthropic Sonnet")
        import anthropic
        client = anthropic.Anthropic()
        resp = client.messages.create(
            model="claude-sonnet-4-6",
            max_tokens=max_tokens,
            messages=[{"role": "user", "content": prompt}]
        )
        return resp.content[0].text
COST_PER_WEEK = 4000  # EUR


def run(feature_list: str, all_reports: dict) -> str:
    """Prioritize features into Phase A, Phase B, and Backlog."""
    # Call 1: Prioritize
    print(f"[{AGENT_NAME}] Prioritizing features into Phase A/B/Backlog (Call 1/2)...")
    phases = _prioritize(feature_list, all_reports)
    phase_a = phases.get("phase_a", [])
    phase_b = phases.get("phase_b", [])
    backlog = phases.get("backlog", [])
    print(f"[{AGENT_NAME}] -> Phase A: {len(phase_a)} features, Phase B: {len(phase_b)} features, Backlog: {len(backlog)} features")

    # Call 2: Budget check + dependency graph
    print(f"[{AGENT_NAME}] Budget check + dependency graph (Call 2/2)...")
    budget_data = _budget_check(phase_a, phase_b)

    pa_budget = budget_data.get("phase_a_budget", {})
    pb_budget = budget_data.get("phase_b_budget", {})
    pa_status = pa_budget.get("status", "unbekannt")
    pb_status = pb_budget.get("status", "unbekannt")
    pa_cost = pa_budget.get("total_cost", 0)
    pb_cost = pb_budget.get("total_cost", 0)
    crit_weeks = budget_data.get("critical_path", {}).get("total_weeks", 0)

    print(f"[{AGENT_NAME}] -> Phase A: {pa_cost:,} EUR / {PHASE_A_BUDGET:,} EUR ({pa_status})")
    print(f"[{AGENT_NAME}] -> Phase B: {pb_cost:,} EUR / {PHASE_B_BUDGET:,} EUR ({pb_status})")
    print(f"[{AGENT_NAME}] -> Critical path: {crit_weeks} weeks")

    # Format
    title = all_reports.get("idea_title", "App")
    return _format_markdown(title, phase_a, phase_b, backlog, budget_data)


def _prioritize(feature_list: str, reports: dict) -> dict:
    """Call 1: Assign features to phases."""
    kpi_text = "\n".join(f"- {k}: {v}" for k, v in KPI_TARGETS.items())

    prompt = f"""Du bist ein Feature-Priorisierungs-Experte fuer Mobile Game MVPs.

Du hast Features fuer EchoMatch. Priorisiere JEDES Feature in eine von drei Phasen:
- Phase A: Soft-Launch MVP (Budget {PHASE_A_BUDGET:,} EUR, Ziel: AU/CA/NZ Soft Launch)
- Phase B: Full Production (Budget {PHASE_B_BUDGET:,} EUR, Ziel: Tier-1 Global Launch)
- Backlog: Post-Launch Updates (v1.2+)

## Feature-Liste
{feature_list[:20000]}

## KPI-Targets (Phase A muss diese erreichen koennen)
{kpi_text}

## Release-Plan Kontext
{reports.get('release_plan', '')[:3000]}

## Kosten-Kalkulation Kontext
{reports.get('cost_calculation', '')[:3000]}

Antworte NUR in JSON (kein Markdown, keine Backticks). Format:

{{
  "phase_a": [
    {{
      "id": "F001",
      "name": "Match-3 Core Loop",
      "kpi_impact": ["D1", "D7", "Session-Dauer"],
      "revenue_impact": "Kein",
      "complexity_weeks": 6,
      "depends_on": [],
      "reasoning": "Core — ohne geht nichts"
    }}
  ],
  "phase_b": [
    {{
      "id": "F020",
      "name": "...",
      "kpi_impact": [],
      "revenue_impact": "Hoch",
      "complexity_weeks": 3,
      "depends_on": ["F011"],
      "reasoning": "..."
    }}
  ],
  "backlog": [
    {{
      "id": "F050",
      "name": "...",
      "planned_version": "v1.2",
      "expected_impact": "...",
      "reasoning": "..."
    }}
  ]
}}

PRIORISIERUNGS-REGELN:
1. Phase A MUSS enthalten: Core Loop, KI-PoC, Basis-Monetarisierung, ALLE Legal-Pflichten (DSGVO, Age-Gating, ATT), Basis-Analytics, Crash-Reporting
2. Phase A MUSS die KPIs D1>=40% und D7>=20% erreichen koennen
3. Legal-Features sind IMMER Phase A — kein Launch ohne Compliance
4. KI-PoC ist Phase A — explizites Go/No-Go Kriterium
5. Battle-Pass kann in Phase A vereinfacht sein, volle saisonale Rotation erst Phase B
6. Social-Features: Basis (Freundesliste, einfache Challenges) Phase A, erweitert (Teams) Phase B
7. complexity_weeks: Realistische Schaetzung fuer 2-3 Entwickler
8. depends_on: Feature-IDs die vorher fertig sein muessen
9. JEDES Feature muss in genau einer Phase landen — nichts weglassen

KRITISCHE ZUSATZREGELN FUER PHASE-A/B-TRENNUNG:
- Phase A ist das MINIMUM das den Soft-Launch ermoeglicht — NICHT alles was ins Budget passt
- "Passt ins Budget" ist KEIN Grund ein Feature in Phase A zu packen
- Frage dich bei JEDEM Feature: "Scheitert der Soft Launch OHNE dieses Feature?" Wenn nein → Phase B oder Backlog
- Konkrete Phase-B Kandidaten (sofern nicht KPI-kritisch):
  * Kooperative Team-Events / Gilden-System → Phase B (Social-Basis reicht fuer Soft Launch)
  * Live-Ops-System / saisonale Events → Phase B (erst nach Retention-Validierung)
  * Erweitertes Analytics (Amplitude) → Phase B (Firebase reicht fuer Soft Launch)
  * Live Activities / Dynamic Island → Phase B (Nice-to-have, nicht KPI-relevant)
  * Erweiterter Battle-Pass mit saisonaler Rotation → Phase B (Basis-Pass reicht)
- Phase A sollte idealerweise 25-35 Features haben, nicht 45+
- Phase B sollte 10-15 Features haben die den Global Launch differenzieren
- Budget-Spielraum in Phase A ist GUT — er ist Puffer fuer Unvorhergesehenes, nicht zum Vollstopfen"""

    raw = _call_llm(prompt, max_tokens=8000, agent_name=AGENT_NAME, profile="dev")
    return _parse_json(raw, {"phase_a": [], "phase_b": [], "backlog": []})


def _budget_check(phase_a: list, phase_b: list) -> dict:
    """Call 2: Budget validation + dependency graph."""
    pa_json = json.dumps(phase_a, ensure_ascii=False, indent=1)[:5000]
    pb_json = json.dumps(phase_b, ensure_ascii=False, indent=1)[:3000]

    prompt = f"""Du bist ein Projekt-Kalkulator fuer Mobile Game Entwicklung.

## Phase A Features
{pa_json}

## Phase B Features
{pb_json}

## Budget
- Phase A: {PHASE_A_BUDGET:,} EUR
- Phase B: {PHASE_B_BUDGET:,} EUR
- Durchschnittlicher Stundensatz: 100 EUR/h (DACH-Markt)
- 1 Entwicklerwoche = 40h = {COST_PER_WEEK:,} EUR

Erstelle Budget-Check, Abhaengigkeits-Graph und kritischen Pfad.

Antworte NUR in JSON (kein Markdown, keine Backticks):

{{
  "phase_a_budget": {{
    "total_weeks": 0,
    "total_cost": 0,
    "budget_available": {PHASE_A_BUDGET},
    "status": "im_budget",
    "over_by": 0
  }},
  "phase_b_budget": {{
    "total_weeks": 0,
    "total_cost": 0,
    "budget_available": {PHASE_B_BUDGET},
    "status": "im_budget",
    "over_by": 0
  }},
  "cuts_if_needed": [
    {{
      "feature_id": "F...",
      "feature_name": "...",
      "saving_weeks": 0,
      "saving_eur": 0,
      "risk": "...",
      "alternative": "..."
    }}
  ],
  "critical_path": {{
    "chain": ["F001", "F002"],
    "total_weeks": 0,
    "description": "..."
  }},
  "parallel_groups": [
    {{
      "group_name": "...",
      "features": ["F005"],
      "can_run_parallel_to": ["F001"]
    }}
  ]
}}"""

    raw = _call_llm(prompt, max_tokens=8000, agent_name=AGENT_NAME, profile="dev")
    return _parse_json(raw, {
        "phase_a_budget": {"total_weeks": 0, "total_cost": 0, "status": "unbekannt"},
        "phase_b_budget": {"total_weeks": 0, "total_cost": 0, "status": "unbekannt"},
        "cuts_if_needed": [], "critical_path": {}, "parallel_groups": [],
    })


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


def _format_markdown(title: str, phase_a: list, phase_b: list, backlog: list, budget: dict) -> str:
    """Format the prioritization as structured Markdown."""
    lines = [
        f"# Feature-Priorisierung: {title}",
        "",
    ]

    # Phase A
    lines.append(f"## Phase A — Soft-Launch MVP ({len(phase_a)} Features)")
    lines.append(f"**Budget:** {PHASE_A_BUDGET:,} EUR")
    lines.append("")
    lines.append("| ID | Feature | KPI-Impact | Revenue | Wochen | Abhaengigkeiten | Begruendung |")
    lines.append("|---|---|---|---|---|---|---|")
    for f in phase_a:
        kpi = ", ".join(f.get("kpi_impact", []))
        deps = ", ".join(f.get("depends_on", []))
        lines.append(
            f"| {f.get('id', '')} | {f.get('name', '')} | {kpi} | "
            f"{f.get('revenue_impact', '')} | {f.get('complexity_weeks', '')} | "
            f"{deps} | {f.get('reasoning', '')} |"
        )
    lines.append("")

    # Phase A Budget
    pa = budget.get("phase_a_budget", {})
    lines.append("### Phase A Budget-Check")
    lines.append(f"- Entwicklerwochen: {pa.get('total_weeks', '?')}")
    lines.append(f"- Kosten: {pa.get('total_cost', '?'):,} EUR" if isinstance(pa.get('total_cost'), (int, float)) else f"- Kosten: {pa.get('total_cost', '?')} EUR")
    lines.append(f"- Budget: {PHASE_A_BUDGET:,} EUR")
    lines.append(f"- Status: **{pa.get('status', '?')}**")
    if pa.get("over_by", 0) > 0:
        lines.append(f"- Ueber Budget um: {pa['over_by']:,} EUR")
    lines.append("")

    # Critical Path
    crit = budget.get("critical_path", {})
    if crit:
        lines.append("### Kritischer Pfad")
        chain = " -> ".join(crit.get("chain", []))
        lines.append(f"- Kette: {chain}")
        lines.append(f"- Gesamtdauer: {crit.get('total_weeks', '?')} Wochen")
        lines.append(f"- Beschreibung: {crit.get('description', '')}")
        lines.append("")

    # Parallel Groups
    groups = budget.get("parallel_groups", [])
    if groups:
        lines.append("### Parallelisierbare Feature-Gruppen")
        for g in groups:
            features = ", ".join(g.get("features", []))
            parallel_to = ", ".join(g.get("can_run_parallel_to", []))
            lines.append(f"- **{g.get('group_name', '')}**: {features} (parallel zu {parallel_to})")
        lines.append("")

    # Phase B
    lines.append(f"## Phase B — Full Production ({len(phase_b)} Features)")
    lines.append(f"**Budget:** {PHASE_B_BUDGET:,} EUR")
    lines.append("")
    lines.append("| ID | Feature | KPI-Impact | Revenue | Wochen | Abhaengigkeiten | Begruendung |")
    lines.append("|---|---|---|---|---|---|---|")
    for f in phase_b:
        kpi = ", ".join(f.get("kpi_impact", []))
        deps = ", ".join(f.get("depends_on", []))
        lines.append(
            f"| {f.get('id', '')} | {f.get('name', '')} | {kpi} | "
            f"{f.get('revenue_impact', '')} | {f.get('complexity_weeks', '')} | "
            f"{deps} | {f.get('reasoning', '')} |"
        )
    lines.append("")

    # Phase B Budget
    pb = budget.get("phase_b_budget", {})
    lines.append("### Phase B Budget-Check")
    lines.append(f"- Entwicklerwochen: {pb.get('total_weeks', '?')}")
    lines.append(f"- Kosten: {pb.get('total_cost', '?'):,} EUR" if isinstance(pb.get('total_cost'), (int, float)) else f"- Kosten: {pb.get('total_cost', '?')} EUR")
    lines.append(f"- Budget: {PHASE_B_BUDGET:,} EUR")
    lines.append(f"- Status: **{pb.get('status', '?')}**")
    if pb.get("over_by", 0) > 0:
        lines.append(f"- Ueber Budget um: {pb['over_by']:,} EUR")
    lines.append("")

    # Backlog
    lines.append(f"## Backlog — Post-Launch ({len(backlog)} Features)")
    lines.append("")
    lines.append("| ID | Feature | Geplante Version | Erwarteter Impact | Begruendung |")
    lines.append("|---|---|---|---|---|")
    for f in backlog:
        lines.append(
            f"| {f.get('id', '')} | {f.get('name', '')} | "
            f"{f.get('planned_version', 'v1.2+')} | {f.get('expected_impact', '')} | "
            f"{f.get('reasoning', '')} |"
        )
    lines.append("")

    # Cuts if needed
    cuts = budget.get("cuts_if_needed", [])
    if cuts:
        lines.append("## Streichungs-Vorschlaege (falls ueber Budget)")
        lines.append("| Feature | Ersparnis | Risiko | Alternative |")
        lines.append("|---|---|---|---|")
        for c in cuts:
            lines.append(
                f"| {c.get('feature_id', '')} {c.get('feature_name', '')} | "
                f"{c.get('saving_eur', 0):,} EUR ({c.get('saving_weeks', 0)} Wo.) | "
                f"{c.get('risk', '')} | {c.get('alternative', '')} |"
            )
        lines.append("")

    # Summary
    total = len(phase_a) + len(phase_b) + len(backlog)
    lines.append("## Zusammenfassung")
    lines.append(f"- **Gesamt Features:** {total}")
    lines.append(f"- **Phase A (Soft-Launch):** {len(phase_a)} Features")
    lines.append(f"- **Phase B (Full Production):** {len(phase_b)} Features")
    lines.append(f"- **Backlog:** {len(backlog)} Features")
    pa_cost = pa.get("total_cost", "?")
    pb_cost = pb.get("total_cost", "?")
    lines.append(f"- **Phase A Kosten:** {pa_cost:,} EUR" if isinstance(pa_cost, (int, float)) else f"- **Phase A Kosten:** {pa_cost} EUR")
    lines.append(f"- **Phase B Kosten:** {pb_cost:,} EUR" if isinstance(pb_cost, (int, float)) else f"- **Phase B Kosten:** {pb_cost} EUR")
    lines.append(f"- **Kritischer Pfad:** {crit.get('total_weeks', '?')} Wochen")

    return "\n".join(lines)
