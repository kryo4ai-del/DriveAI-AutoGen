# Run Memory Module

Module: `factory/operations/run_memory.py`
Date: 2026-03-13
Status: Step 5 of Operations Layer rollout
Depends on: Completion Verifier (reads reports)

---

## What It Does

Records the outcome of every factory run to `factory/memory/run_history.json`. This allows the factory to identify recurring problems — files that are consistently missing or truncated across multiple runs.

**Run Memory is read-only against the pipeline.** It never modifies files, never affects pipeline execution, never triggers recovery. It only:
- Reads completion reports
- Writes JSON history
- Prints a summary

---

## Data Storage

| Path | Purpose |
|---|---|
| `factory/memory/run_history.json` | Persistent run history (append-only per project) |

### Record Structure

```json
{
  "run_id": "20260313_101710",
  "timestamp": "2026-03-13T10:17:10.123456",
  "status": "MOSTLY_COMPLETE",
  "completeness_pct": 84.2,
  "expected_files": 19,
  "actual_files": 53,
  "missing_files": ["LearningStreak.swift"],
  "truncated_files": ["TrainingSessionViewModel.swift"],
  "recovery_triggered": true
}
```

---

## Functions

| Function | Purpose |
|---|---|
| `record_run(project, completion_report)` | Build a run record from completion report dict, store it |
| `store_run_history(project, run_record)` | Append a record to the project's history in JSON |
| `load_run_history()` | Load full history from disk (returns `[]` if missing) |
| `summarize_run_history(project)` | Generate human-readable summary with recurring patterns |
| `print_summary(project)` | Print the summary to console |

---

## Summary Output

```
=======================================================
  Run Memory Summary
=======================================================
  Project:           askfin_premium
  Runs recorded:     3
  Latest status:     MOSTLY_COMPLETE
  Latest complete:   84%

  Recurring missing files:
    - LearningStreak.swift (3 runs)

  Recurring truncations:
    - TrainingSessionViewModel.swift (2 runs)

  Recovery triggered: 1 of 3 runs
=======================================================
```

---

## Integration in main.py

Runs automatically at the end of `_run_operations_layer()`, after the Operations Layer Summary:

```python
final_report = report if not recovery_attempted else report2
run_record = record_run(project_name, final_report.to_dict())
print_memory_summary(project_name)
```

Wrapped in try/except — memory errors never affect pipeline results.

---

## CLI Usage

```bash
# View run history summary for a project
python -m factory.operations.run_memory --project askfin_premium
```

---

## Recovery Detection

Run Memory checks if recovery was triggered by looking at `factory/reports/recovery/<project>_recovery_summary.json`. It only counts recovery as triggered if the summary file was written within the last 10 minutes (to avoid false positives from stale files).
