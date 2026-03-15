# 012 NetworkMonitor Symbol-Scope Fix — Ergebnis

**Datum**: 2026-03-15
**Ausgefuehrt von**: Claude Code (Mac, Xcode 26.3)

## Root Cause

`NetworkMonitor` Typ existierte nicht im Projekt. 1 Referenz in OfflineStatusViewModel.swift.

## Fix

Erstellt: `Services/NetworkMonitor.swift`
- Minimale Implementierung mit NWPathMonitor (Network framework)
- Singleton-Pattern (`.shared`)
- ObservableObject mit `@Published isConnected`

## Policy

Erweitert: `config/residual_compile_policy.json` v1.4
- Neue Section: `missing_infrastructure_type`
- Policy: `stub-or-minimal-implementation`

## Typecheck nach Fix

| Metrik | Vorher (011) | Nachher (012) |
|---|---|---|
| NetworkMonitor Error | 2 | 0 |
| Neue Errors | — | 8 (1 File) |

### NetworkMonitor: Geloest

### Neuer Blocker (vorher maskiert)

`ExamReadinessViewModel.swift` — 8 Errors
- `ExamReadinessServiceProtocol` hat nicht die erwarteten Methoden:
  - `calculateOverallReadiness()`
  - `getCategoryReadiness()`
  - `getWeakCategories(limit:)`
  - `getTrendData(days:)`
- Protocol-Contract-Mismatch zwischen Consumer und Protocol-Definition

## Zusammenfassung

NetworkMonitor implementiert. Naechster Blocker: ExamReadinessServiceProtocol fehlen 4 Methoden.
