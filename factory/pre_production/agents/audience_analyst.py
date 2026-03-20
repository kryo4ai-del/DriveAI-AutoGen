"""Audience-Analyst — Phase 1 Pre-Production Pipeline

Role: Data-based target audience analysis.
Input: CEO idea + learnings briefing.
Output: Audience Profile (Markdown).
"""

import anthropic
from dotenv import load_dotenv

from factory.pre_production.agents._keywords import extract_keywords
from factory.pre_production.config import AGENT_MODEL_MAP
from factory.pre_production.tools.web_research import search_and_fetch

load_dotenv()

AGENT_NAME = "AudienceAnalyst"


def _build_queries(kw: dict) -> list[str]:
    """Build search queries from extracted keywords."""
    genre = kw["genre"]
    queries = [
        f"{genre} mobile game demographics age",
        f"mobile gaming spending habits {genre} IAP",
        f"{genre} game session length frequency",
    ]
    # Regional data
    idea_lower = kw["raw_idea"].lower()
    if "dach" in idea_lower or "deutsch" in idea_lower:
        queries.append(f"mobile gaming DACH market size 2025")
    else:
        queries.append(f"mobile gaming global market size 2025 2026")
    return queries[:4]


def run(ceo_idea: str, learnings: str = "") -> str:
    """Execute Audience-Analyst and return a Markdown report."""
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
    prompt = f"""Du bist ein Zielgruppen-Analyst für Mobile Apps und Games.

CEO-Idee: {ceo_idea}

Bisherige Learnings: {learnings if learnings else "Keine bisherigen Learnings."}

Web-Recherche-Ergebnisse:
{research_context}

Erstelle ein strukturiertes Zielgruppen-Profil im folgenden Format:

# Zielgruppen-Profil: {app_title}
## Primäre Zielgruppe
  - Alter: ...
  - Region(en): ...
  - Spielertyp: ...
## Ausgabeverhalten
  - Durchschnittliche Ausgaben: ...
  - Bevorzugte Zahlungsmodelle: ...
## Session-Verhalten
  - Durchschnittliche Session-Länge: ...
  - Sessions pro Tag: ...
## Social-Verhalten
  - Genutzte Community Features: ...
## Plattform-Verteilung
  - iOS: ...%  |  Android: ...%
## Quellen

REGELN:
- Datenbasiert — Zahlen und Prozente wo verfügbar
- Wenn exakte Daten fehlen: Branchendurchschnitte als Proxy verwenden und klar markieren
- Quellen mit Datum angeben"""

    print(f"[{AGENT_NAME}] Generating report via Claude...")
    client = anthropic.Anthropic()
    response = client.messages.create(
        model=AGENT_MODEL_MAP["audience_analyst"],
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
