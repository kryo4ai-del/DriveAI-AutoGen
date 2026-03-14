# MasterLead Step Report – ML-13

## Title
Final AskFin Baseline Repair before the next End-to-End Autonomy Proof

## Current Situation
The AskFin Baseline Cleanup removed the large majority of stale duplicate artifacts from earlier runs. Duplicate-related compile hygiene issues dropped sharply, and the project baseline is now materially cleaner. However, a small set of **project-side residual blockers** still remains and would likely distort the next autonomy proof if left unresolved.

## Why this step is next
We are now at the point where the factory-side duplicate/integration blockers have been reduced enough that the remaining blockers are mostly in the AskFin project baseline itself.

If we launch the next proof run immediately, there is a high chance that the outcome will still be dominated by these remaining baseline issues rather than by the current factory behavior.

That would weaken the diagnostic value of the next proof.

## Background
The latest cleanup report shows:
- FK-012 duplicate issues reduced from about 105 to 1
- total issues reduced from 162 to 5
- blocking issues reduced from 155 to 4
- generated artifacts fully cleaned out
- the remaining FK-012 is now a real design/name conflict (`StreakData`), not stale duplicate accumulation
- `LocalDataService` is still missing from the project and is referenced in multiple files

This means the cleanup step succeeded. The next logical move is **one final narrow project-baseline repair** so the following proof run tests the factory more fairly.

## Goal
Remove or isolate the last meaningful AskFin baseline blockers that are still unrelated to the current factory core, so the next autonomy proof can evaluate the factory with minimal project-side noise.

## What this step should accomplish
- resolve the remaining `StreakData` ownership/name conflict safely
- resolve, restore, stub, or otherwise safely handle the missing `LocalDataService`
- verify whether the remaining blocking issues are now materially reduced
- leave the project in a cleaner baseline state for the next real proof run

## Success Criteria
This step is successful if:
- the remaining project-baseline blockers are clearly reduced or isolated
- compile hygiene improves further or becomes meaningfully clearer
- the next autonomy proof can be interpreted primarily as a factory-quality signal rather than a legacy-project artifact signal

## Out of Scope
This step is **not** about:
- redesigning the factory
- changing recovery/knowledge/orchestration
- adding new features
- broad AskFin refactoring
- masking unresolved uncertainty

## Why this is better than jumping straight to the next proof
A direct proof run now would still risk failing for reasons we already understand and that belong to project residue, not the active factory core.

A final narrow baseline repair keeps us disciplined: we avoid over-cleaning, but we also avoid wasting the next proof on known residual blockers.

## Expected Follow-up
If this step succeeds, the next step should be:
**another real End-to-End Autonomy Proof Run on AskFin**.
