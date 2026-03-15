# DrivaAI-AutoGen Step Report – ML-33

## Title
Tenth End-to-End Autonomy Proof to Test Recurrence of Class Init Mismatch

## Why this step now
ML-32 delivered an important truth result.

The class-awareness upgrade in `PropertyShapeRepairer` was still the correct central step, but it proved something more specific than originally expected:
the remaining blocking case is not actually a missed class-detection bug anymore.

The repairer now correctly finds class declarations such as `ExamReadinessViewModel`, correctly identifies that the target is a class, correctly detects the presence of an explicit initializer, and correctly refuses to apply a fake property-shape repair that would not solve the real mismatch.

That changes the meaning of the remaining blocker.

The current blocker is now best understood as a code-generation / init-signature mismatch:
`ServiceContainer.swift` constructs `ExamReadinessViewModel(...)` with labels that do not match the real existing initializer.
This is not a false validator issue.
It is not a missed declaration-kind issue.
It is not a classic property-shape case.

So before designing a brand-new repair type, the highest-value next step is another live proof run.
We need to learn whether this mismatch is:
- a recurring generation pattern
- a one-run generation accident
- or the first visible example of a broader init-contract weakness in the factory

## Background
The latest report established:

- declaration matching now supports both `struct` and `class`
- `ExamReadinessViewModel` is correctly discovered as a class
- the repairer correctly detects an explicit `init(...)`
- the repairer correctly skips fake repair because property insertion would not fix the call-site mismatch
- Compile Hygiene still shows exactly 1 blocking issue
- the remaining issue is an init-signature mismatch between generated container code and an existing class initializer
- struct-based behavior did not regress

This is strategically very useful because the system has now separated:
- repair-layer limitations already addressed
from
- a possible deeper generation-contract issue

## Strategic reasoning
We should not jump immediately into building an `Init-Signature Repairer`.

Why not?
Because that would be a larger new repair type, and right now we still do not know whether the observed mismatch is systematic or incidental.

A fresh live proof run gives better truth value at this moment:
- if the mismatch disappears, then the current factory may already be strong enough for the next phase
- if the mismatch repeats, then we have strong evidence for a real recurring gap and can justify a new central init-contract repair layer
- if a different blocker appears, then we avoid prematurely optimizing the wrong subsystem

This is exactly the right order for a factory-first strategy:
measure recurrence first,
then generalize only if the evidence supports it.

## Goal
Run a tenth real end-to-end autonomy proof and determine whether the remaining class-init mismatch is a recurring live factory pattern or only a one-run generation artifact.

## Desired outcome
- the pipeline runs through the normal realistic project-scoped path
- the class-aware repairer remains correct and non-regressive
- the live run reveals whether the `ExamReadinessViewModel` / `ServiceContainer` mismatch:
  - disappears
  - repeats in the same form
  - reappears in a related form
  - or is replaced by a different deeper blocker
- the next major central step can be chosen from real recurrence evidence

## In scope
- a real project-scoped AskFin proof run
- normal pipeline execution
- operations-layer execution
- compile-hygiene observation
- completion-verifier observation
- recovery behavior observation if triggered
- run-memory / knowledge-writeback observation if triggered
- specific observation of init-signature compatibility between generated code and existing class initializers
- identification of whether the last blocker is recurring or incidental

## Out of scope
- pre-run manual patching
- building a new Init-Signature Repairer in this step
- manual modification of `ExamReadinessViewModel` or `ServiceContainer.swift` as the primary solution
- unrelated architecture redesign
- commercialization work
- speculative future features not tied to live evidence

## Success criteria
- the run uses the real project-scoped path
- the run produces a truthful live verdict
- the current class-aware repairer still behaves correctly
- the report clearly states whether the previous class-init mismatch:
  - is gone
  - recurs
  - mutates into a related pattern
  - or is overtaken by another blocker
- if the mismatch recurs, the evidence is strong enough to justify a dedicated new repair/generation-control layer next

## Strategic note for later planning
The broader DriveAI-AutoGen direction remains unchanged:
build toward a highly autonomous, self-improving factory with stronger central coordination, stronger truth systems, safer decomposition, more capable repair layers, and eventually broader multi-provider / multi-model routing.
This step specifically tests whether the next missing layer is truly an init-contract / code-generation-control mechanism.

## Claude Code Prompt
```text
Goal:
Run a tenth real end-to-end autonomy proof on AskFin and determine whether the remaining class-init mismatch is a recurring factory pattern or only a one-run generation artifact.

Task:
Execute the current AskFin factory pipeline as realistically as practical using the normal development-oriented project-scoped path with Ops-layer execution active.
Do not add new fixes before the run.
Do not manually patch `ExamReadinessViewModel` or `ServiceContainer.swift` before the run.
Do not mask failures.
Do not declare success unless the evidence clearly supports it.

Focus especially on:
- project resolution behavior
- implementation output
- downstream pass execution
- Operations Layer execution
- Compile Hygiene results
- CompletionVerifier behavior
- whether the previous `ExamReadinessViewModel` / `ServiceContainer` init-signature mismatch appears again
- whether a related class-init mismatch appears elsewhere
- recovery behavior if triggered
- writeback / run memory behavior if triggered

Required checks:
1. Confirm that the run uses the real project-scoped path.
2. Record stage-by-stage what works autonomously.
3. Verify whether Compile Hygiene remains near-clean or whether blocking reappears.
4. Explicitly determine whether the previous class-init mismatch:
   - disappears,
   - repeats in the same form,
   - reappears in a related form,
   - or is replaced by a different blocker.
5. If the mismatch recurs, explain whether it is best interpreted as:
   - a generation-layer contract problem,
   - an initializer-label mismatch pattern,
   - or some other deeper issue.
6. State whether the current evidence now justifies a new dedicated init-signature repair / generation-alignment layer.
7. If failure remains, isolate the single most important next blocker in the live factory path.

Expected report:
1. Run scope and execution path
2. Project resolution / Ops-layer behavior observed
3. Stage-by-stage observed results
4. Compile Hygiene and compile check outcome
5. CompletionVerifier outcome
6. Whether the prior class-init mismatch recurred
7. What worked autonomously
8. What still failed or degraded
9. Recovery / writeback / run-memory behavior observed
10. Clean success vs partial success vs honest failure verdict
11. Single next recommended step
```

## What happens after this
If the class-init mismatch disappears, the next step should shift toward repeatability and broader factory stabilization.
If it recurs, then the next correct move is likely a new central init-contract / initializer-alignment capability rather than another local patch.
If a different blocker appears, then that new blocker should be judged on whether it is truly central before adding another layer.
