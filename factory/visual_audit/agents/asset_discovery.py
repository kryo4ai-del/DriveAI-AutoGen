"""Asset-Discovery — Kapitel 5 Visual & Asset Audit

Role: Goes screen by screen through the entire screen architecture and identifies
every visual element needed. Includes platform variants, dark mode check, and
launch-criticality.
"""

import json

from dotenv import load_dotenv

load_dotenv()

from factory.visual_audit.config import get_fallback_model

AGENT_NAME = "AssetDiscovery"


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


def run(all_reports: dict) -> str:
    """Discover all visual assets needed across all screens."""
    screen_arch = all_reports.get("screen_architecture", "")
    feature_list = all_reports.get("feature_list", "")
    concept_brief = all_reports.get("concept_brief", "")
    monetization = all_reports.get("monetization_report", "")
    marketing = all_reports.get("marketing_strategy", "")
    legal = all_reports.get("legal_report", "")

    # Call 1: Core Visual Assets
    print(f"[{AGENT_NAME}] Analyzing Core Visual Assets (Call 1/2)...")
    core_assets = _discover_core(screen_arch, feature_list, concept_brief)
    print(f"[{AGENT_NAME}] -> {len(core_assets)} assets identified")

    # Call 2: Supporting Assets
    next_id = len(core_assets) + 1
    print(f"[{AGENT_NAME}] Analyzing Supporting Assets (Call 2/2)...")
    support_assets = _discover_supporting(screen_arch, monetization, marketing, legal, next_id)
    print(f"[{AGENT_NAME}] -> {len(support_assets)} assets identified")

    # Merge
    all_assets = core_assets + support_assets
    launch_critical = sum(1 for a in all_assets if a.get("launch_critical"))
    print(f"[{AGENT_NAME}] Merged: {len(all_assets)} total, {launch_critical} launch-critical")

    title = all_reports.get("idea_title", "App")
    return _format_markdown(title, all_assets)


def _discover_core(screen_arch, feature_list, concept_brief) -> list:
    prompt = f"""Du bist ein Visual-Asset-Spezialist fuer App- und Game-Entwicklung. Deine Aufgabe ist KRITISCH: Jedes visuelle Element das du uebersiehst wird von der Entwicklungs-KI als Text oder Platzhalter generiert — das zerstoert das Nutzererlebnis.

Gehe JEDEN Screen der Screen-Architektur einzeln durch und identifiziere JEDES Element das ein echtes visuelles Asset braucht.

## Screen-Architektur
{screen_arch[:12000]}

## Feature-Liste
{feature_list[:6000]}

## Concept Brief
{concept_brief[:4000]}

Antworte NUR in JSON (kein Markdown, keine Backticks):
{{
  "assets": [
    {{
      "id": "A001",
      "name": "App-Icon",
      "category": "App-Branding",
      "description": "Haupticon fuer Store und Home-Screen",
      "screens": ["Alle"],
      "flows": ["Alle"],
      "static_dynamic": "statisch",
      "why_not_text": "Store-Pflicht, visueller Ersterkennungswert",
      "platform_variants": 18,
      "dark_mode": "kontrastsicher",
      "launch_critical": true
    }}
  ]
}}

KATEGORIEN: App-Branding, Gameplay-Assets, UI-Elemente, Illustrationen, Animationen & Effekte, Datenvisualisierung, Story/Narrative Assets

REGELN:
- JEDEN Screen einzeln durchgehen: S001, S002, S003...
- Bei JEDEM UI-Element fragen: Kann das als reiner Text dargestellt werden? Wenn nein -> Asset
- platform_variants: Anzahl benoetigter Varianten (z.B. App-Icon = 18)
- dark_mode: ja/nein/kontrastsicher
- launch_critical: true wenn App NICHT ohne dieses Asset ausgeliefert werden kann
- BESONDERS ACHTEN auf Fahrschul-App-Fehler:
  * Puzzle-Steine -> brauchen Sprites, NICHT Text-Labels
  * Score-Anzeigen -> brauchen visuelle Gauge, NICHT nur Zahlen
  * Rewards -> brauchen Animation, NICHT nur Text
  * Story-Szenen -> brauchen Illustrationen, NICHT beschreibenden Text
- Erwarte 40-60 Assets"""

    raw = _call_llm(prompt, max_tokens=16000, agent_name=AGENT_NAME, profile="standard")
    data = _parse_json(raw)
    return data.get("assets", [])


