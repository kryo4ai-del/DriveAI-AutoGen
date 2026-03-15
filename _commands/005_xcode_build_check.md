# Command: Xcode / Build-System Reality Check

Status: pending
Created: 2026-03-15
Priority: high

## Aufgabe

Erster echter Xcode/Build-System-Check auf der 100% parse-clean Baseline.
Kein neuer Code generieren — nur die aktuelle Baseline bauen und Ergebnisse dokumentieren.

## Vorbereitung

```bash
cd /Users/andreasott/DriveAI-AutoGen
git pull origin main
```

## Befehle (in dieser Reihenfolge versuchen)

### Option 1: xcodebuild (wenn .xcodeproj existiert)

```bash
ls projects/askfin_v1-1/*.xcodeproj 2>/dev/null
# Falls vorhanden:
xcodebuild -project projects/askfin_v1-1/*.xcodeproj \
  -scheme AskFin \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  build 2>&1 | tail -100
echo "Exit code: $?"
```

### Option 2: Swift Package Manager (wenn Package.swift existiert)

```bash
ls projects/askfin_v1-1/Package.swift 2>/dev/null
# Falls vorhanden:
cd projects/askfin_v1-1 && swift build 2>&1 | tail -100
echo "Exit code: $?"
```

### Option 3: Xcode Workspace

```bash
ls projects/askfin_v1-1/*.xcworkspace 2>/dev/null
```

### Option 4: Wenn kein Build-System existiert

Falls weder .xcodeproj noch Package.swift existiert:
1. Dokumentiere das als Ergebnis
2. Fuehre stattdessen `swiftc` mit allen Files + Framework-Imports aus:

```bash
find projects/askfin_v1-1 -name "*.swift" \
  -not -path "*/quarantine/*" \
  -not -path "*/generated/*" \
  > /tmp/askfin_files.txt

# Volles Compile (nicht nur parse) mit SwiftUI Framework
swiftc -typecheck \
  -target arm64-apple-ios17.0-simulator \
  -sdk $(xcrun --sdk iphonesimulator --show-sdk-path) \
  -import-objc-header /dev/null \
  $(cat /tmp/askfin_files.txt) 2>&1 | head -100
echo "Exit code: $?"
echo "Error count:"
swiftc -typecheck \
  -target arm64-apple-ios17.0-simulator \
  -sdk $(xcrun --sdk iphonesimulator --show-sdk-path) \
  -import-objc-header /dev/null \
  $(cat /tmp/askfin_files.txt) 2>&1 | grep "error:" | wc -l
```

## Erwartetes Ergebnis

Bitte dokumentiere:

1. **Welche Option verfuegbar war** (1, 2, 3, oder 4)
2. **Exit Code** (0 = clean)
3. **Anzahl Errors und Warnings**
4. **Die ersten 10-20 konkreten Fehlermeldungen** (falls vorhanden)
5. **Ob Fehler nach einem Pattern aussehen** (z.B. "cannot find type X", "missing import", etc.)
6. **Ob ein .xcodeproj erstellt werden muesste** fuer einen echten Build

Ergebnis in `_commands/005_xcode_build_check_result.md` speichern, Report in `DeveloperReports/CodeAgent/46-0_Xcode Build Reality Check Report.md`.
Dann commit + push.
