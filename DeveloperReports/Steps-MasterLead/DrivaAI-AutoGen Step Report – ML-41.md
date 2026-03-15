# DrivaAI-AutoGen Step Report – ML-41

## Title
Budget-Aware Run Governance and Promotion Gates After the First True Sonnet Success

## Why this step now
Run 14 already answered the most important stronger-model question.

The first true Sonnet run proved that the stabilized factory core can produce materially stronger output under a stronger model while still returning to a clean end state:
- Sonnet was truly active
- total output increased to 62 Swift files
- 21 files were integrated
- the auto-repair stack handled 3 blocking FK-014 issues and returned the project to 0 BLOCKING
- CompletionVerifier still ended at `MOSTLY_COMPLETE / 95%`

So the core strategic uncertainty is no longer:
“Does Sonnet help at all?”
That has now been answered: yes, it clearly helps.

The new constraint is cost discipline.
If stronger-model proof runs are expensive, then the factory should not keep using them as the default way to think.
Instead, the system needs a clearer central policy for:
- when a dev/cheap run is enough
- when a stronger-profile run is justified
- what preconditions must be satisfied before escalation
- what evidence must be collected before spending more

That means the next correct move is not another Sonnet run.
The next correct move is to build a budget-aware run-governance layer.

## Background
The latest report established:

- this was the first real Sonnet-powered run
- Sonnet uplift is confirmed
- the factory remained stable under higher output
- the remaining technical issue was small and already well understood (`ClosedRange` should be treated as a known framework type)
- the report's local next step was a tiny hygiene/doc step, not another heavy proof run
- repeated expensive runs are now more of an operating-policy question than a repair question

This is the right moment to stop treating every next question as “run again”.
The system now needs a more intelligent promotion policy.

## Strategic reasoning
We should pivot from repeated proof-running to controlled escalation policy.

Why?
Because the next architectural gain is no longer mostly inside compile repair or verifier truth.
It is in deciding how the factory spends expensive model capacity.

A mature autonomous factory should not say:
“we have a question, so launch another expensive run.”

It should say:
- what class of uncertainty do we have?
- can cheap validation answer it?
- do pre-run checks already predict low information gain?
- is stronger-model escalation justified right now?
- what is the maximum run budget for this decision?

This is exactly the kind of central control layer you said you want:
not a local fix,
not speed for its own sake,
but a higher governing layer that prevents waste and increases strategic discipline.

## Goal
Design and implement a first budget-aware run governance / promotion-gate layer so expensive `standard` / Sonnet runs are only triggered when cheaper checks and lower-cost profiles are no longer sufficient.

## Desired outcome
- the system defines clear promotion gates from `dev` to `standard` (and later `premium`)
- stronger-profile runs require explicit preconditions
- the system can identify when the next question is:
  - hygiene/repair validation,
  - generation validation,
  - routing validation,
  - architecture work,
  - docs/state work,
  - or true proof-run work
- cheap validations are preferred when they can answer the current uncertainty
- run-spend becomes more intentional and explainable

## In scope
- inspect current run profiles and how they are used operationally
- define a central run-promotion policy for:
  - `dev`
  - `standard`
  - later `premium`
- define explicit preconditions/checklists before a Sonnet run is allowed
- propose or implement a simple run-budget guard or run-justification record
- define what evidence must be present before expensive escalation
- add docs and/or config support for this governance layer
- include a practical decision tree for:
  - no run
  - cheap validation only
  - dev run
  - standard/Sonnet run
  - premium run
- account for the current reality that small central hygiene fixes may be better than immediate reruns

## Out of scope
- another heavy proof run in this step
- broad provider-routing implementation
- unrelated compile-repair redesign
- feature work
- UI work
- commercialization work

## Success criteria
- there is a clear, reusable policy for when Sonnet runs are justified
- expensive runs are no longer the default next move
- the governance logic is understandable enough to use step by step
- the current next actions can be classified without launching another proof run
- the system becomes more cost-aware without losing rigor

## Strategic note for later planning
The broader DriveAI-AutoGen direction remains unchanged:
build toward a highly autonomous, self-improving factory with stronger central coordination, stronger truth systems, better lifecycle governance, richer planning and decomposition, and eventually trustworthy multi-provider / multi-model routing.
This step specifically strengthens the factory's economic/control discipline so autonomy scales without runaway experimentation cost.

## Claude Code Prompt
```text
Goal:
Design and implement a first budget-aware run governance / promotion-gate layer so expensive `standard` / Sonnet runs are only triggered when cheaper checks and lower-cost profiles are no longer sufficient.

Task:
Inspect the current run-profile usage, run flow, and operator workflow, then add the smallest robust central governance layer that makes run escalation intentional.
The system should help decide whether the next step should be:
- no run,
- cheap validation,
- dev run,
- standard/Sonnet run,
- or later premium/Opus run.

Important:
Do not solve this as a vague documentation note only.
Do not hardcode a single temporary opinion about the current situation.
The goal is a reusable factory-layer control policy for run promotion and budget discipline.

Focus especially on:
- current profile meanings (`dev`, `standard`, `premium`)
- what uncertainty each run type is supposed to answer
- what preconditions must be true before escalating to `standard`
- when cheap static validation should replace a run
- how to record or surface why a run was justified
- how this governance can fit into the current factory docs/config/workflow without overengineering

Required checks:
1. Identify the current decision gaps that lead to expensive runs being launched too quickly.
2. Define a clear promotion policy from `dev` to `standard` (and optionally `premium` later).
3. Implement the smallest robust central representation of this policy (docs, config, helper, or equivalent as appropriate).
4. Show how the current post-Run-14 situation would be classified under the new policy.
5. Confirm that the policy prefers cheaper validation when it can answer the current question.
6. State what the next recommended action is under this new governance layer, without requiring another Sonnet run first.

Expected report:
1. Current run-decision problem
2. Promotion-gate policy defined
3. Exact central artifacts added/updated
4. How the policy classifies the current state after Run 14
5. Cost-discipline / safety benefits
6. Risks or limits that remain
7. Single next recommended step
```

## What happens after this
Once the governance layer exists, the next step should follow the policy rather than habit.
Most likely that means:
- first do the tiny known hygiene/doc corrections cheaply,
- then update operating docs/state,
- and only then schedule the next stronger-model run if the remaining uncertainty still justifies it.
