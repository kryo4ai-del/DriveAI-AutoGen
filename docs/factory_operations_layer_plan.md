# Factory Operations Layer Plan

Date: 2026-03-13
Depends on: docs/factory_autonomy_assessment.md

---

## Purpose

The Operations Layer bridges the gap between "agents generated code" and "code is in the right place, complete, and verified." It replaces the manual operator steps documented in the autonomy assessment.

---

## Proposed Components

### 1. output_integrator

**Purpose:** Replace the static `SUBFOLDER_MAP` classification with path-aware file placement that respects agent-specified paths.

**Why needed:** The code extractor currently maps all Views to `Views/`, ignoring agent output like `Views/Training/QuestionCardView.swift`. This forces manual file relocation after every feature run.

**Type:** Module (extend existing `code_extractor.py`)

**Inputs:**
- Agent messages containing Swift code blocks
- Path hints from code block headers (e.g., `### \`Views/Training/QuestionCardView.swift\``)
- Target project directory (configurable per run)

**Outputs:**
- Files saved to correct nested paths
- Manifest of saved files with full paths

**Key changes:**
1. Parse path from markdown header above code block (already present in agent output)
2. Fall back to SUBFOLDER_MAP only when no header path is found
3. Add `--output-dir` CLI flag (default: `generated_code/`, override for premium: `projects/askfin_premium/generated/`)
4. Make `MAX_FILES_PER_RUN` template-aware: `feature` → 30, `screen` → 15, `service` → 10

**Complexity:** Low — extends existing module, no new dependencies.

---

### 2. completion_verifier

**Purpose:** After extraction, compare what was generated against what was requested. Flag gaps before the pipeline reports success.

**Why needed:** Pipeline currently reports "success" with 0 files saved. The operator discovered missing Views only by manually reading the sprint report. This is the most dangerous silent failure mode.

**Type:** Module (new, called at end of `_run_pipeline` in main.py)

**Inputs:**
- Task prompt (contains component list)
- Template type
- List of saved files (from extractor)
- Implementation summary

**Outputs:**
- Completeness report: `{"requested": 10, "generated": 7, "missing": ["SessionSummaryView", "SkillMapView"], "truncated": []}`
- Console warning if completeness < 80%
- `run_completeness` field in run_manifest.json

**Detection logic:**
1. Extract component names from task prompt (regex: numbered list items, backtick-quoted names)
2. Match against saved file names (fuzzy: `SessionSummaryView` matches `SessionSummaryView.swift`)
3. For each saved file: check if it ends with a closing brace `}` at expected nesting depth (truncation proxy)

**Complexity:** Medium — new module, but logic is straightforward string matching.

---

### 3. recovery_runner

**Purpose:** When the completion_verifier detects missing or truncated files, automatically trigger a targeted follow-up run.

**Why needed:** The operator currently reads the completion gap, writes a new task prompt focused on missing files, and re-runs the pipeline manually. This is the most time-consuming manual step.

**Type:** Background workflow (triggered by completion_verifier, runs autonomously)

**Inputs:**
- Missing file list from completion_verifier
- Original task prompt
- Implementation summary from the original run
- Existing generated files (as API context for the follow-up)

**Outputs:**
- Additional generated files placed into the same output directory
- Updated completeness report

**Behavior:**
1. If completeness >= 80%: skip (good enough, minor gaps can wait)
2. If completeness < 80%: build a focused recovery prompt listing only missing components + existing API surface
3. Run implementation pass only (no full pipeline — just generate the missing code)
4. Extract and merge into existing output
5. Re-run completion_verifier

**Guard:** Maximum 1 recovery attempt per run. If recovery also fails, log the gap and let the operator decide.

**Complexity:** High — orchestrates a sub-run, needs careful state management. Should be implemented last.

---

### 4. artifact_normalizer

**Purpose:** Clean up extraction artifacts — remove reviewer comments embedded in code, fix truncated closing braces, normalize file structure.

**Why needed:** Agent output sometimes contains reviewer comments (e.g., `[reviewer]\n# Code Review:...`) embedded after truncation points. These end up in saved files and break compilation.

**Type:** Module (post-processing step after extraction)

**Inputs:**
- Saved Swift files

**Outputs:**
- Cleaned Swift files (same paths)
- Log of modifications made

**Operations:**
1. Remove lines starting with `[agent_name]` (reviewer leakage)
2. Remove markdown headers (`# `, `## `, `### `) that leaked into code
3. Check brace balance — if unbalanced, append closing braces with `// auto-closed` comment
4. Remove trailing markdown (everything after last `}` at depth 0)

**Complexity:** Low — regex-based post-processing, stateless.

---

### 5. workspace_manager

**Purpose:** Manage per-project output directories so the factory can generate for multiple projects without path conflicts.

**Why needed:** `ProjectIntegrator` hardcodes `DriveAI/` as the target. AskFin Premium needs `projects/askfin_premium/generated/`. Future projects need their own directories.

**Type:** Module (replaces hardcoded paths in project_integrator.py)

**Inputs:**
- Project ID (from `--project` CLI flag or task metadata)
- Project registry (`factory/projects/project_registry.json`)

**Outputs:**
- Resolved output path for the current run
- Directory creation if needed

**Logic:**
1. If `--project askfin_premium` → output to `projects/askfin_premium/generated/`
2. If `--project askfin` → output to `DriveAI/` (legacy MVP behavior)
3. If no project specified → output to `generated_code/` (current default)

**Complexity:** Low — path resolution, no complex logic.

---

### 6. patch_synthesizer

**Evaluation: NOT RECOMMENDED at this stage.**

A patch_synthesizer would diff truncated files against log-recovered versions and produce patches. However:
- The root cause (truncation) should be fixed by increasing message limits or splitting tasks
- Log recovery should be handled by recovery_runner, not a separate patching system
- Adding a patch layer on top of broken extraction adds complexity without fixing the source

**Recommendation:** Defer indefinitely. Fix truncation at the source (completion_verifier + recovery_runner).

---

## Component Priority Matrix

| Component | Impact | Complexity | Blocks Others | Priority |
|---|---|---|---|---|
| output_integrator | High | Low | Yes (everything depends on correct file placement) | P0 |
| artifact_normalizer | Medium | Low | No | P0 |
| completion_verifier | High | Medium | Yes (recovery_runner depends on it) | P1 |
| workspace_manager | Medium | Low | No (workaround: --approval off + manual copy) | P1 |
| recovery_runner | High | High | No | P2 |
| patch_synthesizer | Low | Medium | No | Deferred |

---

## What Should Remain Manual (For Now)

1. **Model selection per run** — Operator chooses Haiku vs Sonnet based on task complexity. Automating this requires cost/quality tradeoffs that need more data.

2. **Task prompt design** — Writing good task prompts is a creative act. The spec already provides the template, but the operator still decides granularity.

3. **Quality judgment** — The CD gate and UX Psychology pass are advisory. Final quality approval before shipping to Xcode remains a human decision.

4. **Run scheduling** — When to run, how many retries, which features to prioritize. This is product management, not factory operations.
