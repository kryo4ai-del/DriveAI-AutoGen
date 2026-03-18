# DrivaAI-AutoGen Step Report – ML-58

## Title
FK-032 Configuration Symbol Scope Resolver for the Remaining `ScoringWeights` Blocker

## Why this step now
ML-57 delivered another precise low-cost win.

The remaining snapshot/model contract family is now resolved centrally:
- `ExamReadinessSnapshot` gained 4 missing properties:
  - `score`
  - `contextualStatement`
  - `examHasPassed`
  - `daysUntilExam`
- `ReadinessScore` gained a `Trend` enum and a derived `trend` computed property
- `ReadinessHeaderSection` now has 0 errors

That is strategically important because the previous blocker family is fully cleared.
The Mac-side typecheck now exposes one new remaining unique blocker:

- `ScoringWeights` not in scope
- location: `ReadinessConfiguration.swift`

So the next correct move is not another expensive generation run and not a broad configuration redesign.
The next correct move is a small central configuration symbol-scope resolution step for this remaining blocker family.

## Background
The latest report established:

- the previous snapshot/model contract family is solved
- the active baseline is cleaner again
- the newly exposed blocker is not about syntax, imports, duplicate definitions, protocol drift, enum display contracts, or snapshot property gaps
- it is a configuration symbol/dependency visibility issue:
  `ReadinessConfiguration.swift` expects `ScoringWeights`, but the symbol is not currently in scope

This means the remaining problem is now a classic configuration symbol-scope drift family:
configuration code references a type that either:
- is missing,
- lives under a different canonical name,
- exists but is not visible here,
- or has drifted out of sync with the configuration surface.

That is exactly the kind of blocker we should still solve cheaply and centrally before thinking about any new model-driven run.

## Strategic reasoning
We should solve this as a reusable configuration symbol-resolution rule, not as an ad hoc local edit.

Why?
Because this failure family is repeatable in generated app code:
- config/readiness/service layers reference shared tuning types
- the canonical type exists elsewhere or under a nearby name
- configuration surfaces drift away from canonical model definitions over time

If we only patch the current file by hand without defining the rule, we clear the symptom but not the class.
A better next step is:
- identify what `ScoringWeights` is supposed to be
- determine whether it already exists canonically or should be introduced canonically
- add the smallest central rule/policy for configuration symbol-scope resolution
- validate it on the current `ScoringWeights` case

This keeps the process cheap, disciplined, and evidence-driven.

## Goal
Identify and resolve the remaining `ScoringWeights` blocker through the smallest robust central rule/policy, so configuration symbol-scope drift is less likely to survive into the project baseline.

## Desired outcome
- the exact reason `ScoringWeights` is not in scope is identified
- the blocker is classified correctly as a configuration symbol-scope family
- the current `ReadinessConfiguration` case is resolved through the smallest safe central rule/policy
- the remaining unique blocker is resolved or materially reduced
- future runs gain a reusable safeguard against configuration symbol/dependency drift
- no expensive model run is required

## In scope
- inspect `ReadinessConfiguration.swift`
- inspect whether `ScoringWeights` already exists anywhere in the project
- determine whether the intended dependency should be:
  - an existing canonical type,
  - a renamed symbol,
  - a nested type,
  - or a missing dedicated configuration model
- define the smallest useful central rule/policy for this configuration symbol-scope family
- apply it to the current `ScoringWeights` case
- prefer a central deterministic handling path over an unexplained one-off patch
- run a cheap Mac-side typecheck recheck afterward if practical
- record whether any remaining issues survive after this fix

## Out of scope
- another LLM generation/autonomy run
- broad redesign of readiness configuration architecture
- unrelated feature work
- commercialization work
- large refactors beyond the current configuration symbol-scope family

## Success criteria
- the exact remaining `ScoringWeights` blocker is identified clearly
- a small reusable configuration symbol-scope rule/policy is added
- the current blocker is resolved or materially reduced
- the result is reusable for future configuration symbol/dependency drift
- the next step can again be chosen from cheap Mac build truth instead of another expensive proof run

## Strategic note for later planning
The broader DriveAI-AutoGen direction remains unchanged:
build toward a highly autonomous, self-improving factory with stronger central coordination, stronger truth systems, better lifecycle governance, richer planning and decomposition, and eventually trustworthy multi-provider / multi-model routing.
This step specifically strengthens the factory's ability to reconcile configuration-layer symbol references with canonical model/type ownership instead of burning expensive generation runs.

## Claude Code Prompt
```text
Goal:
Identify and resolve the remaining `ScoringWeights` blocker through the smallest robust central rule/policy, so configuration symbol-scope drift is less likely to survive into the project baseline.

Prompt ist für Mac

Task:
Inspect `ReadinessConfiguration.swift` and determine exactly what `ScoringWeights` is supposed to refer to, why it is currently not in scope, and what the smallest safe central resolution is for this configuration symbol-scope family.

Current reported blocker:
- `ScoringWeights` not in scope
- location: `ReadinessConfiguration.swift`

Important:
Do not start another generation/autonomy run.
Do not solve this as a broad redesign of readiness configuration architecture.
Do not treat this only as an unexplained one-off hand patch.
The goal is a reusable factory-layer configuration symbol-scope resolution rule/policy, validated on the current `ScoringWeights` case.

Focus especially on:
- whether `ScoringWeights` already exists somewhere in the project
- whether the reference should point to a different canonical type or nested type
- whether the problem is:
  - missing type definition,
  - wrong symbol name,
  - missing visibility/import,
  - stale configuration reference drift,
  - or missing dedicated configuration model
- how to keep the fix deterministic, minimal, and reusable

Required checks:
1. Identify the exact root cause of why `ScoringWeights` is not in scope.
2. Classify the blocker into the correct configuration symbol-scope family.
3. Define the smallest useful central rule/policy for this family.
4. Apply it to the current `ReadinessConfiguration.swift` case.
5. If practical, run a cheap Mac-side typecheck recheck afterward.
6. Confirm whether the remaining unique blocker is resolved or materially reduced.
7. End with one single next recommended step.

Expected report:
1. Root cause of the current `ScoringWeights` blocker
2. Exact central policy/rule implemented
3. How the configuration symbol-scope issue was resolved
4. Recheck outcome if run
5. Regression/safety summary
6. Whether the baseline is now cleaner for a deeper build check
7. Single next recommended step
```

## What happens after this
If the remaining `ScoringWeights` blocker is resolved cleanly, the next best step is another cheap Mac-side build/typecheck recheck from the same baseline.
If a new blocker appears, the next step should classify whether it is another reusable configuration symbol family or a different final build-truth layer.
