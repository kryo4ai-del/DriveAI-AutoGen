# DrivaAI-AutoGen Step Report – ML-52

## Title
FK-026 Missing Symbol Scope Resolver for the Remaining `NetworkMonitor` Blocker

## Why this step now
ML-51 delivered another precise low-cost win.

The final Swift Concurrency blocker in `ExamSessionViewModel.swift` is now centrally resolved through a reusable rule instead of a one-off patch:
- policy: `inout_async_isolation`
- fix pattern: local-copy-then-assign
- `ExamSessionViewModel.swift` now has 0 errors

That is strategically important because the previous blocker family is fully cleared.
The Mac-side typecheck now exposes only one new remaining unique blocker:

- `NetworkMonitor` not in scope
- location: `OfflineStatusViewModel.swift`

So the next correct move is not another expensive generation run and not a broad refactor.
The next correct move is a small central symbol-scope / dependency-resolution step for this final newly exposed blocker.

## Background
The latest report established:

- the actor-isolated `inout` + `async` pattern is fixed
- the previous concurrency family is gone
- the active baseline is cleaner again
- the only newly exposed blocker is a scope-resolution issue for `NetworkMonitor`

This means the remaining problem is no longer about:
- syntax hygiene,
- import hygiene,
- duplicate types,
- contract reconciliation,
- or concurrency semantics.

It is now a single unresolved symbol/dependency visibility problem.

That is exactly the kind of blocker that should be handled cheaply and explicitly before even thinking about another model-driven run.

## Strategic reasoning
We should still solve this centrally, not as a blind local patch.

Why?
Because “type/symbol not in scope” is a reusable factory failure family.
The cause can vary:
- missing canonical type file
- wrong type name
- missing dependency declaration
- missing import or module exposure
- stale reference to a non-canonical infrastructure abstraction

If we only patch the current file by hand without defining what kind of scope problem this is, we learn less than we could.
A better next step is:
- identify exactly what `NetworkMonitor` is supposed to be
- determine why it is not visible here
- apply the smallest central rule/policy that resolves this symbol-scope family

This keeps the process cheap, disciplined, and evidence-driven.

## Goal
Identify and resolve the remaining `NetworkMonitor` symbol-scope blocker through the smallest robust central rule/policy, so unresolved infrastructure/service symbols are less likely to survive into the project baseline.

## Desired outcome
- the exact reason `NetworkMonitor` is not in scope is identified
- the blocker is classified correctly, for example as:
  - missing canonical type
  - wrong symbol name
  - missing import/exposure
  - missing dependency declaration
  - stale reference to a removed abstraction
- the current `OfflineStatusViewModel.swift` case is resolved through the smallest safe central rule/policy
- the remaining unique blocker is resolved or materially reduced
- future runs gain a reusable safeguard against this symbol-scope family
- no expensive model run is required

## In scope
- inspect `OfflineStatusViewModel.swift`
- inspect whether `NetworkMonitor` exists anywhere in the project
- determine whether the intended dependency should be:
  - an existing concrete type,
  - a protocol,
  - a renamed symbol,
  - or a missing dependency declaration
- define the smallest useful central rule/policy for this symbol-scope family
- apply it to the current `NetworkMonitor` case
- prefer a central deterministic handling path over an unexplained one-off patch
- run a cheap Mac-side typecheck recheck afterward if practical
- record whether any remaining issues survive after this fix

## Out of scope
- another LLM generation/autonomy run
- broad networking architecture redesign
- unrelated feature work
- commercialization work
- large refactors beyond the current missing-symbol family

## Success criteria
- the exact remaining `NetworkMonitor` blocker is identified clearly
- a small reusable symbol-scope resolution rule/policy is added
- the current blocker is resolved or materially reduced
- the result is reusable for future unresolved infrastructure/service symbol drift
- the next step can again be chosen from cheap Mac build truth instead of another expensive proof run

## Strategic note for later planning
The broader DriveAI-AutoGen direction remains unchanged:
build toward a highly autonomous, self-improving factory with stronger central coordination, stronger truth systems, better lifecycle governance, richer planning and decomposition, and eventually trustworthy multi-provider / multi-model routing.
This step specifically strengthens the factory's ability to reconcile unresolved symbols/dependencies with the intended project structure instead of burning expensive generation runs.

## Claude Code Prompt
```text
Goal:
Identify and resolve the remaining `NetworkMonitor` symbol-scope blocker through the smallest robust central rule/policy, so unresolved infrastructure/service symbols are less likely to survive into the project baseline.

Prompt ist für Mac

Task:
Inspect `OfflineStatusViewModel.swift` and determine exactly what `NetworkMonitor` is supposed to refer to, why it is currently not in scope, and what the smallest safe central resolution is for this symbol-scope family.

Current reported blocker:
- `NetworkMonitor` not in scope
- location: `OfflineStatusViewModel.swift`

Important:
Do not start another generation/autonomy run.
Do not solve this as a broad networking architecture refactor.
Do not treat this only as an unexplained one-off hand patch.
The goal is a reusable factory-layer symbol-scope resolution rule/policy, validated on the current `NetworkMonitor` case.

Focus especially on:
- whether `NetworkMonitor` already exists somewhere in the project
- whether the reference should point to a different canonical type or protocol
- whether the problem is:
  - missing type definition,
  - wrong symbol name,
  - missing dependency declaration,
  - missing visibility/import,
  - or stale reference drift
- how to keep the fix deterministic, minimal, and reusable

Required checks:
1. Identify the exact root cause of why `NetworkMonitor` is not in scope.
2. Classify the blocker into the correct symbol-scope family.
3. Define the smallest useful central rule/policy for this family.
4. Apply it to the current `OfflineStatusViewModel.swift` case.
5. If practical, run a cheap Mac-side typecheck recheck afterward.
6. Confirm whether the remaining unique blocker is resolved or materially reduced.
7. End with one single next recommended step.

Expected report:
1. Root cause of the current `NetworkMonitor` blocker
2. Exact central policy/rule implemented
3. How the symbol-scope issue was resolved
4. Recheck outcome if run
5. Regression/safety summary
6. Whether the baseline is now cleaner for a deeper build check
7. Single next recommended step
```

## What happens after this
If the remaining `NetworkMonitor` blocker is resolved cleanly, the next best step is another cheap Mac-side build/typecheck recheck from the same baseline.
If a new blocker appears, the next step should classify whether it is another reusable symbol/dependency family or a different final build-truth layer.
