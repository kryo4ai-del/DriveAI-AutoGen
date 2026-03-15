# DrivaAI-AutoGen Step Report – ML-34

## Title
Generated Artifact Lifecycle Guard for Persistent Stale Blockers

## Why this step now
Run 10 changed the interpretation of the remaining blocker in an important way.

The prior class-init mismatch did **not** recur as a new generation pattern.
Instead, the report shows that the same blocking `ServiceContainer.swift` artifact from Run 9 simply persisted in the project while Run 10 generated **0 Swift files**.
That means the factory is no longer mainly suffering from a fresh repair failure.
It is now exposing a deeper control-layer gap:

the system does not yet manage the lifecycle of generated artifacts strongly enough when previously generated files remain in the project and continue to influence later runs.

This is strategically significant because a truly autonomous factory cannot depend on manual deletion of stale generated files to recover truth.
It needs a central mechanism that can distinguish:
- newly generated output
- persistent prior generated artifacts
- stale or incompatible generated artifacts
- files that should be quarantined, replaced, or left untouched

So the next correct move is **not** a manual deletion of `ServiceContainer.swift`.
The next correct move is a reusable central artifact-lifecycle layer.

## Background
The latest live proof established:

- the previous class-init mismatch did not recur as a new output pattern
- Run 10 generated 0 Swift files
- the one remaining blocking issue is the same persistent `ServiceContainer.swift` artifact from Run 9
- CompletionVerifier moved to `INCOMPLETE (80%)` because hygiene still sees that persistent blocker
- Recovery was triggered correctly, but found no missing/incomplete targets and therefore skipped
- this means the factory can already execute and judge runs more honestly, but it still lacks cleanup / quarantine logic for stale generated artifacts

This is exactly the kind of whole-system gap that matters for long-term autonomy:
not just generating code,
but governing what remains from prior runs and how old generated outputs are handled over time.

## Strategic reasoning
We should not solve this by simply deleting one file manually.

Why not?
Because that would clear the symptom without strengthening the factory.
The report has already shown the more important truth:
a generated artifact from an earlier run can persist and keep affecting later autonomy proofs even when no new code is produced.

That means the missing capability is something like:
- generated-file provenance awareness
- stale artifact detection
- mismatch-based quarantine / removal recommendation
- safer lifecycle control over prior generated outputs

This is a better next step than another immediate live proof because the next live proof would still be partially contaminated by the same stale blocker unless the system can manage persistent artifacts more intelligently.

## Goal
Add a central generated-artifact lifecycle guard that can identify and handle stale persistent generated blockers such as the current `ServiceContainer.swift` artifact without relying on a manual one-off deletion.

## Desired outcome
- the factory can identify generated artifacts from prior runs with sufficient provenance or equivalent evidence
- the system can detect when a persistent generated artifact is now the sole remaining blocker
- stale generated blockers can be flagged for:
  - quarantine,
  - replacement,
  - cleanup recommendation,
  - or safe removal
- the current `ServiceContainer.swift` blocker can be handled through this central mechanism rather than a manual ad hoc delete
- the next full proof run can start from a cleaner and more truthful project baseline

## In scope
- inspect how generated artifacts are currently tracked across runs
- identify whether there is already metadata, naming, logs, integration records, or run-memory evidence that can be used as provenance
- design and implement the smallest robust central mechanism to detect stale persistent generated blockers
- support at least one honest action path such as:
  - quarantine recommendation,
  - cleanup recommendation,
  - or automatic safe exclusion/removal if clearly justified
- validate the mechanism specifically on the current persistent `ServiceContainer.swift` blocker
- confirm that the mechanism distinguishes stale persistent artifacts from fresh run output
- confirm that the mechanism does not delete unrelated real project files recklessly

## Out of scope
- manual deletion of `ServiceContainer.swift` as the main solution
- broad redesign of the whole Operations Layer
- a new end-to-end proof run in this step
- feature work
- UI work
- commercialization work
- speculative future capabilities unrelated to artifact lifecycle control

## Success criteria
- the system can explain why the current blocker is a stale persistent generated artifact
- the factory has a reusable central path to flag or handle such artifacts
- the current `ServiceContainer.swift` case is handled via that path
- the solution is safer than a blind cleanup rule
- the next full autonomy proof can proceed from a cleaner baseline with less contamination from prior generated leftovers

## Strategic note for later planning
The broader DriveAI-AutoGen direction remains unchanged:
build toward a highly autonomous, self-improving factory with stronger central coordination, stronger truth systems, safer decomposition, more capable repair layers, and better lifecycle governance of generated outputs.
This step specifically strengthens the factory's ability to govern the persistence and cleanup of prior run artifacts.

## Claude Code Prompt
```text
Goal:
Add a central generated-artifact lifecycle guard that can identify and handle stale persistent generated blockers such as the current `ServiceContainer.swift` artifact without relying on a manual one-off deletion.

Task:
Inspect the current pipeline, Ops-layer, integration flow, run-memory, and any artifact tracking/provenance mechanisms to determine how generated files from prior runs are currently persisted and identified.
Implement the smallest robust central mechanism that can recognize when a previously generated artifact is persisting as the sole remaining blocker and flag or handle it through a reusable lifecycle-control path.

Important:
Do not solve this by just manually deleting `ServiceContainer.swift` as the primary fix.
Do not add a dangerous blanket cleanup rule that could remove legitimate project files.
The goal is a central factory-layer improvement for generated-artifact lifecycle governance, not a one-off local cleanup.

Focus especially on:
- how generated files are currently integrated into the project
- whether provenance already exists in logs, manifests, memory, integration records, or naming patterns
- how to distinguish fresh run output from persistent prior generated artifacts
- how to detect that a persistent generated artifact is now the sole remaining blocker
- what the safest action model should be:
  - quarantine,
  - cleanup recommendation,
  - explicit stale-artifact flag,
  - or controlled removal if clearly justified

Required checks:
1. Identify how the current `ServiceContainer.swift` blocker can be recognized as a stale persistent generated artifact from a prior run.
2. Implement the smallest robust central lifecycle/provenance mechanism needed to support this.
3. Validate the mechanism on the current `ServiceContainer.swift` case.
4. Confirm that unrelated existing project files would not be incorrectly removed.
5. State whether the current blocker can now be handled through this new lifecycle guard.
6. State whether the system is then ready for the next full live autonomy proof.

Expected report:
1. Root cause of the stale-artifact persistence problem
2. What provenance / lifecycle signals already existed
3. Exact central mechanism implemented
4. How the current `ServiceContainer.swift` case is handled
5. Safety / false-positive considerations
6. Whether the project baseline is now cleaner
7. Whether the system is ready for the next full proof run
8. Single next recommended step
```

## What happens after this
If the lifecycle guard can handle the current stale blocker safely, the next correct move is the eleventh full end-to-end autonomy proof run from the cleanest baseline so far.
If the current case cannot yet be handled safely, then the next step should narrow the missing provenance/control gap rather than falling back into repeated contaminated proof runs.
