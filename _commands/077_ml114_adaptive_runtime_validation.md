# 077 Ml114 Adaptive Runtime Validation

**Status**: pending
**Erstellt**: 2026-03-18
**Quelle**: Prompt Pilot (automatisch)

## Auftrag

# mac-driveai-ml114-adaptive-runtime-validation.md

Goal:
Run a focused runtime validation of the adaptive learning loop across repeated sessions and confirm that persisted learning signals influence future selection coherently.

Prompt ist für Mac

Task:
Inspect the current adaptive training behavior at runtime and validate whether persisted learning signals (`totalAnswers`, `correctAnswers`, `weightedAccuracy`, `lastReviewedDate`) actually influence future session selection in a coherent and observable way.

Current confirmed state:
- adaptive topic prioritization already exists in `TrainingSessionViewModel`
- `TopicCompetence` persistence already exists
- cold restart persistence is confirmed
- no new code was required for signal persistence

Important:
Do not start another generation/autonomy run.
Do not redesign the adaptive logic.
Do not add new product features in this step.
The goal is runtime validation of the already-existing adaptive learning behavior.

Focus especially on:
- whether repeated sessions alter topic/question prioritization
- whether weaker topics become more likely in later sessions
- whether due/weak/least-covered behavior is actually visible in runtime outcomes
- whether restart preserves the learned signals and continues influencing selection
- whether the adaptive behavior is strong enough to be product-visible or still mostly internal

Required checks:
1. Inspect the current runtime path where adaptive topic selection can be observed.
2. Run repeated training sessions that create a measurable weak-area signal if practical.
3. Observe whether subsequent sessions prioritize the affected weak topic(s).
4. If practical, restart the app and verify that the prioritization still reflects persisted signals.
5. Record whether the adaptive learning behavior:
   - is clearly visible,
   - is partially visible,
   - or is technically present but not yet user-observable enough.
6. Confirm whether the protected baseline remains green.
7. End with one single next recommended step.

Expected report:
1. Runtime validation path used
2. Sessions executed and signals created
3. Observed adaptive prioritization outcome
4. Restart persistence influence outcome
5. Whether the adaptive loop is product-visible enough
6. Build/gate result if run
7. Single next recommended step

## Nach Abschluss

1. Ergebnis in `_commands/077_ml114_adaptive_runtime_validation_result.md`
2. `git add -A && git commit -m "ml114_adaptive_runtime_validation: execute command 077" && git push`
