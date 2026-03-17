# 069 Drilldown to Training — Ergebnis

**Datum**: 2026-03-17
**Ausgefuehrt von**: Claude Code (Mac, Xcode 26.3)

## 1. What was added

Gap-Detail-Sheet in SimulationResultView mit "Jetzt üben" CTA:
- Topic-Name, Fehlerpunkte (farbcodiert), Empfehlung
- "Jetzt üben" Button → `onTrainWeaknesses?()` → TrainingSessionView(.weaknessFocus)
- "Fertig" Button zum Schließen

## 2. How training is triggered

```
Gap-Eintrag tappen → selectedGap Sheet
  → "Jetzt üben" Button
  → selectedGap = nil (Sheet schließen)
  → onTrainWeaknesses?() (ExamSimulationView fullScreenCover)
  → TrainingSessionView(.weaknessFocus)
```

Reused existierendes onTrainWeaknesses Callback (Command 058).

## 3. Build: SUCCEEDED

## 4. Next Step

Golden Gates laufen lassen oder nächstes Feature.
