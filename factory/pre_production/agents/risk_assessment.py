"""Risk-Assessment — Phase 1 Pre-Production Pipeline

Role: Evaluates risks, estimates costs, provides decision basis for CEO Gate.
Input: Concept Brief + Legal-Report.
Output: Risk-Assessment-Report (Markdown).
"""

import anthropic
from dotenv import load_dotenv

from factory.pre_production.config import AGENT_MODEL_MAP

load_dotenv()

AGENT_NAME = "RiskAssessment"


def _extract_app_name(concept_brief: str) -> str:
    """Extract app name from concept brief header."""
    for line in concept_brief.splitlines():
        if line.startswith("# ") and ":" in line:
            return line.split(":", 1)[1].strip()
    return "App"


def run(concept_brief: str, legal_report: str) -> str:
    """Create risk assessment based on Concept Brief and Legal Report."""
    app_name = _extract_app_name(concept_brief)

    prompt = f"""Du bist der Risk-Assessment-Spezialist der DriveAI Swarm Factory. Du bewertest Risiken, schätzt Kosten und lieferst die Entscheidungsgrundlage für das CEO-Gate.

## Concept Brief
{concept_brief}

## Legal-Research-Report
{legal_report}

Erstelle den Risk-Assessment-Report im folgenden Format:

# Risk-Assessment-Report: {app_name}

## Risiko-Übersicht (Ampel-Tabelle)
| Rechtsfeld | Risiko | Geschätzte Kosten | Zeitaufwand |
|---|---|---|---|
| [Feld] | 🟢/🟡/🔴 | €X / — | X Wochen / — |

## Detailbewertung pro Feld
### 1. [Feld]
- Risiko: 🟢/🟡/🔴
- Begründung: ...
- Geschätzte Kosten: ...
- Alternative (falls 🟡/🔴): ...

## Regionale Einschränkungen
- [Land]: Nicht launchbar / eingeschränkt weil ...

## Gesamtkosten-Schätzung Compliance
- Einmalig: €...
- Laufend (pro Jahr): €...

## Zeitaufwand gesamt
- Geschätzt: ... Wochen

## Gesamtrisiko-Bewertung
🟢/🟡/🔴 — Begründung: ...

## CEO-Entscheidungsgrundlage
### Bei GO:
- Diese Maßnahmen sind vor Launch nötig: ...
- Geschätzte Gesamtkosten: ...
- Geschätzter Zeitrahmen: ...

### Bei KILL:
- Hauptgründe die gegen das Projekt sprechen: ...

### Empfehlung
(Klare Empfehlung: GO / GO mit Auflagen / KILL)
Begründung: ...

## Hinweis
Dieser Report ist eine KI-basierte Ersteinschätzung und ersetzt keine rechtsverbindliche Beratung.

REGELN:
- Für jedes Feld im Legal-Report eine Ampel-Bewertung geben
- Bei 🟡 und 🔴: konkrete Kosten schätzen (Anwaltskosten, Zertifizierungen, Lizenzen)
- Bei 🔴: immer eine Alternative vorschlagen die das Risiko reduziert
- Kosten in Euro, realistische Schätzungen für den DACH-Markt
- Die CEO-Entscheidungsgrundlage muss BEIDE Optionen fair darstellen
- Klare Empfehlung am Ende — der CEO will eine Meinung, nicht nur Daten"""

    print(f"[{AGENT_NAME}] Analyzing risks and generating assessment...")
    client = anthropic.Anthropic()
    response = client.messages.create(
        model=AGENT_MODEL_MAP["risk_assessment"],
        max_tokens=5000,
        messages=[{"role": "user", "content": prompt}],
    )
    return response.content[0].text
