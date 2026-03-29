"""Risk-Assessment — Phase 1 Pre-Production Pipeline

Role: Evaluates risks, estimates costs, provides decision basis for CEO Gate.
Input: Concept Brief + Legal-Report.
Output: Risk-Assessment-Report (Markdown).
"""

from dotenv import load_dotenv

load_dotenv()

AGENT_NAME = "RiskAssessment"


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
    return _call_llm(prompt, max_tokens=5000, agent_name=AGENT_NAME, profile="standard")
