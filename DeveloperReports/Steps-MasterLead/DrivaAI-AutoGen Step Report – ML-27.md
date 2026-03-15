# DrivaAI-AutoGen Step Report – ML-27

## Title
Initializer/Property Mismatch Repair for Real FK-013 Blocker

## Why this step now
The latest OutputIntegrator semantic-dedup step was successful enough that the factory is no longer mainly blocked by integration contamination.

The decisive result is:
- FK-012 from OutputIntegrator semantic duplicates is reduced to **0**
- FK-011 markdown contamination is reduced to **0**
- FK-014 missing-type blockers were already handled by the stub-generator path
- only **1 real blocking issue** remains

That remaining blocker is no longer infrastructural noise.
It is a real code-generation / fix-loop issue:
`ExamReadinessSnapshot(categoryBreakdown: ...)` is being used as though a matching initializer / stored-property shape exists, but the current struct shape does not support that call.

This means the next clean factory target is now a **real initializer/property mismatch repair path**.

## Background
The latest report established:

- OutputIntegrator now performs type-level dedup against project-owned types
- generated semantic duplicates under different filenames/folders are skipped
- obvious markdown contamination like `---` is stripped before write
- blocking issue count drops from **5 to 1**
- the remaining blocker is **FK-013**, and it is described as real rather than validator noise

This is an important transition:
the factory now needs to prove it can fix a genuine compile-shape mismatch, not just defend itself against integration or validation defects.

## Strategic reasoning
We should not jump straight to another proof run.

Why?
Because the report already tells us the current dominant blocker with high confidence.
Running again first would very likely just reproduce the same real compile failure.

The clean order is:
1. add a narrow, deterministic repair path for initializer/property mismatch blockers
2. validate that this class of real FK-013 can now become actionable
3. then run the next full end-to-end autonomy proof

This keeps the next proof run focused on deeper remaining live blockers rather than replaying the same known compile-shape error.

## Goal
Enable the factory to autonomously act on real FK-013 initializer/property mismatch blockers, especially struct/memberwise-init mismatches such as `ExamReadinessSnapshot(categoryBreakdown: ...)`.

## Desired outcome
- real initializer/property mismatch blockers become actionable
- the factory can generate a narrow structural repair instead of just reporting the blocker
- the next autonomy proof is not dominated by the already-known `ExamReadinessSnapshot` mismatch
- if a new blocker appears afterward, it will likely be deeper in the live factory path

## In scope
- trace where the current FK-013 mismatch is detected
- identify the smallest safe factory-level control point where real initializer/property-shape mismatches can become fix tasks
- implement a minimal deterministic repair path for cases like:
  - missing stored property for an expected memberwise init argument
  - struct shape not matching call site assumptions
  - initializer signature mismatch where the intended model shape is clear enough
- preserve explicit logging/reporting for:
  - mismatch detected
  - target type
  - expected arguments/properties
  - repair action taken
  - whether the fix is a scaffold/shape repair or a fuller model repair
- run the closest practical validation

## Out of scope
- broad model-architecture redesign
- one-off manual AskFin patching unless clearly reusable at factory level
- compile-hygiene rewrite
- recovery redesign beyond what is needed to make this blocker actionable
- multi-provider routing implementation
- marketing/legal/roadmap layers
- masking ambiguity where the intended type shape cannot be inferred safely

## Success criteria
- exact root cause of the remaining FK-013 mismatch identified
- minimal factory-level repair path implemented
- before/after evidence that this mismatch class is materially more actionable
- the next full autonomy proof becomes the correct follow-up step

## Strategic note for later planning
Multi-provider / multi-model routing remains in future factory planning as a separate architecture step for rate-limit headroom, cost control, fallback resilience, and role/task-based model selection. It should be introduced later without interrupting the current autonomy-core stabilization path.

## Claude Code Prompt
```text
Goal:
Enable the factory to autonomously act on real FK-013 initializer/property mismatch blockers, especially struct/memberwise-init mismatches such as `ExamReadinessSnapshot(categoryBreakdown: ...)`.

Task:
Audit and minimally improve the current compile-hygiene / fix-path so real initializer/property mismatch blockers can become actionable repairs instead of just remaining reported compile failures.

Do not:
- redesign the full model architecture
- patch AskFin manually in a one-off way unless the logic is clearly reusable at factory level
- perform a broad compile-hygiene rewrite
- change recovery, knowledge, CD policy, or model-routing systems beyond what is needed for this blocker
- hide uncertainty if the intended type shape cannot be inferred safely

Required work:
1. Trace exactly why the remaining FK-013 blocker occurs for `ExamReadinessSnapshot` (or the equivalent remaining real mismatch).
2. Identify the smallest safe control point where this mismatch class can be transformed into a fix action.
3. Implement a minimal factory-level repair path for cases where:
   - a call site assumes a memberwise initializer argument that has no matching stored property,
   - or a model type shape clearly mismatches its current use.
4. Prefer narrow structural repairs such as:
   - adding the missing stored property when the intended shape is clear,
   - aligning a simple initializer signature with the existing model shape,
   - or generating a targeted scaffold/shape-repair task.
5. Preserve explicit logging/reporting for:
   - mismatch detected
   - target type
   - expected args/properties
   - chosen repair action
   - whether the repair was applied, scaffolded, or deferred
6. Keep the fix narrow, deterministic, and auditable.
7. Run the closest practical validation to prove the mismatch class is now materially more actionable.

Validation:
- show before/after handling for the representative FK-013 mismatch
- show how the blocker now enters the repair/fix path
- show expected impact on blocking issue count
- if full end-to-end validation is too expensive, provide code-path proof plus the closest runnable validation

Expected report:
1. Current real FK-013 root cause
2. Minimal fix implemented
3. Files changed
4. Before vs after repair-path behavior
5. Remaining limits
6. Whether real initializer/property mismatch blockers are now materially more actionable
```

## What happens after this
If this step succeeds, the next step should be a new full end-to-end autonomy proof run on AskFin.
That run should reveal whether the factory is now beyond the known `ExamReadinessSnapshot` mismatch and what the next true live blocker is, if any.
