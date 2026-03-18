# DrivaAI-AutoGen Step Report – ML-96

## Title
Post-Exam Weakness Training CTA Wiring Completion on the Protected AskFin Baseline

## Why this step now
The latest CTA runtime report confirms that the Generalprobe result surface is largely coherent at runtime.

Current confirmed state:
- `Alle Antworten ansehen` works
- `Nochmal simulieren` works
- `Fertig` works
- no crash occurred
- 17 tests, 0 failures

Only one meaningful gap remains:
- `Schwächen trainieren` is still only soft-wired
- current behavior uses `onDismiss` instead of real navigation

That means the next correct move is not another expensive model run and not a broad feature expansion.
The next correct move is a narrowly bounded completion of the one remaining weak point in the post-exam insight-to-action path.

## Background
The result screen is now proven in multiple layers:
- runtime validation
- weakness-analysis rendering
- CTA runtime behavior for 3 of 4 actions

This is strategically important because the product is very close to a coherent post-exam action loop.
The current remaining gap is no longer uncertainty.
It is one explicit TODO in the most valuable CTA:
`Schwächen trainieren`.

That is the correct next milestone.

## Strategic reasoning
We should complete the real weakness-to-training handoff now.

Why?
Because this CTA is the most product-significant one on the result screen:
it turns diagnosis into remediation.

The current state proves that the app can:
- show weaknesses
- restart simulation
- dismiss
- show all answers

But the most valuable next user action is still not truly wired.
Fixing that one path has higher leverage than adding more surface area elsewhere.

This is still cost-disciplined:
- no expensive Sonnet run
- no new broad feature buildout
- no architecture redesign
- one tightly scoped runtime-wiring completion on a protected baseline

## Goal
Replace the current soft-wired `Schwächen trainieren` CTA behavior with a real coherent navigation/handoff into the appropriate weakness-focused training flow.

## Desired outcome
- `Schwächen trainieren` is no longer TODO-like
- it opens a real follow-up training path
- the destination matches the CTA promise
- weakness context is handed off coherently if practical
- the golden gates remain green afterward
- the post-exam insight-to-action loop becomes substantially more complete

## In scope
- inspect the current CTA implementation on the result screen
- inspect how weakness-focused training is already represented elsewhere in the app
- determine the smallest coherent real destination for `Schwächen trainieren`
- replace the current soft-wire/onDismiss behavior with real navigation/presentation
- preserve current working CTA behavior for the other actions
- run runtime verification afterward if practical
- run golden gates afterward if practical

## Out of scope
- another LLM generation/autonomy run
- broad redesign of result-screen architecture
- full adaptive weakness engine
- large context-passing refactor unless strictly necessary
- commercialization work

## Success criteria
- `Schwächen trainieren` becomes a real user path
- the destination is coherent and stable
- no regressions are introduced to the existing result CTA surface
- golden gates remain green afterward
- the product proves a stronger diagnosis-to-remediation loop

## Strategic note for later planning
The broader DriveAI-AutoGen direction remains unchanged:
build toward a highly autonomous, self-improving factory with stronger central coordination, stronger truth systems, better lifecycle governance, richer planning and decomposition, and eventually trustworthy multi-provider / multi-model routing.
This step specifically advances the system from “post-exam CTAs mostly work” to “the most valuable remediation CTA is truly connected.”

## Claude Code Prompt
```text
Goal:
Replace the current soft-wired `Schwächen trainieren` CTA behavior with a real coherent navigation/handoff into the appropriate weakness-focused training flow.

Prompt ist für Mac

Task:
Inspect the current `Schwächen trainieren` CTA implementation on the Generalprobe result screen, identify the smallest coherent real destination for that CTA, implement the real wiring, and then verify that the protected baseline remains green.

Current confirmed state:
- `Alle Antworten ansehen` works
- `Nochmal simulieren` works
- `Fertig` works
- `Schwächen trainieren` is still soft-wired TODO (`onDismiss` instead of real navigation)
- 17 tests, 0 failures
- no crash

Important:
Do not start another generation/autonomy run.
Do not broaden into a large weakness-training architecture buildout.
Do not redesign the whole result screen.
The goal is a tightly scoped wiring completion for the most valuable remaining CTA.

Focus especially on:
- what weakness-focused training path already exists in the app
- what the smallest coherent destination is for `Schwächen trainieren`
- whether weakness context can be passed safely and minimally
- replacing the current soft-wire with real navigation/presentation
- preserving all currently working CTA behavior
- verifying the result against runtime behavior and golden gates afterward

Required checks:
1. Inspect the current `Schwächen trainieren` CTA implementation.
2. Identify the smallest coherent real destination for this CTA.
3. Implement the real wiring.
4. Run a focused runtime verification of the CTA afterward.
5. Run the golden gate suite afterward if practical.
6. Record whether:
   - the CTA now works cleanly,
   - the destination matches the CTA promise,
   - the baseline remains green,
   - or a concrete blocker appears.
7. If a blocker appears, isolate the first concrete blocker exactly.
8. End with one single next recommended step.

Expected report:
1. Current CTA wiring inspected
2. Destination chosen and why
3. Implementation summary
4. Runtime verification outcome
5. Golden gate outcome
6. Any blockers found
7. Single next recommended step
```