def _discover_supporting(screen_arch, monetization, marketing, legal, next_id) -> list:
    prompt = f"""Du bist ein Visual-Asset-Spezialist. Fortsetzung der Asset-Discovery. IDs starten bei A{next_id:03d}.

Identifiziere alle visuellen Assets fuer Social-Features, Monetarisierung, Marketing und Legal-UI.

## Screen-Architektur
{screen_arch[:8000]}

## Monetarisierungs-Report
{monetization[:4000]}

## Marketing-Strategie
{marketing[:4000]}

## Legal-Report
{legal[:3000]}

Antworte NUR in JSON (kein Markdown, keine Backticks):
{{
  "assets": [
    {{
      "id": "A{next_id:03d}",
      "name": "...",
      "category": "...",
      "description": "...",
      "screens": ["..."],
      "flows": ["..."],
      "static_dynamic": "...",
      "why_not_text": "...",
      "platform_variants": 1,
      "dark_mode": "ja",
      "launch_critical": true
    }}
  ]
}}

KATEGORIEN: Social-Assets, Monetarisierungs-Assets, Marketing-Assets, Legal-UI

REGELN:
- Marketing-Assets NICHT vergessen: App Store Screenshots, Preview-Video, Press-Kit, Social-Templates
- Battle-Pass braucht visuelle Fortschrittsanzeige mit gestalteten Reward-Icons
- Share-Cards muessen visuell ansprechend sein
- Consent-Screen muss professionell aussehen, nicht wie System-Dialog
- Erwarte 20-40 Assets"""

    raw = _call_llm(prompt, max_tokens=16000, agent_name=AGENT_NAME, profile="standard")
    data = _parse_json(raw)
    return data.get("assets", [])


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
        result = json.loads(repaired)
        print(f"[{AGENT_NAME}] JSON repaired successfully")
        return result
    except json.JSONDecodeError:
        pass

    print(f"[{AGENT_NAME}] WARNING: JSON parse failed — returning empty")
    return {"assets": []}


def _format_markdown(title: str, assets: list) -> str:
    lines = [f"# Asset-Discovery-Liste: {title}", f"## Gesamtanzahl: {len(assets)} Assets", ""]

    # Group by category
    categories = {}
    for a in assets:
        cat = a.get("category", "Sonstige")
        categories.setdefault(cat, []).append(a)

    # Category order
    cat_order = [
        "App-Branding", "Gameplay-Assets", "UI-Elemente", "Illustrationen",
        "Animationen & Effekte", "Datenvisualisierung", "Story/Narrative Assets",
        "Social-Assets", "Monetarisierungs-Assets", "Marketing-Assets", "Legal-UI",
    ]
    # Add any categories not in the predefined order
    for cat in categories:
        if cat not in cat_order:
            cat_order.append(cat)

    for cat in cat_order:
        cat_assets = categories.get(cat, [])
        if not cat_assets:
            continue

        lines.append(f"### {cat}")
        lines.append("| ID | Asset | Beschreibung | Screen(s) | Stat/Dyn | Warum kein Text | Varianten | Dark Mode | Launch-krit. |")
        lines.append("|---|---|---|---|---|---|---|---|---|")

        for a in cat_assets:
            screens = ", ".join(a.get("screens", [])) if isinstance(a.get("screens"), list) else str(a.get("screens", ""))
            launch = "JA" if a.get("launch_critical") else "nein"
            lines.append(
                f"| {a.get('id', '')} | {a.get('name', '')} | "
                f"{a.get('description', '')[:80]} | {screens[:30]} | "
                f"{a.get('static_dynamic', '')} | {a.get('why_not_text', '')[:50]} | "
                f"{a.get('platform_variants', 1)} | {a.get('dark_mode', '')} | {launch} |"
            )
        lines.append("")

    # Summary
    static_count = sum(1 for a in assets if a.get("static_dynamic", "").startswith("stat"))
    dynamic_count = sum(1 for a in assets if a.get("static_dynamic", "").startswith("dyn"))
    launch_crit = sum(1 for a in assets if a.get("launch_critical"))
    nice_to_have = len(assets) - launch_crit
    total_variants = sum(a.get("platform_variants", 1) for a in assets)
    dark_mode_count = sum(1 for a in assets if a.get("dark_mode", "nein") != "nein")

    lines.append("## Zusammenfassung")
    lines.append(f"- **Gesamtanzahl Assets:** {len(assets)}")
    lines.append(f"- **Davon statisch:** {static_count}")
    lines.append(f"- **Davon dynamisch:** {dynamic_count}")
    lines.append(f"- **Davon Launch-kritisch:** {launch_crit}")
    lines.append(f"- **Davon Nice-to-have:** {nice_to_have}")
    lines.append(f"- **Plattform-Varianten gesamt:** {total_variants}")
    lines.append(f"- **Dark-Mode-Varianten noetig:** {dark_mode_count}")

    return "\n".join(lines)
