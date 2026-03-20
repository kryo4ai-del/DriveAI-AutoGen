# Market Strategy Pipeline (Phase 2, Kapitel 3)

## Zweck
Nimmt den validierten Concept Brief (nach CEO-GO) und produziert:
1. Plattform-Strategie (welche Plattformen, welche Reihenfolge)
2. Monetarisierungsmodell (Preispunkte, Economy, Revenue-Prognose)
3. Marketing-Konzept (Pre-Launch bis Post-Launch)
4. Release-Plan (Timeline, Phasen, Checkliste)
5. Gesamtkalkulation (Kosten, Break-Even, Worst-Case)

## Agents
| # | Agent | Aufgabe | Web-Recherche | Modell |
|---|---|---|---|---|
| 8 | Plattform-Strategie | Plattform-Entscheidung | Ja | Sonnet |
| 9 | Monetarisierungs-Architekt | Monetarisierungsmodell | Ja | Sonnet |
| 10 | Marketing-Strategie | Marketing-Konzept | Ja | Sonnet |
| 11 | Release-Planer | Release-Plan | Nein | Sonnet |
| 12 | Kosten-Kalkulation | Gesamtrechnung | Nein | Sonnet |

## Flow
```
Phase-1-Output -> [8+9 parallel] -> [10+11 parallel] -> 12 Kalkulation
```

## Usage
```bash
# With specific Phase-1 run
python -m factory.market_strategy.pipeline --run-dir factory/pre_production/output/003_echomatch

# Auto-detect latest GO run
python -m factory.market_strategy.pipeline --latest
```

## Input
Reads from Phase 1 output directory. Requires CEO-Gate decision = GO.

## Status
- [x] Step 1: Scaffold + Config + Input-Loader
- [ ] Step 2: Platform Strategy + Monetization Architect
- [ ] Step 3: Marketing Strategy + Release Planner
- [ ] Step 4: Cost Calculation
- [ ] Step 5: Pipeline Runner
- [ ] Step 6: Memory Integration
- [ ] Step 7: EchoMatch End-to-End-Test
