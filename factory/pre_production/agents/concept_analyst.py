"""Concept-Analyst — Phase 1 Pre-Production Pipeline

Role: Synthesizes CEO idea with all research reports into final Concept Brief.
Input: CEO idea + Trend + Competitive + Audience reports.
Output: Concept Brief (Markdown).
"""

import anthropic
from dotenv import load_dotenv

from factory.pre_production.config import AGENT_MODEL_MAP

load_dotenv()

AGENT_NAME = "ConceptAnalyst"


def run(ceo_idea: str, trend_report: str, competitive_report: str, audience_profile: str) -> str:
    """Synthesize CEO idea with research data into a Concept Brief."""
    # Extract app name from idea
    app_name = ceo_idea.split("–")[0].strip() if "–" in ceo_idea else "App-Idee"

    prompt = f"""Du bist der Concept-Analyst der DriveAI Swarm Factory. Deine Aufgabe ist es, die rohe CEO-Idee mit den Recherche-Ergebnissen abzugleichen und einen finalen Concept Brief zu erstellen.

## CEO-Idee (Original)
{ceo_idea}

## Trend-Report (Agent 1)
{trend_report}

## Competitive-Report (Agent 2)
{competitive_report}

## Zielgruppen-Profil (Agent 3)
{audience_profile}

---

Erstelle den finalen Concept Brief. Gleiche JEDEN Punkt der CEO-Idee gegen die Recherche-Daten ab:
- Wo die Idee mit den Trends übereinstimmt: bestätigen und mit Daten begründen
- Wo die Idee gegen die Daten läuft: Anpassung vorschlagen und begründen warum
- Wo die Idee eine Lücke im Markt trifft: als Stärke hervorheben

Format:

# Concept Brief: {app_name}

## One-Liner
(Ein Satz der das Produkt beschreibt)

## Kern-Mechanik & Core Loop
- Beschreibung: ...
- Begründung (Daten): ...
- Was passiert in den ersten 60 Sekunden: ...

## Zielgruppe
- Profil: ...
- Begründung (Daten): ...

## Differenzierung zum Wettbewerb
- Direkte Vergleiche: ...
- Unique Selling Points: ...

## Monetarisierung
- Modell: ...
- Begründung (Daten): ...
- Erwartete Einnahmen-Aufteilung: ...

## Session-Design
- Ziel-Dauer: ...
- Frequenz: ...
- Begründung: ...

## Tech-Stack Tendenz
- Empfehlung: ...
- Begründung: ...

## Abweichungen von der CEO-Idee
(Für jedes Feld wo die Recherche eine Anpassung nahelegt:)
- [Feld]: Ursprünglich → Angepasst, weil [Daten-Begründung]

## Stärken des Konzepts (datenbasiert)
(Top 3 Stärken die durch die Recherche bestätigt wurden)

## Risiken und offene Fragen
(Was die Recherche nicht klären konnte oder wo Unsicherheit besteht)

REGELN:
- Jede Aussage muss durch Daten aus den Reports gestützt sein
- Keine generischen Empfehlungen — nur was die Daten hergeben
- Wenn Reports sich widersprechen: beide Seiten nennen und deine Einschätzung geben
- Abweichungen von der CEO-Idee klar und respektvoll kommunizieren
- Der CEO trifft die finale Entscheidung — du lieferst die Grundlage"""

    print(f"[{AGENT_NAME}] Synthesizing Concept Brief from 3 research reports...")
    client = anthropic.Anthropic()
    response = client.messages.create(
        model=AGENT_MODEL_MAP["concept_analyst"],
        max_tokens=6000,
        messages=[{"role": "user", "content": prompt}],
    )
    return response.content[0].text
