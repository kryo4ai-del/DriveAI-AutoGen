# Command: Combine Import-Hygiene Erweiterung + Fix

Status: pending
Created: 2026-03-15
Priority: high

## Aufgabe

Erweitere `factory/operations/import_hygiene.py` um Combine-Symbole und fixe den RecommendationViewModel-Fehler. Dann Typecheck-Recheck.

## Kontext

Import-Hygiene erkennt aktuell nur Foundation-Symbole. `RecommendationViewModel.swift` nutzt `ObservableObject` und `@Published` ohne `import Combine`.

## Aufgaben

### 1. import_hygiene.py erweitern

In `factory/operations/import_hygiene.py`:

**Combine-Symbole hinzufuegen** (neben den bestehenden Foundation-Symbolen):

```python
COMBINE_SYMBOLS = {
    "ObservableObject", "Published", "AnyCancellable",
    "PassthroughSubject", "CurrentValueSubject",
    "AnyPublisher", "Just", "Future",
    "Cancellable", "Subscriber", "Subscription",
}
```

**Logik erweitern**:
- Wenn File bereits `import Combine`, `import SwiftUI`, oder `import UIKit` hat → skip
  (SwiftUI re-exportiert Combine)
- Wenn Combine-Symbol gefunden und kein passender Import → `import Combine` einfuegen
- `@Published` als Symbol erkennen (Attribut-Syntax mit `@`)

### 2. Safeguard auf Projekt laufen lassen

```bash
cd /Users/andreasott/DriveAI-AutoGen
git pull origin main

python3 -c "
from factory.operations.import_hygiene import ImportHygiene
h = ImportHygiene(project_name='askfin_v1-1')
h.fix()
"
```

### 3. Typecheck Recheck

```bash
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

Report in `DeveloperReports/CodeAgent/48-0_Combine Import Hygiene Report.md` mit:
1. Welche Combine-Symbole hinzugefuegt
2. Wie viele Files gefixt
3. Typecheck-Ergebnis
4. Ob RecommendationViewModel gefixt
5. Was der verbleibende Blocker ist (erwartbar: WeakArea Duplikat)

### 5. Commit + Push

```bash
git add -A
git commit -m "factory: extend import hygiene for Combine symbols

- Added COMBINE_SYMBOLS (ObservableObject, Published, AnyCancellable, etc.)
- import Combine auto-inserted when needed (SwiftUI re-export respected)
- Report 48-0

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>"
git push
```

Ergebnis in `_commands/007_combine_import_fix_result.md` speichern.
