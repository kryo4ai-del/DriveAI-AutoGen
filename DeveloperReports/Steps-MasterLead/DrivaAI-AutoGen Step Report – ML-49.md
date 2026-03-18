# DrivaAI-AutoGen Step Report – ML-49

## Title
FK-023 SwiftUI Import Hygiene Expansion Before ExamSessionViewModel Contract Repair

## Why this step now
ML-48 delivered another clear cheap win.

The duplicate-type collision around `WeakArea` is now centrally resolved through a defined policy instead of ad hoc cleanup:
- canonical rule: `dedicated-file-wins`
- canonical definition: `Models/WeakArea.swift`
- inline duplicates removed from:
  - `AssessmentResult.swift`
  - `Recommendation.swift`
- the `WeakArea` collision is fully resolved

That is strategically important because the remaining build-truth surface is no longer diffuse.
The next blocker is now concentrated in one file family:
`ExamSessionViewModel.swift`.

The report identifies two issue classes there:
1. `@StateObject` without SwiftUI import
2. missing properties / services such as `startTime` and `examSessionService`

The correct next move is not to mix both classes immediately.
The cheapest and cleanest next move is to extend the already-proven import-hygiene path one more level so SwiftUI symbols are handled centrally first.
That will strip away the cheap missing-import class and leave the true contract mismatch isolated for the next step.

## Background
The latest Mac-side report established:

- the duplicate `WeakArea` family is solved
- the remaining blocker is no longer structural duplication
- the next blocker is localized to `ExamSessionViewModel.swift`
- one part of the failure is a known cheap pattern:
  missing framework import for SwiftUI symbols
- the other part is more structural:
  missing properties / missing service dependencies

This means the sequence should remain disciplined:
1. clear the cheap deterministic import-family blocker,
2. recheck cheaply,
3. then target the remaining ViewModel contract mismatch with cleaner evidence.

## Strategic reasoning
We should not jump straight into the ViewModel/service contract repair.

Why?
Because the import-hygiene layer has already proven itself across Foundation and Combine.
SwiftUI is the next natural extension, and it is the cheapest root-cause family currently left.

If we mix import hygiene and contract reconciliation into one step now, we lose clarity and risk over-fixing.
A better sequence is:
- first remove the missing-SwiftUI-import class centrally,
- then let the recheck show the exact remaining contract errors.

This is exactly the kind of low-cost sequencing the governance layer was meant to encourage.

## Goal
Extend the deterministic import-hygiene safeguard so known SwiftUI symbols trigger `import SwiftUI` when required, and clear the remaining missing-import class before tackling the deeper `ExamSessionViewModel` contract mismatch.

## Desired outcome
- files using known SwiftUI symbols such as `@StateObject` are detected automatically
- missing `import SwiftUI` is added deterministically when safe
- the SwiftUI-import portion of the `ExamSessionViewModel.swift` error set is removed
- the next cheap Mac recheck leaves the remaining service/property contract mismatch cleanly isolated
- future runs become less likely to emit the same SwiftUI-import omission family

## In scope
- inspect the current import-hygiene implementation
- generalize it from Foundation + Combine to also support SwiftUI
- support at least the currently validated symbol:
  - `@StateObject`
- optionally include a tiny curated set of obviously safe SwiftUI symbols if appropriate
- validate on `ExamSessionViewModel.swift`
- run a cheap Mac-side typecheck recheck afterward if practical
- preserve files that do not require SwiftUI

## Out of scope
- service/property contract repair in this step
- another LLM generation run
- broad import inference for every Apple framework in one pass
- manual one-file patching as the primary final solution
- unrelated architecture redesign
- feature work
- commercialization work

## Success criteria
- the exact missing-SwiftUI-import family is captured in central logic
- `import SwiftUI` is added when known SwiftUI symbols require it
- the import-related part of `ExamSessionViewModel.swift` is resolved through the central mechanism
- the next cheap recheck leaves the remaining blocker primarily as a contract/property/service mismatch
- no expensive model run is required

## Strategic note for later planning
The broader DriveAI-AutoGen direction remains unchanged:
build toward a highly autonomous, self-improving factory with stronger central coordination, stronger truth systems, better lifecycle governance, richer planning and decomposition, and eventually trustworthy multi-provider / multi-model routing.
This step specifically strengthens the import-hygiene layer from Foundation and Combine toward a more reusable multi-framework safeguard.

## Claude Code Prompt
```text
Goal:
Extend the deterministic import-hygiene safeguard so known SwiftUI symbols trigger `import SwiftUI` when required, and clear the remaining missing-import class before tackling the deeper `ExamSessionViewModel` contract mismatch.

Prompt ist für Mac

Task:
Inspect the current `factory/operations/import_hygiene.py` implementation and generalize the proven import-hygiene path beyond Foundation and Combine so that missing `SwiftUI` imports are detected and fixed deterministically when known SwiftUI symbols are present.

Important:
Do not solve this primarily by manually editing only `ExamSessionViewModel.swift`.
Do not start another generation/autonomy run.
Do not mix service/property contract repair into this same step.
The goal is a reusable factory-layer import-hygiene expansion for SwiftUI.

Focus especially on:
- how Foundation and Combine symbol detection already work
- how to add a small safe SwiftUI symbol map
- the currently validated symbol:
  - `@StateObject`
- how to insert `import SwiftUI` safely without regressing existing import ordering
- validating the fix on `ExamSessionViewModel.swift`

Required checks:
1. Identify the exact central path that currently allows missing SwiftUI imports through.
2. Implement the smallest robust deterministic fix for this SwiftUI-import family.
3. Validate the fix on `ExamSessionViewModel.swift`.
4. If practical, run a cheap Mac-side typecheck recheck afterward.
5. Confirm whether the remaining non-import blocker is now primarily the missing property/service contract family.
6. End with one single next recommended step.

Expected report:
1. Root cause in the old import-hygiene path for SwiftUI
2. Exact central fix implemented
3. How SwiftUI symbol detection now works
4. Validation on `ExamSessionViewModel.swift`
5. Recheck outcome if run
6. Regression/safety summary
7. Single next recommended step
```

## What happens after this
If the SwiftUI-import expansion succeeds, the next best step is a focused central contract-reconciliation policy/fix for the remaining `ExamSessionViewModel` property/service mismatch, still without another expensive model run.
If unexpected new import families appear, then the next step should narrow whether to extend import hygiene again or move directly to contract reconciliation.
