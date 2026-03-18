# DrivaAI-AutoGen Step Report – ML-97

## Title
Weakness-Training CTA Golden Gate Expansion on the Protected AskFin Baseline

## Why this step now
The latest report confirms that the last meaningful gap in the post-exam CTA surface is now closed.

Current confirmed state:
- Result Screen `Schwächen trainieren` is now wired
- path: Result Screen -> `fullScreenCover` -> `TrainingSessionView(.weaknessFocus)`
- build succeeded
- all other CTAs were preserved

That is strategically important because the post-exam insight-to-action loop is no longer partially wired.
It is now a real product path:
- user finishes Generalprobe
- sees weakness insight
- can enter weakness-focused remediation directly

So the next correct move is not another expensive model run and not immediate new feature expansion.
The next correct move is to absorb this newly proven CTA behavior into the protected golden baseline.

## Background
Current protected AskFin truths already include:
- build succeeds
- app launches
- shell works
- Home flows work
- lightweight training journey works
- Verlauf reflects session history
- persistence survives cold launch
- Skill Map behavior is protected
- persistent learning loop is protected
- Generalprobe runtime path is protected
- Generalprobe result persistence is protected
- weakness-analysis result behavior is protected

Now we have one more validated product truth:
- the most valuable post-exam remediation CTA is truly wired to weakness-focused training

This is strategically important because the project should not leave newly proven behavior as only “recently implemented.”
Once something is proven and important, the factory should protect it automatically.

## Strategic reasoning
We should now convert the proven weakness-training CTA behavior into a golden gate.

Why?
Because this is the exact operating discipline we want from DriveAI-AutoGen:
- prove a behavior
- absorb it into protected baseline truth
- prevent silent regression later

Otherwise the CTA works today, but the factory still has no obligation to defend it tomorrow.

This is still cost-disciplined:
- no expensive Sonnet run
- no new feature generation
- no broad redesign
- one focused gate-expansion step on an already proven new path

This matches the long-term factory goal:
the system should continuously absorb meaningful newly proven product behavior into governed factory truth.

## Goal
Expand the AskFin golden acceptance suite so the proven `Schwächen trainieren` CTA path into `TrainingSessionView(.weaknessFocus)` becomes part of the protected baseline.

## Desired outcome
- the weakness-training CTA is no longer only recently wired
- at least one golden acceptance gate now covers:
  - reaching the Generalprobe result screen
  - activating `Schwächen trainieren`
  - opening the weakness-focused training flow
- future regressions in this post-exam remediation path become detectable automatically
- the protected AskFin baseline becomes stronger without broadening into new feature work

## In scope
- inspect the current golden gate/XCUITest coverage around result CTAs
- identify the smallest coherent acceptance slice for the weakness-training CTA
- add or extend the relevant automated test coverage
- ensure the gate is named clearly and fits the existing suite
- run the expanded golden gate suite if practical
- record whether the protected baseline remains green

## Out of scope
- another LLM generation/autonomy run
- new feature implementation
- broad result-screen redesign
- major test-architecture redesign
- commercialization work

## Success criteria
- the weakness-training CTA path is represented in the golden gate suite
- the new gate is automated or clearly integrated into existing XCUITest coverage
- the protected AskFin baseline is stronger than before
- future changes will be checked against this expanded truth automatically

## Claude Code Prompt
```text
Goal:
Expand the AskFin golden acceptance suite so the proven `Schwächen trainieren` CTA path into `TrainingSessionView(.weaknessFocus)` becomes part of the protected baseline.

Prompt ist für Mac

Task:
Inspect the current golden gate/XCUITest suite and integrate the smallest coherent acceptance check that protects the validated `Schwächen trainieren` CTA behavior from the Generalprobe result screen.

Current confirmed state:
- Result Screen `Schwächen trainieren` -> `fullScreenCover` -> `TrainingSessionView(.weaknessFocus)`
- build succeeded
- all other CTAs preserved

Important:
Do not start another generation/autonomy run.
Do not broaden into new feature work.
Do not redesign the result screen or weakness-training architecture.
The goal is to convert the newly proven remediation CTA path into a protected golden gate.

Focus especially on:
- the smallest reliable acceptance slice for:
  - access to the result screen
  - activation of `Schwächen trainieren`
  - successful presentation of `TrainingSessionView(.weaknessFocus)`
- whether an existing XCUITest can be extended or a new one is cleaner
- keeping the implementation minimal, explicit, and reusable
- fitting the new gate clearly into the current golden suite
- preserving the fully green protected baseline

Required checks:
1. Inspect the current golden gate/XCUITest coverage around result-screen CTA behavior.
2. Define the smallest coherent acceptance gate for `Schwächen trainieren`.
3. Implement or extend the relevant automated test coverage.
4. Run the expanded gate/test path if practical.
5. Record whether:
   - the new gate works,
   - the full golden baseline remains green,
   - or a concrete blocker appears.
6. If a blocker appears, isolate the first concrete blocker exactly.
7. End with one single next recommended step.

Expected report:
1. Current gate/test coverage inspected
2. Weakness-training CTA acceptance slice chosen
3. Exact automated coverage added or extended
4. Gate/test run outcome
5. Any blockers found
6. Interpretation of whether remaining issues are test/gate/CTA-related
7. Single next recommended step
```
