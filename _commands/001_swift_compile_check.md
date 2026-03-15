# Command: Swift Compile Reality Check

Status: pending
Created: 2026-03-15
Priority: high

## Aufgabe

Fuehre einen echten Swift-Compile-Check auf dem AskFin-Projekt durch.
Kein neuer Code generieren — nur die aktuelle Baseline kompilieren und Ergebnisse dokumentieren.

## Vorbereitung

```bash
cd /Users/andreasott/DriveAI-AutoGen
git pull origin main
```

## Befehle (in dieser Reihenfolge versuchen)

### Option 1: swiftc Parse-Check (schnellster, kein Xcode noetig)

```bash
# Alle Swift-Files im Projekt sammeln (ohne quarantine/ und generated/)
find projects/askfin_v1-1 -name "*.swift" \
  -not -path "*/quarantine/*" \
  -not -path "*/generated/*" \
  > /tmp/askfin_files.txt

echo "Files to check: $(wc -l < /tmp/askfin_files.txt)"

# Parse-Check (Syntax only, kein volles Compile)
swiftc -parse $(cat /tmp/askfin_files.txt) 2>&1 | head -100
echo "Exit code: $?"
```

### Option 2: Xcode Build (vollstaendig, braucht .xcodeproj)

```bash
# Pruefen ob ein Xcode-Projekt existiert
ls projects/askfin_v1-1/*.xcodeproj 2>/dev/null || echo "Kein .xcodeproj gefunden"

# Falls vorhanden:
xcodebuild -project projects/askfin_v1-1/*.xcodeproj \
  -scheme AskFin \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  build 2>&1 | tail -50
echo "Exit code: $?"
```

### Option 3: Swift Package Manager (falls Package.swift existiert)

```bash
ls projects/askfin_v1-1/Package.swift 2>/dev/null || echo "Kein Package.swift"
# Falls vorhanden:
cd projects/askfin_v1-1 && swift build 2>&1 | tail -50
echo "Exit code: $?"
```

## Erwartetes Ergebnis

Bitte dokumentiere:

1. **Welche Option funktioniert hat** (1, 2, oder 3)
2. **Exit Code** (0 = clean, != 0 = Fehler)
3. **Anzahl Errors und Warnings**
4. **Die ersten 5-10 konkreten Fehlermeldungen** (falls vorhanden)
5. **Ob Fehler nach einem Pattern aussehen** (z.B. immer gleicher Import fehlt, Type not found, etc.)

Ergebnis bitte in `_commands/001_swift_compile_check_result.md` speichern.
