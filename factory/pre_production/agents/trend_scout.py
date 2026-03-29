"""Trend-Scout — Phase 1 Pre-Production Pipeline

Role: Researches current market and technology trends relevant to the CEO idea.
Input: CEO idea + learnings briefing.
Output: Structured Trend-Report (Markdown).
"""

from dotenv import load_dotenv

from factory.pre_production.agents._keywords import extract_keywords
from factory.pre_production.config import get_fallback_model
from factory.pre_production.tools.web_research import search_and_fetch

load_dotenv()

AGENT_NAME = "TrendScout"


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


def _build_queries(kw: dict) -> list[str]:
    """Build search queries from extracted keywords."""
    genre = kw["genre"]
    mechanics = kw["mechanics"]
    queries = [
        f"{genre} mobile game trends 2025 2026",
        f"mobile gaming revenue trends 2026",
    ]
    if mechanics:
        queries.append(f"{mechanics[0]} games market growth")
    if len(mechanics) > 1:
        queries.append(f"{mechanics[1]} engagement retention mobile")
    # Ensure at least 3 queries
    if len(queries) < 3:
        queries.append(f"{genre} app store trends downloads 2025")
    return queries[:4]


def run(ceo_idea: str, learnings: str = "") -> str:
    """Execute Trend-Scout and return a Markdown report."""
    kw = extract_keywords(ceo_idea)

    # 1. Web research
    queries = _build_queries(kw)
    all_results = []
    for q in queries:
        print(f"[{AGENT_NAME}] Searching: {q}")
        data = search_and_fetch(q, num_results=3, fetch_top_n=1)
        all_results.append(data)

    # 2. Compile research context
    research_context = _compile_context(all_results)

    # 3. Call Claude
    prompt = f"""Du bist ein Trend-Research-Analyst für Mobile Apps und Games.

CEO-Idee: {ceo_idea}

Bisherige Learnings: {learnings if learnings else "Keine bisherigen Learnings."}

Web-Recherche-Ergebnisse:
{research_context}

Erstelle einen strukturierten Trend-Report im folgenden Format:

# Trend-Report: {kw['raw_idea'].split('–')[0].strip() if '–' in kw['raw_idea'] else 'App-Idee'}
## Suchfelder (extrahiert aus CEO-Idee)
## Trend 1: [Name]
  - Status: wachsend / stagnierend / rückläufig
  - Daten: ...
  - Quellen: ...
## Trend 2: [Name]
  ...
(mindestens 3 Trends)

## Zusammenfassung

REGELN:
- Nur Fakten und Daten, keine Bewertungen oder Empfehlungen
- Quellen und Datum immer angeben
- Wenn Daten fehlen oder unklar sind: explizit markieren
- Fokus auf die Mechaniken und Features der CEO-Idee"""

    print(f"[{AGENT_NAME}] Generating report...")
    return _call_llm(prompt, max_tokens=4000, agent_name=AGENT_NAME, profile="standard")


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
