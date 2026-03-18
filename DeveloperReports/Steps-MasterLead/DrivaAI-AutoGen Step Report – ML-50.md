# DrivaAI-AutoGen Step Report – ML-50

## Title
FK-024 ViewModel Contract Reconciler for the Remaining ExamSessionViewModel Structural Errors

## Why this step now
ML-49 delivered another clean low-cost improvement.

The import-hygiene layer now covers SwiftUI as well:
- 40+ SwiftUI symbols were added centrally
- 29 files were auto-fixed with `import SwiftUI`
- `ExamSessionViewModel.swift` no longer fails because of missing SwiftUI imports
- the remaining error count dropped from 10 to 8

This is strategically important because the remaining failures are no longer hygiene-class issues.
They are now a single, clearly isolated structural contract family inside `ExamSessionViewModel.swift`.

The report identifies the remaining root causes precisely:
- `ExamTimerService` needs `ObservableObject` conformance
- `ExamSession` is expected to provide a `startTime` property
- `examSessionService` is referenced but not declared as a property

That means the next correct move is not another import expansion, not another expensive model run, and not a broad refactor.
The next correct move is a small central contract-reconciliation rule for this ViewModel/service/model mismatch family.

## Background
The recent sequence has now removed the cheap cross-file blocker families one by one:

- syntax fragments / top-level statements were sanitized
- residual preview/debug outliers were classified and handled
- Foundation imports were inferred centrally
- Combine imports were inferred centrally
- SwiftUI imports were inferred centrally
- duplicate `WeakArea` type collisions were resolved centrally

What remains is no longer diffuse build noise.
It is a focused structural mismatch inside a single file family, where the ViewModel expects contracts that the related model/service layer does not currently satisfy.

This is exactly the right moment to move from hygiene-class fixes to contract-class reconciliation.

## Strategic reasoning
We should still solve this centrally, not as an unprincipled local patch.

Why?
Because the failure family is reusable:
generated ViewModels can drift from their dependent service/model contracts in a few repeatable ways:
- expected property exists in usage but not in the model
- expected service property exists in usage but not in the ViewModel
- referenced service type lacks the conformance needed by the UI observation layer

If we only hand-edit `ExamSessionViewModel.swift`, we may clear this instance but fail to strengthen the factory against the same family later.
A better next step is a small deterministic contract-reconciliation layer, validated on the current family.

## Goal
Add a small deterministic ViewModel contract-reconciliation rule/policy so the remaining `ExamSessionViewModel.swift` structural errors are handled centrally and future ViewModel/service/model drift is less likely to survive into the project baseline.

## Desired outcome
- the `ExamSessionViewModel` error family is analyzed as a contract mismatch rather than generic compile noise
- the factory can classify at least these mismatch types:
  - missing required model property
  - missing required ViewModel dependency property
  - missing required observation conformance on a service type
- the current `ExamSessionViewModel` family is reconciled through the smallest safe central rule
- the remaining 8 structural errors are resolved or materially reduced
- future runs gain a reusable safeguard against this contract-drift family
- no expensive model run is required

## In scope
- inspect `ExamSessionViewModel.swift`
- inspect the related definitions for:
  - `ExamSession`
  - `ExamTimerService`
  - the expected `examSessionService` property path
- identify the exact contract mismatches
- define the smallest useful contract-reconciliation rule/policy
- apply it to the current ExamSession family
- prefer a central deterministic handling path over a one-off ad hoc patch
- run a cheap Mac-side typecheck recheck afterward if practical
- record whether any remaining issues survive after this reconciliation

## Out of scope
- another LLM generation/autonomy run
- broad domain redesign of all session models/services
- full symbol-graph infrastructure across the codebase
- unrelated feature work
- commercialization work
- large architecture refactors beyond the current mismatch family

## Success criteria
- the exact remaining `ExamSessionViewModel` mismatch family is identified clearly
- a small reusable contract-reconciliation rule/policy is added
- the current 8 structural errors are resolved or materially reduced
- the result is reusable for future ViewModel/service/model contract drift
- the next step can again be chosen from cheap Mac build truth instead of another expensive proof run

## Strategic note for later planning
The broader DriveAI-AutoGen direction remains unchanged:
build toward a highly autonomous, self-improving factory with stronger central coordination, stronger truth systems, better lifecycle governance, richer planning and decomposition, and eventually trustworthy multi-provider / multi-model routing.
This step specifically strengthens the factory's ability to reconcile ViewModel expectations with service/model contracts without burning expensive generation runs.

## Claude Code Prompt
```text
Goal:
Add a small deterministic ViewModel contract-reconciliation rule/policy so the remaining `ExamSessionViewModel.swift` structural errors are handled centrally and future ViewModel/service/model drift is less likely to survive into the project baseline.

Prompt ist für Mac

Task:
Inspect `ExamSessionViewModel.swift` and the related types it depends on, identify the exact remaining contract mismatches, and implement the smallest robust central rule/policy for this mismatch family.

Current reported mismatch family:
- `ExamTimerService` needs `ObservableObject` conformance
- `ExamSession` is expected to provide a `startTime` property
- `examSessionService` is referenced but not declared as a property

Important:
Do not start another generation/autonomy run.
Do not solve this as a broad refactor of unrelated session architecture.
Do not treat this only as a one-off hand patch without defining the central rule that justifies the fix.
The goal is a reusable factory-layer contract-reconciliation rule/policy, validated on the current ExamSession family.

Focus especially on:
- how to classify this family of errors:
  - missing model property
  - missing ViewModel dependency property
  - missing service observation conformance
- which definition should be treated as canonical in each mismatch
- how to keep the fix as small, deterministic, and safe as possible
- preserving the current import-hygiene and duplicate-type improvements

Required checks:
1. Identify the exact structural reason for each remaining `ExamSessionViewModel.swift` error.
2. Define the smallest useful contract-reconciliation rule/policy for this family.
3. Apply it to the current ExamSession family.
4. If practical, run a cheap Mac-side typecheck recheck afterward.
5. Confirm whether the current 8-error family is resolved or materially reduced.
6. State whether any remaining blockers are still part of the same family or represent a new one.
7. End with one single next recommended step.

Expected report:
1. Root cause of the current `ExamSessionViewModel` mismatch family
2. Exact central policy/rule implemented
3. How each of the three mismatch types was handled
4. Recheck outcome if run
5. Regression/safety summary
6. Whether the baseline is now cleaner for a deeper build check
7. Single next recommended step
```

## What happens after this
If the `ExamSessionViewModel` contract family is resolved cleanly, the next best step is another cheap Mac-side build/typecheck recheck from the same baseline.
If additional contract families appear, then the next step should decide whether contract reconciliation should be generalized one layer further before any new model-driven work.
