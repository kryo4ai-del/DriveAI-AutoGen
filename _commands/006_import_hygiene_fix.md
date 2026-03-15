# Command: Import-Hygiene Safeguard + Fix

Status: pending
Created: 2026-03-15
Priority: high

## Aufgabe

Baue einen deterministischen Import-Hygiene-Safeguard der fehlende `import Foundation` erkennt und ergaenzt. Dann fix die 2 aktuellen Blocker und mache einen Typecheck-Recheck.

## Kontext

`swiftc -typecheck` zeigt 2 Root-Cause Errors:
- ExamReadinessError.swift: nutzt `LocalizedError` ohne `import Foundation`
- MockTrendPersistenceService.swift: nutzt `Date` ohne `import Foundation`

## Aufgaben

### 1. Import-Hygiene-Modul erstellen

Erstelle `factory/operations/import_hygiene.py` mit:

```python
# Deterministisch, kein LLM.
# Scannt Swift-Files nach bekannten Foundation-Symbolen.
# Fuegt `import Foundation` ein wenn noetig und noch nicht vorhanden.

FOUNDATION_SYMBOLS = {
    # Types
    "Date", "Data", "URL", "UUID", "TimeInterval",
    "Calendar", "DateFormatter", "DateComponents",
    "JSONEncoder", "JSONDecoder",
    "UserDefaults", "FileManager", "Bundle",
    "NotificationCenter", "Timer", "RunLoop",
    "NSObject", "NSError", "NSCoder",
    "Locale", "TimeZone", "IndexSet", "CharacterSet",
    "NumberFormatter", "MeasurementFormatter",
    "ProcessInfo", "OperationQueue",
    # Protocols
    "LocalizedError", "CustomNSError",
    "NSCoding", "NSSecureCoding",
    # Functions / Globals
    "DispatchQueue",  # technically Dispatch, but Foundation re-exports
}

# Logik:
# 1. Pruefe ob File bereits `import Foundation` oder `import SwiftUI` hat
#    (SwiftUI re-exportiert Foundation)
# 2. Wenn nicht: scanne nach FOUNDATION_SYMBOLS Usage
# 3. Wenn gefunden: fuege `import Foundation` nach dem letzten Import ein
```

### 2. Fix die 2 aktuellen Files

Entweder durch den neuen Safeguard automatisch, oder manuell:
- `projects/askfin_v1-1/Models/ExamReadinessError.swift`: `import Foundation` einfuegen
- `projects/askfin_v1-1/Services/MockTrendPersistenceService.swift`: `import Foundation` einfuegen

### 3. Typecheck Recheck

```bash
cd /Users/andreasott/DriveAI-AutoGen
git pull origin main

# Safeguard auf ganzes Projekt laufen lassen
python3 -c "
from factory.operations.import_hygiene import ImportHygiene
h = ImportHygiene(project_name='askfin_v1-1')
h.fix()
"

# Recheck
find projects/askfin_v1-1 -name "*.swift" \
  -not -path "*/quarantine/*" \
  -not -path "*/generated/*" \
  -not -path "*Tests*" \
  > /tmp/askfin_app_files.txt

swiftc -typecheck \
  -target arm64-apple-ios17.0-simulator \
  -sdk $(xcrun --sdk iphonesimulator --show-sdk-path) \
  $(cat /tmp/askfin_app_files.txt) 2>&1 | head -50
echo "Exit code: $?"
echo "Error count:"
swiftc -typecheck \
  -target arm64-apple-ios17.0-simulator \
  -sdk $(xcrun --sdk iphonesimulator --show-sdk-path) \
  $(cat /tmp/askfin_app_files.txt) 2>&1 | grep "error:" | wc -l
```

### 4. Report

Report in `DeveloperReports/CodeAgent/47-0_Import Hygiene Report.md` mit:
1. Modul beschrieben
2. Wie viele Files gefixt
3. Typecheck-Ergebnis
4. Ob 0 Errors erreicht

### 5. Commit + Push

```bash
git add -A
git commit -m "factory: import hygiene safeguard + fix missing Foundation imports

- factory/operations/import_hygiene.py: deterministic Foundation import checker
- Scans for known Foundation symbols, adds import when missing
- Fixed: ExamReadinessError.swift, MockTrendPersistenceService.swift
- Report 47-0

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>"
git push
```

Ergebnis in `_commands/006_import_hygiene_fix_result.md` speichern.
