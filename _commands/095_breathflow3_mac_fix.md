# 095 BreathFlow3 — Mac Agent Fix + Rebuild

**Status**: pending
**Ziel**: Fix the 121 compile errors and get BreathFlow3 to BUILD SUCCEEDED

## Auftrag

Fix alle 3 Root Causes aus dem Report 094, dann rebuild. Dokumentiere jeden Fix.

### Fix 1: Fehlende Imports
- Jede .swift Datei in Models/ und Services/ braucht `import Foundation`
- Jede .swift Datei in Views/ und ViewModels/ braucht `import SwiftUI`
- Wenn eine Datei beides braucht (z.B. ViewModel mit Date + View): `import SwiftUI` reicht (importiert Foundation implizit)

### Fix 2: Doppelte Typ-Deklarationen
- `Exercise` existiert in 2+ Dateien → behalte die Haupt-Definition in `Exercise.swift`, entferne Duplikate aus anderen Dateien
- `ExerciseRepository` ambiguous → prüfe ob Protocol und Klasse unterschiedliche Namen brauchen (z.B. `ExerciseRepositoryProtocol` vs `ExerciseRepository`)

### Fix 3: Enum-Syntax-Fehler
- Enums mit Raw Type (`String`, `Int`) dürfen keine Associated Values haben
- Fix: Entweder Raw Type entfernen ODER Associated Values entfernen (je nachdem was sinnvoller ist)
- Beispiel Fix: `case easy(points: Int)` → `case easy` (wenn Raw Type bleibt)

### Nach allen Fixes
```bash
xcodebuild -project BreathFlow3.xcodeproj -scheme BreathFlow3 -configuration Debug -destination "platform=iOS Simulator,name=iPhone 17 Pro" build 2>&1 | tail -20
```

### Report schreiben
Schreibe `095_breathflow3_mac_fix_result.md` mit:
1. Welche Dateien geändert wurden
2. Was genau gefixt wurde (Import/Dedup/Enum)
3. Build-Ergebnis nach Fix
4. Verbleibende Errors (wenn noch welche)

Commit + push wenn fertig.
