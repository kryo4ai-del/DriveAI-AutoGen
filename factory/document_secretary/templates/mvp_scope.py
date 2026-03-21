"""MVP Scope — Professional PDF of Phase A/B split with budget validation."""

import json

import anthropic
from dotenv import load_dotenv

load_dotenv()


def generate(k4_data: dict, builder) -> None:
    """Populate builder with MVP Scope content."""
    content = _extract_content(k4_data)

    # Executive Summary
    builder.add_heading("Executive Summary", level=1)
    summary = content.get("summary", {})
    builder.add_key_value("Phase A (Soft-Launch)", f"{summary.get('phase_a_count', '?')} Features, {summary.get('phase_a_cost', '?')} EUR")
    builder.add_key_value("Phase B (Full Production)", f"{summary.get('phase_b_count', '?')} Features, {summary.get('phase_b_cost', '?')} EUR")
    builder.add_key_value("Backlog", f"{summary.get('backlog_count', '?')} Features")
    builder.add_key_value("Kritischer Pfad", f"{summary.get('critical_path_weeks', '?')} Wochen")

    budget_status = summary.get("phase_a_budget_status", "?")
    level = "success" if "im_budget" in str(budget_status).lower() else "warning"
    builder.add_recommendation(f"Phase A Budget: {budget_status}", level=level)
    builder.add_paragraph("")

    # Phase A
    builder.add_page_break()
    builder.add_heading("Phase A — Soft-Launch MVP", level=1)
    phase_a = content.get("phase_a", [])
    if phase_a:
        builder.add_table(
            ["ID", "Feature", "KPI-Impact", "Revenue", "Wochen", "Abhaengig von"],
            [[f.get("id", ""), f.get("name", ""), f.get("kpi", ""), f.get("revenue", ""),
              str(f.get("weeks", "")), f.get("depends", "")] for f in phase_a],
        )

    # Dependencies
    deps = content.get("dependencies", {})
    if deps.get("critical_path"):
        builder.add_heading("Kritischer Pfad", level=2)
        builder.add_paragraph(f"Kette: {deps['critical_path']}")
        builder.add_paragraph(f"Gesamtdauer: {deps.get('total_weeks', '?')} Wochen")

    parallel = deps.get("parallel_groups", [])
    if parallel:
        builder.add_heading("Parallelisierbare Gruppen", level=2)
        for g in parallel:
            builder.add_paragraph(f"- {g}")

    # Phase B
    builder.add_page_break()
    builder.add_heading("Phase B — Full Production", level=1)
    phase_b = content.get("phase_b", [])
    if phase_b:
        builder.add_table(
            ["ID", "Feature", "KPI-Impact", "Revenue", "Wochen", "Abhaengig von"],
            [[f.get("id", ""), f.get("name", ""), f.get("kpi", ""), f.get("revenue", ""),
              str(f.get("weeks", "")), f.get("depends", "")] for f in phase_b],
        )

    # Backlog
    builder.add_page_break()
    builder.add_heading("Backlog — Post-Launch", level=1)
    backlog = content.get("backlog", [])
    if backlog:
        builder.add_table(
            ["ID", "Feature", "Geplant fuer", "Impact", "Begruendung"],
            [[f.get("id", ""), f.get("name", ""), f.get("version", ""), f.get("impact", ""), f.get("reasoning", "")] for f in backlog],
        )

    # Cuts
    cuts = content.get("cuts", [])
    if cuts:
        builder.add_page_break()
        builder.add_heading("Streichungs-Vorschlaege", level=1)
        builder.add_table(
            ["Feature", "Ersparnis", "Risiko", "Alternative"],
            [[c.get("name", ""), c.get("saving", ""), c.get("risk", ""), c.get("alternative", "")] for c in cuts],
        )


def _extract_content(k4_data: dict) -> dict:
    prompt = f"""Extrahiere die Feature-Priorisierung aus folgendem Markdown in strukturiertes JSON.

{k4_data.get('feature_prioritization', '')[:16000]}

Antworte NUR in JSON (kein Markdown, keine Backticks):

{{
  "summary": {{
    "phase_a_count": 0, "phase_a_cost": "0", "phase_a_budget_status": "im_budget",
    "phase_b_count": 0, "phase_b_cost": "0",
    "backlog_count": 0, "critical_path_weeks": 0
  }},
  "phase_a": [
    {{"id": "F001", "name": "...", "kpi": "...", "revenue": "...", "weeks": 0, "depends": "..."}}
  ],
  "phase_b": [{{"id": "...", "name": "...", "kpi": "...", "revenue": "...", "weeks": 0, "depends": "..."}}],
  "backlog": [{{"id": "...", "name": "...", "version": "v1.2", "impact": "...", "reasoning": "..."}}],
  "dependencies": {{
    "critical_path": "F001 -> F002 -> ...",
    "total_weeks": 0,
    "parallel_groups": ["Gruppe 1: F005, F006 parallel zu F001"]
  }},
  "cuts": [{{"name": "...", "saving": "...", "risk": "...", "alternative": "..."}}]
}}"""

    print("[DocumentSecretary] Extracting MVP Scope content via Claude...")
    client = anthropic.Anthropic()
    response = client.messages.create(
        model="claude-sonnet-4-6", max_tokens=10000,
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
            return {"summary": {}, "phase_a": [], "phase_b": [], "backlog": [], "dependencies": {}, "cuts": []}
