# Completion Verifier

Module: `factory/operations/completion_verifier.py`
Date: 2026-03-13
Status: Step 2 of Operations Layer rollout
Depends on: Output Integrator (Step 1)

---

## Why It Exists

The factory pipeline can report "success" even when critical files are missing. In the AskFin Premium Training Mode run, the pipeline completed with 0 files saved — no warning, no error. The operator only discovered the gap by manually reading the sprint report.

The Completion Verifier prevents this by comparing **what the spec asked for** against **what was actually generated**, and flagging any gaps before anyone assumes the output is ready.

---

## How Expected Files Are Determined

The verifier parses spec files deterministically (no LLM). It scans for:

1. **"Screens to Generate" tables** — the primary source. Extracts names from markdown table rows like `| \`TrainingSessionView\` | ... |`
2. **Backtick names with type suffixes** — `\`TrainingSessionViewModel\``, `\`TopicCompetenceService\``
3. **Numbered list items** — `1. TrainingSessionView — manages question flow`
4. **Explicit .swift filenames** — `TrainingSessionView.swift`
5. **Model definitions in code blocks** — `struct TopicCompetence`, `enum SessionType`

Standard library types (String, Int, Date, UUID, etc.) are excluded automatically.

### Adding New Specs

Place spec files as markdown in `projects/<project>/specs/`. The verifier reads all `*.md` files in that directory. No registration needed — just drop the file.

---

## How Completeness Is Checked

For each file in the generated output:

| Check | Result |
|---|---|
| File exists, >= 50 chars, ends with `}` | **complete** |
| File exists but missing closing brace | **incomplete** |
| File exists but < 50 chars or has agent tag leakage | **suspicious** |
| File expected by spec but not found | **missing** |

Folder structure is also verified — the verifier checks that `Models/`, `Services/`, `ViewModels/`, `Views/` exist and are non-empty.

---

## Project Health Status

| Status | Condition |
|---|---|
| **complete** | All expected files present and complete, no missing folders |
| **mostly_complete** | >= 80% complete, no critical folders missing (Views, Services, ViewModels) |
| **incomplete** | 40-79% complete, or critical files missing |
| **failed** | < 40% complete, or no usable output |

The health status is deterministic and rule-based — same input always produces same output.

---

## How This Prepares for Recovery Runner

The verifier's `missing_files` and `incomplete_files` lists are exactly what a future Recovery Runner needs to build targeted follow-up prompts. When recovery is implemented (Step 4), the flow will be:

```
Pipeline Run -> Output Integrator -> Completion Verifier
                                          |
                                     if health != complete:
                                          |
                                     Recovery Runner (future)
                                          |
                                     Re-verify
```

The verifier's JSON report at `factory/reports/completion/<project>_completion.json` is machine-readable for this purpose.

---

## Usage

```bash
# Standard verification
python -m factory.operations.completion_verifier --project askfin_premium

# Override directories
python -m factory.operations.completion_verifier \
    --project askfin_premium \
    --generated-dir projects/askfin_premium/generated \
    --specs-dir projects/askfin_premium/specs
```

### Programmatic Usage

```python
from factory.operations.completion_verifier import CompletionVerifier

verifier = CompletionVerifier(project_name="askfin_premium")
report = verifier.verify()

if report.health.value in ("incomplete", "failed"):
    print(f"Missing: {report.missing_files}")
    print(f"Incomplete: {report.incomplete_files}")
```

---

## Report Location

- Console: printed automatically
- JSON: `factory/reports/completion/<project>_completion.json`

Each verification overwrites the previous report for the same project (latest state is what matters).
