# 078 Ml115 Adaptive Visibility Layer

**Status**: pending
**Erstellt**: 2026-03-18
**Quelle**: Prompt Pilot (automatisch)

## Auftrag

# mac-driveai-ml115-adaptive-visibility-layer.md

Goal:
Design and implement the smallest bounded UI layer that makes AskFin’s adaptive learning behavior visible and understandable to the user without changing the underlying adaptive logic.

Prompt ist für Mac

Task:
Inspect where adaptive topic/question prioritization is currently decided and add the smallest coherent product-visible explanation layer so users can understand why certain questions or topics are being prioritized.

Current confirmed state:
- adaptive learning loop is technically complete
- prioritization order is:
  - dueTopics
  - weakestTopics
  - leastCoveredTopics
- persisted signals influence future sessions
- cold restart behavior is confirmed
- current gap: adaptation is mostly implicit and not clearly visible to users

Important:
Do not start another generation/autonomy run.
Do not redesign the adaptive logic itself.
Do not introduce large UI changes.
The goal is a bounded visibility/explanation layer on top of already-working adaptive behavior.

Focus especially on:
- where the smallest meaningful explanation can appear
- whether the explanation belongs:
  - before session start
  - inside the training session
  - on a topic/question header
  - or as a compact priority badge/label
- keeping the explanation truthful to the actual logic
- keeping it lightweight, understandable, and non-intrusive
- preserving build/runtime/golden gate stability afterward

Required checks:
1. Inspect where adaptive priority is currently computed and exposed.
2. Choose the smallest coherent visibility surface for adaptive reasoning.
3. Implement the bounded explanation layer.
4. Verify that the explanation matches actual priority causes.
5. Run the golden gate suite afterward if practical.
6. Record whether:
   - the explanation is now visible,
   - it matches the underlying logic,
   - the baseline remains green,
   - or a concrete blocker appears.
7. If a blocker appears, isolate the first concrete blocker exactly.
8. End with one single next recommended step.

Expected report:
1. Adaptive priority path inspected
2. Visibility surface chosen and why
3. Implementation summary
4. Runtime outcome
5. Golden gate outcome
6. Any blockers found
7. Single next recommended step

## Nach Abschluss

1. Ergebnis in `_commands/078_ml115_adaptive_visibility_layer_result.md`
2. `git add -A && git commit -m "ml115_adaptive_visibility_layer: execute command 078" && git push`
