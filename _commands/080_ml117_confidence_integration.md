# 080 Ml117 Confidence Integration

**Status**: pending
**Erstellt**: 2026-03-18
**Quelle**: Prompt Pilot (automatisch)

## Auftrag

# mac-driveai-ml117-confidence-integration.md

Goal:
Integrate user confidence feedback into the adaptive scoring system.

Prompt ist für Mac

Task:
Modify weightedAccuracy (or equivalent signal) to include confidence feedback from SessionResult.

Important:
Do not redesign architecture.
Keep weighting simple (e.g. penalize unsure answers, reward confident correct answers).

Checks:
- confidence affects scoring
- adaptive selection changes accordingly
- build remains green

Expected:
1. Scoring adjustment
2. Integration logic
3. Observed effect
4. Build result
5. Next step

## Nach Abschluss

1. Ergebnis in `_commands/080_ml117_confidence_integration_result.md`
2. `git add -A && git commit -m "ml117_confidence_integration: execute command 080" && git push`
