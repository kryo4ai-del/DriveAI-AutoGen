# Creative Director — Knowledge Integration

Date: 2026-03-12

---

## What Was Integrated

The Creative Director advisory pass now receives a compact block of prior factory learnings before reviewing generated implementations. This grounds the CD's review in specific, evidence-based patterns instead of relying solely on its system message.

---

## How Knowledge Is Selected

**File**: `factory_knowledge/knowledge_reader.py`
**Function**: `select_for_creative_director(template)`

Selection logic (deterministic, no LLM):

1. Load all entries from `factory_knowledge/knowledge.json`
2. Filter by CD-relevant types: `ux_insight`, `design_insight`, `motivational_mechanic`, `failure_case`, `success_pattern`
3. Exclude `technical_pattern` entries (pipeline mechanics, not product quality)
4. Exclude `disproven` entries (kept in store as warnings, not injected as guidance)
5. Sort by confidence: `proven` > `validated` > `hypothesis`, then by ID for stability
6. Cap at 5 entries maximum (`MAX_ENTRIES_PER_INJECTION`)

### Current selection (Round 1 seed)

| ID | Type | Title | Selected? |
|---|---|---|---|
| FK-001 | failure_case | Functional-only app lacks retention | Yes |
| FK-002 | ux_insight | Emotional micro-copy outperforms data-only feedback | Yes |
| FK-003 | motivational_mechanic | Domain-specific progress beats generic gamification | Yes |
| FK-004 | technical_pattern | SelectorGroupChat context reset | No (technical) |
| FK-005 | technical_pattern | Implementation summary for review quality | No (technical) |
| FK-006 | success_pattern | New review agents start advisory-only | No (technical) |

Result: 3 entries selected, ~400-500 chars injected.

---

## Where It Is Injected

**File**: `main.py` (Creative Director pass section, ~line 468)

The knowledge block is prepended to the CD review task prompt, after the implementation summary:

```
[Factory Knowledge — Prior Learnings]          <-- NEW
- [FK-001] Title. Lesson text.
- [FK-002] Title. Lesson text.
- [FK-003] Title. Lesson text.
Apply these learnings when reviewing the implementation.

[Implementation Summary]                       <-- existing
Feature: ...
Files generated: ...
...

Review the generated implementation for '...'  <-- existing CD task
```

### Injection order (outermost first in prompt)

1. Factory Knowledge block (if entries exist)
2. Implementation Summary (if extraction happened)
3. CD review task text

---

## Format of Injected Block

```
[Factory Knowledge — Prior Learnings]
- [FK-001] Functional-only learning app provides no retention hook. Define the emotional core of the product before building features. Ask: why would a user open this tomorrow without being told to?
- [FK-002] Emotional micro-copy outperforms data-only feedback. Contextual, emotionally aware feedback text drives stronger user engagement than raw data display. 'Stark! 8 von 10 richtig' outperforms 'Score: 80%'. Feedback after co...
- [FK-003] Domain-specific progress tracking beats generic gamification. Transforms utility tool into goal-oriented coaching experience. User sees meaningful progress toward their actual objective.
Apply these learnings when reviewing the implementation.
```

Each entry uses:
- `lesson` field if available (most actionable)
- `effect` field as fallback
- `description` field as last resort
- Detail truncated at 150 chars to keep prompt compact

---

## Why This Is Low Risk

1. **Deterministic**: No LLM involved in selection. Pure type filter + confidence sort.
2. **Bounded**: Hard cap at 5 entries. Current seed = 3 entries = ~400-500 chars.
3. **Graceful degradation**: If knowledge.json is empty, missing, or corrupted, returns empty string. No injection, no error.
4. **No behavior change**: CD still runs the same advisory pass with the same termination limits. Knowledge is additional context, not a directive.
5. **Easy to disable**: Remove the 4-line injection block in main.py, or empty knowledge.json.
6. **Console visibility**: Prints `Factory knowledge: N chars injected` so token cost is observable.

---

## Limitations of Round 1

1. **No template-based filtering**: All CD-relevant entries are injected regardless of template type. With only 3 product entries this is fine. At >10 entries, template-based filtering should be added.
2. **No project-specific filtering**: Entries from all projects are injected. With only 1 source project (askfin) this is fine. At >3 projects, `applicable_to` filtering should be added.
3. **Hypothesis entries included**: All 3 product entries are `hypothesis` confidence. This is acceptable for advisory context but should not be treated as proven guidance.
4. **One-directional**: CD reads knowledge but does not write back learnings. Writeback is planned for Step 5.
5. **Static load**: Knowledge is loaded fresh each run from disk. No caching, no hot-reload. Acceptable for current scale.

---

## Token Budget Impact

| Component | Estimated tokens |
|---|---|
| Factory Knowledge block (3 entries) | ~150-200 |
| Implementation Summary | ~100-500 |
| CD review task text | ~80 |
| **Total CD prompt** | **~330-780** |

Well within Haiku's per-request limits. No rate limit risk from this addition.

---

## Validation Result (2026-03-12)

Run: `driveai_run_20260312_203754.txt` — SkillMap screen template

### Knowledge injection confirmed

Log lines 6701-6705 show the injected block:
```
[Factory Knowledge — Prior Learnings]
- [FK-001] Functional-only learning app provides no retention hook. Define the emotional core...
- [FK-002] Emotional micro-copy outperforms data-only feedback. Contextual, emotionally aware...
- [FK-003] Domain-specific progress tracking beats generic gamification. Transforms utility tool...
Apply these learnings when reviewing the implementation.
```

### CD output quality improvement

The CD produced a `conditional_pass` rating with 5 findings, each directly grounded in factory knowledge:

| Finding | Knowledge entry applied | Concrete suggestion |
|---|---|---|
| Missing confidence trajectory | FK-001 (emotional core) | Delta indicators per category (+3% this week) |
| Generic labels everywhere | FK-002 (micro-copy) | German domain-aware copy: "Du erkennst es fast immer" |
| Missing exam-readiness cue | FK-003 (domain progress) | Traffic-light semantics tied to passing threshold |
| No motivated interaction | FK-001 + FK-003 combined | Category tap → drill-down remediation loop |
| Duplicate files = template feel | General product quality | Deduplicate + design system consistency |

### Key observation

The CD summary reads: "SkillMap is functionally complete but emotionally hollow." This is FK-001 restated as a review conclusion — exactly the grounding effect intended.

### Token cost

706 chars of knowledge context added. No rate limit issues. CD still produced concise output within MaxMessageTermination(2).
