# DrivaAI-AutoGen Step Report – ML-54

## Title
FK-028 Duplicate Protocol Collision Resolver for the Remaining LocalDataServiceProtocol Family

## Why this step now
ML-53 delivered another precise low-cost win.

The remaining ExamReadiness service-contract gap is now resolved centrally:
- 4 missing methods were added to `ExamReadinessServiceProtocol`
- the corresponding service contract was extended
- `ExamReadinessViewModel` now has 0 errors

That is strategically important because the previous blocker family is fully cleared.
The Mac-side typecheck now exposes one new remaining unique blocker family:

`LocalDataServiceProtocol` is defined twice.

So the next correct move is not another expensive generation run and not a broad architecture rewrite.
The next correct move is a small central duplicate-protocol collision step, using the same disciplined style that already worked for duplicate types.

## Background
The latest report established:

- the previous protocol-gap family is solved
- the active baseline is cleaner again
- the newly exposed blocker is not about syntax, imports, concurrency, or missing methods
- it is a duplicate protocol definition problem
- the report explicitly says the existing `dedicated-file-wins` policy is applicable here

This is excellent news because it means we do not need a brand-new large mechanism.
We already have a proven pattern:
identify the canonical dedicated-file definition and remove or quarantine the inline/non-canonical duplicates.

## Strategic reasoning
We should solve this centrally, not as an ad hoc deletion.

Why?
Because duplicate protocol definitions are a reusable factory failure family, just like duplicate type definitions:
- multiple generated files can emit overlapping interface declarations
- an inline or legacy duplicate can survive after a dedicated file already exists
- consumer and implementation code then collide on competing definitions

Since the `dedicated-file-wins` policy already worked on the `WeakArea` family, the cheapest and cleanest next step is to extend or apply that same rule to protocols.

This keeps the process cheap, disciplined, and evidence-driven.

## Goal
Apply or extend the existing duplicate-definition policy so the remaining `LocalDataServiceProtocol` duplicate-definition blocker is handled centrally and future duplicate protocol declarations are less likely to survive into the project baseline.

## Desired outcome
- the exact locations of the duplicate `LocalDataServiceProtocol` definitions are identified
- the canonical definition is chosen through the existing dedicated-file rule
- the non-canonical duplicate is removed, quarantined, or otherwise neutralized through the central policy
- the remaining unique blocker is resolved or materially reduced
- future runs gain a reusable safeguard against duplicate protocol/interface drift
- no expensive model run is required

## In scope
- inspect both `LocalDataServiceProtocol` definitions
- determine which definition lives in the canonical dedicated file
- apply or minimally extend the `dedicated-file-wins` policy to protocols if needed
- handle the non-canonical duplicate through the chosen central rule
- prefer a central deterministic handling path over an unexplained one-off patch
- run a cheap Mac-side typecheck recheck afterward if practical
- record whether any remaining issues survive after this fix

## Out of scope
- another LLM generation/autonomy run
- broad local-data architecture redesign
- unrelated feature work
- commercialization work
- large refactors beyond the current duplicate-protocol family

## Success criteria
- the exact remaining `LocalDataServiceProtocol` collision is identified clearly
- a small reusable duplicate-protocol resolution rule/policy is applied or added
- the current blocker is resolved or materially reduced
- the result is reusable for future duplicate protocol/interface drift
- the next step can again be chosen from cheap Mac build truth instead of another expensive proof run

## Strategic note for later planning
The broader DriveAI-AutoGen direction remains unchanged:
build toward a highly autonomous, self-improving factory with stronger central coordination, stronger truth systems, better lifecycle governance, richer planning and decomposition, and eventually trustworthy multi-provider / multi-model routing.
This step specifically strengthens the factory's ability to resolve duplicate interface declarations without burning expensive generation runs.

## Claude Code Prompt
```text
Goal:
Apply or extend the existing duplicate-definition policy so the remaining `LocalDataServiceProtocol` duplicate-definition blocker is handled centrally and future duplicate protocol declarations are less likely to survive into the project baseline.

Prompt ist für Mac

Task:
Inspect the current `LocalDataServiceProtocol` duplicate definitions, determine which definition should be canonical, and apply the smallest robust central duplicate-definition rule to resolve this protocol collision.

Current reported blocker:
- `LocalDataServiceProtocol` defined 2x
- report says `dedicated-file-wins` policy is applicable

Important:
Do not start another generation/autonomy run.
Do not solve this as an unexplained one-off manual deletion.
Do not do a broad local-data architecture refactor.
The goal is a reusable factory-layer duplicate-protocol resolution step, validated on the current `LocalDataServiceProtocol` case.

Focus especially on:
- where both `LocalDataServiceProtocol` definitions currently live
- whether one of them is in the canonical dedicated file
- whether the existing `dedicated-file-wins` policy can be reused directly or needs a tiny protocol-specific extension
- how to remove, quarantine, or neutralize the non-canonical duplicate safely
- preserving the previous contract, import, concurrency, and duplicate-type improvements

Required checks:
1. Identify the exact locations of the duplicate `LocalDataServiceProtocol` definitions.
2. State which definition is canonical and why.
3. Apply the smallest useful central rule/policy for this duplicate-protocol family.
4. Handle the non-canonical definition through that rule.
5. If practical, run a cheap Mac-side typecheck recheck afterward.
6. Confirm whether the remaining unique blocker is resolved or materially reduced.
7. End with one single next recommended step.

Expected report:
1. Root cause of the current `LocalDataServiceProtocol` collision
2. Exact central policy/rule applied or extended
3. Which definition was chosen as canonical and why
4. How the other definition was handled
5. Recheck outcome if run
6. Regression/safety summary
7. Single next recommended step
```

## What happens after this
If the remaining `LocalDataServiceProtocol` duplicate-definition family is resolved cleanly, the next best step is another cheap Mac-side build/typecheck recheck from the same baseline.
If a new blocker appears, the next step should classify whether it is another reusable duplicate/interface family or a different final build-truth layer.
