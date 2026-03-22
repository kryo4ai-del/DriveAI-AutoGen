# 094 BreathFlow3 Build Attempt 2 — Result

**Status**: failed
**Datum**: 2026-03-22
**Ausgefuehrt von**: Mac Agent (Claude Code, manuell)

## Zusammenfassung

Zweiter Build-Versuch nach Windows-seitigen StubGen-Fixes. xcodegen laeuft jetzt in 2 Sekunden (Fix aus Attempt 1 greift). Build schlaegt mit **121 Compiler-Errors** fehl.

## xcodegen: ERFOLG
- Generiert in < 2 Sekunden
- Keine Haenger mehr (Stub-Dateien wurden in Attempt 1 entfernt)

## xcodebuild: 121 Errors

### Error-Verteilung (Top 10)
| Count | Error |
|-------|-------|
| 29 | `'Exercise' is ambiguous for type lookup in this context` |
| 17 | `cannot find type 'View' in scope` |
| 12 | `cannot find type 'UUID' in scope` |
| 10 | `enum with raw type cannot have cases with arguments` |
| 7 | `cannot find type 'Date' in scope` |
| 5 | `'ExerciseRepository' is ambiguous for type lookup in this context` |
| 3 | `cannot find type 'TimeInterval' in scope` |
| 3 | `cannot find type 'Color' in scope` |
| 2 | `type does not conform to protocol 'Decodable'` |
| 2 | `thrown type does not conform to 'Error' protocol` |

### Ursache 1: Fehlende Imports (27 von 28 Dateien)
Nur `Models/ExerciseDifficulty.swift` hat ein `import Foundation`. Alle anderen Swift-Dateien haben **kein** `import Foundation` und **kein** `import SwiftUI`.

Betroffene Dateien ohne Import:
- **Models/**: 21 Dateien (alle ausser ExerciseDifficulty.swift + ExerciseSelectionUseCaseProtocol.swift)
- **Views/**: 5 Dateien (alle)
- **Services/**: 1 Datei (PersistenceController.swift)

Das verursacht die `cannot find type 'UUID'/'Date'/'View'/'Color'` Fehler.

### Ursache 2: Doppelte Typ-Deklarationen
`Exercise` wird in mindestens 2 Dateien deklariert:
- `Models/Exercise.swift` — Haupt-Model
- `Models/ExerciseDifficulty.swift` — Enthaelt ebenfalls eine `Exercise`-Deklaration

`ExerciseRepository` ist ebenfalls mehrdeutig (in `ExerciseRepository.swift` und `ExerciseRepositoryProtocol.swift`).

Das verursacht die 29x `'Exercise' is ambiguous` und 5x `'ExerciseRepository' is ambiguous` Fehler.

### Ursache 3: Enum-Syntax-Fehler
10x `enum with raw type cannot have cases with arguments` — Enums mit Raw Values die trotzdem Associated Values verwenden. Ungueltige Swift-Syntax.

### Ursache 4: Fehlende SwiftUI-Attribute
- `@StateObject`, `@State`, `@Environment` nicht erkannt (weil `import SwiftUI` fehlt)
- `@Preview` Macro nicht gefunden

### Ursache 5: Sonstige
- `PersistenceController.shared` existiert nicht (Property fehlt)
- `RepositoryError` konformiert nicht zu `Error`
- `ReadinessIndicator` konformiert nicht zu `Equatable`

## Einschaetzung

Das Projekt ist ein **Roh-Factory-Output ohne Operations Layer**. Die 3 Hauptprobleme:

1. **Fehlende Imports** — Einfach zu fixen. Jede Datei braucht `import Foundation` (Models/Services) oder `import SwiftUI` (Views/ViewModels). Der Compile Hygiene Validator (FK-011) sollte das als erstes pruefen und automatisch einfuegen.

2. **Doppelte Typ-Deklarationen** — Der Output Integrator hat Duplikate nicht erkannt. Braucht Type-Level Dedup (schon in der Operations Layer vorhanden, muss aber ueber breathflow3 laufen).

3. **Ungueltige Enum-Syntax** — Code-Generation hat Enums mit Raw Types UND Associated Values erzeugt, was in Swift nicht erlaubt ist. Braucht entweder manuellen Fix oder einen neuen FK-Pattern im Compile Hygiene Validator.

## Empfehlung an Windows Agent

1. **Operations Layer ueber breathflow3 laufen lassen** — das loest Punkt 1 und 2
2. **Neuen FK-Pattern** fuer Enum-Syntax-Fehler anlegen (FK-018 oder neuer)
3. **Danach erneut build_ios Command senden**
4. Alternativ: Mac Agent kann die Dateien manuell fixen wenn gewuenscht

## Naechster Schritt

Windows Agent entscheidet: Operations Layer automatisch oder Mac Agent manueller Fix.
