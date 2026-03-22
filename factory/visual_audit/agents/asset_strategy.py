"""Asset-Strategie — Kapitel 5 Visual & Asset Audit

Role: Defines sourcing strategy, costs, style guide, technical formats, performance
constraints, and repo paths for each asset.
"""

import json

import anthropic
from dotenv import load_dotenv

from factory.pre_production.tools.web_research import search_and_fetch
from factory.visual_audit.config import AGENT_MODEL_MAP

load_dotenv()

AGENT_NAME = "AssetStrategy"


def run(all_reports: dict, asset_discovery: str) -> str:
    """Define sourcing strategy, costs, style guide, and repo paths for all assets."""
    client = anthropic.Anthropic()
    model = AGENT_MODEL_MAP["asset_strategy"]

    platform_strategy = all_reports.get("platform_strategy", "")
    cost_calculation = all_reports.get("cost_calculation", "")
    feature_prio = all_reports.get("feature_prioritization", "")

    # Web research for cost data
    print(f"[{AGENT_NAME}] Researching asset costs...")
    search_results = _research_costs()

    # Call 1: Style Guide (small JSON — no sourcing here)
    print(f"[{AGENT_NAME}] Building Style Guide (Call 1/3)...")
    style_guide = _build_style_guide(client, model, asset_discovery, platform_strategy, cost_calculation, search_results)
    print(f"[{AGENT_NAME}] -> Style Guide: {len(style_guide)} keys")

    # Call 2: Sourcing as Markdown (avoids JSON truncation for 100 assets)
    print(f"[{AGENT_NAME}] Building Sourcing Strategy (Call 2/3)...")
    sourcing_md = _build_sourcing_md(client, model, asset_discovery, search_results)
    print(f"[{AGENT_NAME}] -> Sourcing: {len(sourcing_md)} chars")

    # Call 3: Format Requirements + Budget Check + Handover
    print(f"[{AGENT_NAME}] Format Requirements + Budget Check (Call 3/3)...")
    formats_and_budget = _formats_and_budget(
        client, model, platform_strategy, cost_calculation, sourcing_md[:4000]
    )
    print(f"[{AGENT_NAME}] -> Budget: {formats_and_budget.get('budget_total_eur', '?')} EUR, Status: {formats_and_budget.get('budget_status', '?')}")

    title = all_reports.get("idea_title", "App")
    return _format_markdown_v2(title, style_guide, sourcing_md, formats_and_budget)


def _research_costs() -> str:
    queries = [
        "mobile game asset design cost freelancer 2025 2026",
        "lottie animation stock library pricing",
        "app icon design cost professional 2025",
        "unity sprite sheet asset pack marketplace pricing",
    ]
    parts = []
    for q in queries:
        print(f"[{AGENT_NAME}] Searching: {q}")
        data = search_and_fetch(q, num_results=3, fetch_top_n=1)
        parts.append(f"### {q}")
        for r in data.get("results", []):
            parts.append(f"- {r.get('title', '')} — {r.get('snippet', '')}")
        for fc in data.get("fetched_content", []):
            if fc.get("content"):
                parts.append(fc["content"][:1500])
        parts.append("")
    return "\n".join(parts)


def _build_style_guide(client, model, asset_discovery, platform_strategy, cost_calc, search_results) -> dict:
    """Call 1: Style Guide only (small JSON)."""
    prompt = f"""Du bist ein Art Director fuer App-Entwicklung.

Erstelle einen vollstaendigen Stil-Guide fuer das folgende Produkt.

## Asset-Discovery (Auszug)
{asset_discovery[:5000]}

## Plattform-Strategie
{platform_strategy[:2000]}

Antworte NUR in JSON (kein Markdown, keine Backticks):

{{
  "color_palette": {{
    "primary": {{"hex": "#...", "name": "...", "usage": "Hauptfarbe fuer Buttons, Links, Akzente"}},
    "secondary": {{"hex": "#...", "name": "...", "usage": "..."}},
    "accent": {{"hex": "#...", "name": "...", "usage": "..."}},
    "background_light": {{"hex": "#...", "usage": "Light Mode Hintergrund"}},
    "background_dark": {{"hex": "#...", "usage": "Dark Mode Hintergrund"}},
    "success": {{"hex": "#27ae60", "usage": "Erfolg"}},
    "warning": {{"hex": "#f39c12", "usage": "Warnung"}},
    "error": {{"hex": "#e74c3c", "usage": "Fehler"}},
    "text_primary": {{"hex": "#...", "usage": "Haupttext"}},
    "text_secondary": {{"hex": "#...", "usage": "Sekundaertext"}}
  }},
  "typography": {{
    "primary_font": {{"name": "...", "usage": "Headings", "weight": "600-700", "license": "..."}},
    "secondary_font": {{"name": "...", "usage": "Body Text", "weight": "400-500", "license": "..."}},
    "mono_font": {{"name": "...", "usage": "Daten, Scores", "license": "..."}}
  }},
  "illustration_style": {{"style": "...", "description": "...", "rationale": "..."}},
  "icon_style": {{"style": "...", "library": "...", "size_grid": "24x24", "stroke_width": "..."}},
  "animation_style": {{"default_duration_ms": 300, "easing": "ease-in-out", "max_lottie_kb": 500, "max_particles": 50, "static_fallback": true}}
}}

REGELN:
- Farbpalette mit exakten Hex-Werten passend zum Produkt und zur Zielgruppe
- Fonts: Nur frei verfuegbare oder lizenzierbare Fonts (Google Fonts, Apple System, etc.)
- Illustration-Stil passend zur App-Kategorie und Zielgruppe"""

    response = client.messages.create(
        model=model, max_tokens=4000,
        messages=[{"role": "user", "content": prompt}],
    )
    return _parse_json(response.content[0].text)


