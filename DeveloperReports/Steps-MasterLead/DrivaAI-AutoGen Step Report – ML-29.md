# DrivaAI-AutoGen Step Report – ML-29

## Title
SwiftUI-Aware Property Shape Repairer for the Remaining FK-013 Blocking Case

## Why this step now
The latest live autonomy proof did something important:
it moved the system out of the older broad compile-hygiene failure state and narrowed the remaining hard blocker down to a single, well-isolated FK-013 case.

That is strategically valuable because the next move is no longer another blind full run.
The next move is to strengthen the central repair layer that decides whether the factory can autonomously resolve this kind of shape mismatch.

The decisive result is:
- the live run progressed materially through the factory pipeline
- multiple downstream stages executed successfully
- Compile Hygiene improved again, but one FK-013 blocking case remained
- the remaining blocker was isolated to `AnswerButtonView`
- the report indicates the current `PropertyShapeRepairer` skips this case because its stored-property / memberwise-init logic is not SwiftUI-aware

That means the correct next step is not an app-specific patch.
The correct next step is a central factory-layer upgrade.

## Background
The latest run established:

- project-scoped execution worked
- the major pipeline stages ran far enough to produce real evidence
- the factory already handled some compile-shape repair paths successfully
- the remaining blocking case is no longer broad or noisy
- the blocker is now concentrated in the classification logic of the `PropertyShapeRepairer`
- SwiftUI-specific members and computed properties are being interpreted too naively for shape-repair decisions

This matters because a manual patch to `AnswerButtonView` would only hide the structural weakness.
A central repair-layer fix can improve future autonomy across many SwiftUI files, not just this single case.

## Strategic reasoning
We should not run another full end-to-end proof before repairing this central weakness.

Why?
Because the next full run would likely spend its value budget rediscovering the same remaining blocker.
That would teach us less than fixing the classification layer first.

This is exactly the kind of step that fits the larger DriveAI-AutoGen direction:
not local bug-chasing,
but adding a stronger system layer that prevents repeated classes of failure.

A SwiftUI-aware property-shape repair path gives us:
- better memberwise-init reasoning
- better handling of wrapped state/object properties
- less false blocking from UI-layer structures
- a more reusable compile-repair capability for future builds

## Goal
Upgrade the `PropertyShapeRepairer` so it becomes SwiftUI-aware and can handle the remaining FK-013 blocking case without relying on an app-specific manual patch.

## Desired outcome
- `@State`, `@Binding`, `@Environment`, `@EnvironmentObject`, `@ObservedObject`, `@StateObject`, `@Published`, and similar wrapped properties are not misclassified as normal init-relevant stored properties
- computed properties such as `var body: some View { ... }` are excluded from stored-property counting
- the `AnswerButtonView` case is no longer skipped for the old reason
- a targeted validation or compile-hygiene re-check shows that the remaining FK-013 blocker is either resolved or narrowed much further
- the next full autonomy proof can start from a stronger central repair layer

## In scope
- inspection of the current `PropertyShapeRepairer` implementation
- analysis of stored-property counting / memberwise-init detection logic
- SwiftUI-aware classification improvements
- exclusion of computed properties from normal stored-property repair decisions
- targeted validation on the current blocking case
- a focused compile-hygiene or equivalent repair-path verification
- regression awareness for already working auto-fix paths

## Out of scope
- manual patching of `AnswerButtonView` as the main solution
- another full end-to-end autonomy proof run in this step
- CompletionVerifier redesign
- `specs/` directory redesign
- Recovery redesign
- product feature work
- UI polishing
- marketing / commercialization work

## Success criteria
- `AnswerButtonView` is no longer skipped because of the old property-counting logic
- the remaining FK-013 blocker is resolved, reduced, or precisely narrowed
- the fix is clearly central and reusable, not a one-off file hack
- previously working auto-fix paths do not regress
- the next recommended step can be chosen from cleaner system evidence

## Strategic note for later planning
The broader long-term objective remains larger than AskFin:
DriveAI-AutoGen should evolve toward a highly autonomous, self-improving factory with stronger central coordination, richer planning layers, safer decomposition, and eventually broader multi-provider / multi-model routing.
That larger direction should continue without interrupting the current autonomy-core stabilization path.

## Claude Code Prompt
```text
Goal:
Upgrade the PropertyShapeRepairer so it becomes SwiftUI-aware and can handle the remaining FK-013 blocking case without relying on an app-specific manual patch.

Task:
Inspect the current PropertyShapeRepairer implementation, especially the stored-property counting / memberwise-init detection logic.
Fix the logic so SwiftUI-specific properties and computed properties are not misclassified as normal stored properties for shape-repair decisions.

Important:
Do not manually patch AnswerButtonView as the primary fix.
Do not add a one-off special case for this single file unless absolutely necessary for validation.
The goal is a central factory-layer improvement, not a local app workaround.

Focus especially on:
- @State
- @Binding
- @Environment
- @EnvironmentObject
- @ObservedObject
- @StateObject
- @Published
- computed properties such as `var body: some View { ... }`
- any other property-wrapper-based members that should not be treated as normal memberwise-init stored properties

Required checks:
1. Identify exactly where the current PropertyShapeRepairer miscounts SwiftUI properties.
2. Implement the smallest robust central fix in the counting / classification logic.
3. Re-run the relevant compile-hygiene / shape-repair path on the current blocking case.
4. Verify whether AnswerButtonView is no longer skipped for the old reason.
5. Confirm whether the remaining FK-013 blocking issue is now resolved, reduced, or narrowed further.
6. Confirm that the fix does not regress previously working auto-fixes such as FK-014 stub generation and the current hygiene flow.

Expected report:
1. Root cause in the old PropertyShapeRepairer logic
2. Exact central fix implemented
3. How SwiftUI wrappers / computed properties are now handled
4. Validation on the AnswerButtonView case
5. Compile Hygiene outcome after the fix
6. Whether the remaining blocking issue is gone or what exactly remains
7. Regression check summary
8. Single next recommended step
```

## What happens after this
If this central fix resolves the remaining blocking case, the next correct move is a new full end-to-end autonomy proof run from the improved factory baseline.
If the blocker only narrows further, then the next step should target the newly isolated residual mechanism rather than falling back into app-level patching.
