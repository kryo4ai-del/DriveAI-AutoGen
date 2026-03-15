# 51-0 ViewModel Contract Reconciliation Report

**Datum**: 2026-03-15
**Agent**: Claude Code (Mac, Xcode 26.3)

## Policy

`consumer-declares-need`: Wenn ein Consumer ein Property/Conformance erwartet, wird es zum Typ hinzugefuegt.

## Fixes

1. **ExamTimerService**: `ObservableObject` Conformance (fuer `@StateObject`)
2. **ExamSession**: Stub zu vollem Struct (7 Properties mit Defaults)
3. **ExamSessionViewModel**: `examSessionService` Property hinzugefuegt

## Ergebnis

- Errors: 8 → 2 (1 unique)
- Verbleibend: Swift Concurrency Error (`inout` + `async` auf actor-isolated Property)
- Dies erfordert ein Code-Pattern-Change, kein einfacher Fix
