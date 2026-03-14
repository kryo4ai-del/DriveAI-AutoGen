# DrivaAI-AutoGen Step Report – ML-19

## Title
Profile-Aware Creative Director Gate Policy

## Why this step now
The CD parser hardening did its job: the Creative Director gate signal is now more trustworthy and auditable.

The key result is important:
the pipeline is **not** mainly blocked by parser ambiguity anymore.
It is blocked because the Creative Director is returning a real `fail`, and the current gate policy treats that as a hard stop even in the current development-oriented factory phase.

That means the next blocker is now a **policy / control-flow mismatch**:
the factory is trying to prove autonomous app generation on a technical core path, while the Creative Director gate is still acting like a premium-quality final-approval gate.

## Background
The latest report established:

- all correctly formatted `Rating:` lines in the analyzed runs came from the `creative_director`
- the previous “wrong agent parsed” hypothesis was disproven
- the parser is now more robust and auditable
- for the analyzed runs, the gate outcome remains `FAIL`
- the remaining blocker is therefore the **gate policy**, not the parser

This matters because the current factory objective is still:
**produce a clean, autonomous, technically viable app output first**.

At this stage, a strict Creative Director hard stop can prevent the pipeline from reaching:
- compile hygiene
- compile check
- recovery
- final technical truth

## Strategic reasoning
We should not remove the Creative Director entirely.
The CD still provides useful review signal and should continue generating findings.

But for the current development-focused core validation phase, the CD should not be allowed to prematurely block the technical pipeline when the issue is quality-calibration rather than technical impossibility.

The smallest safe move is therefore:
- keep the CD review
- keep the CD rating visible
- make the gate **profile-aware**
- for dev-oriented profiles, downgrade CD `fail` from hard stop to advisory or non-blocking continuation
- preserve stricter gating for higher-quality profiles later

This keeps the architecture honest while aligning the gate with the current phase of factory maturation.

## Goal
Allow the factory to continue through the technical validation path in development-oriented runs even when the Creative Director returns `fail`, while preserving the CD signal and keeping stricter gating available for other profiles.

## Desired outcome
- the CD remains part of the pipeline
- CD findings are still logged and usable
- dev-profile runs are no longer stopped too early by premium-quality expectations
- the next proof run can reveal the real downstream technical blocker, if any
- stricter CD gating can remain available for standard/premium phases later

## In scope
- trace how CD gate policy is currently applied
- identify the smallest profile-aware control point
- implement a minimal rule such as:
  - Dev profile: CD fail becomes advisory / continue
  - Higher-quality profiles: existing hard gate may remain
- preserve logging so the CD rating and gate decision are explicit
- validate before/after gate behavior

## Out of scope
- removing the Creative Director from the system
- rewriting the whole quality governance model
- changing recovery, knowledge, legal, marketing, or roadmap layers
- broad prompt rewrites
- hiding or ignoring CD feedback

## Success criteria
- clear identification of current gate policy location
- minimal profile-aware gate policy fix implemented
- before/after evidence of dev-profile gate behavior
- CD findings still preserved
- the next end-to-end proof run becomes the correct follow-up

## Claude Code Prompt
```text
Goal:
Make the Creative Director gate policy profile-aware so development-oriented runs can continue through the technical validation path even when the Creative Director returns `fail`, while preserving the CD review signal.

Task:
Audit and minimally adjust the current Creative Director gate policy so the CD remains active, but its blocking behavior matches the current run profile and factory phase.

Do not:
- remove the Creative Director from the pipeline
- change the parser again unless required by the policy change
- redesign the full quality governance system
- change recovery, knowledge, strategy, or marketing layers
- hide or discard CD findings

Required work:
1. Trace where the current CD gate policy decides stop vs continue.
2. Identify the smallest safe control point for profile-aware behavior.
3. Implement a minimal policy such as:
   - development-oriented profile(s): CD `fail` becomes advisory / non-blocking continuation
   - standard or premium profile(s): existing stricter behavior may remain
4. Preserve explicit logging for:
   - CD rating
   - profile
   - gate decision
   - reason for continue vs stop
5. Keep the change narrow and auditable.
6. Run the closest practical validation showing that dev-profile behavior now continues past CD fail while preserving the rating signal.

Validation:
- show before/after gate behavior for a representative dev-profile case
- show the selected policy path
- show how CD findings remain available downstream
- if a full end-to-end run is too expensive, provide code-path proof plus the closest runnable validation

Expected report:
1. Current CD gate policy root cause
2. Minimal policy fix implemented
3. Files changed
4. Before vs after gate behavior
5. Remaining limits
6. Whether dev-profile runs are now materially less likely to stop prematurely at the CD gate
```

## What happens after this
If this step succeeds, the next step should be a new real end-to-end autonomy proof run on AskFin.
That run should finally tell us what the true downstream technical blocker is once the development-phase CD hard stop no longer dominates the path.
