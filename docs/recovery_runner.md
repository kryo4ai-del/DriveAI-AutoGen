# Recovery Runner

Module: `factory/operations/recovery_runner.py`
Date: 2026-03-13
Status: Step 4 of Operations Layer rollout
Depends on: Output Integrator (Step 1), Completion Verifier (Step 2)

---

## Why It Exists

After a factory run, the Completion Verifier often reports missing or incomplete files. Previously, the operator had to:

1. Read the completion report
2. Identify which files are missing
3. Write a focused task prompt listing only the gaps
4. Include context from existing generated code
5. Re-run the pipeline manually with the right flags

This was the most time-consuming manual step (~20 min per recovery). The Recovery Runner automates steps 1-4 completely and makes step 5 a single command.

---

## How It Uses Completion Reports

The runner reads `factory/reports/completion/<project>_completion.json` and extracts:

- `missing_files` — files expected by spec but not found in output
- `incomplete_files` — files found but truncated or broken
- `health` — project health status (complete/mostly_complete/incomplete/failed)

If health is `complete`, recovery exits cleanly with "No recovery needed."

---

## How Recovery Targets Are Selected

1. All `missing_files` become recovery targets with reason `missing`
2. All `incomplete_files` become recovery targets with reason `incomplete`
3. Duplicates are removed
4. Each target is classified by category (Views, ViewModels, Services, Models, Tests) using the same normalization rules as the Output Integrator
5. Each target gets a canonical `target_dir` for correct file placement

---

## Dry-Run vs Execution Mode

### Dry-Run (default, safe)

```bash
python -m factory.operations.recovery_runner --project askfin_premium --dry-run
```

Shows:
- Recovery targets with reasons
- Full recovery prompt preview
- Exact command to execute manually
- Saves prompt file for manual use

**No pipeline execution happens.**

### Execution Mode

```bash
python -m factory.operations.recovery_runner --project askfin_premium --execute
```

Does everything in dry-run, plus:
- Launches the factory pipeline via `main.py --task-file <prompt>`
- Uses `--env-profile standard` (Sonnet), `--approval off`, `--no-cd-gate`
- Streams output to console
- Records exit code

**Safety guards:**
- 10-minute timeout
- Single recovery attempt (no retry loops)
- Prompt is saved before execution (reviewable)

---

## Why This Is Safer Than Manual Recovery

| Manual Recovery | Recovery Runner |
|---|---|
| Operator writes prompt from memory | Prompt built deterministically from completion report |
| May forget which files are missing | Uses exact missing_files list |
| May include wrong context | Compact context from actual file inventory |
| Different flags each time | Consistent CLI flags every run |
| No record of what was attempted | Full summary saved as JSON |
| May accidentally regenerate existing files | Prompt explicitly excludes existing files |

---

## Output Files

| File | Purpose |
|---|---|
| `factory/reports/recovery/<project>_recovery_prompt.txt` | The generated recovery prompt |
| `factory/reports/recovery/<project>_recovery_summary.json` | Execution summary with targets, command, result |

---

## Full Pipeline Flow

```
Pipeline Run
    |
Output Integrator  (collect, normalize, write)
    |
Completion Verifier  (expected vs actual)
    |
    if health != complete:
    |
Recovery Runner  (build prompt, execute)
    |
Output Integrator  (re-integrate recovery output)
    |
Completion Verifier  (re-verify)
```

---

## Limitations

- Maximum 1 recovery attempt per invocation (no retry loops)
- Recovery uses the full pipeline (all 7 passes), not a minimal implementation-only pass
- Does not yet integrate directly with Output Integrator post-recovery (manual re-run needed)
- Recovery prompt quality depends on the Completion Verifier correctly identifying gaps
