"""Platform-Strategy — Phase 2 Market Strategy Pipeline

Role: Decides which platforms to build and in what order.
Input: Concept Brief + Audience Profile + Risk Assessment + Legal Report.
Output: Platform Strategy Report.
"""

from dotenv import load_dotenv

from factory.pre_production.tools.web_research import search_and_fetch

load_dotenv()

AGENT_NAME = "PlatformStrategy"


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


def _detect_genre(concept_brief: str) -> str:
    """Detect genre from concept brief."""
    brief_lower = concept_brief.lower()
    genres = [
        "puzzle", "match-3", "casual", "hybrid-casual", "rpg", "strategy",
        "simulation", "racing", "shooter", "adventure", "idle",
    ]
    return next((g for g in genres if g in brief_lower), "mobile game")


def _build_queries(concept_brief: str) -> list[str]:
    """Build search queries from concept brief."""
    genre = _detect_genre(concept_brief)
    brief_lower = concept_brief.lower()
    queries = [
        f"{genre} mobile game iOS vs Android market share revenue 2025",
        f"cross-platform game development Unity vs native cost comparison",
        f"{genre} game revenue per platform iOS Android 2025",
        f"mobile game soft launch regions best practices 2025",
    ]
    if "web" in brief_lower or "pwa" in brief_lower or "browser" in brief_lower:
        queries.append("progressive web app gaming limitations vs native")
    return queries[:5]


def run(concept_brief: str, audience_profile: str, risk_assessment: str, legal_report: str) -> str:
    """Analyze platforms and recommend build order."""
    # 1. Web research
    queries = _build_queries(concept_brief)
    all_results = []
    for q in queries:
        print(f"[{AGENT_NAME}] Searching: {q}")
        data = search_and_fetch(q, num_results=3, fetch_top_n=1)
        all_results.append(data)

    # 2. Compile context
    research_context = _compile_context(all_results)

    # 3. Extract app name
    app_name = "App"
    for line in concept_brief.splitlines():
        if line.startswith("# ") and ":" in line:
            app_name = line.split(":", 1)[1].strip()
            break

    # 4. Call Claude
    prompt = f"""Du bist ein Plattform-Stratege für Mobile Apps und Games.

## Concept Brief
{concept_brief}

## Zielgruppen-Profil
{audience_profile}

## Risk-Assessment (Phase 1)
{risk_assessment}

## Legal-Report (Phase 1)
{legal_report}

## Web-Recherche-Ergebnisse
{research_context}

Erstelle einen Plattform-Strategie-Report im folgenden Format:

# Plattform-Strategie-Report: {app_name}

## Zielgruppen-Plattform-Analyse
  - iOS Anteil: ...% | Begründung: ...
  - Android Anteil: ...% | Begründung: ...
  - Web/Browser Anteil: ...% | Begründung: ...
  - Quellen: ...

## Revenue-Verteilung pro Plattform
  - iOS: ...% des Umsatzes in dieser Nische
  - Android: ...%
  - Web: ...%
  - Quellen: ...

## Plattform-Bewertung

### iOS (Native / Swift)
  - Vorteile: ...
  - Nachteile: ...
  - Geschätzte Entwicklungskosten: ...
  - Feature-Einschränkungen: ...

### Android (Native / Kotlin)
  - Vorteile: ...
  - Nachteile: ...
  - Geschätzte Entwicklungskosten: ...
  - Feature-Einschränkungen: ...

### Web (PWA / Browser App)
  - Vorteile: ...
  - Nachteile: ...
  - Geschätzte Entwicklungskosten: ...
  - Feature-Einschränkungen: ...

### Cross-Platform (Unity / React Native / etc.)
  - Vorteile: ...
  - Nachteile: ...
  - Geschätzte Entwicklungskosten: ...
  - Feature-Einschränkungen: ...

## Gestaffelter vs. gleichzeitiger Launch
  - Empfehlung: ...
  - Begründung: ...

## Cross-Platform Synergien
  - Cloud-Save: ja/nein
  - Cross-Play: ja/nein
  - Geteilte Accounts: ja/nein

## Finale Plattform-Entscheidung
  - Phase 1 Launch: [Plattform(en)]
  - Phase 2 Erweiterung: [Plattform(en)]
  - Technologie: [Stack]
  - Begründung: ...

## Legal-Relevanz
  - Plattform-spezifische Einschränkungen aus Phase 1: ...

REGELN:
- Jede Empfehlung mit Daten begründen
- Kosten in Euro schätzen (DACH-Markt Perspektive)
- Legal-Einschränkungen aus Phase 1 berücksichtigen
- Klare finale Entscheidung treffen, nicht nur Optionen auflisten"""

    print(f"[{AGENT_NAME}] Generating Platform Strategy Report...")
    return _call_llm(prompt, max_tokens=5000, agent_name=AGENT_NAME, profile="standard")


def _compile_context(all_results: list[dict]) -> str:
    """Format search results into a readable context block."""
    parts = []
    for data in all_results:
        parts.append(f"### Suche: \"{data['query']}\"")
        if not data["results"]:
            parts.append("Keine Ergebnisse gefunden.\n")
            continue
        for r in data["results"]:
            parts.append(f"- **{r['title']}** ({r['link']})")
            parts.append(f"  {r['snippet']}")
        for fc in data.get("fetched_content", []):
            if fc["content"]:
                parts.append(f"\n**Volltext-Auszug ({fc['title']}):**")
                parts.append(fc["content"][:2000])
        parts.append("")
    return "\n".join(parts)
