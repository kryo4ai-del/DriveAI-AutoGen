# DrivaAI-AutoGen Step Report – ML-57

## Title
FK-031 Snapshot Model Contract Completer for the Remaining `ExamReadinessSnapshot` Property Gaps

## Why this step now
ML-56 delivered another precise low-cost win.

The remaining SwiftUI view-structure blocker is now resolved centrally:
- `ReadinessLevelBadge.swift` was normalized from the old Group/switch shape into a canonical computed-property pattern
- badge errors dropped from 10 to 0
- enum cases were aligned to the current `ReadinessLevel` contract

That is strategically important because the previous blocker family is fully cleared.
The Mac-side typecheck now exposes one new remaining unique blocker family:

- `ReadinessHeaderSection.swift`
- 6 errors
- `ExamReadinessSnapshot` is missing expected properties

So the next correct move is not another expensive generation run and not a broad architecture rewrite.
The next correct move is a small central snapshot/model contract-completion step for this newly exposed property-gap family.

## Background
The latest report established:

- the previous SwiftUI structure family is solved
- the active baseline is cleaner again
- the newly exposed blocker is not about syntax, imports, duplicate definitions, protocol drift, or view-builder structure
- it is a model/snapshot property-contract mismatch:
  consuming UI code expects properties on `ExamReadinessSnapshot` that the canonical snapshot model does not currently provide

This means the remaining problem is now a classic snapshot contract drift family:
view code is written against a richer read-model surface than the current snapshot type actually declares.

That is exactly the kind of blocker we should still solve cheaply and centrally before thinking about any new model-driven run.

## Strategic reasoning
We should solve this as a reusable snapshot/model contract-completion rule, not as an ad hoc local edit.

Why?
Because this failure family is repeatable in generated app code:
- snapshot/read-model structs are used with expected derived or stored properties
- the canonical snapshot exists but lags behind consumer expectations
- UI-facing contracts drift from model definitions over time

If we only patch the current file by hand without defining the rule, we clear the symptom but not the class.
A better next step is:
- identify the canonical `ExamReadinessSnapshot` owner
- determine which properties belong canonically on the snapshot
- add the smallest central rule/policy for snapshot contract completion
- validate it on the current `ExamReadinessSnapshot` case

This keeps the process cheap, disciplined, and evidence-driven.

## Goal
Identify and resolve the remaining `ExamReadinessSnapshot` property-gap blocker through the smallest robust central rule/policy, so snapshot/model contract drift is less likely to survive into the project baseline.

## Desired outcome
- the exact reason `ExamReadinessSnapshot` lacks the expected properties is identified
- the blocker is classified correctly as a snapshot/model contract family
- the current canonical snapshot type is completed or reconciled through the smallest safe central rule/policy
- the remaining unique blocker is resolved or materially reduced
- future runs gain a reusable safeguard against snapshot/model property-contract drift
- no expensive model run is required

## In scope
- inspect the canonical `ExamReadinessSnapshot` definition
- inspect `ReadinessHeaderSection.swift` and any other consumer(s) expecting the missing properties
- determine which properties belong canonically on the snapshot
- define the smallest useful central rule/policy for this snapshot/model contract family
- apply it to the current `ExamReadinessSnapshot` case
- prefer a central deterministic handling path over an unexplained one-off patch
- run a cheap Mac-side typecheck recheck afterward if practical
- record whether any remaining issues survive after this fix

## Out of scope
- another LLM generation/autonomy run
- broad redesign of readiness modeling or analytics
- unrelated feature work
- commercialization work
- large refactors beyond the current snapshot contract family

## Success criteria
- the exact remaining `ExamReadinessSnapshot` blocker is identified clearly
- a small reusable snapshot/model contract-completion rule/policy is added
- the current property gap is resolved or materially reduced
- the result is reusable for future snapshot/model contract drift
- the next step can again be chosen from cheap Mac build truth instead of another expensive proof run

## Strategic note for later planning
The broader DriveAI-AutoGen direction remains unchanged:
build toward a highly autonomous, self-improving factory with stronger central coordination, stronger truth systems, better lifecycle governance, richer planning and decomposition, and eventually trustworthy multi-provider / multi-model routing.
This step specifically strengthens the factory's ability to reconcile canonical snapshot/model definitions with real UI-facing property expectations instead of burning expensive generation runs.

## Claude Code Prompt
```text
Goal:
Identify and resolve the remaining `ExamReadinessSnapshot` property-gap blocker through the smallest robust central rule/policy, so snapshot/model contract drift is less likely to survive into the project baseline.

Prompt ist für Mac

Task:
Inspect the canonical `ExamReadinessSnapshot` definition and determine exactly why `ReadinessHeaderSection.swift` expects properties that are not currently present, whether those properties belong canonically on the snapshot, and what the smallest safe central resolution is for this snapshot/model contract family.

Current reported blocker:
- `ReadinessHeaderSection.swift`
- 6 errors
- `ExamReadinessSnapshot` missing expected properties

Important:
Do not start another generation/autonomy run.
Do not solve this as a broad redesign of readiness modeling or analytics.
Do not treat this only as an unexplained one-off hand patch.
The goal is a reusable factory-layer snapshot/model contract-completion rule/policy, validated on the current `ExamReadinessSnapshot` case.

Focus especially on:
- where the canonical `ExamReadinessSnapshot` definition lives
- which consumer(s) expect the missing properties
- whether the mismatch is:
  - snapshot contract lag,
  - wrong consumer expectation,
  - naming drift,
  - or stale read-model drift
- how to keep the fix deterministic, minimal, and reusable

Required checks:
1. Identify the exact root cause of why `ExamReadinessSnapshot` lacks the expected properties.
2. Classify the blocker into the correct snapshot/model contract family.
3. Define the smallest useful central rule/policy for this family.
4. Apply it to the current `ExamReadinessSnapshot` case.
5. If practical, run a cheap Mac-side typecheck recheck afterward.
6. Confirm whether the remaining unique blocker is resolved or materially reduced.
7. End with one single next recommended step.

Expected report:
1. Root cause of the current `ExamReadinessSnapshot` blocker
2. Exact central policy/rule implemented
3. How the snapshot/model contract issue was resolved
4. Recheck outcome if run
5. Regression/safety summary
6. Whether the baseline is now cleaner for a deeper build check
7. Single next recommended step
```

## What happens after this
If the remaining `ExamReadinessSnapshot` blocker is resolved cleanly, the next best step is another cheap Mac-side build/typecheck recheck from the same baseline.
If a new blocker appears, the next step should classify whether it is another reusable snapshot/model contract family or a different final build-truth layer.
