# Document Secretary (Agent 13)

## Zweck
Transformiert rohe Agent-Reports in professionelle .docx-Dokumente fuer verschiedene Zielgruppen.

## Dokument-Typen

| Typ | Beschreibung | Input |
|---|---|---|
| CEO Briefing P1 | Executive Summary Phase 1 | Phase-1 Output |
| CEO Briefing P2 | Executive Summary Phase 2 | Phase-2 Output |
| Marketing-Konzept | Vollstaendiges Dokument fuer Marketing-Agentur | Phase 1 + Phase 2 Output |

## Usage

```bash
# CEO Briefing Phase 1
python -m factory.document_secretary.secretary --type ceo-p1 --run-dir factory/pre_production/output/003_echomatch

# CEO Briefing Phase 2
python -m factory.document_secretary.secretary --type ceo-p2 --run-dir factory/market_strategy/output/001_echomatch

# Marketing Konzept (braucht beide Phasen)
python -m factory.document_secretary.secretary --type marketing --p1-dir factory/pre_production/output/003_echomatch --p2-dir factory/market_strategy/output/001_echomatch

# Mit E-Mail-Versand
python -m factory.document_secretary.secretary --type ceo-p1 --run-dir ... --send-email
```

## Output
Dokumente werden gespeichert in `factory/document_secretary/output/`.

## E-Mail
Nutzt SMTP-Konfiguration aus `.env` (BRIEFING_SMTP_* Variablen).
