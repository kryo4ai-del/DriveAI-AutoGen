# DrivaAI-AutoGen Step Report – ML-92

## Title
Protected Feature Expansion: Post-Exam Weakness Analysis Slice on the Golden AskFin Baseline

## Why this step now
Stopping ML-91 was the correct decision.

The proposed “Protected Evolution Loop” would have added formal workflow abstraction for a pattern that is already working in practice.

Current confirmed reality:
- 17/17 gates are green
- 3 bounded feature slices were added safely
- each successful cycle already followed:
  - select
  - implement
  - gate-check
  - absorb
  - promote
- there has been no regression event requiring another orchestration layer

So the problem is not “missing workflow formalization.”
The higher-leverage opportunity is to use the protected baseline for the next meaningful product capability.

## Strategic decision
The next correct move is:

**Option 1 — next real feature**

And the best bounded next feature is:

**Post-Exam Weakness Analysis after Generalprobe**

Not:
- another workflow abstraction layer
- not quarantine cleanup as the primary focus
- not docs-only work as the main next step

Quarantine cleanup should remain secondary unless it blocks the feature.
Docs/README should follow soon, but not ahead of the next high-value protected feature slice.

## Why this feature
This is the highest-leverage bounded next slice because it:

- builds directly on the newly protected Generalprobe result path
- uses already existing persisted exam results/history
- strengthens the product’s core learning value, not just UI polish
- creates a natural bridge between:
  - Generalprobe
  - Verlauf
  - Schwächen trainieren
  - Lernstand / Skill Map
- is more strategically valuable than a simple result detail screen
- is more product-central than export

This is exactly the right type of next move on a protected baseline:
small enough to stay safe,
important enough to increase real product intelligence.

## Goal
Design and implement the smallest coherent post-exam weakness-analysis slice on the protected AskFin baseline, then verify that the golden gates remain green.

## Desired outcome
- after a Generalprobe result, the app can show a bounded weakness-analysis view or section
- the slice uses already available exam/result data where practical
- the output is coherent and user-visible
- the existing protected baseline remains green
- the factory proves another safe product expansion cycle on top of the governed baseline

## In scope
- inspect the current Generalprobe result path and available persisted result data
- determine the smallest coherent weakness-analysis slice
- prefer a bounded feature such as:
  - weak categories/topics summary
  - top weak areas list
  - or a simple post-exam recommendation block
- keep the slice connected to the current product surfaces if practical
- implement the feature with tightly bounded scope
- run the golden gate suite afterward
- record whether:
  - the slice works
  - the baseline remains protected
  - or a concrete blocker appears

## Out of scope
- another broad autonomy cycle
- full adaptive learning engine
- broad analytics architecture redesign
- large quarantine cleanup
- docs-only work as the primary objective
- commercialization work

## Success criteria
- one bounded post-exam weakness-analysis feature slice exists
- it is user-visible and meaningful
- golden gates remain green afterward
- the project proves another safe protected evolution cycle on a product-significant feature

## Strategic note for later planning
The broader DriveAI-AutoGen direction remains unchanged:
build toward a highly autonomous, self-improving factory with stronger central coordination, stronger truth systems, better lifecycle governance, richer planning and decomposition, and eventually trustworthy multi-provider / multi-model routing.
This step specifically advances the system from “protected app with persisted exam results” to “protected app that begins turning exam results into actionable learning insight.”

## Claude Code Prompt
```text
Goal:
Design and implement the smallest coherent post-exam weakness-analysis slice on the protected AskFin baseline, then verify that the golden gates remain green.

Prompt ist für Mac

Task:
Inspect the current Generalprobe result path, persisted exam result/history data, and related Lernstand/Schwächen surfaces.
Determine the smallest meaningful weakness-analysis slice that can be built safely on top of the protected baseline.
Implement that bounded slice and then run the full golden gate suite to verify the baseline remains protected.

Current confirmed state:
- 17/17 gates are green
- Generalprobe runtime path is protected
- Generalprobe result persistence into Verlauf is protected
- the current “protected evolution” workflow already works in practice
- ML-91 (extra workflow formalization) was intentionally stopped as overengineering

Important:
Do not start a broad autonomy cycle.
Do not introduce a new orchestration/control layer.
Do not broaden into a full adaptive learning engine.
Do not do broad quarantine cleanup unless a blocker directly prevents this slice.
The goal is one minimal, meaningful, safe product expansion on the protected baseline.

Focus especially on:
- what the smallest meaningful post-exam weakness-analysis slice is
- how to reuse existing persisted exam/result data
- how to keep the slice tightly bounded, coherent, and testable
- whether the slice should live:
  - inside the exam result view,
  - as a linked detail surface,
  - or as a compact recommendation block
- preserving current build/runtime/product truth
- verifying the change against the full golden gate suite afterward

Required checks:
1. Inspect the current Generalprobe result/history baseline and identify the smallest coherent weakness-analysis slice.
2. State clearly which slice was chosen and why it is the safest meaningful next feature.
3. Implement the bounded feature.
4. Run the full golden gate suite afterward.
5. Record whether:
   - the new slice works,
   - all gates remain green,
   - or a concrete blocker appears.
6. If a blocker appears, isolate the first concrete blocker exactly.
7. End with one single next recommended step.

Expected report:
1. Feature candidate options considered
2. Chosen weakness-analysis slice and why
3. Implementation summary
4. Golden gate run outcome
5. Any blockers found
6. Interpretation of whether remaining issues are feature/data/UI/gate-related
7. Single next recommended step
```
