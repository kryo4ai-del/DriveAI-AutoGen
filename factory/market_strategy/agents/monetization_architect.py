"""Monetization-Architect — Phase 2 Market Strategy Pipeline

Role: Designs the monetization model with price points, economy and revenue projection.
Input: Concept Brief + Audience Profile + Competitive Report + Risk Assessment.
Output: Monetization Report.
"""

from dotenv import load_dotenv

from factory.market_strategy.config import get_fallback_model
from factory.pre_production.tools.web_research import search_and_fetch

load_dotenv()

AGENT_NAME = "MonetizationArchitect"


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
    queries = [
        f"{genre} mobile game ARPU conversion rate benchmark 2025",
        f"battle pass pricing mobile games best practices",
        f"rewarded ads eCPM mobile games {genre} 2025",
        f"mobile game in-app purchase price points psychology",
        f"free to play mobile game revenue model comparison 2025",
    ]
    return queries[:5]


def run(concept_brief: str, audience_profile: str, competitive_report: str, risk_assessment: str) -> str:
    """Design monetization model and revenue projection."""
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
    prompt = f"""Du bist ein Monetarisierungs-Architekt für Mobile Apps und Games.

## Concept Brief
{concept_brief}

## Zielgruppen-Profil
{audience_profile}

## Competitive-Report (Wettbewerber)
{competitive_report}

## Risk-Assessment (Phase 1)
{risk_assessment}

## Web-Recherche-Ergebnisse
{research_context}

Erstelle einen Monetarisierungs-Report im folgenden Format:

# Monetarisierungs-Report: {app_name}

## Modell-Analyse
### Modell 1: Free-to-Play + IAP
  - Benchmarks: ARPU ..., Conversion ...%, Retention-Impact ...
  - Bewertung für dieses Konzept: ...
  - Quellen: ...
### Modell 2: Abo/Subscription
  - ...
### Modell 3: Hybrid (Ads + Battle Pass + IAP)
  - ...

## Wettbewerber-Monetarisierung
  | App | Modell | Geschätzte Revenue | Preispunkte |
  |---|---|---|---|

## Empfohlenes Modell
  - Modell: ...
  - Begründung: ...

## Preispunkte
  - IAP Pakete: ... (z.B. 0,99€ / 4,99€ / 9,99€ / 19,99€)
  - Battle Pass: ... pro Season
  - Abo: ... pro Monat (falls zutreffend)
  - Begründung Preisgestaltung: ...

## In-Game Economy
  - Virtuelle Währung: ja/nein
  - Name der Währung: ...
  - Umrechnungskurs: 1€ = ... Einheiten
  - Ausgabemöglichkeiten: ...
  - Verdienstmöglichkeiten (ohne Echtgeld): ...
  - Ausbaustufen / Progression: ...

## Rewarded Ads Strategie
  - Platzierung: ...
  - Frequenz: max ... pro Session
  - Belohnung pro Ad: ...
  - Geschätzter eCPM: ...

## Legal-Kompatibilität
  - Konflikte mit Phase 1 Ergebnissen: ja/nein
  - Falls ja — Anpassungen: ...

## Revenue-Prognose
  | Szenario | Monatliche Nutzer | Conversion | ARPU | Monatlicher Umsatz |
  |---|---|---|---|---|
  | Pessimistisch | ... | ...% | ...€ | ...€ |
  | Realistisch | ... | ...% | ...€ | ...€ |
  | Optimistisch | ... | ...% | ...€ | ...€ |

## Quellen

REGELN:
- Konkrete Preispunkte in Euro definieren
- Revenue-Prognose mit 3 Szenarien (pessimistisch, realistisch, optimistisch)
- Alle Zahlen mit Quellen oder "geschätzt basierend auf Branchendurchschnitt" markieren
- Legal-Kompatibilität mit Phase-1-Ergebnissen explizit prüfen
- In-Game Economy konkret designen (nicht nur "könnte man machen")"""

    print(f"[{AGENT_NAME}] Generating Monetization Report...")
    return _call_llm(prompt, max_tokens=6000, agent_name=AGENT_NAME, profile="standard")


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
