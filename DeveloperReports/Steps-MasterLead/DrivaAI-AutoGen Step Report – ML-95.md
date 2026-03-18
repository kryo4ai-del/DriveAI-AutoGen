# DrivaAI-AutoGen Step Report – ML-95

## Title
Post-Exam CTA Runtime Validation and Guided Weakness-to-Training Flow Test

## Why this step now
The latest report confirms another protected product truth:

- Gate 12: Weakness Analysis — PASSED
- Generalprobe → 30 Fragen → Result Screen renders
- weakness analysis is now protected by the golden gate suite
- ALL PASSED

That means the result screen and its weakness-analysis layer are no longer just runtime-verified once.
They are now part of the protected AskFin baseline.

So the next correct move is not another expensive model run and not another broad feature-build prompt.
The next correct move is to validate the next user action after the result screen:

Can the user move from post-exam weakness insight into a coherent follow-up learning flow?

## Background
Current protected AskFin truths now include:
- build succeeds
- app launches
- shell/navigation works
- Home entry flows work
- lightweight training journey works
- Verlauf reflects session history
- persistence survives cold launch
- Skill Map behavior is protected
- persistent learning loop is protected
- Generalprobe runtime path is protected
- Generalprobe result persistence is protected
- weakness-analysis result behavior is protected

This is strategically important because the product is no longer only showing analysis.
The next meaningful product question is whether the app can turn analysis into action.

The likely next truth is:
- user finishes Generalprobe
- sees weaknesses
- taps a recommended next action / CTA
- lands in a coherent follow-up learning flow

That is the correct next milestone.

## Strategic reasoning
We should now validate the first guided follow-up path from insight to action.

Why?
Because a learning product becomes far more valuable when it does not stop at “Here are your weak areas.”
It should help the user do the next right thing.

This step is still cost-disciplined:
- no expensive Sonnet run
- no broad architecture redesign
- no new orchestration layer
- one focused runtime truth step on already-existing post-exam UX

This also fits the long-term factory goal:
the system should not only protect isolated screens, but validate meaningful product transitions between them.

## Goal
Run a focused runtime validation of the post-exam CTA path(s) from `SimulationResultView` into the next relevant learning flow, especially weakness-directed training if available.

## Desired outcome
- at least one post-exam CTA is exercised
- CTA behavior is observed and recorded
- the destination flow is coherent and meaningful
- no crash / hang / broken navigation occurs
- the next step can be chosen from real “insight → action” product truth rather than only result-screen truth

## In scope
- inspect the current post-exam result screen CTA surface
- identify which CTA(s) are actually interactive
- complete one representative Generalprobe run if needed
- from the result screen, activate the most meaningful CTA
- verify whether the destination:
  - opens correctly
  - matches the CTA promise
  - remains stable
  - allows the user to continue sensibly
- record any:
  - crash
  - hang
  - blank screen
  - broken navigation
  - misleading CTA-to-destination mismatch
  - stale or missing weakness-context handoff

## Out of scope
- another LLM generation/autonomy run
- broad new feature implementation unless a tiny blocker fix is strictly required
- redesign of the result/analysis architecture
- commercialization work

## Success criteria
- at least one post-exam CTA path is runtime-validated
- the result-to-training handoff is observed and recorded
- no expensive model run is required
- the next step can be chosen from real guided-learning-flow evidence

## Strategic note for later planning
The broader DriveAI-AutoGen direction remains unchanged:
build toward a highly autonomous, self-improving factory with stronger central coordination, stronger truth systems, better lifecycle governance, richer planning and decomposition, and eventually trustworthy multi-provider / multi-model routing.
This step specifically advances the system from “the app shows weakness analysis” to “the app can guide the user from weakness insight into the next learning action.”

## Claude Code Prompt
```text
Goal:
Run a focused runtime validation of the post-exam CTA path(s) from `SimulationResultView` into the next relevant learning flow, especially weakness-directed training if available.

Prompt ist für Mac

Task:
Inspect the existing CTA surface on the Generalprobe result screen, determine which CTA(s) are actually interactive, and validate the most meaningful post-exam follow-up flow from insight to action.

Current confirmed state:
- Gate 12: Weakness Analysis PASSED
- Generalprobe result screen renders with gap analysis
- weakness-analysis result behavior is protected by the golden gates
- ALL PASSED

Important:
Do not start another generation/autonomy run.
Do not broaden into deep feature QA.
Do not redesign the result/analysis architecture.
Do not add broad new features unless a tiny blocker fix is strictly required for the tested CTA path.
The goal is runtime validation of the already-existing post-exam CTA flow.

Focus especially on:
- which CTA(s) on the result screen are interactive
- whether the CTA destination matches the promise of the CTA
- whether weakness context or recommended topic focus is handed off coherently
- whether the destination flow is stable and meaningful
- whether any step causes:
  - crash
  - hang
  - blank state
  - broken navigation
  - CTA mismatch
  - missing context handoff

Required checks:
1. Identify the available CTA(s) on the Generalprobe result screen.
2. Determine which CTA is the highest-value runtime validation target.
3. Complete a representative Generalprobe run if needed to reach the result screen.
4. Activate the chosen CTA.
5. Record whether the destination:
   - opens cleanly,
   - matches the CTA promise,
   - remains stable,
   - or shows runtime/navigation/context issues.
6. If a blocker appears, isolate the first concrete blocker exactly.
7. End with one single next recommended step.

Expected report:
1. Available CTA surface inspected
2. CTA chosen and why
3. Runtime destination outcome
4. Any blockers or inconsistencies found
5. Interpretation of whether remaining issues are CTA/navigation/context-related
6. Single next recommended step
```
