# DrivaAI-AutoGen Step Report – ML-43

## Title
FK-019 Top-Level Statement Cleaner and Fragment Detection from First Mac Compile Truth

## Why this step now
ML-42 delivered the first real platform-side compile truth for AskFin on a Mac toolchain.

That result is strategically extremely valuable because it separates factory-internal health from actual Swift syntax reality.
The good news is that the baseline is much stronger than before:
- 227 Swift files were checked
- 211 files were clean
- about 93% of files passed parse-level syntax checking
- the failures were not random app-domain issues

The important bad news is equally clear:
the remaining failures are mostly factory-central generation artifacts, especially top-level statements and structural code fragments that should never survive extraction into final Swift source files.

This means the next correct move is not another expensive Sonnet run.
The next correct move is a cheap, central, deterministic factory-layer fix.

## Background
The Mac-side swiftc parse check established four clear error families:

1. top-level statements / expressions in production Swift files
2. structural fragments such as stray braces or partial bodies
3. truncated files ending in incomplete declaration state
4. pseudo-code placeholders such as `...` inside output

The dominant failure family is top-level statements in generated files.
That strongly suggests a missing guard in the code extraction / output sanitation path rather than a project-local business-logic bug.

The report explicitly interprets these as factory-central issues and recommends a deterministic cleaner / FK-pattern rather than manual cleanup of all affected files.

## Strategic reasoning
We should fix the dominant structural output defect before any new run.

Why?
Because the Mac compile check already produced the high-value evidence we needed.
The next highest-return action is now to teach the factory not to emit or retain these malformed file shapes.

This is exactly the kind of low-cost, high-leverage step your governance layer was meant to prefer:
- no expensive stronger-model run
- no blind repetition
- no manual cleanup across many files
- one central deterministic fix that improves future output quality for all runs

This also fits the long-term factory goal:
the system should become stricter about what qualifies as valid source output before integration.

## Goal
Add a new deterministic compile-hygiene / extraction safeguard that detects and cleans top-level statements and obvious structural fragments in generated Swift files before they survive into the project baseline.

## Desired outcome
- top-level executable statements in normal Swift source files are detected automatically
- obvious structural fragments are detected automatically
- malformed generated snippets are removed, commented out, quarantined, or otherwise neutralized safely
- Compile Hygiene gains a new FK-pattern (for example FK-019) or equivalent central rule
- the current 16-file Mac parse failure set is reduced materially without another model run
- future runs become less likely to reintroduce the same failure class

## In scope
- inspect CodeExtractor / output sanitation / compile_hygiene flow
- identify where top-level statements and fragments are currently allowed through
- implement the smallest robust central safeguard
- support at least these pattern classes:
  - top-level statements / expressions
  - obvious structural fragments (e.g. stray braces, partial method bodies)
  - optionally placeholder pseudo-code if easy to include safely
- integrate the new logic into Compile Hygiene and/or post-generation sanitation
- validate the fix against the current Mac-compile failure files if available
- record whether the fix is safe for legitimate constructs like declarations, extensions, previews, and valid top-level constructs if the project intentionally uses scripts (if any)

## Out of scope
- another LLM generation run
- broad project feature work
- manual cleanup of all 16 files as the main solution
- full architecture redesign
- commercialization work
- multi-model routing work

## Success criteria
- the exact structural reason for the dominant Mac parse failures is captured in central logic
- top-level statement artifacts are no longer allowed through silently
- the new rule is reusable for future runs
- the current failure set is reduced materially through a cheap deterministic path
- the next step can be chosen from a cleaner Mac compile baseline without requiring another expensive proof run first

## Strategic note for later planning
The broader DriveAI-AutoGen direction remains unchanged:
build toward a highly autonomous, self-improving factory with stronger central coordination, stronger truth systems, better lifecycle governance, richer planning and decomposition, and eventually trustworthy multi-provider / multi-model routing.
This step specifically strengthens the boundary between raw generated text and valid integrated source code.

## Claude Code Prompt
```text
Goal:
Add a deterministic central safeguard for top-level statements and structural fragments in generated Swift files so the dominant Mac parse failures are prevented without another expensive model run.

Task:
Inspect the current CodeExtractor / output sanitation / CompileHygiene flow and identify exactly why top-level statements and structural fragments are surviving into integrated Swift source files.
Implement the smallest robust central fix so these malformed output patterns are detected and neutralized before they remain in the project baseline.

Important:
Do not solve this primarily by manually editing all affected files one by one.
Do not launch another generation/autonomy run in this step.
The goal is a reusable factory-layer safeguard, ideally integrated as a new FK-pattern (for example FK-019) or an equivalent deterministic sanitation pass.

Focus especially on:
- top-level executable statements/expressions in normal Swift source files
- structural fragments such as stray braces or partial bodies
- whether these should be removed, commented out, quarantined, or otherwise neutralized safely
- where this logic belongs best:
  - CodeExtractor
  - post-generation sanitizer
  - CompileHygiene
  - or a small combination of these
- preserving valid declarations, extensions, previews, and other legitimate Swift constructs

Required checks:
1. Identify the exact central path that currently allows top-level statements/fragments through.
2. Implement the smallest robust central fix or FK-pattern for this failure family.
3. Validate the fix against the current Mac parse failure examples if available.
4. Confirm that legitimate Swift declarations/previews do not regress.
5. State whether the current Mac-side failure set is now materially reduced.
6. End with a single next recommended step that does not assume another expensive run is needed immediately.

Expected report:
1. Root cause in the old extraction / hygiene path
2. Exact central fix implemented
3. How top-level statements / fragments are now detected and handled
4. Validation against the current failure examples
5. Regression/safety check summary
6. Whether the baseline is now cleaner for a second Mac compile check
7. Single next recommended step
```

## What happens after this
If the new safeguard materially reduces the current Mac parse failures, the next best step is a second cheap Mac compile reality check rather than another Sonnet run.
If the failures remain mostly unchanged, then the next step should narrow whether truncation and fragment handling need to be split into separate deterministic passes.
