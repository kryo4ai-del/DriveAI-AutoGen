# DrivaAI-AutoGen Step Report – ML-69

## Title
Home Entry Wiring Completion for the Remaining `Tägliches Training` and `Schwächen trainieren` Actions

## Why this step now
The first navigation and interaction smoke test confirms that AskFin has crossed the next real runtime threshold.

Observed runtime result:
- 4/4 tabs have working views
- Home renders correctly
- Lernstand works
- Generalprobe works
- Verlauf works
- `Thema üben` opens a functional `TopicPickerView` sheet
- only 2 of the 3 home entry actions remain unfinished:
  - `Tägliches Training`
  - `Schwächen trainieren`

That means the shell is no longer the blocker.
The next correct move is not another expensive model run and not a broad feature expansion.
The next correct move is a small central runtime-wiring completion step for the remaining home entry points.

## Background
The runtime smoke test established:

- the app launches
- the full bottom-tab shell works
- the visible primary screens can be opened
- one home-card action is already wired
- the remaining two home-card actions are explicitly still TODO

This is strategically important because we are no longer dealing with basic launch or navigation fragility.
We are dealing with a narrow and concrete product-shell completion gap:
the home hub exposes 3 primary actions, but only 1 is currently interactive.

That means the next step should not be another generalized system exercise.
It should be a focused completion of the home entry contract.

## Strategic reasoning
We should complete the home entry wiring before doing deeper feature-path smoke tests.

Why?
Because the home screen is now the primary user-facing launch surface.
If two of its three main actions are still TODO, then further runtime testing below that layer is artificially constrained.

This is also the cheapest meaningful next step:
- no expensive Sonnet run
- no new generation/autonomy loop
- no broad architecture churn
- one narrow runtime wiring task with immediate user-visible value

This fits the long-term factory goal:
the system should not only build and launch, but also expose coherent, navigable primary entry points.

## Goal
Wire the remaining two Home actions — `Tägliches Training` and `Schwächen trainieren` — to their correct first-level destination flow, using the smallest safe and coherent runtime completion path.

## Desired outcome
- `Tägliches Training` becomes interactive and opens an appropriate first-level screen/flow
- `Schwächen trainieren` becomes interactive and opens an appropriate first-level screen/flow
- the wiring is coherent with the current app structure and does not create dead-end placeholder navigation
- the home screen then exposes 3/3 functional entry points
- the next runtime smoke pass can test a complete home-entry surface instead of a partial one

## In scope
- inspect the Home screen implementation
- inspect the existing routing/navigation patterns already used by `Thema üben`
- determine the correct minimal destinations for:
  - `Tägliches Training`
  - `Schwächen trainieren`
- wire both actions into the smallest coherent first-level flow
- keep the implementation consistent with the current runtime shell
- run a cheap simulator recheck afterward if practical
- confirm whether all 3 home entry cards are now functional

## Out of scope
- another LLM generation/autonomy run
- deep feature implementation behind those flows beyond the first correct destination
- broad redesign of the home screen
- unrelated feature work
- commercialization work

## Success criteria
- `Tägliches Training` is tappable and navigates/presents correctly
- `Schwächen trainieren` is tappable and navigates/presents correctly
- the home screen now exposes 3/3 working primary actions
- no broad runtime regressions are introduced
- the next step can be chosen from a more complete runtime product shell

## Strategic note for later planning
The broader DriveAI-AutoGen direction remains unchanged:
build toward a highly autonomous, self-improving factory with stronger central coordination, stronger truth systems, better lifecycle governance, richer planning and decomposition, and eventually trustworthy multi-provider / multi-model routing.
This step specifically advances the factory from “runtime shell works” to “runtime home entry surface is actually usable.”

## Claude Code Prompt
```text
Goal:
Wire the remaining two Home actions — `Tägliches Training` and `Schwächen trainieren` — to their correct first-level destination flow, using the smallest safe and coherent runtime completion path.

Prompt ist für Mac

Task:
Inspect the current Home screen implementation and the existing runtime navigation patterns, then wire the two remaining TODO actions so all 3 Home entry cards become functional.

Current runtime status:
- 4/4 tabs work
- `Thema üben` already opens `TopicPickerView`
- `Tägliches Training` is still TODO
- `Schwächen trainieren` is still TODO

Important:
Do not start another generation/autonomy run.
Do not broaden scope into deep feature development.
Do not redesign the entire home screen.
The goal is a focused runtime wiring completion step for the remaining two Home entry points.

Focus especially on:
- how `Thema üben` is currently wired
- what the most coherent first-level destination should be for:
  - `Tägliches Training`
  - `Schwächen trainieren`
- whether those should push, present a sheet, or reuse an existing screen pattern
- keeping the implementation minimal, consistent, and testable
- avoiding dead-end placeholder navigation if a better existing destination already exists

Required checks:
1. Identify the current Home action wiring structure.
2. Determine the smallest coherent destination flow for `Tägliches Training`.
3. Determine the smallest coherent destination flow for `Schwächen trainieren`.
4. Implement the runtime wiring for both actions.
5. If practical, run a simulator recheck afterward.
6. Confirm whether all 3 Home cards are now functional.
7. End with one single next recommended step.

Expected report:
1. Home wiring structure before the change
2. Exact destinations chosen for both remaining actions
3. What was implemented
4. Simulator/runtime recheck outcome
5. Regression/safety summary
6. Whether the Home entry surface is now fully functional
7. Single next recommended step
```

## What happens after this
If all 3 Home entry points become functional, the next best step is a second interaction smoke pass focused on the newly opened flows.
If one of the two actions reveals a deeper missing-flow dependency, the next step should target that dependency directly and cheaply.
