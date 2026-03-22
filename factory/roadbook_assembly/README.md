# Roadbook Assembly (Kapitel 6) — Finales Kapitel

## Zweck
Kompiliert ALLES aus Kapitel 1-5 in zwei finale Dokumente:
1. **CEO Strategic Roadbook** (15-25 Seiten)
2. **Creative Director Technical Roadbook** (30-50 Seiten)

## Multi-Provider Integration
Erstes Kapitel das TheBrain `model_provider` nutzt statt hardcoded Anthropic-Calls.
Gemini 2.5 Flash (1M Context, 65k Output) ist der bevorzugte Provider fuer die 200k+ Input-Menge.

## Agents
| # | Agent | Zielgruppe | Modell |
|---|---|---|---|
| 22 | CEO-Roadbook | CEO, Investoren | via TheBrain (Gemini Flash bevorzugt) |
| 23 | CD-Roadbook | Creative Director, Lines | via TheBrain (Gemini Flash bevorzugt) |

## Flow
```
20 Reports aus 5 Kapiteln -> [Agent 22 + Agent 23 parallel] -> 2 Roadbooks
```

## Status
- [x] Step 1: Scaffold + Config + Input-Loader + Multi-Provider
- [ ] Step 2: CEO-Roadbook (Agent 22)
- [ ] Step 3: CD-Roadbook (Agent 23)
- [ ] Step 4: Pipeline-Runner
- [ ] Step 5: Document Secretary PDFs
- [ ] Step 6: EchoMatch E2E-Test
