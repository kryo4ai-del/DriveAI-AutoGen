# Creative Director — Soft Gate Mode

Date: 2026-03-13

---

## Why the Gate Was Introduced

The Creative Director advisory pass was producing structured, knowledge-grounded product quality assessments. These assessments included explicit ratings (pass/conditional_pass/fail), but the pipeline ignored the rating entirely — all review passes continued regardless.

With the gate, the pipeline can now react to strong negative signals from the CD, preventing further processing of implementations that fail basic product quality standards.

---

## How It Works

### Rating extraction

The CD rating is extracted from agent output using a robust regex parser that handles all observed format variations:

- `**Rating: conditional_pass**`
- `Rating: **conditional_pass**`
- `## Rating: **conditional_pass**`
- `` **Rating:** `conditional_pass` ``
- `**Overall Rating: FAIL**`

Parser location: `factory_knowledge/knowledge_reader.py` → `extract_cd_rating(messages)`

### Gate behavior

| CD Rating | Gate Action |
|---|---|
| `pass` | Continue normally |
| `conditional_pass` | Continue with logged warning |
| `fail` | Stop further passes (refactor, test gen, fix execution) |
| Not detected | Treat as `pass` (fail-open) |

### Fail-open design

If the CD rating cannot be parsed (unusual output format, agent selected wrong speaker, etc.), the gate defaults to `pass`. This prevents the gate from blocking the pipeline due to formatting quirks.

---

## When It Triggers

### Template-aware activation

The gate only activates for product-facing templates:

| Template | CD runs? | Gate active? |
|---|---|---|
| `screen` | Yes | Yes |
| `feature` | Yes | Yes |
| `service` | No (CD skipped) | No |
| `viewmodel` | No (CD skipped) | No |
| Other | No (CD skipped) | No |

This ensures technical tasks (services, parsers, infrastructure) are never blocked by product quality assessments.

### What happens on FAIL

When the CD rates an implementation as `fail`:

1. Console prints: `[CD GATE] Product quality FAIL — stopping further passes.`
2. Logger records: `[CD GATE] Product quality FAIL — pipeline stopped by CD gate.`
3. Remaining passes (refactor, test generation, fix execution) are skipped
4. The run still completes normally (code extraction, delivery export, git commit all happen)
5. Console summary shows: `CD Gate: FAIL — pipeline stopped early`
6. Skipped phases listed in summary

The implementation pass output and bug hunter output are preserved — only review/optimization passes are skipped.

---

## Why It Is Soft and Not Hard Blocking

1. **Fail-open**: Unknown ratings default to pass. No accidental blocking.
2. **Advisory retained**: Even on `fail`, the CD's findings are logged and visible. The gate prevents wasted review passes on code that needs fundamental rework.
3. **Override available**: `--no-cd-gate` flag bypasses the gate entirely.
4. **No code deletion**: The gate never deletes generated code. It only prevents further review passes.
5. **conditional_pass continues**: Only a clear `fail` stops the pipeline. Partial quality issues are logged as warnings.

---

## How to Disable

```bash
# Bypass the CD gate for a single run
python main.py --template screen --name Dashboard --profile dev --approval auto --no-cd-gate

# Disable the CD entirely (no review, no gate)
python main.py --template screen --name Dashboard --profile dev --approval auto --disable-agent creative_director
```

---

## Implementation Location

### Rating parser
`factory_knowledge/knowledge_reader.py` lines 110-160:
- `_CD_RATING_RE`: Robust regex handling 6+ format variations
- `extract_cd_rating(messages)`: Two-pass scanner — first checks `creative_director` source, then falls back to all non-user messages (handles SelectorGroupChat picking wrong speaker)

### Gate logic
`main.py` lines 486-509:
- Inserted after CD pass, before refactor pass
- Uses `gate_ctx["cd_gate_stop"]` flag to skip subsequent passes
- Guards on refactor, test generation, and fix execution passes

### CLI flag
`main.py` line 210: `--no-cd-gate` → `result["no_cd_gate"] = True`
Passed through all `_run_pipeline()` call sites (single run, task pack, batch queue).

---

## Console Output Examples

### Pass
```
--- Creative Director pass (advisory) ---
  Factory knowledge: 706 chars injected
  CD rating: pass
```

### Conditional Pass
```
--- Creative Director pass (advisory) ---
  Factory knowledge: 706 chars injected
  CD rating: conditional_pass
  [CD GATE] Conditional pass — product quality warnings logged, continuing.
```

### Fail
```
--- Creative Director pass (advisory) ---
  Factory knowledge: 706 chars injected
  CD rating: fail

[CD GATE] Product quality FAIL — stopping further passes.
  The Creative Director rated this implementation as below premium standards.
  Use --no-cd-gate to override this gate.
```

---

## Validation Results (2026-03-13)

### Test A — conditional_pass (pipeline continues)

Run: `driveai_run_20260313_041830.txt` — GateTestE_Stats screen template

- CD source: `creative_director` (selector hint working)
- CD rating: `conditional_pass` → correctly parsed
- Gate action: `[CD GATE] Conditional pass — product quality warnings logged, continuing.`
- Pipeline: Refactor + Test generation ran normally
- Messages: 10 (impl) + 10 (bugs) + 10 (creative) + 10 (refactor) + 10 (tests)

### Test B — fail (pipeline stops)

Run: `driveai_run_20260313_031543.txt` — GateTestC_Profile screen template

- CD source: `creative_director` (selector hint working)
- CD rating: `fail` → correctly parsed
- Gate action: `[CD GATE] Product quality FAIL — stopping further passes.`
- Pipeline: Refactor, test_generation, fix_execution skipped
- Messages: 10 (impl) + 10 (bugs) + 2 (creative) + 0 (refactor) + 0 (tests)
- Console summary: `CD Gate: FAIL — pipeline stopped early`

### Bugs found and fixed during validation

1. **SelectorGroupChat wrong speaker**: Selector chose `driveai_lead` instead of `creative_director`. Fix: added `creative_director:` task prefix + fallback scan in `extract_cd_rating`.
2. **Missing team.reset()**: No reset between Bug Hunter and CD passes — accumulated context caused issues. Fix: added `team.reset()` between Bug Hunter → CD and CD → Refactor.
3. **MaxMessageTermination(2) ineffective**: Setting `team._termination_condition` only changes the Team object attribute, not the already-initialized GroupChatManager. Fix: removed the workaround (10-message CD pass works fine for rating extraction).
