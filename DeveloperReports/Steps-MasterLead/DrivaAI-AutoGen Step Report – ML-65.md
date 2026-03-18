# DrivaAI-AutoGen Step Report – ML-65

## Title
FK-039 Canonical ExamReadiness Model Reconstruction and Service Contract Realignment

## Why this step now
The latest Mac-side quarantine + batch-fix loop did exactly what a good low-cost truth pass should do:
it removed multiple noisy blocker families cheaply, stopped at the right moment, and exposed the next real architectural issue.

The important result is not just that several files were quarantined or patched.
It is that the remaining stop condition is now clearly **not** another superficial compile-hygiene issue.

The stop reason is:

- `ExamReadiness` is structurally incomplete
- the current `ExamReadiness` type is effectively only a fragment
- `ExamReadinessService` expects real model properties such as:
  - `overallScore`
  - `categoryScores`
  - and related readiness data
- those properties do not exist on the canonical model

That means the next correct move is not another expensive generation run and not another blind batch-fix loop.
The next correct move is a deliberate central model reconstruction step.

## Background
The latest report established:

- 7 rounds completed, stop at round 8
- 4 files quarantined
- 12 files changed/created
- multiple residual blocker families were cleared cheaply
- the loop stopped only when it reached a true architecture-level mismatch
- the report explicitly states: **ExamReadiness model redesign required**
- the current `ExamReadiness` struct is only a fragment with a nested enum
- the service layer expects a richer canonical read model than currently exists

This is strategically important because the system is now no longer blocked by general mess.
It has compressed the uncertainty into one central domain-model decision.

## Strategic reasoning
We should not treat this as just another one-off compile fix.

Why?
Because this is exactly the kind of deeper layer you said should be preferred over endless local repairs.
The problem is no longer:
- import hygiene
- duplicate definitions
- pseudo-code leftovers
- call-shape ambiguity
- isolated service gaps

The problem is now:
**What is the canonical shape of `ExamReadiness` as a real domain/read model?**

If we only patch the few currently missing properties without deciding the canonical model intentionally, we risk creating another temporary shell that later drifts again.

A better next step is:
- define the canonical responsibility of `ExamReadiness`
- decide what properties truly belong on it
- align `ExamReadinessService` to that canonical model
- use that as the single source of truth for future consumers

This is a true system-layer step, not just another compile bandage.

## Goal
Reconstruct `ExamReadiness` as a canonical model/read-model and realign `ExamReadinessService` to that model, so future readiness consumers stop drifting against a fragmentary type.

## Desired outcome
- the canonical owner and role of `ExamReadiness` is defined clearly
- `ExamReadiness` is expanded from fragment to real model/read-model
- the properties expected by `ExamReadinessService` are either:
  - added canonically,
  - renamed canonically,
  - or rejected with a clear service-side realignment
- the service/model contract becomes explicit and internally consistent
- future compile issues stop surfacing from this same readiness-model drift family
- no expensive model run is required

## In scope
- inspect the current `ExamReadiness` definition
- inspect `ExamReadinessService` and its expectations
- inspect major consumers of `ExamReadiness` if needed for canonical shape
- determine whether `ExamReadiness` should be:
  - a pure domain model,
  - a read model / projection,
  - or a hybrid UI-facing readiness summary model
- define the smallest useful canonical property set
- realign the service contract to that canonical shape
- implement the minimal central reconstruction needed
- run a cheap Mac-side typecheck recheck afterward if practical
- record whether remaining issues survive after this model realignment

## Out of scope
- another LLM generation/autonomy run
- broad redesign of the whole readiness subsystem beyond the current canonical model issue
- unrelated feature work
- commercialization work
- speculative UI redesign

## Success criteria
- the exact architectural problem in `ExamReadiness` is identified clearly
- a canonical model/read-model decision is made
- `ExamReadiness` is reconstructed or realigned into a coherent canonical shape
- `ExamReadinessService` is brought into contract alignment with that shape
- the result is reusable as the canonical readiness model going forward
- the next step can again be chosen from cheap Mac build truth instead of another expensive proof run

## Strategic note for later planning
The broader DriveAI-AutoGen direction remains unchanged:
build toward a highly autonomous, self-improving factory with stronger central coordination, stronger truth systems, better lifecycle governance, richer planning and decomposition, and eventually trustworthy multi-provider / multi-model routing.
This step specifically strengthens the factory's ability to stop local compile-fix churn by restoring a canonical domain/read-model layer where the current architecture has collapsed into fragments.

## Claude Code Prompt
```text
Goal:
Reconstruct `ExamReadiness` as a canonical model/read-model and realign `ExamReadinessService` to that model, so future readiness consumers stop drifting against a fragmentary type.

Prompt ist für Mac

Task:
Inspect the current `ExamReadiness` definition, `ExamReadinessService`, and the main consumers that rely on readiness data.
Determine exactly why the current `ExamReadiness` type is only a fragment, what the canonical model/read-model should contain, and implement the smallest safe central reconstruction so the service/model contract becomes coherent again.

Current reported stop reason:
- `ExamReadiness` struct is effectively a fragment (only nested enum / incomplete shape)
- `ExamReadinessService` expects properties such as:
  - `overallScore`
  - `categoryScores`
  - and related readiness data
- architecture/model decision is required

Important:
Do not start another generation/autonomy run.
Do not solve this as a chain of ad hoc property patches without first deciding the canonical model shape.
Do not do a broad redesign of unrelated readiness UI or analytics layers.
The goal is a reusable factory-layer canonical model reconstruction / service realignment step, validated on the current `ExamReadiness` family.

Focus especially on:
- where the canonical `ExamReadiness` definition lives
- whether `ExamReadiness` should be treated as:
  - domain model,
  - read model / projection,
  - or hybrid summary model
- which properties truly belong canonically on it
- whether any currently expected properties should instead live on another type
- how to keep the fix deterministic, minimal, and reusable
- aligning `ExamReadinessService` to the chosen canonical model shape

Required checks:
1. Identify the exact architectural reason `ExamReadiness` is currently only a fragment.
2. Classify the blocker into the correct canonical-model / service-contract family.
3. Define the smallest useful central rule/policy for reconstructing this family.
4. Apply it to the current `ExamReadiness` / `ExamReadinessService` case.
5. If practical, run a cheap Mac-side typecheck recheck afterward.
6. Confirm whether the current remaining blocker family is resolved or materially reduced.
7. End with one single next recommended step.

Expected report:
1. Root cause of the current `ExamReadiness` architecture/model problem
2. Exact central policy/rule implemented
3. Canonical model shape chosen for `ExamReadiness`
4. How the service/model contract was realigned
5. Recheck outcome if run
6. Regression/safety summary
7. Single next recommended step
```

## What happens after this
If the `ExamReadiness` canonical model is reconstructed cleanly, the next best step is another cheap Mac-side build/typecheck recheck from the same baseline.
If new blockers appear, the next step should classify whether they are downstream consequences of the new canonical model or a different final build-truth layer.
