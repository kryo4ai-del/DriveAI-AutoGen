# DrivaAI-AutoGen Step Report – ML-21

## Title
Project Context Hardening for True Ops-Layer Execution

## Why this step now
The fifth autonomy proof was a major breakthrough, but it also exposed a new dominant blocker that is **not** a deep model-quality issue:

the run was started **without `--project`**, which caused the pipeline to lose project context.

That single missing flag disabled or degraded several critical parts of the real validation path:
- integration targeted `DriveAI/` instead of `projects/askfin_v1-1/`
- CodeExtractor project-awareness was inactive
- the Operations Layer did not run
- Compile Hygiene, Recovery, and Run Memory were skipped

So the run proved that the multi-pass agent pipeline now works much better,
but it did **not** yet prove the full autonomous factory path under correct project-scoped execution.

## Background
The latest report established:

- all 6 agent/review passes ran successfully
- the Creative Director returned `conditional_pass`
- UX Psychology, Refactor, and Test Generation executed for the first time
- 7 test files were generated
- the pipeline reached `success` status at the conversational layer

But the most important missing piece was:
the run had **no active project context** for the downstream factory infrastructure.

Without project context, this is not a full autonomy proof.
It is a partially successful pipeline run whose technical validation tail never activated.

## Strategic reasoning
We should **not** simply tell the human operator to remember `--project` forever.
That would keep a fragile manual dependency inside a factory that is supposed to become autonomous.

The correct next move is therefore:
make project context handling more robust and less human-fragile.

The smallest safe approach is not a broad redesign.
It is a narrow hardening step such as:
- propagate project context automatically when available
- infer a default project safely when appropriate
- or fail loudly instead of silently running in a degraded no-project state

This keeps the system honest and removes a trivial but highly consequential operator dependency.

## Goal
Ensure that development runs no longer silently execute without project context when the factory clearly depends on project-scoped integration and operations-layer validation.

## Desired outcome
- project context is present for real AskFin runs
- Operations Layer executes reliably
- integration targets the real project
- CodeExtractor project-awareness activates automatically when applicable
- the next proof run becomes a true full-path autonomy proof, not a degraded partial run

## In scope
- trace where `project` is currently required and how it becomes `None`
- identify the smallest safe hardening point
- implement one narrow improvement such as:
  - default project inference
  - config-backed active project resolution
  - template-to-project mapping
  - or explicit fail-fast when project context is required but missing
- preserve clear logging of how the project was chosen
- validate before/after behavior

## Out of scope
- broad CLI redesign
- changing recovery/knowledge/CD logic
- marketing/legal/roadmap layers
- large registry refactors
- masking ambiguity if project selection is genuinely unclear

## Success criteria
- exact root cause of missing project context identified
- minimal hardening fix implemented
- before/after proof that the run now gets correct project context (or fails loudly)
- Operations Layer becomes reachable in normal AskFin dev runs
- the next proof run becomes the right follow-up step

## Strategic note for later planning
A future factory-level expansion should also introduce **multi-provider / multi-model routing** so rate limits, cost tiers, and task-specific model assignment can be handled more intelligently. That is being kept in planning, but it should not interrupt the current autonomy-core stabilization path.

## Claude Code Prompt
```text
Goal:
Harden project context handling so AskFin dev runs no longer silently execute without `--project` and thereby skip the real project-scoped validation path.

Task:
Audit and minimally improve the current project-context resolution path so the factory either:
- automatically resolves the correct project context when it is clearly inferable, or
- fails loudly instead of silently running in a degraded no-project state.

Do not:
- redesign the full CLI architecture
- change recovery, knowledge, CD policy, or model-routing systems
- perform broad cleanup outside this blocker
- hide ambiguity if the correct project cannot be safely inferred

Required work:
1. Trace exactly how `a["project"]` is currently set, lost, or left as `None`.
2. Identify the smallest safe hardening point for normal AskFin runs.
3. Implement one narrow fix such as:
   - default project inference from active project/config/registry,
   - template-to-project mapping where safe,
   - or fail-fast with explicit error when project context is required.
4. Preserve explicit logging for:
   - chosen project
   - source of project resolution
   - whether resolution was explicit, inferred, or missing
5. Ensure that with correct project context:
   - ProjectIntegrator targets the real project path
   - CodeExtractor project-awareness can activate
   - Operations Layer can run
6. Run the closest practical validation to prove the fix.

Validation:
- show before/after project resolution behavior
- show what happens when `--project` is omitted
- show whether the factory now reaches the project-scoped path or fails loudly
- if full end-to-end validation is too expensive, provide code-path proof plus the closest runnable validation

Expected report:
1. Current project-context root cause
2. Minimal fix implemented
3. Files changed
4. Before vs after project-resolution behavior
5. Remaining limits
6. Whether normal AskFin runs are now materially less likely to bypass the Operations Layer
```

## What happens after this
If this step succeeds, the next step should be a new full end-to-end autonomy proof run on AskFin with proper project context active.
That run should finally exercise the full validation tail:
integration, compile hygiene, recovery, writeback, and run memory.
