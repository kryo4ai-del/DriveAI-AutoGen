# 081 Ml118 Confidence Runtime Validation

**Status**: pending
**Erstellt**: 2026-03-18
**Quelle**: Prompt Pilot (automatisch)

## Auftrag

# mac-driveai-ml118-confidence-runtime-validation.md

Goal:
Run a focused runtime validation to confirm that confidence feedback materially changes future topic prioritization in a coherent way.

Prompt ist für Mac

Task:
Validate the new confidence-aware scoring behavior at runtime by creating a measurable difference between low-confidence and high-confidence answers, then observing whether later training sessions prioritize the affected topics differently.

Current confirmed state:
- confidence feedback is captured
- weighting is integrated into `weightedAccuracy`
- multipliers:
  - unsure = 0.7x
  - okay = 1.0x
  - confident = 1.2x
- weak topics remain longer in `weakestTopics()`
- build succeeded

Important:
Do not start another generation/autonomy run.
Do not redesign the adaptive system.
Do not add new product features in this step.
The goal is runtime validation of the already-integrated confidence-aware adaptation.

Focus especially on:
- whether low-confidence correct/incorrect answers keep a topic under pressure longer
- whether high-confidence correct answers reduce future priority appropriately
- whether the resulting prioritization is observable in later sessions
- whether restart preserves the effect if practical
- whether the behavior feels coherent enough to count as real product intelligence

Required checks:
1. Run repeated sessions that create contrasting confidence signals on at least one topic.
2. Observe whether later sessions prioritize the low-confidence topic(s) more strongly.
3. If practical, restart the app and verify the effect persists.
4. Record whether the behavior is:
   - clearly visible,
   - partially visible,
   - or technically present but still too implicit.
5. Confirm whether the protected baseline remains green.
6. End with one single next recommended step.

Expected report:
1. Runtime validation path used
2. Sessions/signals created
3. Observed prioritization outcome
4. Restart persistence outcome if tested
5. Whether confidence-aware adaptation is product-visible enough
6. Build/gate result if run
7. Single next recommended step

## Nach Abschluss

1. Ergebnis in `_commands/081_ml118_confidence_runtime_validation_result.md`
2. `git add -A && git commit -m "ml118_confidence_runtime_validation: execute command 081" && git push`
