"""Cost-Calculation — Phase 2 Market Strategy Pipeline

Role: Calculates all costs, revenue projections and break-even analysis.
Input: All Phase 2 reports + Risk Assessment.
Output: Cost Calculation Report.
"""

import anthropic
from dotenv import load_dotenv

from factory.market_strategy.config import AGENT_MODEL_MAP

load_dotenv()

AGENT_NAME = "CostCalculation"


def run(concept_brief: str, platform_strategy: str, monetization_report: str,
        marketing_strategy: str, release_plan: str, risk_assessment: str) -> str:
    """Calculate total costs, revenue projections and break-even analysis."""
    # Extract app name
    app_name = "App"
    for line in concept_brief.splitlines():
        if line.startswith("# ") and ":" in line:
            app_name = line.split(":", 1)[1].strip()
            break

    prompt = f"""Du bist ein Finanz-Analyst und Kosten-Kalkulator für Mobile App Projekte.

Du bekommst alle strategischen Reports und musst daraus eine vollständige Gesamtkalkulation erstellen. Extrahiere alle Kosten und Revenue-Daten aus den Reports und rechne sie zusammen.

## Concept Brief
{concept_brief}

## Plattform-Strategie (Agent 8)
{platform_strategy}

## Monetarisierungs-Report (Agent 9)
{monetization_report}

## Marketing-Strategie (Agent 10)
{marketing_strategy}

## Release-Plan (Agent 11)
{release_plan}

## Risk-Assessment (Phase 1)
{risk_assessment}

Erstelle den Kosten-Kalkulations-Report:

# Kosten-Kalkulations-Report: {app_name}

## Entwicklungskosten
  | Posten | Kosten |
  |---|---|
  | Plattform 1: [aus Agent 8] | ...€ |
  | Plattform 2: [falls geplant] | ...€ |
  | AI-Integration | ...€ |
  | Backend / API | ...€ |
  | **Gesamt Entwicklung** | **...€** |

## Marketing-Budget (aus Agent 10)
  | Phase | Kosten |
  |---|---|
  | Pre-Launch | ...€ |
  | Launch | ...€ |
  | Monatlich laufend | ...€ |
  | **Gesamt Marketing Q1** | **...€** |

## Compliance-Kosten (aus Phase 1)
  | Posten | Einmalig | Laufend/Monat |
  |---|---|---|
  | [aus Risk-Assessment] | ...€ | ...€ |
  | **Gesamt Compliance** | **...€** | **...€/Monat** |

## Infrastruktur-Kosten (monatlich)
  | Posten | Kosten/Monat |
  |---|---|
  | Cloud Hosting | ...€ |
  | AI-Service API | ...€ |
  | CDN / Storage | ...€ |
  | Analytics | ...€ |
  | Crash-Reporting | ...€ |
  | Push Notifications | ...€ |
  | **Gesamt Infrastruktur** | **...€/Monat** |

## Laufende Betriebskosten (monatlich)
  | Posten | Kosten/Monat |
  |---|---|
  | Support | ...€ |
  | Content-Erstellung | ...€ |
  | App Store Gebühren | ...€ |
  | Apple/Google Revenue Share | ...% |
  | **Gesamt Betrieb** | **...€/Monat** |

## Revenue vs. Kosten (monatlich nach Launch)
  | Szenario | Einnahmen/Monat | Kosten/Monat | Ergebnis/Monat |
  |---|---|---|---|
  | Pessimistisch | ...€ | ...€ | ...€ |
  | Realistisch | ...€ | ...€ | ...€ |
  | Optimistisch | ...€ | ...€ | ...€ |

## Break-Even Analyse
  | Szenario | Break-Even Monat | Benötigte Nutzer |
  |---|---|---|
  | Pessimistisch | Monat ... | ... |
  | Realistisch | Monat ... | ... |
  | Optimistisch | Monat ... | ... |

## Gesamtbudget bis Launch
  | Posten | Kosten |
  |---|---|
  | Entwicklung | ...€ |
  | Marketing Pre-Launch | ...€ |
  | Compliance | ...€ |
  | Infrastruktur Setup | ...€ |
  | **Zwischensumme** | **...€** |
  | Puffer (25%) | ...€ |
  | **Gesamtbudget bis Launch** | **...€** |

## Monatliche Kosten nach Launch
  | Posten | Kosten/Monat |
  |---|---|
  | Infrastruktur | ...€ |
  | Betrieb | ...€ |
  | Marketing laufend | ...€ |
  | Compliance laufend | ...€ |
  | **Gesamt monatlich** | **...€** |

## Worst-Case Szenario
  - Entwicklung dauert ...% länger: Mehrkosten ...€
  - Launch verschiebt sich um ... Monate: Mehrkosten ...€
  - Revenue bleibt unter Pessimistisch: Maximaler Verlust nach 6 Monaten ...€
  - **Maximales Risiko-Exposure: ...€**

## Fazit
  - Gesamtinvestition bis Launch: ...€
  - Monatliche Kosten nach Launch: ...€
  - Break-Even (realistisch): Monat ...
  - Maximales Risiko: ...€
  - Empfehlung: ...

REGELN:
- Alle Zahlen aus den Reports extrahieren — nichts erfinden
- Wenn ein Report keine konkreten Zahlen hat: realistische Schätzung mit Markierung "geschätzt"
- Alle Beträge in Euro
- Revenue-Prognose NACH Abzug der Apple/Google Commission (15-30%)
- Break-Even = kumulierte Einnahmen >= kumulierte Kosten
- Puffer von 25% auf Gesamtkosten
- Worst-Case muss ein realistisches Verlust-Szenario zeigen
- Fazit mit klarer Empfehlung"""

    print(f"[{AGENT_NAME}] Analyzing all reports...")
    client = anthropic.Anthropic()
    response = client.messages.create(
        model=AGENT_MODEL_MAP["cost_calculation"],
        max_tokens=6000,
        messages=[{"role": "user", "content": prompt}],
    )
    return response.content[0].text
