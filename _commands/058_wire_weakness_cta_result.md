# 058 Wire Schwaechen-Trainieren CTA — Ergebnis

**Datum**: 2026-03-17
**Ausgefuehrt von**: Claude Code (Mac, Xcode 26.3)

## Aenderungen

1. **SimulationResultView**: `onTrainWeaknesses` Optional Callback hinzugefuegt
   - "Schwaechen trainieren" Button: `onTrainWeaknesses?()` falls gesetzt, sonst `onDismiss()`
2. **ExamSimulationView**: `@State showWeaknessTraining` + fullScreenCover
   - Uebergibt `onTrainWeaknesses: { showWeaknessTraining = true }` an SimulationResultView
   - fullScreenCover zeigt TrainingSessionView(.weaknessFocus)

## Wiring

```
SimulationResultView "Schwächen trainieren" Button
  → onTrainWeaknesses()
  → ExamSimulationView.showWeaknessTraining = true
  → fullScreenCover: TrainingSessionView(.weaknessFocus)
```

## Build: SUCCEEDED

## Andere CTAs bewahrt
- "Alle Antworten ansehen": Unveraendert (Sheet)
- "Nochmal simulieren": Unveraendert (onRetry)
- "Fertig": Unveraendert (onDismiss)
