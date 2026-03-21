# Document Secretary (Agent 13)

## Zweck
Transformiert rohe Agent-Reports in professionelle PDF-Dokumente fuer verschiedene Zielgruppen.
HTML/CSS Design -> PDF via Playwright (Chromium).

## Dokument-Typen

| Typ | CLI | Beschreibung | Input |
|---|---|---|---|
| CEO Briefing P1 | `ceo-p1` | Executive Summary Phase 1 | Phase-1 Output |
| CEO Briefing P2 | `ceo-p2` | Executive Summary Phase 2 | Phase-2 Output |
| Marketing-Konzept | `marketing` | Vollstaendiges Dokument fuer Marketing-Agentur | Phase 1 + 2 |
| Investor Summary | `investor` | Investment Pitch fuer potenzielle Investoren | Phase 1 + 2 |
| Tech Brief | `tech-brief` | Technische Architektur fuer Entwicklungsteam | Phase 1 + 2 |
| Legal Summary | `legal` | Compliance-Zusammenfassung fuer Rechtsberatung | Phase 1 + 2 |
| Feature-Liste | `features` | Alle Features mit Tech-Stack-Check | Kapitel 4 |
| MVP Scope | `mvp-scope` | Phase A/B Priorisierung + Budget | Kapitel 4 |
| Screen-Architektur | `screens` | Screens, Flows, Edge Cases | Kapitel 4 |
| Alle | `all` | Generiert alle 9 Dokumente auf einmal | Phase 1 + 2 + K4 |

## Usage

```bash
# Phase 1 + 2 Dokumente
python -m factory.document_secretary.secretary --type ceo-p1 --run-dir factory/pre_production/output/003_echomatch
python -m factory.document_secretary.secretary --type ceo-p2 --run-dir factory/market_strategy/output/001_echomatch
python -m factory.document_secretary.secretary --type marketing --p1-dir ... --p2-dir ...
python -m factory.document_secretary.secretary --type investor --p1-dir ... --p2-dir ...
python -m factory.document_secretary.secretary --type tech-brief --p1-dir ... --p2-dir ...
python -m factory.document_secretary.secretary --type legal --p1-dir ... --p2-dir ...

# Kapitel 4 Dokumente
python -m factory.document_secretary.secretary --type features --k4-dir factory/mvp_scope/output/001_echomatch
python -m factory.document_secretary.secretary --type mvp-scope --k4-dir factory/mvp_scope/output/001_echomatch
python -m factory.document_secretary.secretary --type screens --k4-dir factory/mvp_scope/output/001_echomatch

# ALLE 9 Dokumente
python -m factory.document_secretary.secretary --type all --p1-dir ... --p2-dir ... --k4-dir ...

# Mit E-Mail-Versand
python -m factory.document_secretary.secretary --type all --p1-dir ... --p2-dir ... --k4-dir ... --send-email
```

## Output
PDF-Dokumente in `factory/document_secretary/output/`.

## E-Mail
Nutzt SMTP-Konfiguration aus `.env` (BRIEFING_SMTP_* Variablen).
