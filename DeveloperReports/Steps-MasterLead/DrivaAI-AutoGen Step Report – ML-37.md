# DrivaAI-AutoGen Step Report – ML-37

## Title
Profile Resolution Fix for Standard→Sonnet Model Escalation

## Why this step now
Run 12 delivered the strongest output-bearing proof so far.

The most important result is not only that the factory stayed healthy under much higher output.
It is that the system already proved it can remain operationally stable while generating substantial code volume:

- 45 Swift files generated across the run
- 16 files integrated
- 1 new blocking FK-014 issue automatically fixed by StubGen
- final state returned to 0 BLOCKING
- CompletionVerifier remained at `MOSTLY_COMPLETE / 95%`
- the Ops layer remained coherent under real load

That means the factory core is no longer primarily bottlenecked by repair, verifier truth, or artifact lifecycle.

But Run 12 also exposed the next clearly isolated central issue:
`--profile standard` changed the run behavior (`run_mode: full`, 7 passes), yet the actual model still remained `claude-haiku-4-5` instead of switching to the intended stronger model.
So the system gained higher output mainly from run-mode expansion, not from true model escalation.

This is now the cleanest next system step:
fix profile resolution so the requested profile actually controls the model selection.

## Background
The latest report established:

- `--profile standard` was used
- the run executed in `full` mode with 7 passes including Fix Execution
- output increased dramatically versus Run 11
- the model shown in the run still remained `claude-haiku-4-5`
- the report explicitly identifies this as the next recommended step
- the likely issue is profile/model precedence resolution rather than a code-generation stability failure

This means we now have strong evidence for a very specific control-plane bug:
profile intent and actual model resolution are not aligned.

That is strategically important because future factory architecture depends on trustworthy routing and escalation.
If a requested profile does not reliably activate its intended model, then later multi-provider / multi-model routing will rest on a weak foundation.

## Strategic reasoning
We should not run another proof first.

Why not?
Because Run 12 already answered the important question:
the factory can remain stable under heavier output load.

The next high-value question is now:
can the system actually obey its own profile-to-model contract?

Until that is fixed, another `standard` run would still be ambiguous:
better or worse results could not be attributed confidently because the requested model layer would still be untrustworthy.

So the next correct move is a control-plane fix:
repair the profile resolution path so `standard` really resolves to the intended stronger model.

## Goal
Fix the profile-resolution / model-selection path so `--profile standard` actually activates the intended stronger model instead of silently remaining on Haiku.

## Desired outcome
- `--profile standard` resolves to the intended standard-profile model
- run mode and model selection both follow the same effective profile configuration
- the active model is visible and trustworthy in run output/logging
- the precedence chain between CLI args, environment profile, run mode, and `config/llm_profiles.json` becomes explicit and testable
- the system becomes ready for a clean follow-up proof run with true model escalation

## In scope
- inspect profile resolution flow end to end
- inspect how `--profile` affects:
  - env profile
  - run mode
  - model selection
  - config loading
  - defaults / overrides / precedence
- inspect `config/llm_profiles.json`
- identify why `standard` is not producing the expected model switch
- implement the smallest robust central fix
- improve logging so the effective resolved profile and model are unmistakable
- run a focused validation showing that `--profile standard` now resolves to the intended model

## Out of scope
- another full end-to-end proof run in this step
- manual one-off forcing of a model only for one run without fixing resolution logic
- broad multi-model routing architecture
- unrelated repair-layer work
- feature work
- UI work
- commercialization work

## Success criteria
- the exact root cause of the profile/model mismatch is identified
- `--profile standard` resolves to the intended model consistently
- run mode and model no longer diverge silently
- logging clearly reports the effective model and why it was chosen
- the system is ready for a follow-up proof run that truly tests stronger-model output

## Strategic note for later planning
The broader DriveAI-AutoGen direction remains unchanged:
build toward a highly autonomous, self-improving factory with stronger central coordination, stronger truth systems, better lifecycle governance, richer planning and decomposition, and eventually trustworthy multi-provider / multi-model routing.
This step specifically strengthens the routing/control contract that future model escalation and provider selection will depend on.

## Claude Code Prompt
```text
Goal:
Fix the profile-resolution / model-selection path so `--profile standard` actually activates the intended stronger model instead of silently remaining on Haiku.

Task:
Inspect the current profile resolution flow end to end and identify exactly why `--profile standard` is changing run behavior (`run_mode: full`) but not switching the active model away from `claude-haiku-4-5`.
Implement the smallest robust central fix so profile intent, run mode, and effective model selection stay aligned and are clearly logged.

Important:
Do not solve this with a one-off hardcoded override only for the current run.
Do not just manually pass a different model and call the problem solved.
The goal is a reusable factory-layer control-plane fix for profile/model resolution.

Focus especially on:
- CLI `--profile` handling
- env profile resolution
- config loading from `config/llm_profiles.json`
- precedence between defaults, environment, run mode, and profile config
- where the effective model is finally chosen
- logging/reporting of the resolved model and effective profile

Required checks:
1. Identify the exact root cause of why `standard` changes run mode but leaves the model on Haiku.
2. Implement the smallest robust central fix so `--profile standard` resolves to the intended model.
3. Make the effective profile + model resolution clearly visible in logs/output.
4. Validate the fix with a focused check or dry run showing the resolved model is now correct.
5. Confirm that other profiles do not regress.
6. State whether the system is now ready for a new proof run that truly tests stronger-model output.

Expected report:
1. Root cause in the old profile/model resolution logic
2. Exact central fix implemented
3. Effective precedence/order after the fix
4. Validation that `standard` now resolves to the intended model
5. Logging/reporting improvements
6. Regression check summary
7. Whether the system is ready for the next proof run
8. Single next recommended step
```

## What happens after this
If the profile-resolution fix succeeds, the next correct move is a new real autonomy proof with a truly escalated model so we can measure the effect of stronger generation quality from the same stable factory baseline.
If the fix reveals a deeper routing/control inconsistency, then the next step should target that control-plane gap before returning to proof runs.
