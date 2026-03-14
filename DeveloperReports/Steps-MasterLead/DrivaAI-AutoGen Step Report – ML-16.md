# DrivaAI-AutoGen Step Report – ML-16

## Title
CodeExtractor Project-Awareness for Existing Project Types

## Why this step now
The ProjectIntegrator fix materially improved safety by preventing blind overwrites of existing project files, but it did **not** solve duplicate types introduced by **newly generated files** whose filenames do not yet exist in the project.

That means the current factory is safer, but not yet protected against a second important collision path:
- a new generated file is copied into the project
- that file contains inline Swift types already owned elsewhere in the project
- compile hygiene still degrades, even without overwrite behavior

This is now the next smallest and most deterministic factory-level blocker.

## Background
The latest ProjectIntegrator Dedup Guard report shows:

- blind overwrite protection is now dynamic and project-wide
- overwrite-caused FK-012 collisions are reduced to zero
- total ProjectIntegrator-caused FK-012 is reduced by about 60%
- the remaining risk comes from **new files with inline duplicate types**
- the report explicitly points to **CodeExtractor project-awareness** as the next step

So the core problem has shifted:
from **unsafe file placement**
to **insufficient awareness of already-owned project types during code extraction/output shaping**.

## Strategic reasoning
A new proof run **right now** would likely still be polluted by this remaining duplicate-type path.
That would tell us less than a narrow, deterministic fix first.

So the correct order is:

1. make extraction/output shaping aware of existing project types
2. strip or prevent duplicate inline type definitions in newly generated files
3. then run the next real end-to-end autonomy proof

This keeps the process aligned with the overall plan:
minimal factory fix first, then a real proof run.

## Goal
Ensure that newly generated Swift files do not inline duplicate type definitions when those types are already owned elsewhere in the existing project.

## Desired outcome
- new generated files become safer before integration
- FK-012 caused by new-file inline duplicates is materially reduced
- the next proof run measures the factory more fairly
- the fix stays narrow and deterministic

## In scope
- trace where duplicate type ownership is introduced for new generated files
- make CodeExtractor or adjacent output-shaping logic project-aware
- compare extracted/generated types against existing project files
- remove or suppress duplicate inline type definitions when safe
- keep reporting and validation explicit

## Out of scope
- full type registry redesign
- broad merge engine
- changes to recovery, knowledge, roadmap, legal, or marketing layers
- large refactors of integration architecture
- prompt-only mitigation as the sole solution

## Success criteria
- clear root cause for remaining new-file duplicate types
- minimal deterministic fix implemented
- before/after evidence for duplicate-type suppression
- expected FK-012 reduction explained
- next proof run becomes the right follow-up step

## Claude Code Prompt
```text
Goal:
Prevent newly generated Swift files from carrying inline duplicate type definitions when those types already exist elsewhere in the AskFin project.

Task:
Audit and minimally improve the current CodeExtractor/output-shaping path so it becomes aware of existing project-owned Swift types, not only current-run files.

Do not:
- redesign the full generation architecture
- build a large type registry system
- change recovery, knowledge, strategy, or marketing layers
- perform broad cleanup outside this blocker
- rely only on prompt wording as the primary fix

Required work:
1. Trace exactly where inline duplicate Swift types in newly generated files are currently introduced or preserved.
2. Identify the smallest reliable fix point, preferably in:
   - CodeExtractor duplicate stripping,
   - extraction/output shaping,
   - or an adjacent pre-integration cleanup layer.
3. Make the duplicate-type suppression aware of existing AskFin project files, not only current-run generated files.
4. Ensure that if a type already has a dedicated project owner file, the same type is not preserved inline inside a newly generated file unless clearly necessary.
5. Keep the fix narrow, deterministic, and architecture-consistent.
6. If a small prompt reinforcement helps, it may be added only as secondary support, not as the sole solution.

Focus especially on cases like:
- CategoryReadiness
- LocalDataService
- CategoryProgress
- and any similar types that appear inline in new generated files while already existing elsewhere in the project

Validation:
- show before/after evidence of duplicate-type handling for new generated files
- show where project-awareness was added
- show expected impact on FK-012
- if full end-to-end validation is too expensive, provide code-path proof plus the closest runnable validation

Expected report:
1. Current new-file duplicate-type root cause
2. Minimal fix implemented
3. Files changed
4. Before vs after type-suppression flow
5. Remaining limits
6. Whether FK-012 risk from new generated files should now be materially reduced
```

## What happens after this
If this step is successful, the next step should be a real end-to-end autonomy proof run on AskFin.
