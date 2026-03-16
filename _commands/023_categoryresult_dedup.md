# 023 CategoryResult Dedup + QuestionAttempt Stub

**Status**: pending
**Ziel**: CategoryResult Duplikat aufloesen + fehlenden QuestionAttempt Typ erstellen

## Auftrag

### Teil 1: CategoryResult Dedup

1. Finde beide Definitionen:
   - `Models/CategoryResult.swift` (Codable, Sendable)
   - `Models/ReadinessAssessment.swift:40` (Identifiable, Codable)
2. Kanonisch = `Models/CategoryResult.swift` (dedicated file wins)
3. Entferne die Definition aus `ReadinessAssessment.swift`
4. Merge ggf. fehlende Properties/Conformances in die kanonische Definition
5. Falls ReadinessAssessment die kanonische CategoryResult braucht: Import/Referenz passt automatisch (gleicher Module Scope)

### Teil 2: QuestionAttempt

1. Pruefe ob `QuestionAttempt` irgendwo definiert ist:
   ```bash
   grep -r "struct QuestionAttempt\|class QuestionAttempt\|enum QuestionAttempt" projects/askfin_v1-1/ --include="*.swift"
   ```
2. Falls nicht: Minimalen Stub erstellen in `Models/QuestionAttempt.swift`
3. Properties aus Aufrufstellen ableiten

## Policy

- CategoryResult: `dedicated-file-wins` (wie WeakArea Report 49-0, LocalDataServiceProtocol Report 55-0)
- QuestionAttempt: `stub-or-minimal-implementation` (wie NetworkMonitor Report 53-0)

## Nach dem Fix

```bash
cd ~/DriveAI-AutoGen
xcrun swiftc -typecheck \
  projects/askfin_v1-1/**/*.swift \
  -sdk $(xcrun --show-sdk-path) \
  -target arm64-apple-macosx15.0 \
  2>&1 | head -60
```

## Report

Ergebnis in `_commands/023_categoryresult_dedup_result.md`:
- CategoryResult: Welche Definition kanonisch + was gemerged
- QuestionAttempt: Erstellt oder gefunden?
- Typecheck-Ergebnis nach Fix
- Naechster Blocker falls vorhanden

## Git

```bash
git add -A
git commit -m "fix: CategoryResult dedup + QuestionAttempt stub (Report 64-0)

- dedicated-file-wins fuer CategoryResult
- QuestionAttempt stub erstellt falls fehlend"
git push
```