def _build_sourcing_md(client, model, asset_discovery, search_results) -> str:
    """Call 2: Sourcing as Markdown table (avoids JSON truncation for 100 assets)."""
    prompt = f"""Du bist ein Asset-Stratege fuer App-Entwicklung.

Erstelle eine Beschaffungsstrategie fuer JEDES Asset als Markdown-Tabelle.

## Asset-Discovery-Liste
{asset_discovery[:16000]}

## Web-Recherche: Asset-Kosten
{search_results[:3000]}

Erstelle eine VOLLSTAENDIGE Markdown-Tabelle (KEIN JSON) fuer JEDES Asset:

| ID | Asset | Quelle | Tool | Format | Kosten EUR | Prioritaet | Repo-Pfad | Notizen |
|---|---|---|---|---|---|---|---|---|
| A001 | App-Icon | Custom Design | Figma | PNG 1024x1024 | 350 | Launch-kritisch | assets/branding/app_icon/ | Hell+Dunkel |
| A002 | ... | ... | ... | ... | ... | ... | ... | ... |

QUELLEN-TYPEN:
- Custom Design: Freelancer/Agentur, geschaetzte Kosten €60-100/h
- AI-generiert: Midjourney/DALL-E/Firefly, ~€0-20 pro Bild
- Stock: Shutterstock/Adobe Stock/Freepik, ~€5-50 pro Asset
- Free/Open-Source: Lucide/Phosphor/unDraw/Storyset, €0
- Lottie: LottieFiles Free/Premium, €0-15 pro Animation
- Native: Systemkomponente, €0

REGELN:
- JEDES Asset aus der Liste muss einen Eintrag haben
- Kosten realistisch fuer Indie/Startup-Budget
- Launch-kritisch vs. Nice-to-have angeben
- repo_path: z.B. assets/sprites/, assets/icons/, assets/branding/"""

    response = client.messages.create(
        model=model, max_tokens=16000,
        messages=[{"role": "user", "content": prompt}],
    )
    return response.content[0].text


