# DrivaAI-AutoGen Step Report – ML-44

## Title
Residual Debug/Preview Compile Policy for the Last Two Mac Parse Outliers

## Why this step now
The Mac recheck after the FK-019 sanitizer is a major milestone.

The factory moved from the first real Mac parse truth of 93.0% cleanliness to 99.1% cleanliness in the same session.
That is a huge result, and it changes the nature of the remaining work completely.

The important part is not just that almost all parse failures are gone.
It is that the remaining two files are now clearly identified as a special class:

- `ReadinessScore+Extension.swift`
- `PreviewDataFactory.swift`

These are not normal broad generation failures anymore.
They are residual structural outliers in debug/preview-oriented code:
- one is a fragment-like file shape
- one has an unmatched compiler directive boundary

That means the next correct move is not another expensive model run and not another broad sanitizer expansion.
The next correct move is a small central policy for how the factory should treat non-safely-autofixable debug/preview compile outliers.

## Background
The latest Mac compile recheck established:

- parse cleanliness improved to 99.1%
- the block-aware sanitizer removed the dominant top-level/fragment failure class
- 15 affected files were fully cleaned from the prior failure set
- only 2 files remain with 4 total parse errors
- both remaining files are debug/preview-oriented and low priority
- both remaining files are explicitly described as not safely auto-repairable by the current sanitizer

This matters because we are no longer dealing with a large hygiene gap.
We are dealing with the question:
what should the factory do when only a very small number of non-safely-autofixable debug/preview residuals remain?

That is a policy/governance issue more than a generation issue.

## Strategic reasoning
We should not immediately do another broad fix pass.

Why?
Because the current baseline is already extremely clean, and the report itself makes clear that the remaining files are edge cases where automatic repair could become unsafe.

So the right next step is to teach the factory how to classify and handle this residual category intentionally.

The missing layer is something like:
- residual compile-outlier classification
- distinction between release-critical vs debug/preview-only failures
- safe policy choices such as:
  - quarantine
  - explicit low-priority ignore
  - manual-fix-needed classification
  - defer-until-human-review classification

This fits your broader architectural goal very well:
not just “fix more,”
but give the system a better governing layer for edge conditions.

## Goal
Add a small central residual-compile policy for debug/preview-only outliers that are not safely auto-fixable, so the last two Mac parse blockers are handled intentionally rather than ad hoc.

## Desired outcome
- the factory can classify residual parse blockers by impact and repair safety
- debug/preview-only residuals are distinguished from release-critical blockers
- non-safely-autofixable residuals can be routed to a clear policy state such as:
  - QUARANTINE_CANDIDATE
  - MANUAL_FIX_REQUIRED
  - LOW_PRIORITY_DEBUG_OUTLIER
  - IGNORE_FOR_RELEASE_BASELINE
- the current two files are classified through that central policy
- the system can then decide cleanly whether to quarantine them, patch them manually, or accept them as non-release blockers
- no expensive model run is required for this decision

## In scope
- inspect where compile results / hygiene results are currently classified
- add a small residual-outlier policy layer or equivalent central rule
- define classification fields such as:
  - compile criticality
  - debug/release scope
  - auto-fix safety
  - recommended disposition
- evaluate the two current files through this policy
- recommend the best policy action for each of the two files
- prefer a low-cost, explicit, reusable handling path

## Out of scope
- another LLM generation run
- broad sanitizer expansion into risky auto-repair territory
- full architecture redesign
- major feature work
- UI work
- commercialization work

## Success criteria
- the remaining two files are no longer treated as generic unresolved noise
- the factory has a reusable policy for residual non-safely-autofixable compile outliers
- the current state is made operationally clear:
  - release-relevant or not
  - quarantine-worthy or not
  - manual-fix-worthy or not
- the next action can be chosen cheaply and deliberately

## Strategic note for later planning
The broader DriveAI-AutoGen direction remains unchanged:
build toward a highly autonomous, self-improving factory with stronger central coordination, stronger truth systems, better lifecycle governance, richer planning and decomposition, and eventually trustworthy multi-provider / multi-model routing.
This step specifically strengthens the factory's ability to govern the final edge-case layer between “almost clean” and “operationally acceptable.”

## Claude Code Prompt
```text
Goal:
Add a small central residual-compile policy for debug/preview-only outliers that are not safely auto-fixable, so the last two Mac parse blockers are handled intentionally rather than ad hoc.

Prompt ist für Mac

Task:
Inspect the current compile-result interpretation / hygiene-result classification path and implement the smallest robust central policy for residual compile outliers that are:
- low in count,
- debug/preview-oriented,
- and not safely auto-fixable by the current sanitizer.

Use the two currently remaining files as the concrete validation cases:
- `ReadinessScore+Extension.swift`
- `PreviewDataFactory.swift`

Important:
Do not start another generation/autonomy run.
Do not solve this by blindly forcing the sanitizer to mutate risky fragment cases.
Do not treat these two files as generic unresolved leftovers.
The goal is a reusable factory-layer policy for residual compile outliers.

Focus especially on:
- whether a residual blocker is release-critical or debug/preview-only
- whether automatic repair is safe or unsafe
- whether the best disposition is:
  - quarantine,
  - manual-fix-required,
  - low-priority ignore,
  - or ignore-for-release-baseline
- how this policy can be represented centrally in the current factory flow/docs/state
- how the two current files should be classified under the new policy

Required checks:
1. Define the smallest useful residual-outlier classification policy.
2. Apply it to the two current remaining files.
3. State clearly whether each file is:
   - release-critical or not,
   - safe to auto-fix or not,
   - quarantine candidate or not,
   - manual-fix candidate or not.
4. Recommend the single best action for each file under this policy.
5. Confirm that no expensive model run is needed for this decision.
6. End with one single next recommended step.

Expected report:
1. Residual-outlier policy defined
2. Exact central artifact(s) added/updated
3. Classification of `ReadinessScore+Extension.swift`
4. Classification of `PreviewDataFactory.swift`
5. Recommended disposition for each
6. Why this is cheaper/safer than another run
7. Single next recommended step
```

## What happens after this
Once the two residual files are classified intentionally, the next step will likely be one of three low-cost options:
- quarantine the non-essential debug/preview outliers,
- perform one tiny manual fix on Mac,
- or accept them as non-release blockers and freeze the baseline.

Only after that should we decide whether any further compile reality work is needed.
