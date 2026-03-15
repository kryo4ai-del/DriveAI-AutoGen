# 007 Combine Import-Hygiene Erweiterung — Ergebnis

**Datum**: 2026-03-15
**Ausgefuehrt von**: Claude Code (Mac, Xcode 26.3)

## Import-Hygiene Erweiterung

`import_hygiene.py` erweitert um:
- **COMBINE_SYMBOLS**: ObservableObject, Published, AnyCancellable, PassthroughSubject, CurrentValueSubject, AnyPublisher, Just, Future, Cancellable, Subscriber, Subscription
- **COMBINE_COVERING_IMPORTS**: import Combine, import SwiftUI
- `@Published` Attribut-Syntax wird erkannt

## Fix-Ergebnis

| Metrik | Wert |
|---|---|
| Files gefixt (Combine) | 11 |
| RecommendationViewModel gefixt | Ja |

### Gefixt Files
- AppCoordinator.swift (ObservableObject, Published)
- PredictionEngine.swift (ObservableObject)
- ReadinessCalculator.swift (ObservableObject)
- SimulationMode.swift (Future)
- TrendAnalyzer.swift (ObservableObject)
- ExamTimerService.swift (Published)
- BaseViewModel.swift (ObservableObject, Published)
- ExamReadinessViewModel.swift (ObservableObject, Published)
- ExamSessionViewModel.swift (Published)
- OfflineStatusViewModel.swift (ObservableObject, Published)
- RecommendationViewModel.swift (ObservableObject, Published)

## Typecheck nach Fix

| Metrik | Vorher (006) | Nachher (007) |
|---|---|---|
| Errors | 14 | 4 (2 unique) |
| Root Causes | 2 | 1 |

### Verbleibender Blocker: WeakArea 3x dupliziert

`WeakArea` ist in 3 Files definiert:
1. `Models/AssessmentResult.swift:35`
2. `Models/WeakArea.swift:4`
3. `Models/Recommendation.swift:20`

Dies ist ein **strukturelles Duplikat-Problem**, kein Import-Problem.
2 der 3 Definitionen muessen entfernt werden.
