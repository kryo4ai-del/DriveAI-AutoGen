# 017 ExamReadinessSnapshot Contract Fix

**Status**: pending
**Ziel**: Fehlende Properties auf ExamReadinessSnapshot ergaenzen

## Auftrag

1. Lies die kanonische `ExamReadinessSnapshot` Definition (vermutlich `Models/ExamReadinessSnapshot.swift`)
2. Lies `ReadinessHeaderSection.swift` — dort werden 3 fehlende Properties erwartet:
   - `score` (vermutlich Double oder ReadinessScore)
   - `contextualStatement` (vermutlich String)
   - `examHasPassed` (vermutlich Bool)
3. Leite die Return-Types aus den Aufrufstellen ab
4. Ergaenze die fehlenden stored properties auf ExamReadinessSnapshot
5. Falls ExamReadinessSnapshot ein struct ist: Memberwise-Init passt sich automatisch an
6. Falls class: Init anpassen
7. Policy: `consumer-declares-need`

## Policy

Gleiche Policy wie Report 54-0 (Protocol Contract) und 56-0 (enum display contract):
- `consumer-declares-need` — Consumer definiert was gebraucht wird, Model liefert nach

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

Ergebnis in `_commands/017_snapshot_contract_fix_result.md`:
- Welche Properties ergaenzt + Types
- Typecheck-Ergebnis nach Fix
- Naechster Blocker falls vorhanden

## Git

```bash
git add -A
git commit -m "fix: ExamReadinessSnapshot contract completion (Report 58-0)

- 3 fehlende Properties ergaenzt (score, contextualStatement, examHasPassed)
- Policy: consumer-declares-need"
git push
```
