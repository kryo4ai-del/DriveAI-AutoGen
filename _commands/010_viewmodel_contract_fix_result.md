# 010 ViewModel Contract-Reconciliation — Ergebnis

**Datum**: 2026-03-15
**Ausgefuehrt von**: Claude Code (Mac, Xcode 26.3)

## Policy

Erweitert: `config/residual_compile_policy.json` v1.2
- Neue Section: `contract_reconciliation`
- Policy: `consumer-declares-need`

## Fixes angewendet

| Fix | File | Aenderung |
|---|---|---|
| 1. Missing Conformance | Services/ExamTimerService.swift | `ObservableObject` Conformance hinzugefuegt |
| 2. Missing Properties | Models/ExamSession.swift | Stub zu vollem Struct erweitert (id, startTime, endTime, answers, score, passed, questionIds) |
| 3. Missing Dependency | ViewModels/ExamSessionViewModel.swift | `examSessionService: ExamSessionService` Property + init-Parameter hinzugefuegt |

## Typecheck nach Fix

| Metrik | Vorher (009) | Nachher (010) |
|---|---|---|
| Errors | 8 | 2 (1 unique) |
| Error Files | 1 | 1 |
| Warnings | 1 | 1 (Swift 6 Sendable) |

### Verbleibender Error

`ExamSessionViewModel.swift:24` — `actor-isolated property 'session' cannot be passed 'inout' to 'async' function call`

Dies ist ein **Swift Concurrency Restriction**: Ein `@MainActor`-isoliertes Property (`session`) kann nicht als `inout` an eine `async` Funktion uebergeben werden. Fix erfordert ein Pattern-Change (z.B. lokale Kopie, dann zurueckschreiben).

## Zusammenfassung

3 von 3 Contract-Mismatches gefixt. Verbleibend: 1 Swift-Concurrency-Error (kein Import/Contract-Problem).
