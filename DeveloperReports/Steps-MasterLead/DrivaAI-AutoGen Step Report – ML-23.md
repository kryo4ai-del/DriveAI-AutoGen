# DrivaAI-AutoGen Step Report – ML-23

## Title
Compile-Hygiene-Driven Missing Type Recovery

## Why this step now
The sixth autonomy proof is the first run that exercised the **full project-scoped validation tail** under a normal dev-style invocation without manually passing `--project`.

That makes the result especially valuable:
the core factory path now runs deeply enough that the remaining blocker is no longer mainly orchestration, gating, deduplication, or project-context plumbing.

The most important remaining live blocker is now **real compile breakage from missing type declarations**:
- `PriorityLevel` is referenced but not declared
- `ReadinessCalculationService` is referenced but not declared

These are not just validator false positives.
They are genuine gaps in the generated code path.

## Background
The latest proof showed:

- project context is now auto-inferred successfully
- all 6 main pipeline/review passes run
- Operations Layer now activates
- OutputIntegrator, Compile Hygiene, Run Memory, and Knowledge Writeback all execute
- duplicate-collision handling is materially improved

But the run still ends in `FAILED` because Compile Hygiene surfaces real unresolved type-reference gaps.

At the same time, a second structural issue also became visible:
**Recovery did not start**, because it depends on fresh integrated output files, while the current run had 0 OutputIntegrator writes due to correct dedup skipping.

So the factory can now *see* compile blockers, but it still cannot *autonomously act on them* when those blockers are discovered in already-integrated project files.

## Strategic reasoning
The next step should not be a broad rewrite of generation prompts.
Prompt-only fixes are too soft for this stage.

The next step also should not be a validator-only cleanup, because FK-012 and FK-013 are secondary once compared with the real compile blocker FK-014.

The strongest small move is therefore:

1. make Compile Hygiene / project-state findings usable as fix input
2. allow recovery/fix logic to act even when OutputIntegrator wrote 0 files
3. target the most concrete blocker class first: missing type declarations

That gives the factory a more autonomous path from:
**compile blocker detected**
→ **structured fix task created**
→ **minimal type recovery applied**

This is a better long-term factory move than hardcoding one-off AskFin manual fixes.

## Goal
Enable the factory to respond autonomously to real FK-014-style missing type declaration blockers, even when the relevant files are already in the project and OutputIntegrator writes 0 new files.

## Desired outcome
- FK-014 findings become actionable fix input
- recovery/fix logic is no longer blocked merely because OutputIntegrator wrote 0 files
- the factory can generate or apply narrow missing-type fixes/stubs where appropriate
- the next proof run can test whether genuine compile blockers are now automatically reduced

## In scope
- trace why Recovery currently requires fresh OutputIntegrator-written files
- identify the smallest safe way to let recovery/fix logic operate on project-integrated files or Compile Hygiene findings
- focus specifically on real missing type declaration blockers (FK-014)
- allow narrow recovery outputs such as:
  - protocol/type stubs
  - enum scaffolds
  - minimal interface placeholders
  - or targeted fix tasks for the fix executor
- preserve explicit logging of:
  - source blocker
  - target file(s)
  - fix artifact produced
  - whether the fix is a stub/scaffold or a full implementation

## Out of scope
- broad compile-hygiene redesign
- large prompt overhauls
- manual AskFin-only patching without factory-level reuse
- changes to marketing/legal/roadmap layers
- multi-provider routing implementation

## Success criteria
- exact reason Recovery currently skips when OutputIntegrator writes 0 files is identified
- minimal fix is implemented so FK-014 blockers can still enter the autonomous fix path
- before/after proof shows missing-type blockers are now actionable
- the next proof run becomes the right follow-up step

## Claude Code Prompt
```text
Goal:
Enable the factory to autonomously act on real FK-014 missing type declaration blockers even when OutputIntegrator writes 0 files and the relevant compile blockers exist in already-integrated project files.

Task:
Audit and minimally improve the current recovery/fix path so Compile Hygiene findings—especially FK-014 missing type declarations—can still produce actionable fixes when the current run has no newly written OutputIntegrator artifacts.

Do not:
- redesign the full recovery architecture
- perform a broad compile-hygiene rewrite
- patch AskFin manually in a one-off way unless the logic is reusable at factory level
- change CD policy, model-routing, marketing, or roadmap layers
- hide uncertainty about whether a missing type should be stubbed or fully implemented

Required work:
1. Trace exactly why recovery currently reports "too little output for recovery" when OutputIntegrator writes 0 files.
2. Identify the smallest safe control point where Compile Hygiene findings and project-integrated files can still enter the fix path.
3. Implement a minimal factory-level mechanism so FK-014 findings become actionable, for example by:
   - generating narrow type/protocol/enum stubs,
   - creating targeted fix tasks from compile-hygiene findings,
   - or allowing recovery to operate on project files already integrated this run.
4. Keep the fix narrow, deterministic, and auditable.
5. Preserve explicit logging for:
   - FK-014 findings detected
   - files/types affected
   - recovery/fix action taken
   - whether the action created a stub/scaffold or a fuller fix
6. Run the closest practical validation to prove that missing-type blockers are now materially more actionable.

Validation:
- show before/after recovery eligibility when OutputIntegrator writes 0 files
- show how FK-014 now enters the fix path
- show expected impact on missing-type compile blockers
- if full end-to-end validation is too expensive, provide code-path proof plus the closest runnable validation

Expected report:
1. Current recovery skip root cause
2. Minimal fix implemented
3. Files changed
4. Before vs after fix-path behavior
5. Remaining limits
6. Whether FK-014 blockers are now materially more actionable
```

## What happens after this
If this step succeeds, the next step should be a new full end-to-end autonomy proof run on AskFin.
That run should tell us whether the current core can now reduce real compile blockers autonomously rather than only detecting them.
