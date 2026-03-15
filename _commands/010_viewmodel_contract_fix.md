# Command: ViewModel Contract-Reconciliation + Fix

Status: pending
Created: 2026-03-15
Priority: high

## Aufgabe

Fixe die 3 strukturellen Mismatches in ExamSessionViewModel.swift durch eine zentrale Contract-Policy. Dann Typecheck-Recheck.

## Kontext

8 Errors in ExamSessionViewModel.swift, 3 Root Causes:
1. `ExamTimerService` conformt nicht zu `ObservableObject` (braucht es fuer `@StateObject`)
2. `ExamSession` hat kein Property `startTime`
3. `examSessionService` nicht als Property im ViewModel deklariert

## Aufgaben

### 1. Contract-Reconciliation Policy

Erweitere `config/residual_compile_policy.json` um eine `contract_reconciliation` Section:

```json
{
  "contract_reconciliation": {
    "policy": "consumer-declares-need",
    "description": "Wenn ein ViewModel/Consumer ein Property oder eine Conformance von einem Typ erwartet die nicht existiert, wird die fehlende Deklaration zum referenzierten Typ hinzugefuegt — sofern es minimal und sicher ist.",
    "rules": [
      {
        "type": "missing_conformance",
        "action": "Conformance zum referenzierten Typ hinzufuegen wenn es ein Marker-Protocol ist (z.B. ObservableObject, Sendable)"
      },
      {
        "type": "missing_property",
        "action": "Property als optionales oder Default-Wert-Property hinzufuegen wenn der Typ aus dem Kontext klar ist"
      },
      {
        "type": "missing_dependency",
        "action": "Property-Deklaration im Consumer hinzufuegen wenn der Service-Typ existiert"
      }
    ]
  }
}
```

### 2. Fixes anwenden

**Fix 1: ExamTimerService + ObservableObject**

Oeffne `Services/ExamTimerService.swift`. Pruefe ob die class-Deklaration `ObservableObject` conformance hat. Wenn nicht, fuege hinzu:
```swift
// VORHER: class ExamTimerService { ... }
// NACHHER: class ExamTimerService: ObservableObject { ... }
```

**Fix 2: ExamSession + startTime**

Oeffne die Datei die `ExamSession` definiert (vermutlich `Models/ExamSession.swift` oder ein Stub). Fuege hinzu:
```swift
let startTime: Date = Date()
```
Wenn ExamSession ein Stub ist, fuege das Property dort ein.

**Fix 3: examSessionService im ViewModel**

Oeffne `ViewModels/ExamSessionViewModel.swift`. Pruefe welcher Service-Typ erwartet wird und fuege eine Property-Deklaration hinzu. Vermutlich:
```swift
// Am Anfang der class, nach den @Published vars:
private let examSessionService: ExamSimulationService  // oder passender Typ
```
Pruefe den Typ aus dem Kontext (wie wird `examSessionService` im ViewModel verwendet?).

### 3. Typecheck Recheck

```bash
cd /Users/andreasott/DriveAI-AutoGen
git pull origin main

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

Report in `DeveloperReports/CodeAgent/51-0_ViewModel Contract Reconciliation Report.md` mit:
1. Policy definiert
2. Welche 3 Fixes angewendet
3. Typecheck-Ergebnis
4. Ob 0 Errors erreicht oder was noch bleibt

### 5. Commit + Push

```bash
git add -A
git commit -m "factory: ViewModel contract reconciliation policy + fix ExamSession family

- Policy: consumer-declares-need in residual_compile_policy.json
- Fix 1: ExamTimerService + ObservableObject conformance
- Fix 2: ExamSession + startTime property
- Fix 3: examSessionService property in ViewModel
- Report 51-0

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>"
git push
```

Ergebnis in `_commands/010_viewmodel_contract_fix_result.md` speichern.
