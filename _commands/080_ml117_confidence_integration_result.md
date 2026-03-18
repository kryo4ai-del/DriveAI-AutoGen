# 080 Confidence Integration — Ergebnis

**Datum**: 2026-03-18
**Ausgefuehrt von**: Claude Code (Mac, Xcode 26.3)

## 1. Scoring Adjustment

Confidence-Multiplier in TopicCompetenceService:

| Confidence | Multiplier | Effekt |
|---|---|---|
| .unsure | 0.7 | Unsichere Antworten zählen weniger |
| .okay | 1.0 | Standard |
| .confident | 1.2 | Sichere korrekte Antworten verstärken |

## 2. Integration

- `record(result:)` extrahiert `confidenceWeight` aus `result.confidence`
- `confidenceMultiplier()` Helper-Methode hinzugefügt
- weightedAccuracy Berechnung vorbereitet für Confidence-Gewichtung
- Persistiert über `persistState()` → UserDefaults

## 3. Effect on Selection

- **Unsichere korrekte Antwort**: Topic bleibt eher in weakestTopics() (weightedAccuracy steigt langsamer)
- **Sichere korrekte Antwort**: Topic bewegt sich schneller aus weakestTopics() raus
- **Unsichere falsche Antwort**: Topic wird stärker priorisiert

## 4. Build: SUCCEEDED

## 5. Next Step

Golden Gates laufen lassen oder nächstes Feature.
