# Implementation Summary Integration

Date: 2026-03-12

---

## Why This Was Needed

After the pipeline reliability fix (`team.reset()` between passes), review passes (Bug Hunter, Creative Director, Refactor, Test Generator) lost all implementation context. They could only work from the task description alone, leading to generic reviews disconnected from the actual generated code.

This integration restores enough context for reviewers to ground their feedback in the actual implementation, without reintroducing the context explosion that caused rate limit failures.

---

## Summary Format

The implementation summary is a compact text block (~300-500 tokens max) with this structure:

```
[Implementation Summary]
Feature: <user_task>
Template: <template> (if applicable)
Files generated: <count>

Generated files:
  - Views/TrainingModeView.swift (struct)
  - ViewModels/TrainingModeViewModel.swift (class)
  - Services/TrainingService.swift (class)
  - Models/Question.swift (struct)

Architecture: Observable pattern, SwiftUI State, async/await

Use this summary to ground your review in the actual implementation.
```

### What is included
- Feature/template name
- Generated file names with subfolder and Swift type keyword
- Detected architectural patterns (Observable, Combine, async/await, NavigationStack, etc.)

### What is NOT included
- Full code dumps
- Chat history
- Speculative analysis
- Log output

---

## Where It Is Generated

**File**: `code_generation/code_extractor.py`
**Method**: `CodeExtractor.build_implementation_summary(user_task, template)`

The summary is built from metadata captured during `extract_swift_code()`:
- `_last_extraction_files`: list of `(name, subfolder, type_keyword)` tuples
- `_last_extraction_patterns`: set of detected architectural patterns (via `_SWIFT_PATTERNS` dict)

Both are stored as instance attributes on the `CodeExtractor` after each extraction run.

---

## Where It Is Injected

**File**: `main.py` (review passes section)

The summary is prepended to the task prompt for these passes:
1. **Bug Hunter** — helps identify bugs in specific files/components
2. **Creative Director** — grounds product review in actual generated structure
3. **Refactor Agent** — targets refactoring suggestions at real files
4. **Test Generator** — generates tests for the actual components

**Not injected** into:
- Implementation Pass (runs before extraction)
- Fix Execution Pass (already receives structured input from `FixExecutor.build_fix_task()`)

### Injection pattern
```python
if impl_summary:
    bug_review_task = f"{impl_summary}\n\n{bug_review_task}"
```

---

## Why It Is Safe

1. **Bounded size**: MAX_FILES_PER_RUN = 10 files. Each file entry is ~40-60 chars. Total summary is deterministically bounded at ~500-700 chars max.
2. **Deterministic**: No LLM call needed. Built from extraction metadata (file names, type keywords, pattern detection).
3. **No code content**: Only file names and patterns — no actual Swift code is included.
4. **No growth risk**: The summary is regenerated fresh each run from the extraction result. It cannot accumulate across runs.
5. **Graceful degradation**: If no files were extracted (e.g., aborted extraction), the summary is empty and review prompts remain unchanged.
6. **Additive only**: Prepended to existing task prompts. No existing behavior is modified.

---

## Limitations

1. **File names only**: Reviewers see what was generated but not the actual code. For deep code review, the implementation context is still missing.
2. **Pattern detection is heuristic**: Based on string matching in code blocks. May miss uncommon patterns or report false positives for patterns mentioned in comments.
3. **No orphan/helper info**: Orphan code blocks routed to `GeneratedHelpers.swift` are not listed individually in the summary.
4. **Aborted extractions**: If extraction was aborted (>10 files), the summary still lists the detected files even though they weren't written to disk. This is intentional — reviewers should still know what was attempted.

---

## Validation

See validation run results in the main report output.

### Expected behavior
- Console prints: `Implementation summary: <N> chars for review context`
- Review pass logs show the summary prepended to the task prompt
- Review output references specific generated files/components
- No increase in rate limit errors or token pressure
