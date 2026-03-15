# DrivaAI-AutoGen Step Report – ML-30

## Title
Project-Aware Completion Verifier Baseline Before the Ninth Autonomy Proof

## Why this step now
ML-29 delivered a real central win.

The SwiftUI-aware PropertyShapeRepairer fix did exactly what it was supposed to do:
it removed the last FK-013 blocking case, eliminated the remaining hard compile-hygiene blocker, and moved the current project state to zero blocking issues.

That is a major milestone because the factory is no longer primarily blocked by compile-shape repair.

But the latest report also exposed the next deeper central weakness:
the CompletionVerifier is still not producing trustworthy completion judgments because it fails when no `specs/` directory exists.
That means a known verification-layer weakness can still distort the meaning of the next full autonomy proof and can block or degrade recovery behavior.

So the next correct move is not another blind end-to-end run yet.
The next correct move is to repair the truth layer that decides whether a run should be considered complete, incomplete, or failed.

## Background
The latest report established:

- the SwiftUI-aware counting fix worked
- the previous FK-013 blocking case is gone
- Compile Hygiene now reports 0 BLOCKING and warnings only
- no regression was introduced in the currently working repair paths
- the factory is now strong enough that the next meaningful bottleneck is no longer compile-hygiene blocking
- the CompletionVerifier still has a structural weakness: it expects `specs/` and can fail for the wrong reason when that directory is absent
- this weakens downstream confidence, recovery correctness, and run verdict quality

This means the next autonomy proof would still be partially contaminated by a known false-verdict mechanism unless we fix that layer first.

## Strategic reasoning
This is a central factory step, not an app step.

A factory that aims toward real autonomy cannot rely on a verifier that hard-fails because one expected folder is missing.
The verifier must become project-aware, evidence-based, and honest:
it should judge completion from actual project context, generated artifacts, build evidence, and available requirements sources.

Without that, the system may:
- report failure when the real problem is only missing verifier inputs
- block recovery on a false negative
- reduce the value of otherwise successful proof runs
- hide the next real autonomy blocker behind verification noise

So before Run 9, we should strengthen the completion-truth layer.

## Goal
Upgrade the CompletionVerifier so it can make a project-aware, evidence-based verdict even when a `specs/` directory is absent.

## Desired outcome
- the CompletionVerifier no longer hard-fails just because `specs/` does not exist
- the verifier can derive completion evidence from other valid project sources
- the verifier distinguishes between:
  - no evidence available
  - partial evidence available
  - strong completion evidence
  - explicit failure evidence
- recovery is no longer blocked by this specific false-verdict condition
- the next full autonomy proof can produce a more trustworthy run verdict

## In scope
- inspect the current CompletionVerifier assumptions and failure logic
- identify exactly where missing `specs/` becomes a hard failure
- redesign the verifier so it supports projects without a `specs/` directory
- make the verifier project-aware and evidence-based using available sources such as:
  - project context
  - README / docs / requirements-like material if present
  - generated outputs
  - compile results
  - operations-layer artifacts
  - stage results / run metadata
- produce a verdict model that can express:
  - PASS
  - PARTIAL
  - FAIL
  - INSUFFICIENT_EVIDENCE (or equivalent honest state if needed)
- ensure recovery gating uses the improved verifier result more safely
- run a targeted validation of the new verifier behavior on the current AskFin project state

## Out of scope
- full ninth end-to-end autonomy proof in this step
- app feature work
- UI work
- manual content creation of a fake `specs/` directory just to satisfy the verifier
- broad redesign of all operations-layer modules
- commercialization work
- provider-routing expansion
- long-horizon multi-platform work

## Success criteria
- missing `specs/` no longer causes an automatic misleading failure
- the verifier produces a grounded, inspectable verdict on the current project
- the verdict logic is more reusable across future projects with different documentation layouts
- recovery is no longer blocked by this exact verifier weakness
- we are in a stronger position to run a ninth full autonomy proof afterward

## Strategic note for later planning
The larger DriveAI-AutoGen direction remains unchanged:
build toward a highly autonomous, self-improving factory with stronger central coordination, layered planning, safer decomposition, more reliable truth/evidence systems, and later broader multi-provider / multi-model routing.
This step specifically strengthens the truth-and-verification layer of that factory.

## Claude Code Prompt
```text
Goal:
Upgrade the CompletionVerifier so it becomes project-aware and can make an honest evidence-based completion verdict even when no `specs/` directory exists.

Task:
Inspect the current CompletionVerifier implementation and identify exactly why it fails when `specs/` is absent.
Replace that brittle assumption with a more robust project-aware evidence model that can evaluate completion from available project artifacts and run evidence.

Important:
Do not solve this by adding a fake `specs/` folder just to satisfy the current implementation.
Do not hide uncertainty.
If evidence is weak, the verifier should say so explicitly instead of pretending success or forcing failure.
The goal is a central factory-layer improvement, not a project-specific workaround.

Focus especially on:
- where `specs/` is assumed as mandatory
- what other evidence sources already exist in the pipeline
- how to derive an honest verdict from available signals
- how verifier output influences recovery decisions
- how to avoid false FAIL results caused only by missing verifier inputs

Required checks:
1. Identify the exact hard-failure path caused by missing `specs/`.
2. Implement the smallest robust central redesign that supports projects without `specs/`.
3. Define and use a clearer verdict model such as PASS / PARTIAL / FAIL / INSUFFICIENT_EVIDENCE (or a similarly honest equivalent).
4. Validate the new verifier on the current AskFin project state.
5. Confirm whether recovery would still be blocked for the old reason.
6. Confirm that the change does not weaken honest failure detection.
7. State whether the system is now ready for a ninth full autonomy proof run.

Expected report:
1. Root cause in the old CompletionVerifier logic
2. Exact central fix implemented
3. New verdict / evidence model
4. What sources of evidence are now used
5. Validation on the current project
6. Whether recovery is still blocked for the old reason
7. Risks or limitations that remain
8. Single next recommended step
```

## What happens after this
If the CompletionVerifier becomes trustworthy on the current project state, the next correct move is the ninth full end-to-end autonomy proof run from this stronger baseline.
If a new structural weakness appears during this verifier upgrade, then the next step should target that newly isolated truth-layer gap before returning to full-run proofing.