def _formats_and_budget(client, model, platform_strategy, cost_calc, sourcing_summary) -> dict:
    prompt = f"""Du bist ein Technical Art Director.

Definiere technische Format-Anforderungen, Budget-Zusammenfassung und Uebergabe-Protokoll.

## Plattform-Strategie
{platform_strategy[:3000]}

## Kosten-Kalkulation
{cost_calc[:3000]}

## Sourcing-Zusammenfassung
{sourcing_summary}

Antworte NUR in JSON (kein Markdown, keine Backticks):

{{
  "format_requirements": {{
    "unity_sprites": {{"format": "PNG / Sprite Sheet", "resolution": "2x Retina", "max_size": "2MB", "tool": "TexturePacker"}},
    "icons": {{"format": "SVG", "viewbox": "24x24", "stroke": "2px"}},
    "animations": {{"format": "Lottie JSON", "max_size_kb": 500, "tool": "After Effects + Bodymovin", "fallback": "Statisches PNG"}},
    "app_icon_ios": {{"format": "PNG", "sizes": "1024x1024 + Varianten", "notes": "Keine Transparenz"}},
    "app_icon_android": {{"format": "PNG Adaptive", "foreground": "108dp", "safe_zone": "72dp"}},
    "screenshots_store": {{"format": "PNG", "sizes_ios": "1290x2796, 1242x2208", "sizes_android": "1080x1920"}}
  }},
  "budget_summary": [
    {{"category": "App-Branding", "asset_count": 5, "total_cost_eur": 850, "source_mix": "..."}}
  ],
  "budget_total_eur": 0,
  "budget_available_eur": 0,
  "budget_status": "im_budget",
  "handover_protocol": {{
    "directory_structure": "assets/ mit Unterordnern",
    "naming_convention": "lowercase_snake_case",
    "delivery_checklist": ["..."]
  }}
}}

REGELN:
- Format-Anforderungen spezifisch fuer den Tech-Stack
- Budget gegen verfuegbares Budget pruefen
- Uebergabe-Protokoll: Ordnerstruktur, Naming, Checkliste"""

    response = client.messages.create(
        model=model, max_tokens=8000,
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
        result = json.loads(repaired)
        print(f"[{AGENT_NAME}] JSON repaired successfully")
        return result
    except json.JSONDecodeError:
        pass
    print(f"[{AGENT_NAME}] WARNING: JSON parse failed")
    return {"style_guide": {}, "sourcing": [], "format_requirements": {}, "budget_summary": [], "budget_total_eur": 0, "budget_status": "unbekannt", "handover_protocol": {}}


def _format_markdown_v2(title: str, style_guide: dict, sourcing_md: str, formats_budget: dict) -> str:
    lines = [f"# Asset-Strategie-Report: {title}", ""]

    # Style Guide
    lines.append("## Stil-Guide")

    palette = style_guide.get("color_palette", {})
    if palette:
        lines.append("### Farbpalette")
        lines.append("| Name | Hex | Verwendung |")
        lines.append("|---|---|---|")
        for key, val in palette.items():
            if isinstance(val, dict):
                lines.append(f"| {val.get('name', key)} | `{val.get('hex', '')}` | {val.get('usage', '')} |")
        lines.append("")

    typo = style_guide.get("typography", {})
    if typo:
        lines.append("### Typografie")
        lines.append("| Font | Verwendung | Gewicht | Lizenz |")
        lines.append("|---|---|---|---|")
        for key, val in typo.items():
            if isinstance(val, dict):
                lines.append(f"| {val.get('name', '')} | {val.get('usage', '')} | {val.get('weight', '')} | {val.get('license', '')} |")
        lines.append("")

    illust = style_guide.get("illustration_style", {})
    if illust:
        lines.append("### Illustrations-Stil")
        lines.append(f"- **Stil:** {illust.get('style', '')}")
        lines.append(f"- **Beschreibung:** {illust.get('description', '')}")
        lines.append(f"- **Begruendung:** {illust.get('rationale', '')}")
        lines.append("")

    icons = style_guide.get("icon_style", {})
    if icons:
        lines.append("### Icon-Stil")
        lines.append(f"- **Stil:** {icons.get('style', '')}")
        lines.append(f"- **Library:** {icons.get('library', '')}")
        lines.append(f"- **Grid:** {icons.get('size_grid', '')}")
        lines.append("")

    anim = style_guide.get("animation_style", {})
    if anim:
        lines.append("### Animations-Stil")
        lines.append(f"- **Default Duration:** {anim.get('default_duration_ms', 300)}ms")
        lines.append(f"- **Easing:** {anim.get('easing', '')}")
        lines.append(f"- **Max Lottie:** {anim.get('max_lottie_kb', 500)} KB")
        lines.append(f"- **Static Fallback:** {'Ja' if anim.get('static_fallback') else 'Nein'}")
        lines.append("")

    # Sourcing (already Markdown from Call 2)
    lines.append("## Beschaffungsstrategie pro Asset")
    lines.append(sourcing_md)
    lines.append("")

    # Format requirements
    fmt_reqs = formats_budget.get("format_requirements", {})
    if fmt_reqs:
        lines.append("## Technische Format-Anforderungen")
        lines.append("| Asset-Typ | Format | Aufloesung/Groesse | Tool | Hinweise |")
        lines.append("|---|---|---|---|---|")
        for key, val in fmt_reqs.items():
            if isinstance(val, dict):
                res = val.get("resolution", val.get("sizes", val.get("max_size", "")))
                lines.append(
                    f"| {key} | {val.get('format', '')} | {res} | "
                    f"{val.get('tool', '')} | {val.get('notes', val.get('fallback', ''))} |"
                )
        lines.append("")

    # Budget summary
    budget_items = formats_budget.get("budget_summary", [])
    if budget_items:
        lines.append("## Kosten-Uebersicht")
        lines.append("| Kategorie | Anzahl | Kosten | Quellen-Mix |")
        lines.append("|---|---|---|---|")
        for b in budget_items:
            cost = b.get("total_cost_eur", 0)
            cost_str = f"{cost:,} EUR" if isinstance(cost, (int, float)) else str(cost)
            lines.append(
                f"| {b.get('category', '')} | {b.get('asset_count', '')} | "
                f"{cost_str} | {b.get('source_mix', '')} |"
            )
        lines.append("")

    # Budget check
    total = formats_budget.get("budget_total_eur", 0)
    available = formats_budget.get("budget_available_eur", 0)
    status = formats_budget.get("budget_status", "unbekannt")
    lines.append("## Budget-Check")
    total_str = f"{total:,}" if isinstance(total, (int, float)) else str(total)
    avail_str = f"{available:,}" if isinstance(available, (int, float)) else str(available)
    lines.append(f"- **Geschaetzte Gesamtkosten:** {total_str} EUR")
    lines.append(f"- **Verfuegbares Budget:** {avail_str} EUR")
    lines.append(f"- **Status:** {status}")
    lines.append("")

    # Handover protocol
    handover = formats_budget.get("handover_protocol", {})
    if handover:
        lines.append("## Asset-Uebergabe-Protokoll")
        lines.append(f"- **Ordnerstruktur:** {handover.get('directory_structure', '')}")
        lines.append(f"- **Naming-Convention:** {handover.get('naming_convention', '')}")
        checklist = handover.get("delivery_checklist", [])
        if checklist:
            lines.append("### Delivery-Checkliste")
            for item in checklist:
                lines.append(f"- [ ] {item}")
        lines.append("")

    return "\n".join(lines)
