# 005 Xcode / Build-System Reality Check — Ergebnis

**Datum**: 2026-03-15
**Ausgefuehrt von**: Claude Code (Mac, Xcode 26.3)

## Build-System Status

- .xcodeproj: **nicht vorhanden**
- Package.swift: **nicht vorhanden**
- .xcworkspace: **nicht vorhanden**

→ **Option 4** ausgefuehrt: `swiftc -typecheck` mit iOS Simulator SDK

## Ergebnis

| Metrik | Alle Files (223) | App-Only (215, ohne @testable) |
|---|---|---|
| Exit Code | 1 | 1 |
| Errors | blockiert bei 1. Test-File | 10 (2 root causes) |
| Warnings | — | 4 |

### Test-Files (8 Files mit @testable import)
Koennen ohne .xcodeproj/Module nicht kompiliert werden (`no such module 'DriveAI'`, `no such module 'XCTest'`). Das ist erwartbar — Tests brauchen ein Build-Target.

### App-Files: 2 Root-Cause Errors

**1. ExamReadinessError.swift** — `cannot find type 'LocalizedError'`
- Ursache: Fehlendes `import Foundation` — `LocalizedError` ist in Foundation definiert
- 1 Error, aber Kaskadeneffekt auf MockTrendPersistenceService (3 Folge-Errors: `does not conform to 'Error'`)

**2. MockTrendPersistenceService.swift** — `cannot find type 'Date'`
- Ursache: Fehlendes `import Foundation` — `Date` ist in Foundation definiert
- 1 Error + 4 Warnings (Sendable-Conformance, Swift 6 Vorbereitung)

### Fehlerzusammenfassung

| Error | Anzahl | Root Cause |
|---|---|---|
| cannot find type 'LocalizedError' | 1 | Fehlendes `import Foundation` |
| cannot find type 'Date' | 1 | Fehlendes `import Foundation` |
| does not conform to 'Error' | 3 | Kaskade von LocalizedError |
| thrown expression type does not conform | 3 | Kaskade von LocalizedError |
| Sendable warnings | 4 | Swift 6 Vorbereitung (nicht blockierend) |

## Braucht es ein .xcodeproj?

**Ja**, fuer einen echten Build wird ein Xcode-Projekt benoetigt:
- Test-Files brauchen ein Test-Target
- App braucht ein App-Target mit Info.plist, Asset Catalog, etc.
- `swiftc -typecheck` ist nur ein Syntax+Type-Check, kein vollstaendiger Build

## Zusammenfassung

**215 App-Files: nur 2 fehlende `import Foundation` Statements als Root Cause.**
213/215 App-Files (99.1%) sind type-check clean. Die 2 Fehler sind trivial (fehlende Imports).
Ein .xcodeproj muss erstellt werden fuer den naechsten Schritt (echter Xcode Build).
