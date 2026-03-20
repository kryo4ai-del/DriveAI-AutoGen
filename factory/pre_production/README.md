# Pre-Production Pipeline (Phase 1)

## Zweck
Nimmt eine rohe CEO-Idee und produziert vollautomatisch:
1. Concept Brief (datenbasiert, gegen Marktrecherche abgeglichen)
2. Legal-Report (rechtliche Lage für alle relevanten Felder)
3. Risk-Assessment (Ampel-Bewertung + Kosten + Empfehlung)

Am Ende steht das CEO-Gate: Kill or Go.

## Agents
| # | Agent | Aufgabe | Modell |
|---|---|---|---|
| 1 | Trend-Scout | Markt- und Technologie-Trends recherchieren | Sonnet |
| 2 | Competitor-Scan | Wettbewerbsanalyse und Marktsättigung | Sonnet |
| 3 | Zielgruppen-Analyst | Datenbasierte Zielgruppen-Analyse | Sonnet |
| 4 | Concept-Analyst | Synthese zum fertigen Concept Brief | Sonnet |
| 5 | Legal-Research | Rechtliche Recherche | Sonnet |
| 6 | Risk-Assessment | Risikobewertung + Empfehlung | Sonnet |
| 7 | Memory-Agent | Persistenter Wissensspeicher | Haiku |

## Flow
```
CEO-Idee → Memory-Briefing → [1+2+3 parallel] → 4 Synthese → 5 Legal → 6 Risk → CEO-Gate → Memory-Speichern
```

## Usage
```bash
# Will be available after Step 10
python -m factory.pre_production.pipeline --idea "Deine App-Idee hier"
```

## Status
- [x] Step 1: Scaffold + Config
- [ ] Step 2: Web-Research-Tool
- [ ] Step 3: Memory-Agent
- [ ] Step 4-6: Research Agents
- [ ] Step 7: Concept-Analyst
- [ ] Step 8-9: Legal + Risk
- [ ] Step 10: Pipeline-Runner
- [ ] Step 11: CEO-Gate
- [ ] Step 12: EchoMatch End-to-End-Test
