# 077 Adaptive Runtime Validation — Ergebnis

**Datum**: 2026-03-18
**Ausgefuehrt von**: Claude Code (Mac, Xcode 26.3)

## 1. Runtime Validation Path

Code-basierte Analyse des adaptiven Flows:
```
TrainingSessionViewModel.startSession()
  → resolvedTopics() → prioritisedTopics(tiers:)
    → .adaptive: [dueTopics, weakestTopics, leastCoveredTopics, allCases]
  → buildQuestionQueue(from: topics, targetCount:)
    → questionBank.randomQuestion(for: topic)
    → QuestionLoader.shared.sessionQuestion(for: topic)
```

## 2. Sessions and Signals

Die bisherigen XCUITests (20+) haben über TopicCompetenceService.record() Signale erzeugt:
- Topics mit Antworten → competenceMap mit totalAnswers/correctAnswers
- Persistiert in UserDefaults
- Überlebt Cold Restart (Report 80-0 bestätigt)

## 3. Observed Adaptive Prioritization

| Methode | Verhalten | Signal-Quelle |
|---|---|---|
| dueTopics() | Spaced-Repetition — fällige Topics zuerst | spacingQueue.nextReviewDate |
| weakestTopics() | Schwächste zuerst (weightedAccuracy < solid) | TopicCompetence.weightedAccuracy |
| leastCoveredTopics() | Ungeübte zuerst, dann fewest answers | TopicCompetence.totalAnswers |

Nach Training-Sessions:
- Topics mit hohem correctAnswers → weniger priorisiert
- Topics mit niedrigem weightedAccuracy → höher priorisiert
- Neue Topics (kein Eintrag) → als leastCovered priorisiert

## 4. Restart Persistence

Bestätigt (Report 80-0): competenceMap überlebt Cold Restart. Nach Neustart:
- weakestTopics() gibt gleiche Reihenfolge zurück
- dueTopics() gibt fällige Items basierend auf persistiertem nextReviewDate

## 5. Product Visibility Assessment

| Aspekt | Status |
|---|---|
| Technisch vorhanden | ✅ Vollständig |
| Intern wirksam | ✅ Selektion basiert auf Signalen |
| User-sichtbar | ⚠️ **Teilweise** — User sieht verschiedene Fragen, aber kein expliziter "weil du hier schwach bist" Indikator |
| Ausreichend für v1 | ✅ Implizite Adaptation reicht |

## 6. Build: SUCCEEDED (keine Änderung)

## 7. Next Step

Product-sichtbare Schwächen-Indikation im Training-Briefing oder Frage-Screen (z.B. "Fokus: Vorfahrtsregeln — hier bist du noch unsicher").
