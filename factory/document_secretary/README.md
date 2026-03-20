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
| Alle | `all` | Generiert alle 6 Dokumente auf einmal | Phase 1 + 2 |

## Usage

```bash
# CEO Briefing Phase 1
python -m factory.document_secretary.secretary --type ceo-p1 --run-dir factory/pre_production/output/003_echomatch

# CEO Briefing Phase 2
python -m factory.document_secretary.secretary --type ceo-p2 --run-dir factory/market_strategy/output/001_echomatch

# Marketing Konzept
python -m factory.document_secretary.secretary --type marketing --p1-dir factory/pre_production/output/003_echomatch --p2-dir factory/market_strategy/output/001_echomatch

# Investor Summary
python -m factory.document_secretary.secretary --type investor --p1-dir ... --p2-dir ...

# Tech Brief
python -m factory.document_secretary.secretary --type tech-brief --p1-dir ... --p2-dir ...

# Legal Summary
python -m factory.document_secretary.secretary --type legal --p1-dir ... --p2-dir ...

# ALLE 6 Dokumente
python -m factory.document_secretary.secretary --type all --p1-dir ... --p2-dir ...

# Mit E-Mail-Versand
python -m factory.document_secretary.secretary --type all --p1-dir ... --p2-dir ... --send-email
```

## Output
PDF-Dokumente in `factory/document_secretary/output/`.

## E-Mail
Nutzt SMTP-Konfiguration aus `.env` (BRIEFING_SMTP_* Variablen).
