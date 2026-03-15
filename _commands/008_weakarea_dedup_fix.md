# Command: WeakArea Duplikat-Kollision loesen

Status: pending
Created: 2026-03-15
Priority: high

## Aufgabe

Loesche die `WeakArea`-Typ-Kollision (3 Definitionen) durch eine zentrale Policy und fuehre einen Typecheck-Recheck durch.

## Kontext

`WeakArea` ist in 3 Files definiert:
1. `Models/AssessmentResult.swift:35`
2. `Models/WeakArea.swift:4`
3. `Models/Recommendation.swift:20`

## Aufgaben

### 1. Duplicate-Type Collision Policy

Erstelle oder erweitere `config/residual_compile_policy.json` um eine `duplicate_type_collision` Section:

```json
{
  "duplicate_type_collision": {
    "policy": "dedicated-file-wins",
    "description": "Wenn ein Typ sowohl in einer eigenen Datei (TypeName.swift) als auch inline in einer anderen Datei definiert ist, gilt die eigene Datei als canonical.",
    "non_canonical_action": "remove_inline_definition"
  }
}
```

### 2. Policy anwenden auf WeakArea

**Canonical**: `Models/WeakArea.swift` (eigene Datei = canonical nach Policy)

**Non-canonical**: Die `WeakArea` struct-Definitionen in:
- `Models/AssessmentResult.swift` (inline)
- `Models/Recommendation.swift` (inline)

**Aktion**: Die inline `struct WeakArea { ... }` Bloecke in den 2 non-canonical Files entfernen. Nur die Typ-Definition entfernen, nicht den gesamten File-Inhalt.

### 3. Durchfuehrung

```bash
cd /Users/andreasott/DriveAI-AutoGen
git pull origin main
```

Fuer jedes non-canonical File:
1. Oeffne die Datei
2. Finde den `struct WeakArea` Block (von `struct WeakArea` bis zur schliessenden `}`)
3. Entferne NUR diesen Block
4. Pruefe ob der Rest der Datei syntaktisch korrekt bleibt

### 4. Typecheck Recheck

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

### 5. Report

Report in `DeveloperReports/CodeAgent/49-0_WeakArea Dedup Report.md` mit:
1. Policy definiert
2. Canonical File gewaehlt
3. Was entfernt wurde
4. Typecheck-Ergebnis (Ziel: 0 Errors)

### 6. Commit + Push

```bash
git add -A
git commit -m "factory: duplicate-type collision policy + fix WeakArea 3x definition

- Policy: dedicated-file-wins (TypeName.swift is canonical)
- Removed inline WeakArea from AssessmentResult.swift and Recommendation.swift
- Canonical: Models/WeakArea.swift
- Report 49-0

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>"
git push
```

Ergebnis in `_commands/008_weakarea_dedup_fix_result.md` speichern.
