# DrivaAI-AutoGen Step Report – ML-15

## Step
Harden the `ProjectIntegrator` so it no longer blindly copies generated Swift files into the AskFin project in ways that overwrite existing files or create duplicate type/file ownership conflicts before the safer `OutputIntegrator` stage runs.

## Why this step now
The third autonomy proof showed a clear shift in the blocker chain:
- AskFin baseline cleanup held.
- The later `OutputIntegrator` is now much safer than before.
- The dominant remaining collision source is the earlier `ProjectIntegrator` path during implementation.

This means the main blocker is no longer historical project contamination or the late integration stage. It is an active factory-core behavior that reintroduces FK-012 style conflicts too early in the pipeline.

## Background
Recent work already improved:
- truthful run status
- context transfer across review passes
- structured review handoff
- stateful recovery
- cross-run knowledge writeback
- role-based knowledge injection
- run-scoped output integration and dedup
- inline type dedup in generated code
- AskFin baseline cleanup

The latest proof run demonstrated that these improvements are real, but also exposed a second integration path that still performs unsafe file placement.

## Goal
Make early project integration materially safer so the factory stops re-creating duplicate file/type ownership conflicts before compile hygiene and the safer output path can do their job.

## What Claude should do
1. Trace exactly how `ProjectIntegrator` copies generated files into the project.
2. Confirm the specific root causes of:
   - blind overwrites
   - duplicate file placement
   - types being reintroduced into locations where ownership already exists
3. Implement the smallest safe guardrails, preferably:
   - build a project file index before copy
   - skip or explicitly surface writes when a filename already exists
   - avoid blind overwrite behavior
4. Assess whether a narrow deferral to `OutputIntegrator` is safer than duplicate placement logic, if that can be done without a larger redesign.
5. Keep the fix minimal, deterministic, and auditable.

## Success criteria
- Existing project files are protected from blind overwrite.
- `ProjectIntegrator` no longer reintroduces obvious FK-012 style collisions.
- Reporting clearly shows what was skipped, copied, or blocked.
- The next proof run can test the factory with a much cleaner live integration path.

## What we are intentionally not doing
- no broad integration redesign
- no merge engine
- no recovery or knowledge architecture changes
- no new product features
- no AskFin-wide cleanup unless directly required by this blocker

## Expected output from Claude
1. Current `ProjectIntegrator` root cause
2. Minimal fix implemented
3. Files changed
4. Before vs after integration behavior
5. Remaining limits
6. Whether `ProjectIntegrator` is now materially safer

## Why this is the right next move
A new proof run before this fix would likely just reconfirm the same early collision pattern. Fixing this path first gives us a cleaner and more meaningful next end-to-end autonomy proof.
