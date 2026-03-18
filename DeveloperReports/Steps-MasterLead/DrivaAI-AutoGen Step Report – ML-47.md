# DrivaAI-AutoGen Step Report – ML-47

## Title
FK-021 Multi-Framework Import Hygiene Expansion for Combine Before Duplicate-Type Resolution

## Why this step now
ML-46 was a strong cheap win.

The new deterministic import-hygiene layer fixed the original missing-Foundation family centrally instead of patching only two files by hand.
That already paid off immediately:
- 41 files were auto-fixed with `import Foundation`
- the two original root causes were cleared
- the baseline advanced to the next real build-truth layer without another expensive model run

The new evidence now shows two remaining issue classes:

1. `RecommendationViewModel.swift`
   - missing `import Combine`
   - symbols such as `ObservableObject` / `@Published`

2. duplicate `WeakArea` definitions
   - `AssessmentResult.swift`
   - `WeakArea.swift`
   - `Recommendation.swift`

The correct next move is not to mix both classes into one broad step.
The cheapest and cleanest next move is to extend the now-proven import-hygiene mechanism one level further so framework symbols from `Combine` are also handled centrally.

That removes one full root-cause family cheaply and leaves the duplicate-type collision as the next isolated structural blocker.

## Background
The latest report established:

- `factory/operations/import_hygiene.py` now exists as a deterministic safeguard
- 30+ Foundation symbols are covered
- Foundation import inference already worked at scale
- the original two-file Foundation failures are gone
- one new remaining issue is a missing `Combine` import for `RecommendationViewModel.swift`
- the other remaining issue is a true structural duplicate-type problem around `WeakArea`

This means the import-hygiene path has already proven its value.
The next sensible step is to broaden it slightly rather than stopping after Foundation only.

## Strategic reasoning
We should clear the remaining import-family blocker before addressing duplicate-type collisions.

Why?
Because the duplicate-type issue is structurally different and should be treated as its own central policy/repair problem.
If we mix the two now, we lose clarity.

A better sequence is:
1. finish the cheap deterministic import-hygiene expansion,
2. recheck cheaply,
3. then isolate the duplicate-type family as the next structural target.

This is exactly the kind of low-cost disciplined sequencing the governance layer was meant to encourage.

## Goal
Extend the deterministic import-hygiene safeguard so known Combine symbols trigger `import Combine` when required, and clear the remaining missing-import root cause before tackling duplicate-type collisions.

## Desired outcome
- files using known Combine symbols such as `ObservableObject` or `@Published` are detected automatically
- missing `import Combine` is added deterministically when safe
- `RecommendationViewModel.swift` is fixed through the central mechanism rather than only a manual patch
- the next cheap Mac recheck removes the import-family blocker and leaves duplicate-type collisions as the isolated next structural issue
- future runs become less likely to emit the same Combine-import omission family

## In scope
- inspect the current import-hygiene implementation
- generalize it from Foundation-only inference to at least one additional framework family: Combine
- support at least the currently validated symbols:
  - `ObservableObject`
  - `@Published`
- optionally include a tiny curated set of other clearly safe Combine symbols if appropriate
- validate on `RecommendationViewModel.swift`
- run a cheap Mac-side typecheck recheck afterward if practical
- preserve files that do not require Combine

## Out of scope
- duplicate-type collision repair in this step
- another LLM generation run
- broad import inference for every Apple framework in one pass
- manual one-file patching as the primary final solution
- unrelated architecture redesign
- feature work
- commercialization work

## Success criteria
- the exact missing-Combine-import family is captured in central logic
- `import Combine` is added when the known symbols require it
- `RecommendationViewModel.swift` is resolved through the central mechanism
- the next cheap recheck leaves duplicate-type collisions as the primary isolated blocker
- no expensive model run is required

## Strategic note for later planning
The broader DriveAI-AutoGen direction remains unchanged:
build toward a highly autonomous, self-improving factory with stronger central coordination, stronger truth systems, better lifecycle governance, richer planning and decomposition, and eventually trustworthy multi-provider / multi-model routing.
This step specifically strengthens the import-hygiene layer from single-framework coverage toward a more reusable multi-framework safeguard.

## Claude Code Prompt
```text
Goal:
Extend the deterministic import-hygiene safeguard so known Combine symbols trigger `import Combine` when required, and clear the remaining missing-import root cause before tackling duplicate-type collisions.

Prompt ist für Mac

Task:
Inspect the current `factory/operations/import_hygiene.py` implementation and generalize the proven import-hygiene path beyond Foundation so that missing `Combine` imports are detected and fixed deterministically when known Combine symbols are present.

Important:
Do not solve this primarily by manually editing only `RecommendationViewModel.swift`.
Do not start another generation/autonomy run.
Do not mix duplicate-type collision repair into this same step.
The goal is a reusable factory-layer import-hygiene expansion for Combine.

Focus especially on:
- how Foundation symbol detection already works
- how to add a small safe Combine symbol map
- the currently validated symbols:
  - `ObservableObject`
  - `@Published`
- how to insert `import Combine` safely without regressing existing import ordering
- validating the fix on `RecommendationViewModel.swift`

Required checks:
1. Identify the exact central path that currently allows missing Combine imports through.
2. Implement the smallest robust deterministic fix for this Combine-import family.
3. Validate the fix on `RecommendationViewModel.swift`.
4. If practical, run a cheap Mac-side typecheck recheck afterward.
5. Confirm whether the remaining non-import blocker is now primarily the duplicate `WeakArea` type family.
6. End with one single next recommended step.

Expected report:
1. Root cause in the old import-hygiene path for Combine
2. Exact central fix implemented
3. How Combine symbol detection now works
4. Validation on `RecommendationViewModel.swift`
5. Recheck outcome if run
6. Regression/safety summary
7. Single next recommended step
```

## What happens after this
If the Combine-import expansion succeeds, the next best step is a focused central duplicate-type collision policy/fix for the `WeakArea` family, still without another expensive model run.
If unexpected new import families appear, then the next step should narrow whether to extend import hygiene again or move directly to structural collision handling.
