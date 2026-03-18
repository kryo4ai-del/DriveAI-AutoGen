# DrivaAI-AutoGen Step Report – ML-85

## Title
Persistent Learning Loop Golden Gate Expansion

## Why this step now
The latest report confirms another important baseline upgrade:

- Gate 7: Skill Map — PASSED
- Lernstand tab renders content
- 13 tests total
- 0 failures
- AskFin baseline is further protected

That means Skill Map is no longer only runtime-validated — it is now part of the protected golden baseline.

So the next correct move is not another expensive model run and not a new feature build prompt.
The next correct move is to protect the next highest-value proven truth that still matters most for AskFin as a learning product:

the **persistent learning loop** itself.

## Background
AskFin has already proven, through prior runtime evidence, that:
- a training journey can complete
- progress updates
- Verlauf reflects sessions
- state survives restart
- multi-session state stays coherent
- Skill Map/Lernstand reflects progress

The strategic gap is:
not all of that product-state truth is necessarily protected as one coherent acceptance path.

Right now, the system has many proven truths.
The next step is to bind the most important of them into one stronger gate:

**Complete session → reflected progress/history → survives cold launch.**

## Strategic reasoning
We should now protect the end-to-end learning loop, not just isolated surfaces.

Why?
Because AskFin is no longer only an app that renders screens.
It is now becoming a real learning product.

The most important product truth is no longer just:
- app launches
- tabs render
- Skill Map opens

The most important product truth is:
- a user completes learning activity
- the product records it
- the product reflects it
- the product still remembers it later

That is the real durable learning loop.

This is the highest-value next gate because it protects the core product promise, not just one UI surface.

## Goal
Expand the golden acceptance suite with a persistent learning-loop gate that protects the end-to-end truth:
completed training updates progress/history and survives cold launch.

## Desired outcome
- the golden suite protects a true product loop, not only isolated screens
- at least one automated path verifies:
  - complete training session
  - reflected progress/history
  - relaunch persistence
- future regressions in the durable learning loop become detectable automatically
- the protected AskFin baseline becomes meaningfully closer to a true product-quality baseline

## In scope
- inspect current golden gate/XCUITest coverage
- identify the smallest coherent acceptance slice for the persistent learning loop
- likely include:
  1. complete one lightweight training journey
  2. verify progress/history reflection
  3. cold relaunch
  4. verify restored reflection
- implement or extend the relevant automated coverage
- run the expanded gate/test path if practical
- record whether the baseline remains green

## Out of scope
- another LLM generation/autonomy run
- new product feature implementation
- broad redesign of persistence/history architecture
- deep analytics/statistics work
- commercialization work

## Success criteria
- a persistent learning-loop gate exists
- the gate covers session completion + reflection + restore in one coherent acceptance path
- the AskFin golden baseline protects more than UI reachability
- future regressions in the app's core learning loop become easier to catch automatically

## Strategic note for later planning
The broader DriveAI-AutoGen direction remains unchanged:
build toward a highly autonomous, self-improving factory with stronger central coordination, stronger truth systems, better lifecycle governance, richer planning and decomposition, and eventually trustworthy multi-provider / multi-model routing.
This step specifically advances the system from “the app works and key screens are protected” to “the core durable learning loop is protected automatically.”

## Claude Code Prompt
```text
Goal:
Expand the golden acceptance suite with a persistent learning-loop gate that protects the end-to-end truth: completed training updates progress/history and survives cold launch.

Prompt ist für Mac

Task:
Inspect the current golden gate/XCUITest coverage and implement the smallest coherent automated acceptance path that verifies the durable AskFin learning loop:
complete training → reflected progress/history → cold relaunch → restored state.

Current confirmed state:
- Gate 7: Skill Map PASSED
- 13 total tests, 0 failures
- build/launch/shell/home flows/journey/persistence/Skill Map are protected or proven
- AskFin baseline is further protected

Important:
Do not start another generation/autonomy run.
Do not broaden into new feature work.
Do not redesign the persistence/history architecture.
The goal is to protect the core durable learning loop as a golden gate.

Focus especially on:
- what current automated coverage already exists for:
  - training journey
  - Verlauf/history
  - persistence/relaunch
- the smallest coherent acceptance slice that combines them
- whether an existing XCUITest should be extended or whether one dedicated test is cleaner
- making the gate deterministic, understandable, and reusable

Required checks:
1. Inspect the current golden gate/XCUITest coverage around journey/history/persistence.
2. Define the smallest coherent persistent learning-loop gate.
3. Implement or extend the relevant automated coverage.
4. Run the expanded gate/test path if practical.
5. Record whether:
   - the new gate works,
   - the full golden baseline remains green,
   - or a concrete blocker appears.
6. If a blocker appears, isolate the first concrete blocker exactly.
7. End with one single next recommended step.

Expected report:
1. Current gate/test coverage inspected
2. Persistent learning-loop acceptance slice chosen
3. Exact automated coverage added or extended
4. Gate/test run outcome
5. Any blockers found
6. Interpretation of whether remaining issues are gate/persistence/history/state-related
7. Single next recommended step
```
