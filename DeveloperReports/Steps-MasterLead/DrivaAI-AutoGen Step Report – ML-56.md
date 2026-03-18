# DrivaAI-AutoGen Step Report – ML-56

## Title
FK-030 SwiftUI ViewBuilder Structure Normalizer for the Remaining `ReadinessLevelBadge.swift` Blocker

## Why this step now
ML-55 delivered another precise low-cost win.

The enum/model display-contract gap is now resolved centrally:
- `ReadinessLevel` now exposes an `emoji` computed property
- the previous `emoji` blocker is gone
- an additional enum-case mismatch was corrected (`.notStarted` -> `.notReady`)

That is strategically important because the previous blocker family is fully cleared.
The Mac-side typecheck now exposes one new remaining unique blocker family:

- `ReadinessLevelBadge.swift`
- 10 errors
- Group/switch SwiftUI View structure problem

So the next correct move is not another expensive generation run and not a broad architecture rewrite.
The next correct move is a small central SwiftUI view-structure normalization step for this remaining ViewBuilder/switch family.

## Background
The latest report established:

- the previous enum/display-contract family is solved
- the active baseline is cleaner again
- the newly exposed blocker is not about syntax, imports, duplicate definitions, protocol drift, or missing enum properties
- it is a SwiftUI structural composition issue inside a view-building context
- the error family is concentrated in a single file: `ReadinessLevelBadge.swift`

This means the remaining problem is now a classic SwiftUI view-builder drift family:
code generation can create Group/switch view composition that is syntactically plausible but structurally invalid or ambiguous to SwiftUI's builder semantics.

That is exactly the kind of blocker we should still solve cheaply and centrally before thinking about any new model-driven run.

## Strategic reasoning
We should solve this as a reusable SwiftUI view-structure rule, not as an ad hoc local edit.

Why?
Because this failure family is repeatable in generated SwiftUI code:
- `switch` inside `body`
- `Group` wrappers around branches
- mismatched opaque return/view-builder shapes
- case branches that do not normalize to a clean view-building pattern

If we only patch the current file by hand without defining the rule, we clear the symptom but not the class.
A better next step is:
- identify the exact invalid Group/switch shape
- define the smallest central SwiftUI view-builder normalization rule
- validate it on `ReadinessLevelBadge.swift`

This keeps the process cheap, disciplined, and evidence-driven.

## Goal
Identify and resolve the remaining `ReadinessLevelBadge.swift` SwiftUI Group/switch blocker through the smallest robust central rule/policy, so SwiftUI view-builder structure drift is less likely to survive into the project baseline.

## Desired outcome
- the exact reason `ReadinessLevelBadge.swift` fails is identified
- the blocker is classified correctly as a SwiftUI view-builder structure family
- the current file is normalized or reconciled through the smallest safe central rule/policy
- the remaining unique blocker is resolved or materially reduced
- future runs gain a reusable safeguard against Group/switch view-structure drift
- no expensive model run is required

## In scope
- inspect `ReadinessLevelBadge.swift`
- inspect the exact Group/switch structure producing the 10 errors
- determine the minimal canonical SwiftUI pattern for this case
- define the smallest useful central rule/policy for this SwiftUI structure family
- apply it to the current `ReadinessLevelBadge.swift` case
- prefer a central deterministic handling path over an unexplained one-off patch
- run a cheap Mac-side typecheck recheck afterward if practical
- record whether any remaining issues survive after this fix

## Out of scope
- another LLM generation/autonomy run
- broad redesign of readiness UI styling
- unrelated feature work
- commercialization work
- large refactors beyond the current SwiftUI structure family

## Success criteria
- the exact remaining `ReadinessLevelBadge.swift` blocker is identified clearly
- a small reusable SwiftUI view-structure rule/policy is added
- the current 10-error family is resolved or materially reduced
- the result is reusable for future SwiftUI Group/switch structure drift
- the next step can again be chosen from cheap Mac build truth instead of another expensive proof run

## Strategic note for later planning
The broader DriveAI-AutoGen direction remains unchanged:
build toward a highly autonomous, self-improving factory with stronger central coordination, stronger truth systems, better lifecycle governance, richer planning and decomposition, and eventually trustworthy multi-provider / multi-model routing.
This step specifically strengthens the factory's ability to normalize generated SwiftUI composition patterns instead of burning expensive generation runs.

## Claude Code Prompt
```text
Goal:
Identify and resolve the remaining `ReadinessLevelBadge.swift` SwiftUI Group/switch blocker through the smallest robust central rule/policy, so SwiftUI view-builder structure drift is less likely to survive into the project baseline.

Prompt ist für Mac

Task:
Inspect `ReadinessLevelBadge.swift` and determine exactly why the current Group/switch SwiftUI structure produces 10 errors, what the minimal canonical SwiftUI pattern should be, and what the smallest safe central resolution is for this view-builder structure family.

Current reported blocker:
- `ReadinessLevelBadge.swift`
- 10 errors
- Group/switch SwiftUI View structure problem

Important:
Do not start another generation/autonomy run.
Do not solve this as a broad redesign of readiness UI styling.
Do not treat this only as an unexplained one-off hand patch.
The goal is a reusable factory-layer SwiftUI view-structure normalization rule/policy, validated on the current `ReadinessLevelBadge.swift` case.

Focus especially on:
- the exact Group/switch shape currently used
- whether the mismatch is:
  - invalid view-builder branch structure,
  - opaque return/view type inconsistency,
  - unnecessary Group wrapping,
  - or stale generated switch composition drift
- what the canonical minimal SwiftUI pattern should be for this case
- how to keep the fix deterministic, minimal, and reusable

Required checks:
1. Identify the exact root cause of why `ReadinessLevelBadge.swift` fails.
2. Classify the blocker into the correct SwiftUI view-builder structure family.
3. Define the smallest useful central rule/policy for this family.
4. Apply it to the current `ReadinessLevelBadge.swift` case.
5. If practical, run a cheap Mac-side typecheck recheck afterward.
6. Confirm whether the remaining unique blocker is resolved or materially reduced.
7. End with one single next recommended step.

Expected report:
1. Root cause of the current `ReadinessLevelBadge.swift` blocker
2. Exact central policy/rule implemented
3. How the SwiftUI structure issue was resolved
4. Recheck outcome if run
5. Regression/safety summary
6. Whether the baseline is now cleaner for a deeper build check
7. Single next recommended step
```

## What happens after this
If the remaining `ReadinessLevelBadge.swift` blocker is resolved cleanly, the next best step is another cheap Mac-side build/typecheck recheck from the same baseline.
If a new blocker appears, the next step should classify whether it is another reusable SwiftUI structure family or a different final build-truth layer.
