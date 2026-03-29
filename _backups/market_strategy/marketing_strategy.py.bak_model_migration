"""Marketing-Strategy — Phase 2 Market Strategy Pipeline

Role: Develops complete marketing concept from pre-launch to post-launch.
Input: Concept Brief + Audience Profile + Platform Strategy + Monetization Report.
Output: Marketing Strategy Report.
"""

from dotenv import load_dotenv

from factory.pre_production.tools.web_research import search_and_fetch

load_dotenv()

AGENT_NAME = "MarketingStrategy"


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
    brief_lower = concept_brief.lower()
    genres = [
        "puzzle", "match-3", "casual", "hybrid-casual", "rpg", "strategy",
        "simulation", "racing", "shooter", "adventure", "idle",
    ]
    return next((g for g in genres if g in brief_lower), "mobile game")


def _build_queries(concept_brief: str, platform_strategy: str) -> list[str]:
    genre = _detect_genre(concept_brief)
    platform = "iOS" if "ios" in platform_strategy.lower() else "mobile"
    queries = [
        f"{genre} mobile game marketing strategy launch 2025",
        f"mobile game user acquisition cost CPI {platform} 2025",
        f"app store optimization ASO {genre} games keywords",
        f"mobile game influencer marketing cost micro macro 2025",
        f"indie game launch marketing budget pre-launch strategy",
    ]
    return queries[:5]


def run(concept_brief: str, audience_profile: str, platform_strategy: str, monetization_report: str) -> str:
    """Develop marketing strategy from pre-launch to post-launch."""
    # 1. Web research
    queries = _build_queries(concept_brief, platform_strategy)
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
    prompt = f"""Du bist ein Marketing-Stratege für Mobile Apps und Games.

## Concept Brief
{concept_brief}

## Zielgruppen-Profil
{audience_profile}

## Plattform-Strategie (Agent 8)
{platform_strategy}

## Monetarisierungs-Report (Agent 9)
{monetization_report}

## Web-Recherche-Ergebnisse
{research_context}

Erstelle einen Marketing-Strategie-Report im folgenden Format:

# Marketing-Strategie-Report: {app_name}

## Marketing-Kanal-Analyse
  - Effektivste Kanäle für Zielgruppe: ...
  - Benchmark: Was machen erfolgreiche Wettbewerber: ...
  - Quellen: ...

## Website-Entscheidung
  - Empfehlung: ja/nein
  - Typ: Landing Page / Full Site / Community-Hub
  - Begründung: ...
  - Geschätzte Kosten: ...

## Pre-Launch Strategie
### Landing Page & Waitlist
  - Empfehlung: ...
  - Features: ...
### Social Media Teaser
  - Plattformen: ...
  - Content-Typen: ...
  - Timeline: ... Wochen vor Launch
### Beta-Programm
  - Typ: geschlossen / offen / TestFlight
  - Ziel-Teilnehmerzahl: ...
  - Dauer: ...
### Press Kit
  - Inhalte: ...

## Launch-Strategie
### Launch-Typ
  - Empfehlung: Soft Launch / Global Launch
  - Soft Launch Regionen: ... (falls zutreffend)
  - Begründung: ...
### Launch-Tag Plan
  - Aktivitäten: ...
### PR & Presse
  - Ziel-Outlets: ...
  - Pitch-Ansatz: ...

## App Store Optimization (ASO)
  - Primäre Keywords: ...
  - Sekundäre Keywords: ...
  - Screenshot-Strategie: ...
  - Preview-Video: ja/nein
  - Bewertungs-Prompt Timing: ...

## Social Media Strategie
  | Kanal | Content-Typ | Frequenz | Ziel |
  |---|---|---|---|
  | TikTok | ... | ... | ... |
  | Instagram | ... | ... | ... |
  | YouTube | ... | ... | ... |
  | Discord | ... | ... | ... |

## Influencer-Strategie
  - Empfehlung: ja/nein
  - Tier: Micro / Mid / Macro
  - Plattform: ...
  - Geschätzte Kosten: ... pro Kooperation
  - Anzahl geplante Kooperationen: ...

## Paid User Acquisition
  | Kanal | Geschätzter CPI | Budget 30 Tage | Budget 60 Tage | Budget 90 Tage |
  |---|---|---|---|---|
  | Meta Ads | ...€ | ...€ | ...€ | ...€ |
  | Google UAC | ...€ | ...€ | ...€ | ...€ |
  | TikTok Ads | ...€ | ...€ | ...€ | ...€ |
  | Apple Search Ads | ...€ | ...€ | ...€ | ...€ |

## Post-Launch Plan
### Content-Plan Woche 1-4
  - Woche 1: ...
  - Woche 2: ...
  - Woche 3: ...
  - Woche 4: ...
### Community Management
  - Kanäle: ...
  - Response-Zeit Ziel: ...
### Retention-Marketing
  - Push Notifications: ...
  - E-Mail: ...
  - In-App Messages: ...

## Marketing-Budget Gesamt
  | Phase | Kosten |
  |---|---|
  | Pre-Launch | ...€ |
  | Launch (Tag 1-7) | ...€ |
  | Monatlich laufend | ...€ |
  | **Gesamt erstes Quartal** | **...€** |

REGELN:
- Konkrete Budgets in Euro
- CPI-Schätzungen pro Kanal mit Quellenangabe
- Influencer-Kosten realistisch für Indie-Budget
- Social Media Strategie mit konkreter Frequenz und Content-Typen
- ASO Keywords spezifisch für dieses Genre und diese Nische"""

    print(f"[{AGENT_NAME}] Generating Marketing Strategy Report...")
    return _call_llm(prompt, max_tokens=7000, agent_name=AGENT_NAME, profile="standard")


def _compile_context(all_results: list[dict]) -> str:
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
