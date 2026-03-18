# DrivaAI-AutoGen Step Report – ML-81

## Title
Golden Gate Failure Response and Regression Triage Workflow

## Why this step now
The latest report confirms another real factory milestone.

AskFin is no longer only protected by tests in principle.
It is now protected by an explicit promotion barrier:

- `scripts/run_golden_gates.sh` exists
- it executes build + 11 tests
- it returns clear success/failure via exit code
- it emits a JSON result
- ALL PASSED → safe to promote
- AskFin now has an explicit gate-governed baseline

That is strategically important because the project has crossed from:
- “tests exist”
to
- “promotion is blocked unless tests pass”

But one major factory question now becomes central:

**What happens when the gates fail?**

If that answer is still mostly manual and ad hoc, then the factory is only half-governed.
The next correct move is therefore not another expensive model run and not more app feature work.
The next correct move is to define and implement the factory’s first explicit **gate-failure response path**.

## Background
Current proven state:
- AskFin has a clean, working, protected baseline
- golden gates are automated
- promotion now depends on those gates
- JSON results exist

This means the next unknown is no longer:
“Can we detect regressions?”

The next unknown is:
“Can the workflow respond to regressions in a structured way?”

That is the correct next milestone for your long-term goal.
A real autonomous factory does not only know how to say:
- pass
- fail

It also knows how to say:
- what failed
- how serious it is
- whether promotion is blocked
- what repair path should start next

## Strategic reasoning
We should now build the response layer beneath the gate system.

Why?
Because without an explicit fail-response workflow, future red gates still collapse back into manual interpretation.
That would mean the factory can detect a regression, but not govern its consequences properly.

The right next step is therefore:
- classify gate failures into meaningful families
- standardize the fail artifact/output
- define what happens when promotion is blocked
- point the workflow toward the correct next repair path

This is exactly the kind of higher-level governance layer you wanted:
not another local fix,
but a system that knows how to react when something goes wrong.

## Goal
Create the first explicit gate-failure response workflow so AskFin regressions are not only detected, but also classified, blocked, and routed into the correct repair path automatically.

## Desired outcome
- golden gate failures produce a structured triage result
- promotion remains blocked automatically on failure
- failures are classified into useful families such as:
  - build failure
  - launch/runtime failure
  - home-flow failure
  - journey failure
  - persistence/history failure
  - cold-launch restore failure
- the workflow makes the next repair route explicit
- AskFin moves from gate-protected to gate-governed-with-response

## In scope
- inspect `scripts/run_golden_gates.sh` and current JSON output
- define a minimal regression-triage schema
- define gate-failure categories and severity
- define clear workflow behavior on pass vs fail
- add the smallest robust mechanism that produces a structured fail artifact or summary
- ensure promotion stays blocked on failure
- if practical, simulate or run a failing-path example without damaging the stable baseline
- document the next-repair routing behavior

## Out of scope
- another LLM generation/autonomy run
- broad CI/CD redesign
- new app features
- unrelated app changes
- commercialization work

## Success criteria
- gate failure is no longer just “red”
- it becomes classified, structured, and workflow-actionable
- pass/fail consequences are explicit
- AskFin now has not only a protected baseline, but a governed regression response path
- future regressions can be handled more systematically by the factory

## Strategic note for later planning
The broader DriveAI-AutoGen direction remains unchanged:
build toward a highly autonomous, self-improving factory with stronger central coordination, stronger truth systems, better lifecycle governance, richer planning and decomposition, and eventually trustworthy multi-provider / multi-model routing.
This step specifically advances the system from “the factory can block bad changes” to “the factory knows how to react when a bad change happens.”

## Claude Code Prompt
```text
Goal:
Create the first explicit gate-failure response workflow so AskFin regressions are not only detected, but also classified, blocked, and routed into the correct repair path automatically.

Prompt ist für Mac

Task:
Inspect the current golden gate workflow (`scripts/run_golden_gates.sh`, JSON result, pass/fail behavior) and implement the smallest robust failure-response layer that turns a gate failure into a structured regression-triage result.

Current confirmed state:
- `scripts/run_golden_gates.sh` exists
- build + 11 tests are executed
- exit 0/1 works
- JSON result exists
- AskFin baseline is promotion-gated

Important:
Do not start another generation/autonomy run.
Do not broaden into major CI/CD redesign.
Do not add new app features.
The goal is to make gate failures workflow-actionable, not just detectable.

Focus especially on:
- the current JSON result shape
- what information is needed to classify a failure meaningfully
- defining a small failure taxonomy such as:
  - build
  - launch/runtime
  - shell/navigation
  - home-flow
  - journey
  - persistence/history
  - cold-launch restore
- how promotion remains blocked on failure
- how the next repair route is made explicit
- keeping the mechanism minimal, explicit, and reusable

Required checks:
1. Inspect the current golden gate workflow and output.
2. Define the minimal regression-triage schema and failure taxonomy.
3. Implement the smallest useful failure-response mechanism.
4. State clearly what happens on gate fail vs gate pass.
5. If practical, simulate or exercise the failure-response path safely.
6. Confirm that AskFin now has an explicit regression-response workflow, not just a pass/fail gate.
7. End with one single next recommended step.

Expected report:
1. Current gate workflow/output inspected
2. Triage schema and failure taxonomy defined
3. Exact mechanism implemented
4. Pass/fail response behavior
5. Validation/simulation outcome if executed
6. Remaining gaps if any
7. Single next recommended step
```
