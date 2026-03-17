# 069 Ml106 Drilldown To Training

**Status**: pending
**Erstellt**: 2026-03-17
**Quelle**: Prompt Pilot (automatisch)

## Auftrag

# mac-driveai-ml106-drilldown-to-training.md

Goal:
Allow users to start a focused training session directly from the weakness drilldown view.

Prompt ist für Mac

Task:
Inspect the current drilldown (topic detail sheet) and add a CTA that starts an existing training flow for that weakness.

Important:
Do not introduce new models.
Do not redesign flows.
Reuse existing training entry points.

Checks:
- CTA triggers training correctly
- correct topic passed
- build remains green
- no regression in existing flows

Expected:
1. What was added
2. How training is triggered
3. Build/gate result
4. Next step

## Nach Abschluss

1. Ergebnis in `_commands/069_ml106_drilldown_to_training_result.md`
2. `git add -A && git commit -m "ml106_drilldown_to_training: execute command 069" && git push`
