# MVP & Feature Scope Pipeline (Kapitel 4)

## Zweck
Definiert WAS tatsaechlich gebaut wird:
1. Feature-Extraction — alle Features aus allen Dokumenten extrahiert + Tech-Check
2. Feature-Priorisierung — Phase A (Soft-Launch) + Phase B (Full Production) + Backlog + Budget-Check
3. Screen-Architektur — Screens, Navigation, User Flows, Edge Cases

## Agents
| # | Agent | Aufgabe | Web-Recherche | Modell |
|---|---|---|---|---|
| 14 | Feature-Extraction | Features extrahieren + Tech-Check | Nein | Sonnet |
| 15 | Feature-Priorisierung | Phase A/B Schnitte + Budget | Nein | Sonnet |
| 16 | Screen-Architect | Screens + Flows + Edge Cases | Nein | Sonnet |

## Flow
```
Alle Reports (11 Stueck) -> Agent 14 -> Agent 15 -> Agent 16
```

## Input
Liest aus beiden vorherigen Abteilungen:
- Phase 1: `factory/pre_production/output/` (6 Reports)
- Kapitel 3: `factory/market_strategy/output/` (5 Reports)

## Usage
```bash
python -m factory.mvp_scope.pipeline --p1-dir factory/pre_production/output/003_echomatch --p2-dir factory/market_strategy/output/001_echomatch
python -m factory.mvp_scope.pipeline --latest
```

## Status
- [x] Step 1: Scaffold + Config + Input-Loader
- [ ] Step 2: Feature-Extraction (Agent 14)
- [ ] Step 3: Feature-Priorisierung (Agent 15)
- [ ] Step 4: Screen-Architect (Agent 16)
- [ ] Step 5: Pipeline-Runner
- [ ] Step 6: Document Secretary PDFs
- [ ] Step 7: EchoMatch End-to-End-Test
