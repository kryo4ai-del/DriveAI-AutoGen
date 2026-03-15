# DrivaAI-AutoGen Step Report – ML-32

## Title
Class-Aware Property Shape Repairer for ObservableObject / ViewModel Init Mismatches

## Why this step now
Run 9 was the strongest live autonomy proof so far.

The factory reached a much more truthful and operationally mature state:
- CompletionVerifier stayed in project-evidence mode and reported `MOSTLY_COMPLETE`
- Recovery no longer misfired for the old reason
- RunMemory recorded a positive state instead of a false failure
- Compile Hygiene stayed near-clean and exposed only a single remaining blocking issue

That remaining blocker is now highly valuable because it is narrow, honest, and structurally meaningful:
the current `PropertyShapeRepairer` still assumes `struct TypeName` and therefore skips repair when the affected type is actually a `class`, such as an `ObservableObject` ViewModel.

This means the next correct move is not another full proof run yet.
The next correct move is to upgrade the central repair layer so it can handle both `struct` and `class` declarations.

## Background
The latest live report established:

- project-scoped AskFin execution worked
- all six passes executed
- OutputIntegrator behaved correctly
- CompletionVerifier worked correctly in evidence mode
- Recovery correctly decided "no recovery needed"
- RunMemory recorded `MOSTLY_COMPLETE / 95%`
- only **1 BLOCKING** issue remained
- the remaining FK-013 blocker is in `ServiceContainer.swift`
- `ExamReadinessViewModel` is instantiated with DI parameters that do not exist on its current initializer
- the `PropertyShapeRepairer` attempted repair logic but skipped the target because it searched for `struct ExamReadinessViewModel` and did not support `class ExamReadinessViewModel`

So the system has already done the most important thing:
it isolated the next real blocker cleanly.

## Strategic reasoning
This is exactly the kind of step that fits the long-term DriveAI-AutoGen direction.

We are not fixing a single app bug by hand.
We are extending a central factory-layer repair capability so it can reason about a wider class of type declarations.

That matters because many real-world generated SwiftUI / MVVM projects use:
- `struct` for views and value types
- `class` for services, coordinators, and `ObservableObject` view models

If the shape-repair layer only understands `struct`, the factory will repeatedly fail on an entire category of common project patterns.

So the next move should be:
upgrade the repair layer to become declaration-kind aware.

## Goal
Upgrade the `PropertyShapeRepairer` so it supports both `struct` and `class` declarations and can repair the remaining `ExamReadinessViewModel` FK-013 class init mismatch centrally.

## Desired outcome
- the repairer no longer assumes that the target type must be a `struct`
- the repairer can detect and analyze `class` declarations as repair targets
- `ObservableObject`-style ViewModels are included in shape-repair eligibility when appropriate
- the current `ExamReadinessViewModel` init mismatch is either automatically repaired or narrowed further with much higher precision
- the next full autonomy proof can start from a true 0-BLOCKING baseline if this repair succeeds

## In scope
- inspect the current `PropertyShapeRepairer` declaration-matching logic
- identify where only `struct` is supported
- extend detection, counting, and insertion logic to support `class` as well
- validate on the current `ExamReadinessViewModel` blocking case
- run the relevant compile-hygiene / repair path again after the change
- confirm whether the remaining FK-013 blocking issue is resolved, reduced, or narrowed
- check for regressions on already working struct-based repairs

## Out of scope
- manual patching of `ExamReadinessViewModel` as the primary solution
- hardcoded special-casing only for this one file
- a new full end-to-end autonomy proof run in this step
- broad redesign of the entire operations layer
- unrelated app feature work
- commercialization work
- multi-platform expansion

## Success criteria
- the repairer can locate both `struct` and `class` targets correctly
- `ExamReadinessViewModel` is no longer skipped because of declaration-kind mismatch
- the remaining FK-013 blocker is resolved, reduced, or isolated more precisely
- existing working struct-based shape repairs do not regress
- the next recommended step can be chosen from a cleaner near-zero-blocking baseline

## Strategic note for later planning
The larger DriveAI-AutoGen path remains unchanged:
build toward a highly autonomous, self-improving factory with stronger central coordination, better truth systems, safer decomposition, richer learning loops, and later broader multi-provider / multi-model routing.
This step specifically strengthens the factory's central type-shape repair intelligence across common Swift project architectures.

## Claude Code Prompt
```text
Goal:
Upgrade the PropertyShapeRepairer so it becomes declaration-kind aware and can repair the remaining FK-013 blocking case when the target type is a class rather than a struct.

Task:
Inspect the current PropertyShapeRepairer implementation and identify exactly where it assumes that the repair target must be declared as `struct TypeName`.
Extend the central repair logic so it supports both `struct` and `class` declarations, then validate the change on the current `ExamReadinessViewModel` blocking case.

Important:
Do not manually patch ExamReadinessViewModel as the main solution.
Do not add a one-off file-specific hack unless absolutely necessary for validation.
The goal is a central factory-layer improvement that generalizes across future ViewModel / ObservableObject cases.

Focus especially on:
- declaration matching logic (`struct` vs `class`)
- stored-property counting / memberwise-init reasoning for classes
- property insertion / repair support for class declarations
- ObservableObject-style ViewModels
- ensuring previously working struct-based repairs still work

Required checks:
1. Identify the exact place(s) where the current repairer only supports `struct`.
2. Implement the smallest robust central fix so both `struct` and `class` declarations are supported.
3. Re-run the relevant compile-hygiene / shape-repair path on the current blocking case.
4. Verify whether `ExamReadinessViewModel` is no longer skipped for the old reason.
5. Confirm whether the remaining FK-013 blocking issue is now resolved, reduced, or narrowed further.
6. Confirm that the change does not regress previously working struct-based repairs.
7. State whether the system is now ready for the next full end-to-end autonomy proof run.

Expected report:
1. Root cause in the old declaration-matching logic
2. Exact central fix implemented
3. How `class` and `struct` are now both handled
4. Validation on the `ExamReadinessViewModel` case
5. Compile Hygiene outcome after the fix
6. Whether the remaining blocking issue is gone or what exactly remains
7. Regression check summary
8. Single next recommended step
```

## What happens after this
If this central repair upgrade removes the final blocking issue, the next correct move is a new full end-to-end autonomy proof run from the strongest baseline so far.
If a residual mismatch remains, the next step should target that newly isolated mechanism directly at the correct central layer.
