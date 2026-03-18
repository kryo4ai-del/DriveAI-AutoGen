# DrivaAI-AutoGen Step Report – ML-79

## Title
Golden Acceptance Gate Automation from the Proven AskFin Runtime Baseline

## Why this step now
The latest cold-launch report confirms a major durable-state milestone.

Current confirmed state:
- state is fully restored after terminate + relaunch
- 100% Prüfungsbereit remains intact after cold launch
- `UserDefaults` persistence works for:
  - `TopicCompetence`
  - `SessionHistory`
- no data loss
- cross-tab state remains consistent

That means AskFin has now crossed a very important threshold:

it is no longer just a manually recoverable success case.
It is now a product baseline with repeatable, proven truths across:
- build
- launch
- navigation
- training journey
- session history
- persistence
- cold-launch restoration

So the next correct move is not another expensive model run and not immediate new feature expansion.
The next correct move is to turn these proven truths into **automated acceptance gates** for the factory.

## Background
We now have a strong verified staircase:

- Xcode build clean
- simulator launch clean
- 4/4 tabs work
- 3/3 Home flows work
- first in-flow interactions work
- full lightweight training journey works
- Verlauf integration works
- multi-session coherence works
- cold-launch restoration works

This is strategically important because these are no longer hypotheses.
They are now validated runtime truths.

If we do not encode them into repeatable acceptance checks, then the system still depends too much on manual rediscovery.
That would slow down the transition from “Mac agent improving the app” to “Factory enforcing quality automatically.”

## Strategic reasoning
We should now capture the proved behavior as a reusable validation layer.

Why?
Because this is exactly the moment where the project should move one level upward:
from proving the app manually,
to teaching the factory what “good” now means.

The right next move is therefore:
- define the proven runtime/build truths as named gates
- automate as many of them as practical using the existing UI-test/build infrastructure
- make future regressions visible immediately

This is aligned with your long-term goal:
not just shipping one app,
but building a factory that can protect correctness and stop repeating solved mistakes.

## Goal
Create the first golden acceptance gate suite from the currently proven AskFin baseline, so the factory can automatically verify the app's core build/runtime truths in future iterations.

## Desired outcome
- the proven AskFin truths are converted into named acceptance gates
- at least the most important gates are automated or scaffolded
- future regressions in:
  - build
  - launch
  - home flow wiring
  - training journey
  - session history
  - cold-launch restoration
  become easier to catch automatically
- the project moves from manual proof accumulation toward reusable factory validation discipline

## In scope
- inspect the current `AskFinUITests` setup and any existing build/test scripts
- define a minimal golden gate set for the currently proven baseline
- prioritize gates such as:
  1. build succeeds
  2. app launches
  3. 4 tabs available
  4. 3 Home actions available
  5. one training journey can complete
  6. session history appears
  7. cold-launch restore preserves state
- automate the subset that is practical now
- scaffold or document the remainder clearly if full automation is not yet practical
- ensure the gate names and purpose are explicit
- run the gates if practical and record the result

## Out of scope
- another LLM generation/autonomy run
- broad feature expansion
- redesign of the whole test architecture
- deep analytics QA
- commercialization work

## Success criteria
- a first named acceptance gate set exists
- the most important proven truths are automated or clearly scaffolded
- the project now has a reusable quality baseline, not just one-off successful runs
- future work can be measured against this baseline automatically

## Strategic note for later planning
The broader DriveAI-AutoGen direction remains unchanged:
build toward a highly autonomous, self-improving factory with stronger central coordination, stronger truth systems, better lifecycle governance, richer planning and decomposition, and eventually trustworthy multi-provider / multi-model routing.
This step specifically advances the project from “AskFin works now” to “the factory can prove that AskFin still works later.”

## Claude Code Prompt
```text
Goal:
Create the first golden acceptance gate suite from the currently proven AskFin baseline, so the factory can automatically verify the app's core build/runtime truths in future iterations.

Prompt ist für Mac

Task:
Inspect the current `AskFinUITests` setup, build/test scripts, and proven runtime baseline, then define and implement the smallest useful golden acceptance gate suite for AskFin.

Current confirmed baseline truths:
- Xcode build succeeds
- app launches in simulator
- 4/4 tabs work
- 3/3 Home flows work
- lightweight training journey works
- Verlauf reflects session history
- state persists across cold launch

Important:
Do not start another generation/autonomy run.
Do not broaden into major feature work.
Do not redesign the whole testing architecture.
The goal is a practical first acceptance-gate layer that captures the truths we have already proven.

Focus especially on:
- what can already be automated with `AskFinUITests`
- what should be a named gate even if only partially automated at first
- the smallest reliable gate set that protects the proven baseline
- making regression detection easy and explicit
- keeping the gate suite minimal, understandable, and reusable

Required checks:
1. Inspect current test/build automation assets.
2. Define the minimal golden gate set for the proven AskFin baseline.
3. Implement or scaffold the gates with clear naming and purpose.
4. Automate as much of the key baseline as practical now.
5. If practical, run the gate suite and record the outcome.
6. State which truths are now protected automatically and which are only scaffolded.
7. End with one single next recommended step.

Expected report:
1. Existing test/build assets found
2. Golden gate set defined
3. What was implemented vs scaffolded
4. Gate run outcome if executed
5. Regression protection now covered
6. Gaps that remain
7. Single next recommended step
```
