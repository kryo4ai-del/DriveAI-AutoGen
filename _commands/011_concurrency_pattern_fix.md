# Command: Swift Concurrency Pattern Fix

Status: pending
Created: 2026-03-15
Priority: high

## Aufgabe

Fixe den letzten verbleibenden Swift Concurrency Error in ExamSessionViewModel.swift durch eine zentrale Concurrency-Policy. Dann Typecheck-Recheck.

## Kontext

1 Error (2 Meldungen) verbleibt:
- `ExamSessionViewModel.swift:24` — `actor-isolated property 'session' cannot be passed 'inout' to 'async' function call`
- Das ist ein Swift Concurrency Restriction: `@MainActor`-isolierte Properties koennen nicht `inout` an async Funktionen uebergeben werden.

## Aufgaben

### 1. Concurrency-Pattern Policy

Erweitere `config/residual_compile_policy.json` um eine `concurrency_patterns` Section:

```json
{
  "concurrency_patterns": {
    "inout_async_isolation": {
      "description": "Actor-isolated properties cannot be passed inout to async functions. Use local-copy-then-assign pattern.",
      "canonical_fix": "var localCopy = self.property; await asyncFunc(&localCopy); self.property = localCopy",
      "severity": "compile-error"
    }
  }
}
```

### 2. Fix anwenden

Oeffne `ViewModels/ExamSessionViewModel.swift` Zeile 24 (oder die Stelle mit dem inout+async Fehler).

**Pattern**:
```swift
// VORHER (ungueltig):
await someAsyncFunction(&self.session)

// NACHHER (local-copy-then-assign):
var localSession = self.session
await someAsyncFunction(&localSession)
self.session = localSession
```

Falls der Code anders aussieht (z.B. `session.mutatingMethod()` in async context), passe den Fix entsprechend an — das Prinzip bleibt: lokale Kopie, async-Call, zurueckschreiben.

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

Report in `DeveloperReports/CodeAgent/52-0_Concurrency Pattern Fix Report.md` mit:
1. Policy definiert
2. Welcher Fix angewendet
3. Typecheck-Ergebnis
4. Ob 0 Errors erreicht oder was noch bleibt

### 5. Commit + Push

```bash
git add -A
git commit -m "factory: concurrency pattern policy + fix actor-isolated inout async

- Policy: local-copy-then-assign for inout+async on actor-isolated properties
- Fixed: ExamSessionViewModel.swift actor isolation error
- Report 52-0

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>"
git push
```

Ergebnis in `_commands/011_concurrency_pattern_fix_result.md` speichern.
