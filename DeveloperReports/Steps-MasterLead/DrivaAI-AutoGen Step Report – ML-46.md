# DrivaAI-AutoGen Step Report – ML-46

## Title
FK-020 Missing Foundation Import Inference from First Build Reality Check

## Why this step now
The first real Apple-side build reality check delivered a very strong result.

Even without an `.xcodeproj`, `.xcworkspace`, or `Package.swift`, the Mac-side `swiftc -typecheck` check shows that the current active baseline is already extremely close to real compile readiness:

- 215 app files checked
- 213 clean files
- 99.1% app-file type-check cleanliness
- only 2 files with real errors
- 10 total errors, but only 2 true root causes
- both root causes are trivial missing imports

That means the next correct move is not another expensive generation run and not a broad architecture change.
The next correct move is a cheap, central, deterministic fix for missing standard/framework imports.

## Background
The current Mac-side build reality check isolated two root causes:

1. `ExamReadinessError.swift`
   - missing `import Foundation`
   - `LocalizedError` not found
   - causes a small cascade

2. `MockTrendPersistenceService.swift`
   - missing `import Foundation`
   - `Date` not found

The important point is that these are not app-domain logic failures.
They are not model-quality failures.
They are not type-architecture failures.

They are a final class of factory-central hygiene issue:
the system can still emit Swift files that use standard Foundation symbols without ensuring the required module import is present.

This is exactly the kind of cheap, deterministic defect we should solve centrally.

## Strategic reasoning
We should not fix these as isolated manual edits first.

Why?
Because the evidence says this is a reusable failure family:
generated files may reference known Foundation types/protocols without carrying the matching import.

If we patch just the two files manually, we remove the symptom but not the pattern.
A better next move is to teach the factory a small central import-inference / import-hygiene safeguard.

This also fits the current governance layer:
- zero Sonnet cost
- no speculative rerun
- no overbuilding
- one cheap deterministic factory improvement
- then a second Mac-side build/typecheck recheck

## Goal
Add a deterministic central import-hygiene safeguard that detects usage of known Foundation symbols and ensures `import Foundation` is present when required.

## Desired outcome
- files using known Foundation symbols such as `Date` or `LocalizedError` are detected automatically
- missing `import Foundation` is added deterministically when safe
- the current two-file failure set is resolved through a central mechanism rather than only manual patching
- future runs become less likely to emit the same import omission class
- the baseline becomes ready for a second cheap Mac build/typecheck recheck

## In scope
- inspect current code extraction / integration / hygiene flow
- identify where import completeness is currently unchecked
- implement the smallest robust central safeguard for Foundation imports
- support at least the currently proven symbols:
  - `Date`
  - `LocalizedError`
- optionally include a small curated set of other obvious Foundation-bound symbols if safe
- validate the fix on the two current failing files
- run a cheap Mac-side recheck afterward if practical
- preserve files that intentionally should not import Foundation unless required

## Out of scope
- another LLM generation run
- broad import auto-management for every Apple framework in this step
- manual patching as the primary final solution
- full Xcode project generation in this step
- unrelated architecture redesign
- feature work
- commercialization work

## Success criteria
- the exact missing-import failure family is captured in central logic
- `import Foundation` is added when these known symbols require it
- the current two-file typecheck failures are resolved materially
- the new rule is reusable for future runs
- the next step can be a cheap Mac recheck rather than another expensive proof run

## Strategic note for later planning
The broader DriveAI-AutoGen direction remains unchanged:
build toward a highly autonomous, self-improving factory with stronger central coordination, stronger truth systems, better lifecycle governance, richer planning and decomposition, and eventually trustworthy multi-provider / multi-model routing.
This step specifically strengthens the final hygiene boundary between “syntactically valid Swift” and “type-check-ready Swift.”

## Claude Code Prompt
```text
Goal:
Add a deterministic central import-hygiene safeguard that detects usage of known Foundation symbols and ensures `import Foundation` is present when required.

Prompt ist für Mac

Task:
Inspect the current extraction / integration / hygiene path and identify where files can survive into the baseline while referencing Foundation symbols such as `Date` or `LocalizedError` without importing Foundation.
Implement the smallest robust central fix so this missing-import family is handled deterministically.

Important:
Do not solve this primarily by manually editing only the two current files.
Do not start another generation/autonomy run.
The goal is a reusable factory-layer import-hygiene safeguard.

Focus especially on:
- where import completeness is currently unchecked
- how to detect safe cases requiring `import Foundation`
- the current validated symbols:
  - `Date`
  - `LocalizedError`
- whether a very small curated Foundation symbol list should be supported immediately
- how to avoid adding Foundation when it is not actually needed

Required checks:
1. Identify the exact central path that currently allows missing Foundation imports through.
2. Implement the smallest robust deterministic fix for this failure family.
3. Validate the fix on:
   - `ExamReadinessError.swift`
   - `MockTrendPersistenceService.swift`
4. If practical, run a cheap Mac-side typecheck recheck after the fix.
5. Confirm that the current 2-file root-cause set is resolved or materially reduced.
6. End with one single next recommended step.

Expected report:
1. Root cause in the old import-hygiene path
2. Exact central fix implemented
3. How Foundation symbol detection now works
4. Validation on the two current failing files
5. Recheck outcome if run
6. Regression/safety summary
7. Single next recommended step
```

## What happens after this
If the import-hygiene fix clears the current two-file root causes, the next best step is a second Mac-side build/typecheck recheck from the same cheap baseline.
If unexpected new root causes appear, then the next step should narrow whether they belong to the same import family or to a different final build-truth layer.
