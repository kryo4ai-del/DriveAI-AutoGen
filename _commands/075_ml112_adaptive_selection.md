# 075 Ml112 Adaptive Selection

**Status**: pending
**Erstellt**: 2026-03-18
**Quelle**: Prompt Pilot (automatisch)

## Auftrag

# mac-driveai-ml112-adaptive-selection.md

Goal:
Introduce a minimal adaptive question selection mechanism based on weakness signals.

Prompt ist für Mac

Task:
Modify the question selection logic so that weaker topics are prioritized during training sessions.

Important:
Do not introduce complex scoring systems.
Do not redesign architecture.
Keep logic simple and bounded.

Focus:
- reuse existing weakness signals
- simple weighting or prioritization
- stable selection behavior

Checks:
- weaker topics appear more frequently
- no crashes or bias issues
- flows still work
- baseline remains green

Expected:
1. Selection strategy
2. Implementation summary
3. Behavior validation
4. Build/gate result
5. Next step

## Nach Abschluss

1. Ergebnis in `_commands/075_ml112_adaptive_selection_result.md`
2. `git add -A && git commit -m "ml112_adaptive_selection: execute command 075" && git push`
