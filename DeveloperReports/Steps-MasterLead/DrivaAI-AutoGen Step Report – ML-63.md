# DrivaAI-AutoGen Step Report – ML-63

## Title
FK-037 Duplicate Type Collision Resolver for the Remaining `CategoryResult` Family

## Why this step now
ML-62 delivered another precise low-cost win.

The remaining navigation/model-conformance family is now resolved centrally:
- `ExamSession` now conforms to `Hashable`
- the conformance was satisfied through automatic synthesis
- `AppCoordinator` now has 0 errors

That is strategically important because the previous blocker family is fully cleared.
The Mac-side typecheck now exposes one new remaining unique blocker family:

- `CategoryResult` defined 2x

So the next correct move is not another expensive generation run and not a broad domain-model rewrite.
The next correct move is a small central duplicate-type collision step, using the same disciplined style that already worked for `WeakArea`.

## Background
The latest report established:

- the previous `ExamSession` Hashable family is solved
- the active baseline is cleaner again
- the newly exposed blocker is not about syntax, imports, protocol drift, placeholder artifacts, navigation conformance, or service contracts
- it is a duplicate type-definition problem
- the report explicitly indicates that the existing `dedicated-file-wins` policy applies

This is excellent news because we do not need a brand-new large mechanism.
We already have a proven pattern:
identify the canonical dedicated-file definition and remove or quarantine the inline/non-canonical duplicates.

## Strategic reasoning
We should solve this centrally, not as an ad hoc deletion.

Why?
Because duplicate type definitions are a reusable factory failure family:
- multiple generated files can emit overlapping domain models
- an inline or legacy duplicate can survive after a dedicated file already exists
- consumer and service code then collide on competing definitions

Since the `dedicated-file-wins` policy already worked for `WeakArea`, the cheapest and cleanest next step is to apply that same rule to the `CategoryResult` family.

This keeps the process cheap, disciplined, and evidence-driven.

## Goal
Apply the existing duplicate-definition policy so the remaining `CategoryResult` duplicate-definition blocker is handled centrally and future duplicate domain-type declarations are less likely to survive into the project baseline.

## Desired outcome
- the exact locations of the duplicate `CategoryResult` definitions are identified
- the canonical definition is chosen through the existing dedicated-file rule
- the non-canonical duplicate is removed, quarantined, or otherwise neutralized through the central policy
- the remaining unique blocker is resolved or materially reduced
- future runs gain a reusable safeguard against duplicate type drift
- no expensive model run is required

## In scope
- inspect both `CategoryResult` definitions
- determine which definition lives in the canonical dedicated file
- apply the `dedicated-file-wins` policy
- handle the non-canonical duplicate through the chosen central rule
- prefer a central deterministic handling path over an unexplained one-off patch
- run a cheap Mac-side typecheck recheck afterward if practical
- record whether any remaining issues survive after this fix

## Out of scope
- another LLM generation/autonomy run
- broad exam-result domain redesign
- unrelated feature work
- commercialization work
- large refactors beyond the current duplicate-type family

## Success criteria
- the exact remaining `CategoryResult` collision is identified clearly
- the reusable duplicate-type resolution rule/policy is applied
- the current blocker is resolved or materially reduced
- the result is reusable for future duplicate type drift
- the next step can again be chosen from cheap Mac build truth instead of another expensive proof run

## Strategic note for later planning
The broader DriveAI-AutoGen direction remains unchanged:
build toward a highly autonomous, self-improving factory with stronger central coordination, stronger truth systems, better lifecycle governance, richer planning and decomposition, and eventually trustworthy multi-provider / multi-model routing.
This step specifically strengthens the factory's ability to resolve duplicate domain model declarations without burning expensive generation runs.

## Claude Code Prompt
```text
Goal:
Apply the existing duplicate-definition policy so the remaining `CategoryResult` duplicate-definition blocker is handled centrally and future duplicate domain-type declarations are less likely to survive into the project baseline.

Prompt ist für Mac

Task:
Inspect the current `CategoryResult` duplicate definitions, determine which definition should be canonical, and apply the smallest robust central duplicate-definition rule to resolve this type collision.

Current reported blocker:
- `CategoryResult` defined 2x
- report says `dedicated-file-wins` policy is applicable

Important:
Do not start another generation/autonomy run.
Do not solve this as an unexplained one-off manual deletion.
Do not do a broad domain-model refactor.
The goal is a reusable factory-layer duplicate-type resolution step, validated on the current `CategoryResult` case.

Focus especially on:
- where both `CategoryResult` definitions currently live
- whether one of them is in the canonical dedicated file
- how to remove, quarantine, or neutralize the non-canonical duplicate safely
- preserving the previous conformance, contract, import, and sanitizer improvements

Required checks:
1. Identify the exact locations of the duplicate `CategoryResult` definitions.
2. State which definition is canonical and why.
3. Apply the smallest useful central rule/policy for this duplicate-type family.
4. Handle the non-canonical definition through that rule.
5. If practical, run a cheap Mac-side typecheck recheck afterward.
6. Confirm whether the remaining unique blocker is resolved or materially reduced.
7. End with one single next recommended step.

Expected report:
1. Root cause of the current `CategoryResult` collision
2. Exact central policy/rule applied
3. Which definition was chosen as canonical and why
4. How the other definition was handled
5. Recheck outcome if run
6. Regression/safety summary
7. Single next recommended step
```

## What happens after this
If the remaining `CategoryResult` duplicate-definition family is resolved cleanly, the next best step is another cheap Mac-side build/typecheck recheck from the same baseline.
If a new blocker appears, the next step should classify whether it is another reusable duplicate-type family or a different final build-truth layer.
