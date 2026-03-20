"""Legal-Research — Phase 1 Pre-Production Pipeline

Role: Researches legal landscape for all relevant fields.
Input: Concept Brief.
Output: Legal-Research-Report (Markdown).
"""

import anthropic
from dotenv import load_dotenv

from factory.pre_production.config import AGENT_MODEL_MAP
from factory.pre_production.tools.web_research import search_and_fetch

load_dotenv()

AGENT_NAME = "LegalResearch"


def _build_queries(concept_brief: str) -> list[str]:
    """Build legal search queries based on concept brief content."""
    brief_lower = concept_brief.lower()
    queries = []

    # Always relevant
    queries.append("app store guidelines in-app purchase rewarded ads 2025")

    # Gambling / loot box law
    if any(kw in brief_lower for kw in ["battle pass", "iap", "lootbox", "gacha", "in-app"]):
        queries.append("mobile game loot box gambling law EU 2025")

    # AI content copyright
    if any(kw in brief_lower for kw in ["ai", "generated", "generiert", "ki"]):
        queries.append("AI generated content copyright commercial use 2025")

    # GDPR / personalization
    if any(kw in brief_lower for kw in ["personalisierung", "personalization", "tracking", "spielstil", "daten"]):
        queries.append("GDPR personalization user data mobile app 2025")

    # Youth protection / COPPA
    if any(kw in brief_lower for kw in ["kinder", "jugend", "under 18", "unter 18", "13", "coppa"]):
        queries.append("COPPA children mobile game regulations 2025")
    else:
        queries.append("mobile game youth protection USK PEGI rating 2025")

    # Trademark search — extract app name
    app_name = _extract_app_name(concept_brief)
    if app_name and app_name.lower() != "app-idee":
        queries.append(f"{app_name} trademark app name conflict")

    return queries[:6]


def _extract_app_name(concept_brief: str) -> str:
    """Extract app name from concept brief header."""
    for line in concept_brief.splitlines():
        if line.startswith("# ") and ":" in line:
            return line.split(":", 1)[1].strip()
    return ""


def run(concept_brief: str) -> str:
    """Research legal landscape based on the Concept Brief."""
    # 1. Web research
    queries = _build_queries(concept_brief)
    all_results = []
    for q in queries:
        print(f"[{AGENT_NAME}] Searching: {q}")
        data = search_and_fetch(q, num_results=3, fetch_top_n=1)
        all_results.append(data)

    # 2. Compile research context
    research_context = _compile_context(all_results)

    # 3. Extract app name
    app_name = _extract_app_name(concept_brief) or "App"

    # 4. Call Claude
    prompt = f"""Du bist ein Legal-Research-Spezialist für Mobile Apps und Games. Du lieferst eine KI-basierte Ersteinschätzung — KEINE rechtsverbindliche Beratung.

## Concept Brief
{concept_brief}

## Web-Recherche-Ergebnisse
{research_context}

Erstelle einen strukturierten Legal-Research-Report im folgenden Format:

# Legal-Research-Report: {app_name}

## Identifizierte Rechtsfelder
(Liste aller rechtlich relevanten Aspekte des Konzepts)

## 1. Monetarisierung & Glücksspielrecht
- Aktuelle Gesetzeslage: ...
- Länderspezifisch (EU, Belgien, Niederlande, USA, China): ...
- Relevanz für dieses Konzept: ...
- Quellen: ...

## 2. App Store Richtlinien
- Apple App Store: ...
- Google Play Store: ...
- Relevanz: ...

## 3. AI-generierter Content — Urheberrecht
- Aktuelle Rechtslage: ...
- Kommerzielle Nutzung: ...
- Relevanz: ...

## 4. Datenschutz (DSGVO / COPPA)
- DSGVO-Anforderungen: ...
- COPPA (falls Zielgruppe Kinder einschließt): ...
- Relevanz: ...

## 5. Jugendschutz (USK / PEGI)
- Einstufungskriterien: ...
- Erwartete Einstufung: ...

## 6. Social Features — Auflagen
- Chat / Freundeslisten bei Minderjährigen: ...
- Relevanz: ...

## 7. Markenrecht — Namenskonflikt
- Recherche-Ergebnis: ...

## 8. Patente
- Relevante bestehende Patente: ...

## Hinweis
Dieser Report ist eine KI-basierte Ersteinschätzung und ersetzt keine rechtsverbindliche Beratung. Bei 🟡 und 🔴 Feldern wird professionelle Rechtsberatung empfohlen.

REGELN:
- Länderspezifisch differenzieren wo relevant (EU, USA, China)
- Quellen mit Datum angeben
- Wo Daten fehlen oder unklar: explizit markieren
- Nur Felder behandeln die für DIESES Konzept relevant sind
- Felder die nicht zutreffen: kurz als "nicht relevant" markieren und begründen"""

    print(f"[{AGENT_NAME}] Generating Legal-Research-Report via Claude...")
    client = anthropic.Anthropic()
    response = client.messages.create(
        model=AGENT_MODEL_MAP["legal_research"],
        max_tokens=5000,
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
