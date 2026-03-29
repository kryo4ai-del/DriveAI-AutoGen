"""Feature-Extraction — Kapitel 4 MVP & Feature Scope

Role: Extracts ALL features from all previous reports, checks tech-stack compatibility.
Input: All 11 reports.
Output: Complete feature list with IDs, descriptions, sources, tech-check.
"""

import json
import re

from dotenv import load_dotenv

load_dotenv()

from factory.mvp_scope.config import get_fallback_model

AGENT_NAME = "FeatureExtraction"


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
            model=get_fallback_model(),
            max_tokens=max_tokens,
            messages=[{"role": "user", "content": prompt}]
        )
        return resp.content[0].text

CORE_CATEGORIES = [
    "Core Gameplay",
    "Narrative & Story",
    "Social & Multiplayer",
    "Monetarisierung",
    "Backend & Infrastruktur",
]

SUPPORTING_CATEGORIES = [
    "Legal & Compliance",
    "Marketing & Growth",
    "Analytics & Monitoring",
    "Resilience & Fallbacks",
]

ALL_CATEGORIES = CORE_CATEGORIES + SUPPORTING_CATEGORIES


def run(all_reports: dict) -> str:
    """Extract all features from all reports and check tech-stack compatibility."""
    # Call 1: Core features
    print(f"[{AGENT_NAME}] Extracting Core features (Call 1/2)...")
    core_features = _extract_core(all_reports)
    print(f"[{AGENT_NAME}] -> {len(core_features)} features extracted")

    # Call 2: Supporting features
    next_id = len(core_features) + 1
    print(f"[{AGENT_NAME}] Extracting Supporting features (Call 2/2)...")
    support_features = _extract_supporting(all_reports, next_id)
    print(f"[{AGENT_NAME}] -> {len(support_features)} features extracted")

    # Merge
    all_features = core_features + support_features
    all_features = _deduplicate(all_features)
    print(f"[{AGENT_NAME}] Merging: {len(all_features)} total features")

    # Stats
    compatible = sum(1 for f in all_features if f.get("tech_compatible", True))
    warnings = sum(1 for f in all_features if not f.get("tech_compatible", True))
    print(f"[{AGENT_NAME}] Tech-Stack check: {compatible} compatible, {warnings} warnings")

    # Format
    return _format_markdown(all_features, all_reports.get("idea_title", "App"))


def _extract_core(reports: dict) -> list[dict]:
    """Extract core features from concept, platform, monetization, release reports."""
    prompt = f"""Du bist ein Feature-Extraction-Spezialist fuer Mobile App Entwicklung.

Extrahiere JEDES Feature das in den folgenden Reports explizit erwaehnt oder implizit benoetigt wird. Jedes Feature bekommt eine eindeutige ID.

## Concept Brief
{reports.get('concept_brief', '')[:6000]}

## Platform Strategy
{reports.get('platform_strategy', '')[:4000]}

## Monetization Report
{reports.get('monetization_report', '')[:4000]}

## Release Plan
{reports.get('release_plan', '')[:3000]}

Antworte NUR in JSON (kein Markdown, keine Backticks). Format:

{{
  "features": [
    {{
      "id": "F001",
      "name": "Match-3 Core Loop",
      "description": "Klassische Swipe-Puzzle-Mechanik als Kern-Gameplay",
      "category": "Core Gameplay",
      "source": "Concept Brief",
      "tech_compatible": true,
      "tech_note": "Unity 2D — Standardimplementierung"
    }}
  ]
}}

KATEGORIEN (verwende genau diese):
- Core Gameplay
- Narrative & Story
- Social & Multiplayer
- Monetarisierung
- Backend & Infrastruktur

REGELN:
- Jedes Feature das genannt wird MUSS extrahiert werden — nichts weglassen
- Auch implizite Features extrahieren (z.B. Battle-Pass erwaehnt -> Saison-Timer-System noetig)
- tech_compatible: true wenn mit Unity + Firebase + Cloud Run umsetzbar, false wenn nicht
- tech_note: Kurze Begruendung zur Tech-Kompatibilitaet
- IDs starten bei F001 und sind fortlaufend
- Beschreibung: 1-2 Saetze, konkret
- Erwarte 25-40 Features aus diesen Reports"""

    raw = _call_llm(prompt, max_tokens=8000, agent_name=AGENT_NAME, profile="dev")
    return _parse_features(raw)


def _extract_supporting(reports: dict, next_id: int) -> list[dict]:
    """Extract supporting features from legal, risk, marketing, audience reports."""
    prompt = f"""Du bist ein Feature-Extraction-Spezialist fuer Mobile App Entwicklung.

Extrahiere JEDES Feature das in den folgenden Reports explizit erwaehnt oder implizit benoetigt wird. IDs starten bei F{next_id:03d}.

## Legal Report
{reports.get('legal_report', '')[:4000]}

## Risk Assessment
{reports.get('risk_assessment', '')[:4000]}

## Marketing Strategy
{reports.get('marketing_strategy', '')[:4000]}

## Audience Profile
{reports.get('audience_profile', '')[:2000]}

Antworte NUR in JSON (kein Markdown, keine Backticks). Format:

{{
  "features": [
    {{
      "id": "F{next_id:03d}",
      "name": "...",
      "description": "...",
      "category": "...",
      "source": "...",
      "tech_compatible": true,
      "tech_note": "..."
    }}
  ]
}}

KATEGORIEN (verwende genau diese):
- Legal & Compliance
- Marketing & Growth
- Analytics & Monitoring
- Resilience & Fallbacks

REGELN:
- Jedes Feature das genannt wird MUSS extrahiert werden
- Auch implizite Features (z.B. DSGVO-Consent erfordert Consent-Management-Service)
- tech_compatible: true/false basierend auf Unity + Firebase + Cloud Run Stack
- Erwarte 15-25 Features aus diesen Reports"""

    raw = _call_llm(prompt, max_tokens=8000, agent_name=AGENT_NAME, profile="dev")
    return _parse_features(raw)


