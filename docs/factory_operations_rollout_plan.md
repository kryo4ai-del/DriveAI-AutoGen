# Factory Operations Layer — Rollout Plan

Date: 2026-03-13
Depends on: docs/factory_operations_layer_plan.md

---

## Rollout Philosophy

Each step must be **independently useful** — no step depends on a later step being completed. If we stop after any step, the factory is strictly better than before.

Validation project: **AskFin Premium Training Mode** (already generated, known failure modes documented).

---

## Step 1: output_integrator + artifact_normalizer (P0)

**What:** Extend `code_extractor.py` to parse path headers from agent output and place files into nested directories. Add post-extraction cleanup (reviewer leakage, brace balancing, trailing markdown).

**Changes:**
- `code_extractor.py`: Parse `### \`Views/Training/QuestionCardView.swift\`` headers → use as output path
- `code_extractor.py`: Fall back to `SUBFOLDER_MAP` only when no header path found
- `code_extractor.py`: Make `MAX_FILES_PER_RUN` template-aware: `feature` → 30, `screen` → 15, `service` → 10
- New: `code_generation/artifact_normalizer.py` — called after extraction, cleans all saved `.swift` files
- `main.py`: Call `artifact_normalizer.clean()` after `code_extractor.extract()`

**Validation:**
1. Re-run Training Mode pipeline with `--env-profile standard`
2. Check: files land in `Views/Training/`, `Views/SkillMap/` (not flat `Views/`)
3. Check: no `[reviewer]` or `[swift_developer]` tags in any saved file
4. Check: all files end with balanced braces

**Success criteria:** Zero manual file relocation needed. Zero agent-tag leakage in output.

**Risk:** Low. Extends existing module, no new dependencies.

---

## Step 2: completion_verifier (P1)

**What:** After extraction, compare generated files against the task prompt. Report gaps before the pipeline declares success.

**Changes:**
- New: `code_generation/completion_verifier.py`
- `main.py`: Call `completion_verifier.verify()` at end of `_run_pipeline`, before writing run_manifest
- `run_manifest.json`: Add `run_completeness` field with `requested`, `generated`, `missing`, `truncated` counts

**Validation:**
1. Run Training Mode pipeline
2. Deliberately reduce `MAX_FILES_PER_RUN` to 5 to force incomplete extraction
3. Check: completion_verifier reports missing files by name
4. Check: `run_manifest.json` contains accurate completeness data
5. Restore limit, run again — completeness should be >= 80%

**Success criteria:** Pipeline never reports "success" with 0 files saved. Missing files are named explicitly.

**Risk:** Medium. New module, but logic is string matching — no external dependencies.

---

## Step 3: workspace_manager (P1)

**What:** Replace hardcoded output paths with project-aware directory resolution.

**Changes:**
- New: `factory/projects/project_registry.json` — maps project IDs to output paths
- New: `code_generation/workspace_manager.py` — resolves output path from `--project` flag
- `main.py`: Add `--project` CLI flag, pass resolved path to extractor
- `project_integrator.py`: Use workspace_manager instead of hardcoded `DriveAI/`

**Validation:**
1. Run with `--project askfin_premium` → files go to `projects/askfin_premium/generated/`
2. Run with `--project askfin` → files go to `DriveAI/` (legacy)
3. Run without `--project` → files go to `generated_code/` (current default)
4. Run two different projects back-to-back — no path conflicts

**Success criteria:** Multi-project support without manual `--output-dir` juggling.

**Risk:** Low. Path resolution only.

---

## Step 4: recovery_runner (P2)

**What:** When completion_verifier detects < 80% completeness, automatically trigger a focused follow-up run for missing files only.

**Changes:**
- New: `code_generation/recovery_runner.py`
- `main.py`: After completion_verifier, if completeness < 80%, invoke recovery_runner
- Recovery uses implementation pass only (no full 7-pass pipeline)
- Maximum 1 recovery attempt per run

**Validation:**
1. Run Training Mode with artificially limited context (force truncation)
2. Check: recovery_runner triggers automatically
3. Check: focused prompt contains only missing file names + existing API surface
4. Check: recovered files merge into same output directory
5. Check: updated completeness report reflects recovery

**Success criteria:** Operator no longer writes manual recovery prompts. Gap-to-recovery is fully automated.

**Risk:** High. Orchestrates a sub-run with state management. Must not loop or corrupt existing output. Implement last, test extensively.

---

## Step 5: Dynamic Model Routing (Future)

**What:** Wire the existing `model_router.py` into `TaskManager` so agents use task-appropriate models (Haiku for classification, Sonnet for generation, Opus for review).

**Not part of current rollout.** Listed here as the natural next step after Operations Layer is stable. Depends on:
- Cost data from multiple AskFin Premium runs
- Confidence that completion_verifier catches model-quality issues
- Token budget tooling (not yet designed)

---

## Implementation Order Summary

| Step | Component(s) | Complexity | Cumulative Value |
|---|---|---|---|
| 1 | output_integrator + artifact_normalizer | Low | Files land correctly, no cleanup needed |
| 2 | completion_verifier | Medium | Pipeline reports actual completeness |
| 3 | workspace_manager | Low | Multi-project without path conflicts |
| 4 | recovery_runner | High | Automated gap recovery |
| 5 | Dynamic Model Routing | Medium | Cost optimization (future) |

**Estimated operator intervention after each step:**
- After Step 1: No file relocation, no tag cleanup → saves ~30 min/run
- After Step 2: No silent failures → saves debugging time, prevents false confidence
- After Step 3: No manual path configuration → saves ~5 min/run
- After Step 4: No manual recovery prompts → saves ~20 min/run + eliminates the most complex manual step
