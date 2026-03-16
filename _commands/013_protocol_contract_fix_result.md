# 013 ExamReadinessServiceProtocol Contract Fix — Ergebnis

**Datum**: 2026-03-16
**Ausgefuehrt von**: Claude Code (Mac, Xcode 26.3)

## Root Cause

`ExamReadinessServiceProtocol` hatte nur 2 Methoden, aber ViewModel erwartete 6 (4 fehlend).

## Fix

4 Methoden zu Protocol + Service hinzugefuegt:

| Methode | Return Type | Quelle |
|---|---|---|
| `calculateOverallReadiness()` | `ExamReadinessScore` | ViewModel Zeile 45/57 |
| `getCategoryReadiness()` | `[CategoryReadiness]` | ViewModel Zeile 46/58 |
| `getWeakCategories(limit:)` | `[CategoryReadiness]` | ViewModel Zeile 47/59 |
| `getTrendData(days:)` | `[ReadinessTrendPoint]` | ViewModel Zeile 48/60 |

Service-Implementierung: Minimale Default-Werte (leere Arrays, Score 0). Werden spaeter durch echte Logik ersetzt.

## Typecheck nach Fix

| Metrik | Vorher (012) | Nachher (013) |
|---|---|---|
| ExamReadinessViewModel Errors | 8 | 0 |
| Neue Errors | — | 2 (1 unique) |

### ExamReadinessServiceProtocol: Geloest

### Neuer Blocker (vorher maskiert)

`LocalDataServiceProtocol` ist 2x definiert:
1. `Services/LocalDataService.swift:3` (mit Sendable)
2. `Models/LocalDataServiceProtocol.swift:3` (mit AnyObject)

Gleiches Pattern wie WeakArea — `dedicated-file-wins` Policy anwendbar.

## Zusammenfassung

Protocol-Contract gefixt. Naechster Blocker: LocalDataServiceProtocol Duplikat.
