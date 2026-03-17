# 070 Ml107 Full Loop Validation

**Status**: pending
**Erstellt**: 2026-03-18
**Quelle**: Prompt Pilot (automatisch)

## Auftrag

# mac-driveai-ml107-full-loop-validation.md

Goal:
Validate the full insight-to-action loop as a continuous user journey.

Prompt ist für Mac

Task:
Simulate the full flow:
Exam → Result → Drilldown → Detail → "Jetzt üben" → Training

Verify that:
- navigation works across all steps
- data/context is preserved
- no broken states occur

Important:
Do not add features.
Do not refactor architecture.
This is a validation step only.

Checks:
- full loop works end-to-end
- correct data flows through each step
- no UI or state inconsistencies
- build and gates remain green

Expected:
1. Full flow validation result
2. Any inconsistencies found
3. Gate/build result
4. Single next step

## Nach Abschluss

1. Ergebnis in `_commands/070_ml107_full_loop_validation_result.md`
2. `git add -A && git commit -m "ml107_full_loop_validation: execute command 070" && git push`
