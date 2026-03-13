# Output Integrator

Module: `factory/operations/output_integrator.py`
Date: 2026-03-13
Status: Step 1 of Operations Layer rollout

---

## Why It Exists

The factory pipeline generates Swift code through multi-agent conversations, but the extraction step (`code_extractor.py`) has several failure modes that require manual operator intervention:

| Failure Mode | What Happens | Frequency |
|---|---|---|
| **Silent success** | Pipeline reports "complete" but 0 files saved | Every feature run |
| **File limit abort** | Extraction aborts when >10 files detected | Every feature run |
| **Flat classification** | `Views/Training/X.swift` placed in `Views/X.swift` | Every run with nested paths |
| **Agent tag leakage** | `[reviewer]` or `[swift_developer]` in saved files | ~30% of runs |
| **Truncated files** | Files cut mid-function without closing braces | ~30% of runs |
| **Log-only artifacts** | Files exist in logs but not in generated_code/ | When extraction aborts |

The Output Integrator is a **post-run integration layer** that addresses these failures without modifying the pipeline itself.

---

## What It Does

### 1. Artifact Collection

Scans all known artifact sources:

- `generated_code/**/*.swift` — primary extraction output
- `logs/driveai_run_*.txt` — log files containing embedded code blocks
- `delivery/exports/**/` — pipeline export directories
- `projects/<project>/generated/` — existing output (for merge comparison)

### 2. Log Extraction

Detects file headers in logs:

```
### `Views/Training/QuestionCardView.swift`

```swift
import SwiftUI
struct QuestionCardView: View { ... }
```​
```

Extracts the code block associated with each header. When the same file appears multiple times in a log, **keeps the last occurrence** (most refined version).

### 3. Content Normalization

Removes artifacts that shouldn't be in Swift files:

- Agent name tags: `[reviewer]`, `[swift_developer]`, `[bug_hunter]`
- Leaked markdown headers: `# Code Review:`, `## Implementation`
- Trailing markdown after the last balanced closing brace

### 4. Path Normalization

Uses **deterministic rules** (not AI inference) to place files correctly:

| Filename Pattern | Target Directory |
|---|---|
| `*SessionView`, `*CardView`, `*BriefView`, `*SummaryView`, `RevealDisplayModel` | `Views/Training/` |
| `*SkillMapView` | `Views/SkillMap/` |
| `*ViewModel`, `DomainSection`, `RevealCopy`, `AdaptiveQueueBuilder` | `ViewModels/` |
| `*Service`, `*Protocol`, `PersistenceStore` | `Services/` |
| `Mock*`, `TestFixtures` | `Tests/Helpers/` |
| Everything else | `Models/` |

Rules are checked in order — first match wins. New projects extend the rules list.

### 5. Version Selection

When multiple versions of the same file exist (from different sources), selects the best:

1. **Longest** file (by character count)
2. File that **ends with `}`** (complete, not truncated)
3. File with the **most Swift structural keywords** (struct, class, func, etc.)

### 6. Safe Writing

- Creates directories as needed
- **Never overwrites a larger file with a smaller one**
- **Never overwrites a complete file with a truncated version**
- Skips identical content (no unnecessary writes)

### 7. Reporting

Produces a console summary and a JSON report:

```
projects/askfin_premium/integration_report_20260313_150000.json
```

---

## When to Run

Run the integrator **after every pipeline run**, before reviewing the output:

```bash
# Standard usage
python -m factory.operations.output_integrator --project askfin_premium

# Filter to a specific run's logs
python -m factory.operations.output_integrator --project askfin_premium --log-filter 20260313_101710

# Dry run — analyze without writing
python -m factory.operations.output_integrator --project askfin_premium --dry-run
```

### Pipeline Integration (Future)

The integrator is designed to be called from `main.py` after extraction:

```python
from factory.operations.output_integrator import OutputIntegrator

integrator = OutputIntegrator(project_name="askfin_premium")
report = integrator.run()

if report.files_written == 0:
    print("[WARNING] No files written — check integrator report")
```

This wiring is **not yet active** — the integrator currently runs standalone.

---

## Limitations

- Path normalization rules are project-specific (currently AskFin Premium). New projects need their own rules added to `PATH_NORMALIZATION_RULES`.
- Log extraction depends on the `### \`path/file.swift\`` header format. Logs without headers are not parsed.
- The integrator does not fix truncated files — it only **detects and reports** them. Automated recovery is planned for Step 4 (recovery_runner).
- Brace-balance checking is naive (counts `{` vs `}` without parsing strings/comments). Good enough for detection, not for auto-repair.
