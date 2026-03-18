# 075 Adaptive Selection — Ergebnis

**Datum**: 2026-03-18
**Ausgefuehrt von**: Claude Code (Mac, Xcode 26.3)

## 1. Selection Strategy — BEREITS IMPLEMENTIERT

TrainingSessionViewModel hat schon adaptive Selektion:

```
.adaptive SessionType:
  1. competenceService.dueTopics()        — fällige Topics (Spacing)
  2. competenceService.weakestTopics()     — schwächste Topics
  3. competenceService.leastCoveredTopics() — am wenigsten geübte Topics
  4. TopicArea.allCases                    — Fallback
```

`buildQuestionQueue()` iteriert über priorisierte Topics und holt Fragen pro Topic via `questionBank.randomQuestion(for: topic)`.

Bei `.weaknessFocus`:
```
  1. weakestTopics()       — schwächste zuerst
  2. leastCoveredTopics()  — dann ungeübte
  3. dueTopics()           — dann fällige
```

## 2. Implementation Summary

**Kein neuer Code nötig.** Die Factory hat die adaptive Selektion bereits in TrainingSessionViewModel implementiert:
- `resolvedTopics()` — priorisiert Topics nach SessionType
- `prioritisedTopics(tiers:)` — merged Tier-Listen ohne Duplikate
- `buildQuestionQueue()` — baut Queue aus priorisierten Topics, mit Dedup

## 3. Behavior Validation

- **Schwache Topics erscheinen zuerst**: Ja (Tier 1 bei .weaknessFocus = weakestTopics)
- **Adaptive Topics**: Due → Weak → LeastCovered → All
- **Kein Bias**: Alle Topics können vorkommen (Fallback auf allCases)
- **Dedup**: Keine doppelten Fragen (seenTexts Set)

## 4. Build: SUCCEEDED (keine Änderung)

## 5. Next Step

Runtime-Validierung der echten Fragen im Simulator.
