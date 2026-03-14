# MasterLead Step Report — ML-12

## Title
AskFin Baseline Cleanup Before Next End-to-End Proof

## Decision
The next step is a **targeted AskFin project cleanup / repair pass** to remove **pre-existing duplicate project artifacts** that were embedded by earlier runs and are still blocking clean compile validation.

## Why this step now
The latest inline type dedup fix materially reduces factory-generated FK-012 duplicate type issues by removing top-level inline duplicates when the same type already has its own dedicated file. The report projects that the remaining FK-012 issues are now dominated by **pre-existing project duplicates** from earlier runs rather than by newly generated factory output.

That means the biggest remaining blocker is no longer primarily a factory-generation defect. It is now a **contaminated AskFin baseline** that prevents us from fairly measuring the current factory core.

If we skip this cleanup and immediately run another full proof, the result is likely to be obscured by stale project-state collisions. That would reduce the signal quality of the next proof run.

## Background
The inline type dedup report establishes:
- duplicate type ownership was introduced when multi-type Swift blocks were stored under the first detected type name, causing the same type to exist both inline and in its own file
- the new deterministic dedup fix is localized in `code_extractor.py`
- 5 of 14 FK-012 duplicate-type issues are expected to be removed by this fix
- the remaining major FK-012 class is primarily **old project duplicates already present inside AskFin**

Examples of the remaining pre-existing project duplicate types listed in the report include:
- `CategoryMetric`
- `CategoryStat`
- `ReadinessAnalysisService`
- `RecentMetrics`
- `StreakData`
- `WeakCategory`

## Goal
Create a **clean AskFin baseline** so the next autonomy proof measures the current factory realistically instead of failing mainly because of stale duplicate project artifacts left behind by older runs.

## What this step is intended to achieve
- identify the concrete pre-existing duplicate files/types inside the AskFin project tree
- remove or quarantine stale duplicates safely
- preserve the intended current project structure
- leave the project in a cleaner state for the next full autonomy proof

## Why this is the right step instead of another infrastructure fix
The latest report indicates that the factory-side duplicate generation problem has been materially reduced already. The remaining blocker is now mostly project-state contamination.

So this is intentionally a **project fix, not a factory fix**.
That distinction matters because we do not want to keep changing the factory core when the next failure would be caused mainly by old project debris.

## Why not run another full proof immediately
We could run another full proof immediately, but the likely result would still be dominated by old embedded duplicates from previous runs.
That would produce a lower-quality signal and could make the next blocker analysis less precise.

A small cleanup pass first should make the next proof run much more informative.

## Scope of the next step
A narrow cleanup / repair pass focused on:
- locating duplicate Swift type/file ownership inside the AskFin project tree
- distinguishing stale legacy duplicates from intended current files
- removing, isolating, or quarantining stale duplicates safely
- reporting exactly what was cleaned and what still remains

## Out of scope
- no redesign of the factory architecture
- no new recovery/knowledge/orchestration work
- no expansion of strategy/legal/marketing layers
- no broad refactor of AskFin unrelated to duplicate cleanup
- no speculative large-scale code reorganization

## Success criteria
The cleanup step is successful if it:
1. clearly identifies the remaining pre-existing duplicate project artifacts
2. safely removes or isolates the stale duplicates
3. leaves AskFin with a materially cleaner compile baseline
4. produces a precise report of what was changed and what still blocks compile

## What happens after this step
Immediately after the cleanup, the next step should be another **real end-to-end autonomy proof run** on AskFin.
That run will then tell us much more cleanly whether the factory core is now close to a compilable autonomous outcome, or whether a deeper generator/compile blocker still remains.

## Expected Claude output
The developer report for this step should tell us:
- which duplicate files/types were found in AskFin
- which ones were classified as stale versus current
- what was removed/quarantined
- what compile-impact is expected after cleanup
- whether AskFin is now a fairer baseline for the next proof run
