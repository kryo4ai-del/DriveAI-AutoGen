# DrivaAI-AutoGen Step Report – ML-75

## Title
Session Persistence Layer and Restart-State Recovery for Training Progress

## Why this step now
The latest runtime report confirms that AskFin has crossed another meaningful product threshold.

Current confirmed state:
- a full training session can be completed
- post-session navigation across Home, Verlauf, and Lernstand works without crash
- cross-tab state is coherent while the app remains running
- shared in-memory state via `TopicCompetenceService` works
- the main remaining gap is that state is **not yet persisted across app restart**

That means the next correct move is not another expensive model run and not broader feature work.
The next correct move is to add the first real persistence loop for training outcomes.

## Background
The latest report established:

- 5/5 post-session tests passed
- Session → Home → Verlauf → Lernstand works without crash
- cross-tab state is coherent
- the current limitation is explicitly:
  - state is in-memory only
  - not persisted over restart
- Verlauf is still separate from training history and not yet connected

This is strategically important because the current product is now runtime-stable enough that memory-only state becomes the next real limitation.

A training app that forgets everything after restart is not yet a real learning system.
So the next milestone is not more UI breadth, but data continuity.

## Strategic reasoning
We should now build the smallest useful persistence layer before expanding more user journeys.

Why?
Because once persistence works, multiple later capabilities become meaningful:
- restored Lernstand after reopen
- restored Home readiness/progress
- real session history
- trend calculations over time
- weak-area tracking that survives restart

Without persistence, later analytics and learning loops will stay shallow.

This is still cost-disciplined:
- no expensive Sonnet run
- no new generation/autonomy loop
- no broad redesign
- one focused product-state step that upgrades the app from transient demo behavior toward durable learning behavior

This matches the long-term factory goal:
the system should produce apps whose important state survives beyond one launch.

## Goal
Implement the smallest safe persistence layer for completed training-session outcomes and verify restart-state recovery across Home, Lernstand, and related services.

## Desired outcome
- training-session results are persisted after completion
- app restart restores the relevant state
- Home and Lernstand reflect restored state after relaunch if intended
- the current in-memory-only limitation is removed
- the next step can be chosen from persistent product-state truth rather than transient runtime truth

## In scope
- inspect the current state flow around training completion
- inspect `TopicCompetenceService` and related state owners
- determine the smallest correct persistence mechanism for current needs
- persist at least the minimum data needed to restore meaningful progress after restart
- restore persisted state on app launch
- verify post-restart behavior for:
  - Home
  - Lernstand
  - any directly related training progress surfaces
- run a focused restart-state test afterward if practical

## Out of scope
- another LLM generation/autonomy run
- broad data architecture redesign
- full analytics/history system redesign
- deep feature expansion
- commercialization work

## Success criteria
- completed training state is no longer memory-only
- restart restores meaningful progress state
- Home/Lernstand reflection after relaunch is observed and recorded
- no expensive model run is required
- the next step can be chosen from persistent-state evidence

## Strategic note for later planning
The broader DriveAI-AutoGen direction remains unchanged:
build toward a highly autonomous, self-improving factory with stronger central coordination, stronger truth systems, better lifecycle governance, richer planning and decomposition, and eventually trustworthy multi-provider / multi-model routing.
This step specifically advances the app from “session works in-memory” to “session outcomes survive restart,” which is a true product-level threshold.

## Claude Code Prompt
```text
Goal:
Implement the smallest safe persistence layer for completed training-session outcomes and verify restart-state recovery across Home, Lernstand, and related services.

Prompt ist für Mac

Task:
Inspect the current post-session state flow, especially `TopicCompetenceService` and any related state owners, identify the smallest correct persistence mechanism for the current product state, implement it, and then verify that state survives app restart.

Current confirmed state:
- full training session works
- post-session navigation works
- cross-tab state is coherent while app remains open
- state is currently in-memory only
- not persisted across restart

Important:
Do not start another generation/autonomy run.
Do not broaden into a full persistence-architecture redesign.
Do not jump straight into deep analytics/history work.
The goal is a minimal, coherent persistence layer for current training outcomes plus a restart-state verification.

Focus especially on:
- where session completion currently updates state
- what minimum state must be persisted to restore meaningful progress
- the simplest correct persistence mechanism for current app scope
- restoring persisted state on app launch
- whether Home and Lernstand reflect the restored state correctly after restart

Required checks:
1. Identify the exact current in-memory state path after training completion.
2. Define the smallest useful persistence boundary for current product needs.
3. Implement persistence for the required training outcome state.
4. Implement restore/load behavior on app launch.
5. Perform a restart-state verification:
   - complete a small session if needed
   - close/relaunch app
   - inspect Home and Lernstand
6. Record whether state after restart:
   - restores correctly,
   - restores partially,
   - or fails to restore.
7. End with one single next recommended step based on persistent-state evidence.

Expected report:
1. Current in-memory state path
2. Persistence mechanism chosen and why
3. What data is now persisted
4. Restart-state verification outcome
5. First concrete blockers if any
6. Interpretation of whether remaining issues are persistence/restoration/UI-reflection-related
7. Single next recommended step
```

## What happens after this
If restart persistence is clean, the next best step is likely connecting training outcomes to Verlauf or running one deeper state-propagation/product-truth pass.
If persistence/restoration issues appear, the next step should target the first concrete persistence blocker directly and cheaply.
