# DrivaAI-AutoGen Step Report – ML-39

## Title
Framework-Type Awareness Fix for FK-014 / StubGen Before the First True Sonnet Proof

## Why this step now
Run 13 was still highly valuable even though Sonnet did not actually activate.

The run proved again that the factory can stay operationally stable under significant output volume and can return to 0 BLOCKING through the current auto-repair stack.
But it also exposed one new central weakness that should be cleaned up before the first true Sonnet proof:

`StubGen` created a fake stub for `Hasher`, even though `Hasher` is a real Swift framework/standard-library type.

That means the next Sonnet run would still be partially contaminated by a known false-positive path in FK-014 classification.
This is exactly the kind of issue that should be fixed centrally before the next truth-bearing stronger-model run.

## Background
The latest report established:

- `--profile standard` still resolved to Haiku in this run because `VALID_PROFILES` rejected `"standard"` at run start
- that control-plane bug has already been fixed after the run started
- the repair stack still succeeded and returned the project to 0 BLOCKING
- one FK-014 issue incorrectly treated `Hasher` as missing
- `StubGen` then generated a stub for `Hasher`, which is the wrong behavior because `Swift.Hasher` already exists
- the report explicitly recommends adding `Hasher` to `_KNOWN_FRAMEWORK_TYPES`
- the next run should then be the first real Sonnet proof

So the next step is not broad architecture work.
It is a small but important central truth/hygiene fix in the type-classification layer.

## Strategic reasoning
We should fix this before the true Sonnet run.

Why?
Because once Sonnet is really active, we want the next proof to tell us about:
- stronger-model generation quality
- output usefulness
- stability under real higher-capability generation

We do **not** want that run to be diluted by a known false FK-014 pathway that can create bogus stubs for framework types.

This is also exactly the right style of step for DriveAI-AutoGen:
not a manual cleanup,
not a one-off ignore,
but a cleaner type-knowledge boundary in the factory.

## Goal
Fix FK-014 / StubGen framework-type awareness so known Swift/framework/standard-library types such as `Hasher` are not misclassified as missing custom types and do not trigger bogus stub generation.

## Desired outcome
- `Hasher` is recognized as a known framework/standard type
- FK-014 no longer flags `Hasher` as missing
- StubGen no longer creates bogus stubs for known framework types
- the current false `Hasher` stub artifact, if present, is handled safely through a central path
- the system is cleanly ready for the first true Sonnet-powered proof run

## In scope
- inspect FK-014 classification logic
- inspect `_KNOWN_FRAMEWORK_TYPES` or equivalent known-type registry
- add the correct handling for `Hasher`
- check whether other obvious Swift/framework types are missing from the same registry
- make the smallest robust central fix so the problem does not recur for this class of types
- safely handle the currently generated false `Hasher` stub if it exists
- validate the fix with a focused check or hygiene pass
- confirm that legitimate FK-014 stub generation still works for truly missing custom types

## Out of scope
- full Run 14 in this step
- broad redesign of all type-resolution systems
- new routing/model work
- unrelated repair-layer changes
- feature work
- UI work
- commercialization work

## Success criteria
- the exact cause of the `Hasher` false positive is identified
- `Hasher` is no longer treated as a missing custom type
- bogus framework-type stubs are prevented by central logic
- existing legitimate FK-014 auto-stub behavior does not regress
- the project is ready for the first real Sonnet proof run afterward

## Strategic note for later planning
The broader DriveAI-AutoGen direction remains unchanged:
build toward a highly autonomous, self-improving factory with stronger central coordination, stronger truth systems, better lifecycle governance, richer planning and decomposition, and eventually trustworthy multi-provider / multi-model routing.
This step specifically strengthens the factory's boundary between known platform/framework types and truly missing project-local types.

## Claude Code Prompt
```text
Goal:
Fix FK-014 / StubGen framework-type awareness so known Swift/framework/standard-library types such as `Hasher` are not misclassified as missing custom types and do not trigger bogus stub generation.

Task:
Inspect the current FK-014 detection and StubGen type-classification path, identify exactly why `Hasher` was treated as missing, and implement the smallest robust central fix so known platform/framework types are excluded from bogus stub generation.

Important:
Do not solve this with a one-off manual deletion only.
Do not just special-case the current run output without fixing the central classification path.
The goal is a reusable factory-layer truth fix for framework-type awareness.

Focus especially on:
- `_KNOWN_FRAMEWORK_TYPES` or equivalent known-type registry
- where FK-014 decides a type is missing
- where StubGen trusts that decision
- whether `Hasher` is absent from the current known-type list
- whether a small broader safety improvement is needed for similar built-in/framework types
- how to safely handle the currently generated false `Hasher` stub if it exists

Required checks:
1. Identify the exact root cause of the `Hasher` false positive.
2. Implement the smallest robust central fix so `Hasher` is recognized correctly.
3. Validate that FK-014 no longer flags `Hasher` as missing.
4. Validate that StubGen no longer creates a bogus stub for `Hasher`.
5. Confirm that legitimate missing custom types can still trigger valid stub generation.
6. State whether the system is now cleanly ready for the first true Sonnet autonomy proof run.

Expected report:
1. Root cause in the old FK-014 / StubGen type-classification logic
2. Exact central fix implemented
3. How framework/standard types are now handled
4. How the current false `Hasher` stub case was handled
5. Regression check summary
6. Whether the system is ready for the next Sonnet proof run
7. Single next recommended step
```

## What happens after this
If this framework-type awareness fix succeeds, the next correct move is Run 14 as the first real end-to-end autonomy proof with true Sonnet activation.
If the fix exposes a broader type-knowledge gap, then that gap should be narrowed before the Sonnet proof run.
