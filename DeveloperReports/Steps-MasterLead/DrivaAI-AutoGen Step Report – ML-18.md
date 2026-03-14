# DrivaAI-AutoGen Step Report – ML-18

## Title
Creative Director Rating Parser Hardening

## Why this step now
The fourth autonomy proof showed that duplicate-type collisions are no longer the dominant blocker.
The factory now stops mainly at the **Creative Director gate**, not because the integration path is still broken.

The report shows two different `Rating:` lines in the run log:
- an earlier `conditional_pass`
- a later `fail`

The current parser appears to take the **last matching rating line in the whole group chat**, which may not actually belong to the Creative Director.
That means the gate can currently stop the pipeline based on an **ambiguous parser result**, not a trustworthy Creative Director verdict.

Before changing CD standards or gate policy, we first need a truthful CD signal.

## Background
What the latest proof established:

- AskFin baseline is clean before the run
- three-layer duplicate protection is active
- FK-012 is reduced to a single validator false-positive
- Implementation, Bug Hunter, ProjectIntegrator guard, OutputIntegrator, Knowledge Writeback, and Run Memory all worked
- the pipeline still stops at the CD gate
- the log contains multiple rating lines, making current CD-gate parsing unreliable

This means the next blocker is primarily a **pipeline flow / truthfulness issue**, not a duplicate-code issue.

## Strategic reasoning
We should **not** change CD expectations yet.

If we loosen the gate before hardening the parser, we risk compensating for the wrong problem.
The correct order is:

1. make the CD rating parser truthful and agent-specific
2. re-run a real autonomy proof
3. only then decide whether CD expectations are still too strict

This preserves the same discipline we used earlier:
first make status signals honest, then interpret them.

## Goal
Ensure the CD gate uses the **actual Creative Director verdict**, not an ambiguous last `Rating:` line from the wider group chat.

## Desired outcome
- CD gate becomes trustworthy
- `conditional_pass` vs `fail` is read from the right source
- downstream stages are no longer skipped because of parser ambiguity
- the next proof run tells us whether the real remaining issue is parser truthfulness or CD quality standards

## In scope
- trace how the current CD rating is parsed from logs/messages
- identify exactly why multiple rating lines are being conflated
- implement the smallest deterministic parser hardening
- prefer agent-specific or task-bounded extraction over free-text last-match behavior
- validate before/after rating extraction behavior

## Out of scope
- changing CD quality policy yet
- redesigning the whole group-chat system
- changing recovery, knowledge, strategy, legal, or marketing layers
- broad prompt rewrites
- masking uncertainty

## Success criteria
- exact root cause of rating ambiguity identified
- minimal deterministic parser fix implemented
- before/after proof that the parser now selects the correct CD verdict
- clear statement whether the gate result is now trustworthy
- next proof run becomes the correct follow-up

## Claude Code Prompt
```text
Goal:
Make the Creative Director gate use a trustworthy, agent-specific rating signal instead of an ambiguous last-match `Rating:` line from the wider group chat.

Task:
Audit and minimally harden the current Creative Director rating parser / gate input path so the pipeline stops or proceeds based on the actual Creative Director verdict.

Do not:
- change CD quality expectations yet
- redesign the full group-chat architecture
- change recovery, knowledge, strategy, or marketing layers
- perform broad cleanup outside this blocker
- mask uncertainty if the current CD signal is still ambiguous

Required work:
1. Trace exactly how the current CD gate rating is extracted from logs/messages.
2. Confirm why multiple `Rating:` lines from different agents or later messages can currently affect the gate result.
3. Implement the smallest deterministic fix so the gate reads the real Creative Director verdict, for example by:
   - using the Creative Director agent identity/prefix,
   - scoping extraction to the CD response segment,
   - or selecting the first valid rating immediately after the CD task rather than the last rating in the whole log.
4. Keep the fix narrow and auditable.
5. Preserve reporting so we can see:
   - raw candidate rating lines
   - selected rating line
   - why that line was selected
6. Run the closest practical validation to prove the parser now resolves the correct CD verdict.

Validation:
- show before/after rating extraction behavior on a representative run log
- show candidate rating lines and selected line
- show whether the gate decision would differ after the fix
- if a full end-to-end run is too expensive, provide code-path proof plus the closest runnable validation

Expected report:
1. Current CD rating parser root cause
2. Minimal fix implemented
3. Files changed
4. Before vs after rating extraction behavior
5. Remaining limits
6. Whether the CD gate signal is now materially more trustworthy
```

## What happens after this
If this step succeeds, the next step should be a new real end-to-end autonomy proof run on AskFin.
That run will tell us whether the remaining problem is still CD policy/expectations or whether the parser ambiguity was the main blocker.
