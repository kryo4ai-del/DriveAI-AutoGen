# Operations Layer Integration

Date: 2026-03-13
Module: `main.py` (modified)
Depends on: Output Integrator, Completion Verifier, Recovery Runner

---

## When the Operations Layer Runs

The operations layer runs **automatically after every single-run pipeline execution** when the `--project` flag is provided:

```bash
python main.py "Build feature X" --env-profile standard --project askfin_premium
```

It does NOT run for:
- `--queue-run-all` (batch queue runs)
- `--pack` (task pack runs)
- List/summary commands
- If `--no-ops-layer` is set

---

## What Each Component Does

| Step | Component | Purpose |
|---|---|---|
| 1 | **Output Integrator** | Collects artifacts from generated_code/, logs, exports. Normalizes paths. Writes best version of each file. |
| 2 | **Completion Verifier** | Compares spec expectations against actual output. Reports missing/incomplete files. Assigns health status. |
| 3 | **Recovery Runner** | If health is INCOMPLETE, builds a focused prompt and re-runs the pipeline for missing files only. |
| 4 | **Re-integrate + Re-verify** | After recovery, runs Output Integrator and Completion Verifier again to update the health status. |

---

## What Triggers Recovery

| Health Status | Action |
|---|---|
| `COMPLETE` | Stop. All expected files present. |
| `MOSTLY_COMPLETE` | Stop. >= 80% complete, acceptable. |
| `INCOMPLETE` | Trigger Recovery Runner (1 attempt). |
| `FAILED` | Stop. Too little output for recovery to help. |

---

## Why Only One Recovery Attempt

1. **Cost control** — each recovery run consumes API tokens (Sonnet-level).
2. **Diminishing returns** — if the first recovery fails, the issue is likely structural (bad spec parsing, model limitation), not transient.
3. **Loop prevention** — recursive recovery could cascade indefinitely.
4. **Operator safety net** — if one recovery isn't enough, the operator should inspect the completion report and decide the next step.

---

## How to Disable the Operations Layer

```bash
# Skip the entire operations layer
python main.py "Build feature X" --project askfin_premium --no-ops-layer

# Without --project, the operations layer doesn't run either
python main.py "Build feature X" --env-profile standard
```

Use `--no-ops-layer` when:
- Debugging pipeline issues
- Running quick tests
- The operations layer itself has a bug
- You want raw pipeline output without post-processing

---

## CLI Flags

| Flag | Purpose |
|---|---|
| `--project <name>` | Target project for operations layer (e.g. `askfin_premium`). Required to enable ops layer. |
| `--no-ops-layer` | Skip Output Integrator, Completion Verifier, and Recovery Runner entirely. |

---

## Execution Flow

```
python main.py "task" --project askfin_premium --env-profile standard

Pipeline Run (existing behavior, unchanged)
    |
    v
Git Auto-Commit (existing behavior, unchanged)
    |
    v
Operations Layer (new, only if --project is set)
    |
    +-- Output Integrator (collect + normalize + write)
    |
    +-- Completion Verifier (expected vs actual)
    |
    +-- if INCOMPLETE:
    |       Recovery Runner (focused re-run)
    |       Output Integrator (pass 2)
    |       Completion Verifier (pass 2)
    |
    +-- Print Operations Layer Summary
```

---

## Error Handling

If the operations layer throws an exception, it is caught and logged. The pipeline result is **not affected** — the original run output is preserved regardless of operations layer success or failure.

```
[OpsLayer] Error: <error message>
[OpsLayer] Operations layer failed — pipeline result is unaffected.
```
