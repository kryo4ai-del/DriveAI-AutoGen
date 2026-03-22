# 093 BreathFlow3 Build Test — Result

**Status**: failed
**Datum**: 2026-03-22
**Ausgefuehrt von**: Mac Agent (Claude Code, manuell)

## Zusammenfassung

Der erste Build-Test fuer das Factory-generierte Projekt BreathFlow3 ist fehlgeschlagen.
Das Projekt ist noch nicht build-faehig — es muss zunaechst durch die Operations Layer (Compile Hygiene, Type Stub Generator, Property Shape Repairer) auf dem Windows-Rechner laufen.

## Was wurde getestet

1. **Mac Build Agent** (`mac_agent/mac_build_agent.py`) — Polling-Agent gestartet und getestet
2. **health_check Command** — erfolgreich (Xcode 26.3 erkannt)
3. **build_ios Command** fuer breathflow3 — fehlgeschlagen

## Was der Mac Agent gemacht hat

### 1. Mac Build Agent Test
- Agent gestartet, pollt alle 30s `_commands/pending/`
- health_check Command erfolgreich verarbeitet und nach `completed/` verschoben
- Automatischer git push hat funktioniert
- **Ergebnis**: Agent-Infrastruktur funktioniert einwandfrei

### 2. xcodegen haengt (Problem 1)
- `xcodegen generate` hing ueber 114 Minuten bei "Generating project..."
- **Ursache**: Factory-generierte Type-Stub-Dateien mit Namen die Swift-Standard-Typen shadowed haben:
  - `Hashable.swift`, `Equatable.swift`, `Codable.swift`, `Identifiable.swift`
  - `Task.swift`, `MainActor.swift`, `HStack.swift`, `Color.swift`
  - `XCTest.swift`, `XCTestCase.swift`, `NSPersistentContainer.swift`
  - `LocalizedError.swift`, `TimeInterval.swift`, `Preview.swift`, `DriveAI.swift`
- **Fix**: 15 Stub-Dateien entfernt
- Zusaetzlich: `group:` Attribute in project.yml verursachten ebenfalls Haenger
- **Fix**: project.yml vereinfacht (ohne group-Attribute)
- Nach beiden Fixes: xcodegen laeuft in < 2 Sekunden

### 3. Build Errors (Problem 2)
- `GeneratedHelpers.swift` (403 Zeilen) — Top-Level-Code der nicht kompiliert (Beispiel-Snippets statt echtem Code)
- **Fix**: Datei entfernt
- Test-Dateien (*Tests.swift) lagen im App-Target statt in separatem Test-Target
- **Fix**: Nach `Tests/` Ordner verschoben

### 4. Fundamentale Build-Fehler (Problem 3 — nicht gefixt)
- Fehlende `import Foundation` / `import SwiftUI` in fast allen Dateien
- `UUID`, `Date`, `TimeInterval`, `View`, `LocalizedError` nicht gefunden
- Doppelte Typ-Deklaration (`Exercise` in mehreren Dateien)
- Dateien mit Beispiel-Code als echtem Code (z.B. `AppDependencies.swift` mit Kommentar-Code)
- `FetchExercisesUseCase.swift` mit `...` als Parameter (Pseudocode)

## Einschaetzung

### Factory Output Qualitaet
Das breathflow3-Projekt ist ein **Roh-Output der Code-Generation** und wurde noch nicht durch die Operations Layer verarbeitet. Die typischen Probleme:

1. **Type Stubs als eigenstaendige Dateien** — Die Factory generiert Stubs fuer Standard-Typen (Hashable, Task etc.) die xcodegen und den Compiler verwirren. Das ist ein bekanntes Pattern (FK-014) das der Type Stub Generator normalerweise bereinigt.

2. **Fehlende Imports** — Kein `import Foundation`/`import SwiftUI` in den Dateien. Die Compile Hygiene sollte das erkennen (FK-011).

3. **Pseudocode in Swift-Dateien** — Einige Dateien enthalten Beispiel-Code, Kommentare oder Platzhalter (`...`) statt kompilierbarem Code. Das deutet darauf hin, dass der Code Extractor die Markdown-Bloecke nicht sauber getrennt hat.

4. **Tests im falschen Target** — Test-Dateien liegen in `Models/` statt in einem separaten Test-Ordner/Target.

### Mac Build Agent
Der Agent selbst funktioniert einwandfrei. Das Command-Queue-System (pending → completed → git push) laeuft stabil.

### Empfehlung
1. **Operations Layer auf Windows laufen lassen** bevor build_ios Commands geschickt werden
2. **Type Stub Filter** in der Factory erweitern: Dateien die Swift-Standard-Typ-Namen tragen sollten nie als eigenstaendige Dateien extrahiert werden
3. **project.yml ohne `group:` Attribute** generieren — diese verursachen xcodegen-Haenger
4. **Import-Check** als fruehe Quality Gate: Jede .swift Datei braucht mindestens `import Foundation` oder `import SwiftUI`

## Dateien geaendert auf Mac
- 15 Type-Stub-Dateien entfernt
- `GeneratedHelpers.swift` entfernt
- 9 Test-Dateien nach `Tests/` verschoben
- `project.yml` vereinfacht (ohne group-Attribute, mit GENERATE_INFOPLIST_FILE)
- `AppDependencies.swift` — Kommentar-Code entfernt
- `ExerciseCategory+Extension.swift` — Kommentar-Code entfernt
- `ExerciseSelectionUseCaseProtocol.swift` — Trailing @MainActor entfernt
- `FetchExercisesUseCase.swift` — Pseudocode durch kompilierbaren Code ersetzt

## Naechster Schritt
Windows Agent soll Operations Layer (Compile Hygiene + Type Stub Generator + Property Shape Repairer) ueber breathflow3 laufen lassen, dann erneut build_ios Command senden.
