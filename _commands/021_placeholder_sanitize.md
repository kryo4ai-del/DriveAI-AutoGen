# 021 ExamReadinessResult Placeholder Sanitization

**Status**: pending
**Ziel**: Pseudo-Code-Platzhalter `(...)` entfernen oder ersetzen

## Auftrag

1. Lies `Models/ExamReadinessResult.swift` komplett
2. Finde alle `(...)` Platzhalter
3. Entscheide pro Stelle:
   - Wenn es ein Funktionsaufruf mit `(...)` als Argument ist → durch sinnvollen Default ersetzen (leerer String, 0, [], nil etc.)
   - Wenn es ein ganzer Code-Block ist der nur aus `(...)` besteht → Quarantine-Kandidat
   - Wenn die ganze Datei hauptsaechlich Pseudo-Code ist → in `quarantine/` verschieben
4. Pruefe ob andere Files von ExamReadinessResult abhaengen:
   ```bash
   grep -r "ExamReadinessResult" projects/askfin_v1-1/ --include="*.swift" -l
   ```
5. Falls keine Abhaengigkeiten → Quarantine ist sicher
6. Falls Abhaengigkeiten → Minimalen Stub behalten

## Policy

- Pattern: `pseudo-code-placeholder`
- Wenn File >50% Platzhalter → `quarantine`
- Wenn einzelne Stelle → `replace-with-default`
- Gleiches Pattern wie bereits quarantinierte Files (WeakCategory, Priority)

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

Ergebnis in `_commands/021_placeholder_sanitize_result.md`:
- Was gefunden (Platzhalter-Stellen)
- Entscheidung: Quarantine oder Fix
- Typecheck-Ergebnis nach Fix
- Naechster Blocker falls vorhanden

## Git

```bash
git add -A
git commit -m "fix: ExamReadinessResult placeholder sanitization (Report 62-0)

- Pseudo-code placeholder entfernt/quarantined
- Policy: pseudo-code-placeholder"
git push
```
