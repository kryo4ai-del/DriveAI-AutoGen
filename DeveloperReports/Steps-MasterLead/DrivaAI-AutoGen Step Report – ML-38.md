# DrivaAI-AutoGen Step Report – ML-38

## Title
Thirteenth Autonomy Proof with True Standard→Sonnet Escalation

## Why this step now
ML-37 solved an important control-plane weakness.

Until now, `--profile standard` changed run behavior but did not actually switch the active model away from Haiku.
That made previous “standard-profile” runs only partially trustworthy as model-strength tests.

The latest fix corrected that split:
- `--profile standard` now resolves to the intended stronger model
- `standard` and `premium` now exist as proper run-profile entries
- profile intent, env-profile resolution, and effective model selection are now aligned
- explicit logging/validation confirms that `standard` now activates Sonnet and `premium` activates Opus

This means the next run is the first real opportunity to test the factory under a genuinely stronger model from the same stable baseline.

## Background
The latest report established:

- the root cause was a separation between run-profile and env-profile resolution
- `--profile standard` changed run mode but left env-profile on `dev`
- the model therefore stayed on Haiku
- the central bridge is now fixed
- `standard` now resolves to Sonnet
- `premium` now resolves to Opus
- explicit `--env-profile` still correctly overrides when present
- the control-plane path is now ready for a truthful stronger-model proof run

This is strategically important because future profile escalation, model routing, and provider selection all depend on a trustworthy profile-to-model contract.

## Strategic reasoning
We should run the next proof now.

Why now?
Because the previous ambiguity has been removed.
A new run with `--profile standard` can now answer the real question we wanted answered in Run 12:

What changes when the same stable factory baseline is driven by an actually stronger model rather than only a fuller run mode?

This is the correct next move because it changes one meaningful variable cleanly:
- same project
- same factory
- same Ops-layer
- same clean baseline
- stronger actual model

That gives us high-value evidence for the next architectural decision:
whether future leverage lies more in profile escalation/model routing or somewhere deeper in generation consistency.

## Goal
Run a thirteenth real end-to-end autonomy proof on AskFin using `--profile standard`, now that `standard` truly resolves to Sonnet, and measure the effect of real stronger-model generation on the stable factory baseline.

## Desired outcome
- the run uses the real project-scoped path with true Sonnet activation
- the active resolved model is clearly visible in logs
- implementation output quality and usefulness can be compared honestly against Run 12
- the factory remains operationally stable under the stronger model
- the next leverage point is identified from evidence:
  - stronger-model uplift,
  - generation consistency limits,
  - downstream integration limits,
  - or another deeper layer

## In scope
- a real project-scoped AskFin proof run
- use of `--profile standard`
- confirmation that Sonnet is the actual active model
- normal pipeline execution
- operations-layer execution
- Compile Hygiene observation
- CompletionVerifier observation
- Stale Artifact Guard observation
- SwiftCompile observation if available
- explicit comparison of output quality and code usefulness vs Run 12
- recovery / writeback / run-memory observation if triggered

## Out of scope
- pre-run code fixes
- manual model forcing outside the normal profile path
- new routing architecture in this step
- unrelated repair-layer redesign
- feature switching unless the run itself makes that necessary
- commercialization work
- unrelated future-factory redesign

## Success criteria
- the run uses `--profile standard` and logs Sonnet as the active model
- the run starts from the stable clean baseline
- the report clearly compares output quality vs Run 12
- Compile Hygiene remains non-blocking unless a genuinely new blocker appears
- the Ops Layer remains stable
- the next central leverage point is identified from live evidence

## Strategic note for later planning
The broader DriveAI-AutoGen direction remains unchanged:
build toward a highly autonomous, self-improving factory with stronger central coordination, stronger truth systems, better lifecycle governance, richer planning and decomposition, and eventually trustworthy multi-provider / multi-model routing.
This step specifically tests the real effect of correct profile-to-model escalation on an already stabilized factory core.

## Claude Code Prompt
```text
Goal:
Run a thirteenth real end-to-end autonomy proof on AskFin using `--profile standard`, now that `standard` truly resolves to Sonnet, and measure the effect of real stronger-model generation on the stable factory baseline.

Task:
Execute the current AskFin factory pipeline as realistically as practical using the normal development-oriented project-scoped path with Ops-layer execution active, using `--profile standard`.
Do not add new fixes before the run.
Do not manually restore or manually delete quarantined artifacts before the run.
Do not mask failures.
Do not declare success unless the evidence clearly supports it.

Focus especially on:
- project resolution behavior
- confirmation of the actual active model in logs/output
- implementation output volume and quality
- whether new Swift files are actually generated
- downstream pass execution
- Operations Layer execution
- Compile Hygiene results
- CompletionVerifier behavior
- Stale Artifact Guard behavior
- SwiftCompile results
- recovery behavior if triggered
- writeback / run memory behavior if triggered

Required checks:
1. Confirm that the run uses the real project-scoped path with `--profile standard`.
2. Confirm explicitly that Sonnet is the effective active model for this run.
3. Confirm that the run begins from the stable clean baseline.
4. Record stage-by-stage what works autonomously.
5. Compare implementation/code-output behavior against Run 12:
   - number of generated Swift files
   - number written vs skipped
   - whether output is mostly real code vs mostly review text
   - whether code quality/usefulness improved materially
6. Verify whether Compile Hygiene remains at zero blocking unless a truly new blocker appears.
7. Verify whether the Ops Layer remains stable under the true stronger-model run.
8. Determine whether the current leverage point is now:
   - stronger-model uplift confirmed,
   - still generation consistency,
   - downstream integration,
   - compile/repair,
   - lifecycle governance,
   - or some other deeper layer.
9. If failure remains, isolate the single most important next blocker in the live factory path.
10. State whether the evidence now justifies future profile-escalation policy or broader multi-model routing work.

Expected report:
1. Run scope and execution path
2. Starting baseline state
3. Effective model/profile resolution observed
4. Project resolution / Ops-layer behavior observed
5. Stage-by-stage observed results
6. Implementation output comparison vs Run 12
7. Compile Hygiene / SwiftCompile outcome
8. CompletionVerifier and Stale Artifact Guard outcome
9. What worked autonomously
10. What still failed or degraded
11. Clean success vs stronger partial success vs honest failure verdict
12. Single next recommended step
```

## What happens after this
If Sonnet produces materially better implementation output while the factory remains stable, the next step should shift toward controlled profile-escalation policy and broader routing design.
If output is still weak even with true Sonnet activation, then the next correct move is likely a deeper generation-consistency or orchestration-layer intervention rather than more control-plane work.
