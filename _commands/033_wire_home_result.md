# 033 Wire Home Actions — Ergebnis

**Datum**: 2026-03-16
**Ausgefuehrt von**: Claude Code (Mac, Xcode 26.3)

## Vorher
- "Thema ueben": Sheet → TopicPickerView (funktional)
- "Taegliches Training": Button mit TODO
- "Schwaechen trainieren": Button mit TODO

## Nachher — 3/3 Cards funktional

| Card | Navigation | Destination | SessionType |
|---|---|---|---|
| Taegliches Training | fullScreenCover | TrainingSessionView | .adaptive |
| Thema ueben | sheet | TopicPickerView | — |
| Schwaechen trainieren | fullScreenCover | TrainingSessionView | .weaknessFocus |

## Implementierung

- `showDailyTraining` + `showWeaknessTraining` @State Booleans
- fullScreenCover mit TrainingSessionView factory closure
- TrainingSessionViewModel mit MockQuestionBank + HapticFeedback
- "Beenden" Toolbar Button zum Schliessen

## Build: SUCCEEDED
## Simulator: App laeuft, Screenshot bestaetigt
