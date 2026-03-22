"""Design-Trend-Breaker — Kapitel 4.5 Design Vision (Agent 17a)

Role: Researches genre visual standards and identifies innovative deviations.
"""

from dotenv import load_dotenv

from factory.pre_production.tools.web_research import search_and_fetch

load_dotenv()

AGENT_NAME = "TrendBreaker"


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


def run(all_reports: dict) -> str:
    """Analyze genre standards and identify innovative differentiations."""
    competitive = all_reports.get("competitive_report", "")
    screen_arch = all_reports.get("screen_architecture", "")
    audience = all_reports.get("audience_profile", "")
    concept = all_reports.get("concept_brief", "")
    platform = all_reports.get("platform_strategy", "")

    # Web research
    print(f"[{AGENT_NAME}] Researching innovative designs...")
    search_results = _research_designs()

    # Call 1: Genre Standard + Innovative References
    print(f"[{AGENT_NAME}] Analyzing genre standard + innovative references (Call 1/2)...")
    part1 = _analyze_standard(competitive, screen_arch, audience, concept, search_results)
    print(f"[{AGENT_NAME}] -> {len(part1)} chars")

    # Call 2: Differentiations + Anti-Standard Rules
    print(f"[{AGENT_NAME}] Defining differentiations + anti-standard rules (Call 2/2)...")
    part2 = _define_rules(part1, screen_arch, platform)
    print(f"[{AGENT_NAME}] -> {len(part2)} chars")

    title = all_reports.get("idea_title", "App")
    return f"# Design-Differenzierungs-Report: {title}\n\n{part1}\n\n---\n\n{part2}"


def _research_designs() -> str:
    queries = [
        "best mobile app design awards 2025 2026 innovative UI",
        "match-3 puzzle game UI design standard common patterns",
        "viral app design TikTok 2025 innovative mobile interface",
        "mobile app design trends 2026 breaking conventions",
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


def _analyze_standard(competitive, screen_arch, audience, concept, search_results) -> str:
    prompt = f"""Du bist ein Design-Stratege der sich auf visuelle Differenzierung spezialisiert hat.

Deine Aufgabe: Identifiziere was der STANDARD ist in der Nische dieses Produkts — und dann finde was ANDERS ist. Die Factory darf KEINE durchschnittliche App produzieren.

## Competitive-Report (Wettbewerber)
{competitive[:5000]}

## Screen-Architektur (was gebaut wird)
{screen_arch[:5000]}

## Zielgruppen-Profil
{audience[:3000]}

## Concept Brief
{concept[:3000]}

## Web-Recherche: Innovative Designs
{search_results[:5000]}

Antworte in Markdown (KEIN JSON):

# Genre-Standard-Analyse

## Was sieht der Nutzer bei ALLEN Wettbewerbern
| Element | Standard-Umsetzung | Genutzt von |
|---|---|---|
| Layout | ... | ... |
| Farbschema | ... | ... |
| Navigation | ... | ... |
| Animationen | ... | ... |
| Typografie | ... | ... |
| Onboarding | ... | ... |
| Reward-Screens | ... | ... |
| Shop/Monetarisierung | ... | ... |

## Fazit: Der Genre-Standard ist...
(2-3 Saetze die den visuellen Einheitsbrei beschreiben — DAS ist was die KI ohne Anweisung produzieren wuerde)

## Innovative Referenzen (NICHT aus der eigenen Nische — Genre-uebergreifend)
| Referenz-App/Design | Kategorie | Was sie anders macht | Relevanz fuer unser Produkt | Quelle |
|---|---|---|---|---|
(mindestens 6 Referenzen aus VERSCHIEDENEN App-Kategorien: Fashion, Fintech, Musik, Fitness etc.)

## Virale UI-Momente
(Welche App-Designs werden auf TikTok/Instagram geteilt WEIL sie anders aussehen)

REGELN:
- Genre-Standard: Ehrlich dokumentieren was ALLE machen — das ist das Verbotene
- Innovative Referenzen: NICHT innerhalb der eigenen Nische suchen
- Mindestens 6 Referenzen aus mindestens 3 verschiedenen App-Kategorien
- Konkret bleiben: nicht "innovatives Design" sondern "3D-Parallax-Scroll bei der Level-Auswahl statt flachem Grid"
"""

    return _call_llm(prompt, max_tokens=8000, agent_name=AGENT_NAME, profile="standard")


def _define_rules(standard_analysis, screen_arch, platform) -> str:
    prompt = f"""Du bist ein Design-Stratege. Basierend auf der Genre-Standard-Analyse und den innovativen Referenzen, definiere jetzt die konkreten Differenzierungen und Verbote.

## Genre-Standard-Analyse (vorher erstellt)
{standard_analysis[:8000]}

## Screen-Architektur (was gebaut wird)
{screen_arch[:4000]}

## Tech-Stack Info
{platform[:2000]}

Antworte in Markdown (KEIN JSON):

# Differenzierungspunkte & Anti-Standard-Regeln

## Differenzierungspunkt 1: [Name]
- Standard ist: ...
- Unsere Loesung: ... (KONKRET beschreiben, nicht abstrakt)
- Warum besser fuer die Zielgruppe: ...
- Technisch machbar mit Unity/Web: ja/nein/mit Aufwand
- Betroffene Screens: S00X, S00Y

## Differenzierungspunkt 2: [Name]
...

## Differenzierungspunkt 3: [Name]
...

(mindestens 3, gerne mehr)

## Anti-Standard-Regeln (VERBINDLICH fuer Produktionslinie)

| # | Was die KI normalerweise machen wuerde | Was stattdessen gebaut werden MUSS | Betroffene Screens | Begruendung |
|---|---|---|---|---|
| 1 | Flaches Card-Grid fuer Level-Auswahl | [konkrete Alternative] | S005 | Genre-Standard = austauschbar |
| 2 | Standard Bottom-Tab-Bar (5 Icons) | [konkrete Alternative] | Alle | Jede zweite App sieht so aus |
| 3 | Weisser/heller Hintergrund | [konkrete Alternative] | Alle | Kein Wiedererkennungswert |
| 4 | Statische Screen-Uebergaenge | [konkrete Alternative] | Alle | Fuehlt sich billig an |
(mindestens 4 Regeln)

## Tech-Stack Kompatibilitaet
| Differenzierung | Umsetzbar | Zusaetzlicher Aufwand | Hinweise |
|---|---|---|---|

REGELN:
- Mindestens 3 Differenzierungspunkte
- Mindestens 4 Anti-Standard-Regeln
- Jede Anti-Regel muss eine KONKRETE Alternative haben (nicht "etwas Innovatives")
- Tech-Kompatibilitaet pruefen — Innovation die nicht umsetzbar ist bringt nichts
- Innovation muss zur Zielgruppe passen, nicht nur cool sein
"""

    return _call_llm(prompt, max_tokens=8000, agent_name=AGENT_NAME, profile="standard")
