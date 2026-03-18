# DrivaAI-AutoGen Step Report – ML-48

## Title
FK-022 Duplicate Type Collision Resolver for the Remaining WeakArea Family

## Why this step now
ML-47 delivered another strong cheap win.

The import-hygiene layer has now proven that it can be extended beyond Foundation in a controlled and reusable way:
- Combine symbol detection was added centrally
- `@Published` syntax is now recognized
- SwiftUI/Combine interaction is respected
- 11 files were auto-fixed with `import Combine`
- the remaining Combine-related build errors were reduced from 6 to 0

That means the current baseline has moved past the import-family stage.
Only one real build-truth blocker now remains:
the duplicate `WeakArea` type family.

This is strategically excellent news because it means the remaining problem is now sharply isolated, cheap to reason about, and structurally clear.

## Background
The latest Mac-side typecheck recheck established:

- import-hygiene expansion worked
- `RecommendationViewModel` import issues are gone
- the only remaining unique blocker is duplicate `WeakArea` definitions
- `WeakArea` currently exists in three places:
  - `AssessmentResult.swift`
  - `WeakArea.swift`
  - `Recommendation.swift`

This is no longer an import problem and no longer a hygiene-noise problem.
It is a genuine structural type-collision problem.

That means the next correct move is not another run and not another hygiene expansion.
The next correct move is a small central duplicate-type resolution policy or resolver.

## Strategic reasoning
We should solve this centrally, not as an ad hoc deletion.

Why?
Because duplicate-type collisions are a reusable class of factory output problem:
multiple generated files can independently emit overlapping domain types, nested models, or convenience copies of an already-existing canonical type.

If we only delete two copies by hand, we solve this instance but not the family.
A better next step is to create a small central duplicate-type collision rule that can:
- detect competing type definitions
- decide which definition should be canonical
- route the non-canonical definitions to the safest disposition

This is exactly the kind of system-layer tightening that your long-term factory goal needs.

## Goal
Add a small deterministic duplicate-type collision resolver or policy so the remaining `WeakArea` triple-definition blocker is handled centrally and future duplicate domain-type collisions are less likely to survive into the project baseline.

## Desired outcome
- duplicate top-level type definitions are detected centrally
- the `WeakArea` family is analyzed to determine the canonical definition
- the non-canonical duplicates are removed, quarantined, merged, or otherwise handled through a clear rule
- the remaining build/typecheck blocker is resolved or materially narrowed
- future runs gain a reusable safeguard against this collision family
- no expensive model run is required

## In scope
- inspect the three `WeakArea` definitions
- determine which definition should be canonical based on placement, usage, and project structure
- define the smallest robust duplicate-type collision policy or resolver
- apply it to the current `WeakArea` case
- prefer a central handling path over a one-off manual cleanup
- run a cheap Mac-side typecheck recheck afterward if practical
- record whether any remaining issues survive after the duplicate-type fix

## Out of scope
- another LLM generation/autonomy run
- broad domain-model redesign
- large refactors unrelated to the collision
- full general symbol graphing for every type in the codebase
- feature work
- commercialization work

## Success criteria
- the canonical `WeakArea` definition is identified explicitly
- the duplicate `WeakArea` collision is handled through a central rule/policy
- the current remaining unique blocker is resolved or materially reduced
- the result is reusable for future duplicate-type collisions
- the next step can again be chosen from cheap platform-truth evidence

## Strategic note for later planning
The broader DriveAI-AutoGen direction remains unchanged:
build toward a highly autonomous, self-improving factory with stronger central coordination, stronger truth systems, better lifecycle governance, richer planning and decomposition, and eventually trustworthy multi-provider / multi-model routing.
This step specifically strengthens the factory's ability to resolve structural type-collision artifacts without wasting expensive generation runs.

## Claude Code Prompt
```text
Goal:
Add a small deterministic duplicate-type collision resolver or policy so the remaining `WeakArea` triple-definition blocker is handled centrally and future duplicate domain-type collisions are less likely to survive into the project baseline.

Prompt ist für Mac

Task:
Inspect the three current `WeakArea` definitions and implement the smallest robust central rule or resolver for duplicate type collisions.
The system should determine which `WeakArea` definition is canonical and then handle the non-canonical duplicates through the safest central path.

Current duplicate family:
- `AssessmentResult.swift`
- `WeakArea.swift`
- `Recommendation.swift`

Important:
Do not start another generation/autonomy run.
Do not solve this purely as an unprincipled manual deletion without defining the central rule that justifies it.
The goal is a reusable factory-layer duplicate-type collision policy/resolver, validated on the `WeakArea` family.

Focus especially on:
- how to detect duplicate top-level type definitions
- how to decide which definition should be canonical
- whether non-canonical duplicates should be removed, quarantined, merged, or rewritten
- how to avoid breaking references that expect the canonical type
- keeping the fix as small and deterministic as possible

Required checks:
1. Identify the exact structural reason the three `WeakArea` definitions collide.
2. Define the smallest useful duplicate-type collision policy/resolver.
3. Apply it to the current `WeakArea` family and state which definition is canonical.
4. Handle the non-canonical definitions through the chosen central rule.
5. If practical, run a cheap Mac-side typecheck recheck afterward.
6. Confirm whether the remaining build/typecheck blocker is now resolved or materially reduced.
7. End with one single next recommended step.

Expected report:
1. Root cause of the current `WeakArea` collision
2. Exact central policy/resolver implemented
3. Which `WeakArea` definition was chosen as canonical and why
4. How the other definitions were handled
5. Recheck outcome if run
6. Regression/safety summary
7. Single next recommended step
```

## What happens after this
If the `WeakArea` duplicate-type family is resolved cleanly, the next best step is another cheap Mac-side build/typecheck recheck from the same baseline.
If additional structural collisions appear, then the next step should decide whether duplicate-type handling should be generalized one layer further before any new model-driven work.
