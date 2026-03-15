# DrivaAI-AutoGen Step Report – ML-24

## Title
Compile Hygiene Validator Hardening for Remaining False Positives

## Why this step now
The FK-014 type-stub fix was successful: missing-type blockers can now be handled autonomously even when the OutputIntegrator writes 0 files.

That changes the situation materially:
the dominant remaining blockers are no longer code-generation gaps.
They are now primarily **compile-hygiene truthfulness issues**.

The latest report shows:
- FK-014 is reduced to **0**
- total blocking issues drop further
- the remaining blockers are:
  - **FK-012** nested-type false positive (`ReadinessLevel`)
  - **FK-013** initializer/signature false positive (`DateComponentsValue`)

So the next best step is not another recovery change or another proof run first.
The next best step is to make the validator more truthful.

## Background
The report established a major transition:

- Compile Hygiene findings can now trigger deterministic stub generation
- a missing service type (`ReadinessCalculationService`) was scaffolded automatically
- re-running hygiene after stub generation reduced blocking issues further
- remaining blockers are now validator-side rather than generation-side

This means the factory is getting closer to a fair technical verdict.
But a new proof run right now would still be distorted by known validator false positives.

## Strategic reasoning
We should now target the smallest validator improvement that makes the next proof run more trustworthy.

Instead of changing application code again, the cleaner move is:
- improve **FK-012** handling so nested/internal type declarations are not incorrectly treated as duplicate collisions
- improve **FK-013** handling so known initializer signatures already present in the project are recognized correctly

This keeps the factory honest:
first make the validator tell the truth,
then trust the next autonomy proof to reveal the next real blocker.

## Goal
Reduce the remaining known Compile Hygiene false positives so the next full autonomy proof is judged on real technical blockers instead of validator noise.

## Desired outcome
- FK-012 false positives from nested types are materially reduced
- FK-013 false positives from known project initializer signatures are materially reduced
- Compile Hygiene becomes a more trustworthy gate
- the next proof run can expose the next real blocker from live evidence

## In scope
- trace the exact root cause of remaining FK-012 false positives
- trace the exact root cause of remaining FK-013 false positives
- implement narrow validator improvements such as:
  - scope/column-aware duplicate detection for nested types
  - project initializer/signature scanning or targeted initializer awareness
- preserve explicit reporting for why an issue is still raised or suppressed
- run the closest practical validation

## Out of scope
- broad compile-hygiene rewrite
- application-level manual AskFin patching
- recovery redesign
- model-routing implementation
- marketing/legal/roadmap layers
- masking true blockers

## Success criteria
- exact root cause of FK-012 and/or FK-013 false positives identified
- minimal validator hardening implemented
- before/after evidence that false positives are reduced
- Compile Hygiene becomes materially more truthful
- the next proof run becomes the correct follow-up step

## Strategic note for later planning
Multi-provider / multi-model routing remains in future factory planning as a separate factory-level architecture step. It should improve rate-limit headroom, cost control, fallback resilience, and role/task-based model selection later, without interrupting the current autonomy-core stabilization path.

## Claude Code Prompt
```text
Goal:
Make Compile Hygiene more truthful by reducing the remaining known false positives, especially FK-012 nested-type duplication and FK-013 initializer/signature detection issues.

Task:
Audit and minimally harden the current Compile Hygiene validator so the remaining known blockers are less likely to be false positives and the next full autonomy proof reflects real technical issues.

Do not:
- redesign the full validator architecture
- patch AskFin manually in a one-off way unless the logic is clearly reusable at factory level
- change recovery, knowledge, CD policy, or model-routing systems
- perform broad cleanup outside this blocker
- hide uncertainty when the validator still cannot decide safely

Required work:
1. Trace exactly why FK-012 is still raised for nested/internal type declarations such as `ReadinessLevel`.
2. Trace exactly why FK-013 is still raised for known initializer/signature usage such as `DateComponentsValue`.
3. Identify the smallest safe validator improvements, for example:
   - scope-aware or column-aware duplicate-type detection for FK-012,
   - project initializer/signature scanning or targeted known-init awareness for FK-013.
4. Keep the fix narrow, deterministic, and auditable.
5. Preserve explicit logging/reporting for:
   - issue raised
   - reason
   - evidence used
   - reason for suppression if a former false positive is now ignored
6. Run the closest practical validation to prove the validator is now materially more truthful.

Validation:
- show before/after validator behavior for representative FK-012 and FK-013 cases
- show whether each issue is now suppressed or still raised with clearer evidence
- show expected impact on blocking issue count
- if full end-to-end validation is too expensive, provide code-path proof plus the closest runnable validation

Expected report:
1. Current validator false-positive root causes
2. Minimal fix implemented
3. Files changed
4. Before vs after validator behavior
5. Remaining limits
6. Whether Compile Hygiene is now materially more truthful
```

## What happens after this
If this step succeeds, the next step should be a new full end-to-end autonomy proof run on AskFin.
That run should reveal whether the factory is now blocked by a real compile/runtime issue rather than by validator noise.
