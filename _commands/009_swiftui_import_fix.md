# Command: SwiftUI Import-Hygiene Erweiterung + Fix

Status: pending
Created: 2026-03-15
Priority: high

## Aufgabe

Erweitere `factory/operations/import_hygiene.py` um SwiftUI-Symbole und fixe den ExamSessionViewModel-Import-Fehler. Dann Typecheck-Recheck.

## Kontext

Import-Hygiene erkennt Foundation + Combine, aber nicht SwiftUI-spezifische Symbole wie `@StateObject`. ExamSessionViewModel.swift hat `import Combine` aber braucht `import SwiftUI` fuer `@StateObject`.

## Aufgaben

### 1. import_hygiene.py erweitern

**SwiftUI-Symbole hinzufuegen** (Symbole die NUR in SwiftUI existieren, nicht in Foundation/Combine):

```python
SWIFTUI_SYMBOLS = {
    # Property Wrappers (nur SwiftUI)
    "StateObject", "EnvironmentObject", "Environment",
    "AppStorage", "SceneStorage", "FocusState", "GestureState",
    "Namespace", "FetchRequest", "Query",
    # View Protocol + Body
    "View", "some View",
    # Navigation
    "NavigationStack", "NavigationLink", "NavigationPath",
    # Common Views
    "Text", "Image", "Button", "List", "ForEach",
    "VStack", "HStack", "ZStack", "ScrollView",
    "Form", "Section", "Toggle", "Picker", "Slider",
    "TextField", "TextEditor", "SecureField",
    "ProgressView", "Label", "Spacer", "Divider",
    # Modifiers / Types
    "Color", "Font", "ViewModifier", "ViewBuilder",
    # Preview
    "PreviewProvider",
}
```

**Logik**:
- Wenn File bereits `import SwiftUI` hat → skip
- `import SwiftUI` deckt auch Foundation und Combine ab
- Wenn SwiftUI-Symbol gefunden und kein `import SwiftUI` → `import SwiftUI` einfuegen
- Wenn File `import Foundation` UND `import Combine` hat und jetzt auch SwiftUI braucht:
  Ersetze beide durch `import SwiftUI` (optional, oder einfach `import SwiftUI` hinzufuegen)
- `@StateObject` als Symbol erkennen (Attribut-Syntax mit `@`)

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

Report in `DeveloperReports/CodeAgent/50-0_SwiftUI Import Hygiene Report.md` mit:
1. Welche SwiftUI-Symbole hinzugefuegt
2. Wie viele Files gefixt
3. Typecheck-Ergebnis
4. Ob ExamSessionViewModel Import gefixt
5. Was der verbleibende Blocker ist (erwartbar: fehlende Properties/Services)

### 5. Commit + Push

```bash
git add -A
git commit -m "factory: extend import hygiene for SwiftUI symbols

- Added SWIFTUI_SYMBOLS (StateObject, View, NavigationStack, etc.)
- import SwiftUI auto-inserted when needed
- Report 50-0

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>"
git push
```

Ergebnis in `_commands/009_swiftui_import_fix_result.md` speichern.
