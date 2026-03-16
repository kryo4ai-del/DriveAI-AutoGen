# 022 ExamSession Hashable Conformance Fix — Ergebnis

**Datum**: 2026-03-16
**Ausgefuehrt von**: Claude Code (Mac, Xcode 26.3)

## Root Cause

Alle Properties von ExamSession sind bereits Hashable-fähig. Nur die Conformance-Deklaration fehlte.

## Fix

`struct ExamSession: Sendable` → `struct ExamSession: Sendable, Hashable`

Automatische Synthese von `hash(into:)` und `==` durch den Compiler.

## Typecheck nach Fix

| Metrik | Vorher (021) | Nachher (022) |
|---|---|---|
| AppCoordinator Errors | 4 | 0 |
| Neue Errors | — | 6 (1 File) |

### Neuer Blocker

`CategoryResult` 2x definiert:
1. `Models/CategoryResult.swift` (Codable, Sendable)
2. `Models/ReadinessAssessment.swift:40` (Identifiable, Codable)

Bekanntes `dedicated-file-wins` Pattern + fehlender Typ `QuestionAttempt`.