def _parse_features(raw: str) -> list[dict]:
    """Parse features JSON from Claude response with robust fallback."""
    raw = raw.strip()
    # Strip markdown fences
    if raw.startswith("```"):
        raw = raw.split("\n", 1)[1]
    if raw.endswith("```"):
        raw = raw.rsplit("```", 1)[0]
    raw = raw.strip()

    # Try direct parse
    try:
        data = json.loads(raw)
        return data.get("features", [])
    except json.JSONDecodeError:
        pass

    # Try finding JSON object
    try:
        start = raw.index("{")
        end = raw.rindex("}") + 1
        data = json.loads(raw[start:end])
        return data.get("features", [])
    except (ValueError, json.JSONDecodeError):
        pass

    # Try repair: close open structures
    try:
        repaired = raw
        if repaired.count('"') % 2 != 0:
            repaired += '"'
        repaired += "]" * max(0, repaired.count("[") - repaired.count("]"))
        repaired += "}" * max(0, repaired.count("{") - repaired.count("}"))
        data = json.loads(repaired)
        print(f"[{AGENT_NAME}] JSON repaired successfully")
        return data.get("features", [])
    except json.JSONDecodeError:
        pass

    print(f"[{AGENT_NAME}] WARNING: JSON parse failed — using empty list")
    return []


def _deduplicate(features: list[dict]) -> list[dict]:
    """Remove features with very similar names."""
    seen_names: set[str] = set()
    result = []
    for f in features:
        name_key = f.get("name", "").lower().strip()
        # Simple dedup: skip if name already seen (exact match after lowering)
        if name_key in seen_names:
            continue
        seen_names.add(name_key)
        result.append(f)

    # Re-number IDs sequentially
    for i, f in enumerate(result, 1):
        f["id"] = f"F{i:03d}"

    return result


def _format_markdown(features: list[dict], title: str) -> str:
    """Format the feature list as structured Markdown."""
    # Group by category
    by_category: dict[str, list[dict]] = {}
    for f in features:
        cat = f.get("category", "Sonstiges")
        by_category.setdefault(cat, []).append(f)

    lines = [
        f"# Feature-Liste: {title}",
        f"## Gesamtanzahl: {len(features)} Features",
        "",
    ]

    for cat in ALL_CATEGORIES:
        cat_features = by_category.get(cat, [])
        if not cat_features:
            continue
        lines.append(f"### {cat}")
        lines.append("| ID | Feature | Beschreibung | Quelle | Tech-Stack |")
        lines.append("|---|---|---|---|---|")
        for f in cat_features:
            tech = "✅" if f.get("tech_compatible", True) else "⚠️"
            note = f.get("tech_note", "")
            lines.append(
                f"| {f['id']} | {f.get('name', '')} | {f.get('description', '')} | "
                f"{f.get('source', '')} | {tech} {note} |"
            )
        lines.append("")

    # Uncategorized
    for cat, cat_features in by_category.items():
        if cat not in ALL_CATEGORIES:
            lines.append(f"### {cat}")
            lines.append("| ID | Feature | Beschreibung | Quelle | Tech-Stack |")
            lines.append("|---|---|---|---|---|")
            for f in cat_features:
                tech = "✅" if f.get("tech_compatible", True) else "⚠️"
                note = f.get("tech_note", "")
                lines.append(
                    f"| {f['id']} | {f.get('name', '')} | {f.get('description', '')} | "
                    f"{f.get('source', '')} | {tech} {note} |"
                )
            lines.append("")

    # Tech conflicts
    conflicts = [f for f in features if not f.get("tech_compatible", True)]
    if conflicts:
        lines.append("## Tech-Stack Konflikte")
        lines.append("| Feature-ID | Feature | Problem | Loesungsvorschlag |")
        lines.append("|---|---|---|---|")
        for f in conflicts:
            lines.append(f"| {f['id']} | {f.get('name', '')} | {f.get('tech_note', '')} | — |")
        lines.append("")

    # Summary
    compatible = sum(1 for f in features if f.get("tech_compatible", True))
    incompatible = len(features) - compatible
    lines.append("## Zusammenfassung")
    lines.append(f"- Gesamtanzahl Features: {len(features)}")
    lines.append(f"- Davon Tech-Stack kompatibel: {compatible}")
    lines.append(f"- Davon mit Einschraenkung/nicht umsetzbar: {incompatible}")
    lines.append("")

    # Category breakdown
    lines.append("### Features pro Kategorie")
    lines.append("| Kategorie | Anzahl |")
    lines.append("|---|---|")
    for cat in ALL_CATEGORIES:
        count = len(by_category.get(cat, []))
        if count > 0:
            lines.append(f"| {cat} | {count} |")

    return "\n".join(lines)
