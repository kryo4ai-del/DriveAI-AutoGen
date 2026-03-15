# DrivaAI-AutoGen Step Report – ML-26

## Title
OutputIntegrator Type-Level Dedup and Test Markdown Sanity

## Why this step now
The seventh autonomy proof is a strong technical milestone:
the factory now runs end-to-end with the full Ops-layer active, and Compile Hygiene is finally truthful enough that the remaining blockers are real.

That changes the situation materially:
we are no longer mainly fighting validator noise.
We are now looking at actual code-generation / integration defects.

The most important live blocker in the latest run is:
**OutputIntegrator writes duplicate semantic types into `generated/` even when equivalent project-owned types already exist elsewhere in the AskFin project.**

This creates real FK-012 collisions between:
- `generated/...`
- and canonical project files in `Models/` or `Services/`

A secondary but still real issue is:
**AI Markdown contamination in generated test files** (`---`), which causes FK-011.

## Background
The latest report established:

- full project-scoped path is active
- all 6 pipeline passes execute
- Operations Layer executes
- Compile Hygiene is now reporting only real blockers
- FK-014 missing types can now be auto-stubbed
- remaining blocking issues are:
  - 3x real FK-012 from `generated/` vs project-root duplicate types
  - 1x real FK-013 (`ExamReadinessSnapshot` initializer/property mismatch)
  - 1x real FK-011 (AI Markdown in test code)

The report explicitly identifies the top blocker as:
**OutputIntegrator `generated/` vs project-root duplicates**.

## Strategic reasoning
We should not jump first to the initializer/property mismatch blocker.

Why?
Because the duplicate-file/type collisions are more infrastructural and will continue polluting future runs if left unresolved.
They also reduce trust in what the project tree actually contains after a run.

The clean order is:
1. stop OutputIntegrator from creating semantic duplicates in `generated/`
2. add a small sanity pass to strip obvious AI Markdown contamination from test outputs
3. then run the next full autonomy proof
4. only then judge whether `ExamReadinessSnapshot` remains the dominant real code-generation blocker

This keeps the system honest and removes the highest-leverage infrastructural defect first.

## Goal
Prevent OutputIntegrator from writing semantically duplicate project types into `generated/`, and suppress obvious AI Markdown contamination in generated test files, so the next proof run can focus on the remaining real code-generation mismatch blocker.

## Desired outcome
- FK-012 generated-vs-project collisions are materially reduced or eliminated
- generated test files no longer contain obvious AI Markdown separators like `---`
- the next run is judged on deeper real code-generation behavior rather than integrator contamination
- if `ExamReadinessSnapshot` still blocks afterward, it becomes the clean next factory target

## In scope
- trace how OutputIntegrator currently decides what to write into `generated/`
- identify why filename-level dedup is insufficient when equivalent types live under different file names or folders
- implement a minimal type-level dedup guard against existing project-owned types
- add a narrow sanitation step for obvious markdown contamination in test/code outputs
- preserve explicit logging/reporting for skipped semantic duplicates and stripped markdown artifacts
- run the closest practical validation

## Out of scope
- full integration architecture redesign
- broad compile-hygiene rewrite
- one-off manual AskFin patching unless clearly reusable at factory level
- recovery redesign
- multi-provider routing implementation
- marketing/legal/roadmap layers
- masking the remaining real initializer/property mismatch if it still exists

## Success criteria
- exact root cause of OutputIntegrator semantic duplication identified
- minimal type-level dedup fix implemented
- obvious test markdown contamination suppressed
- before/after evidence of reduced FK-012 and FK-011 risk
- the next full autonomy proof becomes the correct follow-up step

## Strategic note for later planning
Multi-provider / multi-model routing remains in future factory planning as a separate architecture step for rate-limit headroom, cost control, fallback resilience, and role/task-based model selection. It should be introduced later without interrupting the current autonomy-core stabilization path.

## Claude Code Prompt
```text
Goal:
Prevent OutputIntegrator from writing semantically duplicate project types into `generated/`, and suppress obvious AI Markdown contamination in generated test files, so the next full autonomy proof reflects deeper real blockers.

Task:
Audit and minimally harden the current OutputIntegrator/output-sanitization path so it no longer writes generated files that duplicate project-owned types under different filenames/folders, and so obvious markdown separators like `---` are removed from generated test/code outputs.

Do not:
- redesign the full integration architecture
- perform a broad compile-hygiene rewrite
- patch AskFin manually in a one-off way unless the logic is clearly reusable at factory level
- change recovery, knowledge, CD policy, or model-routing systems
- hide uncertainty if semantic ownership cannot be determined safely

Required work:
1. Trace exactly why OutputIntegrator currently writes semantic duplicates into `generated/` even when equivalent project-owned types already exist elsewhere in the project.
2. Identify the smallest safe control point where type-level/project-level ownership can be checked, not only filename-level duplication.
3. Implement a minimal type-level dedup guard so OutputIntegrator skips writing generated files when the relevant type(s) are already owned by canonical project files.
4. Add explicit logging/reporting for:
   - candidate artifact
   - detected owned type(s)
   - skip decision and why
5. Add a narrow sanitation step for obvious AI Markdown contamination in generated code/test outputs (for example `---` separators) before integration/hygiene.
6. Keep the fix narrow, deterministic, and auditable.
7. Run the closest practical validation to prove the changes.

Validation:
- show before/after OutputIntegrator behavior for representative FK-012 duplicate cases
- show before/after sanitation behavior for representative FK-011 markdown contamination
- show expected impact on blocking issue count
- if full end-to-end validation is too expensive, provide code-path proof plus the closest runnable validation

Expected report:
1. Current OutputIntegrator semantic-dup root cause
2. Minimal fix implemented
3. Files changed
4. Before vs after integration/sanitation behavior
5. Remaining limits
6. Whether FK-012 and FK-011 risk are now materially reduced
```

## What happens after this
If this step succeeds, the next step should be a new full end-to-end autonomy proof run on AskFin.
That run should reveal whether the remaining dominant blocker is now the real `ExamReadinessSnapshot` initializer/property mismatch or something even deeper in the live factory path.
