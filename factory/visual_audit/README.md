# Visual & Asset Audit Pipeline (Kapitel 5)

## Zweck
Qualitaets-Gate fuer visuelle Vollstaendigkeit. Verhindert den "Fahrschul-App-Fehler":
KI generiert Text wo der Nutzer ein Bild erwartet.

## Agents
| # | Agent | Aufgabe | Web-Recherche | Modell |
|---|---|---|---|---|
| 17 | Asset-Discovery | Jedes visuelle Element identifizieren | Nein | Sonnet |
| 18 | Asset-Strategie | Beschaffung, Kosten, Stil-Guide, Formate | Ja | Sonnet |
| 19 | Visual-Consistency | Ampel-Bewertung, KI-Warnungen, Platzhalter, A11Y | Nein | Sonnet |
| 20 | Review-Assistant | Interaktiver Feedback-Agent | Nein | Sonnet |

## Flow
```
14 Reports -> Agent 17 -> Agent 18 -> Agent 19 -> Human Review Gate (+ Agent 20 bei Bedarf)
```

## MasterLead-Ergaenzungen (eingearbeitet)
1. Plattform-spezifische Asset-Varianten (iOS/Android/Web)
2. Dark Mode / Light Mode Check
3. Accessibility-Assets (Kontrast, Touch-Targets, VoiceOver)
4. Animations-Performance-Constraints
5. Platzhalter-Erkennung (automatisch rot)
6. Asset-Uebergabe-Protokoll (Repo-Pfade)

## Menschliche Eingriffspunkte der gesamten Pipeline
1. CEO-Gate nach Phase 1 (Kill or Go)
2. **Human Review Gate nach Kapitel 5 (Visual Audit)** <-- hier

## Usage
```bash
python -m factory.visual_audit.pipeline --latest
python -m factory.visual_audit.pipeline --p1-dir factory/pre_production/output/003_echomatch --k3-dir factory/market_strategy/output/001_echomatch --k4-dir factory/mvp_scope/output/001_echomatch
```

## Status
- [x] Step 1: Scaffold + Config + Input-Loader
- [ ] Step 2: Asset-Discovery (Agent 17)
- [ ] Step 3: Asset-Strategie (Agent 18)
- [ ] Step 4: Visual-Consistency (Agent 19)
- [ ] Step 5: Pipeline-Runner
- [ ] Step 6: Human Review Gate
- [ ] Step 7: Review-Assistant (Agent 20)
- [ ] Step 8: Document Secretary PDFs
- [ ] Step 9: EchoMatch End-to-End-Test
