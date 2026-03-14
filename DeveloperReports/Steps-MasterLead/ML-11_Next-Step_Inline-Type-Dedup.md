# MasterLead Step Report — ML-11

## Title
Deterministic removal/prevention of inline duplicate type definitions in agent-generated Swift code

## Current situation
The second end-to-end autonomy proof was a real operational improvement:
- all 7 agent passes completed,
- the OutputIntegrator fix worked as intended,
- integrator-caused FK-012 duplicate collisions dropped to 0,
- total issues dropped sharply from the previous run.

But the run still failed at compile hygiene because a new primary blocker is now exposed clearly:
**inline duplicate type definitions created by the agents themselves inside project files.**

Examples from the report include types such as `ReadinessLevel`, `ExamReadinessScore`, and `StrengthRating` being defined both:
- in their own dedicated file, and
- inline at the end of other Swift files.

This is no longer an integration-layer problem. It is now a **code-generation correctness problem** inside the factory core.

## Why this is the next step
This is the single most important next blocker because:
1. it creates real Swift compile-breaking duplicates,
2. the previous integrator fix already proved the downstream infrastructure is now materially safer,
3. the factory cannot be called "clean app capable" while the generator still emits duplicate type ownership,
4. fixing this will test whether the remaining blocker is primarily generation quality rather than orchestration.

## Strategic reasoning
We should **not** start with a prompt-only fix as the main solution.
A prompt reminder like "define each type only once" may help, but it is not deterministic enough, especially for smaller/cheaper models and repeated autonomous runs.

The stronger factory-level move is:
- first identify where duplicate type ownership is introduced,
- then add the smallest deterministic prevention or cleanup mechanism,
- and only use prompt reinforcement as a secondary support if needed.

That keeps the architecture honest and scalable.

## Goal of this step
Make the factory materially safer against duplicate Swift type generation by ensuring that a type is not emitted both inline and in a dedicated file in the same run/project path.

## What this step should accomplish
The next implementation step should aim to:
- trace where inline duplicate types are introduced,
- determine whether the best minimal fix is:
  - pre-write prevention,
  - post-generation cleanup,
  - or a very small ownership rule around extracted/generated Swift types,
- reduce or eliminate the newly exposed intra-project FK-012 duplicates,
- keep the fix narrow and deterministic.

## What this step should NOT do
- no broad architecture redesign,
- no large Swift merge engine,
- no recovery redesign,
- no new strategy/legal/marketing work,
- no speculative cleanup outside the duplicate-type blocker.

## Success criteria
A good result from the next step would show:
- duplicate type ownership is traced clearly,
- the chosen fix is deterministic and minimal,
- FK-012 duplicate definitions from inline agent output are materially reduced,
- the factory becomes closer to a compilable AskFin output without introducing broad new complexity.

## Why this matters for the bigger plan
This step is still part of the current core-autonomy plan, not a distraction from the future scale architecture.
In fact, deterministic ownership of generated artifacts is foundational for later 200–500 file scaling.
A modular large-app factory will also fail if type ownership is ambiguous or duplicated.

## Expected follow-up after this step
If this blocker is fixed cleanly, the correct follow-up will likely be:
- another end-to-end autonomy proof run,
- then reassessment of the next real blocker,
- and only after the core is stable enough, movement toward the larger scale/decomposition architecture.
