# DrivaAI-AutoGen Step Report – ML-70

## Title
Focused Runtime Smoke Test for the Three Functional Home Entry Flows

## Why this step now
The latest runtime wiring step completed the Home entry surface successfully.

Current confirmed runtime state:
- all 3 Home cards are now functional
- `Tägliches Training` opens `TrainingSessionView (.adaptive)`
- `Thema üben` opens `TopicPickerView` as a sheet
- `Schwächen trainieren` opens `TrainingSessionView (.weaknessFocus)`
- build succeeded
- app runs in the simulator

That means the Home hub is no longer only visually complete — it is now wired.
So the next correct move is not another expensive model run and not another compile/build pass.
The next correct move is the next runtime-truth layer:
verify that the three entry flows actually behave coherently after opening.

## Background
The latest report established:

- 3/3 Home cards are now functional
- the two previously unfinished entry actions are wired
- the app still builds and runs successfully after the wiring changes

This is strategically important because the app has moved from:
- launchable shell
to
- navigable shell with a complete primary entry surface

The next unknown is no longer:
“Can the user tap the Home cards?”
The next unknown is:
“Do the first opened flows actually render and behave without immediate runtime issues?”

That is the correct next milestone.

## Strategic reasoning
We should now test the newly opened runtime paths before doing deeper product work.

Why?
Because wiring success is not the same as flow viability.
The next likely runtime issues, if any, will appear after:
- destination view model initialization
- first screen rendering inside the opened flow
- first data/bootstrap assumptions
- first session-state setup
- first modal/push dismissal behavior

This is still the cheapest meaningful next step:
- no expensive Sonnet run
- no new generation
- no broad redesign
- one focused runtime validation step on the newly completed Home flows

This matches the long-term factory goal:
the system should not only expose clickable entry points, but entry flows that actually survive first interaction.

## Goal
Run a focused runtime smoke test for the three now-functional Home entry flows and verify that each one opens, renders, and survives first interaction without immediate blockers.

## Desired outcome
- `Tägliches Training` flow opens and renders cleanly
- `Thema üben` sheet opens cleanly and behaves correctly
- `Schwächen trainieren` flow opens and renders cleanly
- immediate crashes, blank screens, broken dismissals, or obvious bootstrap/data issues are captured exactly if they exist
- the next step can be chosen from real flow-runtime truth rather than wiring truth alone

## In scope
- use the current successful simulator runtime baseline
- launch the app
- open each of the 3 Home entry flows:
  - `Tägliches Training`
  - `Thema üben`
  - `Schwächen trainieren`
- observe whether each destination:
  - opens
  - renders
  - remains stable
  - dismisses/returns correctly if applicable
- record any:
  - crash
  - hang
  - blank screen
  - runtime error state
  - broken modal/navigation behavior
- produce a factual runtime flow report for the next Master Lead step

## Out of scope
- another LLM generation/autonomy run
- deep feature QA
- speculative fixes before runtime evidence is collected
- broad feature redesign
- commercialization work

## Success criteria
- all 3 Home flows are exercised
- runtime behavior of each flow is observed and recorded
- no expensive model run is required
- the next step can be chosen from actual flow-runtime evidence

## Strategic note for later planning
The broader DriveAI-AutoGen direction remains unchanged:
build toward a highly autonomous, self-improving factory with stronger central coordination, stronger truth systems, better lifecycle governance, richer planning and decomposition, and eventually trustworthy multi-provider / multi-model routing.
This step specifically advances the factory from “Home actions are wired” to “Home entry flows actually run.”

## Claude Code Prompt
```text
Goal:
Run a focused runtime smoke test for the three now-functional Home entry flows and verify that each one opens, renders, and survives first interaction without immediate blockers.

Prompt ist für Mac

Task:
Use the current successful simulator runtime baseline exactly as it stands and perform a focused runtime smoke pass through the 3 Home entry flows.

Current runtime status:
- `Tägliches Training` → `TrainingSessionView (.adaptive)`
- `Thema üben` → `TopicPickerView` (sheet)
- `Schwächen trainieren` → `TrainingSessionView (.weaknessFocus)`
- build succeeded
- app runs in the simulator

Important:
Do not start another generation/autonomy run.
Do not broaden into deep feature QA.
Do not make speculative fixes before collecting runtime flow evidence.
Use the currently running build as the source of truth.

Focus especially on:
- whether each of the 3 Home entry flows opens successfully
- whether the destination screen/sheet renders
- whether the opened flow remains stable
- whether there are obvious runtime blockers such as:
  - crash
  - hang
  - blank screen
  - broken dismissal/navigation
  - bootstrap/data initialization failure
  - immediate state/setup errors

Required checks:
1. Launch the app from the current successful simulator baseline.
2. Open each of the 3 Home entry flows.
3. Record whether each flow:
   - opens cleanly,
   - renders with visible issues,
   - fails with runtime blockers,
   - or is only partially wired.
4. If a runtime issue appears, isolate the first concrete blocker(s) exactly.
5. Do not perform broad fixes in this step.
6. End with one single next recommended step based on runtime flow evidence.

Expected report:
1. Runtime environment used
2. Home flows tested
3. Exact flow outcomes
4. First concrete runtime blockers if any
5. Interpretation of whether remaining issues are navigation/UI/bootstrap/data-related
6. Single next recommended step
```

## What happens after this
If all three Home flows survive first interaction cleanly, the next step should likely be one happy-path feature pass inside the most complete flow or a baseline freeze + docs/state consolidation.
If one of the flows fails at runtime, the next step should target the first concrete runtime blocker directly and cheaply.
