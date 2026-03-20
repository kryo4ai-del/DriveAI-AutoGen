"""Competitor-Scan — Phase 1 Pre-Production Pipeline

Role: Competitive analysis and market saturation.
Input: CEO idea + learnings briefing.
Output: Competitive-Report (Markdown).
"""

import anthropic
from dotenv import load_dotenv

from factory.pre_production.agents._keywords import extract_keywords
from factory.pre_production.config import AGENT_MODEL_MAP
from factory.pre_production.tools.web_research import search_and_fetch

load_dotenv()

AGENT_NAME = "CompetitorScan"


def _build_queries(kw: dict) -> list[str]:
    """Build search queries from extracted keywords."""
    genre = kw["genre"]
    mechanics = kw["mechanics"]
    platform = kw["platforms"][0] if kw["platforms"] else "iOS"
    queries = [
        f"best {genre} games {platform} 2025 2026",
        f"{genre} games top apps revenue",
    ]
    if mechanics:
        queries.append(f"{mechanics[0]} mobile games competitors")
    monetization = kw["monetization"]
    if monetization:
        queries.append(f"{genre} games monetization {monetization[0]}")
    else:
        queries.append(f"{genre} games monetization battle pass IAP")
    return queries[:4]


def run(ceo_idea: str, learnings: str = "") -> str:
    """Execute Competitor-Scan and return a Markdown report."""
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
    app_title = kw["raw_idea"].split("–")[0].strip() if "–" in kw["raw_idea"] else "App-Idee"
    prompt = f"""Du bist ein Wettbewerbs-Analyst für den Mobile-App-Markt.

CEO-Idee: {ceo_idea}

Bisherige Learnings: {learnings if learnings else "Keine bisherigen Learnings."}

Web-Recherche-Ergebnisse:
{research_context}

Erstelle einen strukturierten Competitive-Report im folgenden Format:

# Competitive-Report: {app_title}
## Wettbewerber-Kategorie(n)
## Wettbewerber-Übersicht (Tabelle)
  | App | Publisher | Downloads | Rating | Monetarisierung | Kernmechanik |
## Detailanalyse pro Wettbewerber
  - Stärken / Schwächen / Nutzer-Beschwerden
## Feature-Vergleich (Tabelle)
## Gap-Analyse: Was fehlt im Markt
## Sättigungseinschätzung
## Datenlücken (was nicht verfügbar war)

REGELN:
- Echte Apps und echte Daten verwenden (aus den Suchergebnissen)
- Wo Downloads/Revenue nicht verfügbar: klar markieren als "nicht verfügbar"
- Fokus auf die direkte Wettbewerbs-Nische der CEO-Idee
- Klar markieren was Fakt vs. Schätzung ist"""

    print(f"[{AGENT_NAME}] Generating report via Claude...")
    client = anthropic.Anthropic()
    response = client.messages.create(
        model=AGENT_MODEL_MAP["competitor_scan"],
        max_tokens=4000,
        messages=[{"role": "user", "content": prompt}],
    )
    return response.content[0].text


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
