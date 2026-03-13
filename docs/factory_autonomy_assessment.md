# Factory Autonomy Assessment

Date: 2026-03-13
Based on: AskFin Premium Training Mode runs (Run 20260313_092851, 20260313_101710, 20260313_113101)

---

## A. What the Factory Can Do Autonomously

These capabilities work end-to-end without operator intervention:

| Capability | Status | Evidence |
|---|---|---|
| Spec-driven multi-agent generation | Stable | 10-message implementation pass produces structured Swift code |
| Bug Hunter review pass | Stable | Correctly identified missing View layer, duplicate files, crash risks |
| Creative Director advisory + soft gate | Stable | Rating extraction works, fail-open default, gate stops pipeline on "fail" |
| UX Psychology review pass | Stable | Behavioral science findings grounded in named principles |
| Refactor pass | Stable | Identifies duplication, naming issues, structural problems |
| Test generation pass | Stable | Produces test fixtures and case structures |
| Fix execution pass | Stable | Attempts to remediate findings from Bug Hunter + Refactor |
| Factory knowledge injection | Stable | Deterministic: type filter + product_type filter + confidence sort + cap at 5 |
| Knowledge proposal generation | Stable | Extracts learnings from CD/Bug/Refactor messages, saves to proposals/ |
| Rate limit retry | Stable | 65s/130s/195s backoff, 3 retries, prevented total failure on Haiku runs |
| Delivery export | Stable | Sprint report, run manifest, delivery package all generated per run |
| Git auto-commit | Stable | Commits + pushes after each run |
| team.reset() between passes | Stable | Prevents context accumulation across review passes |
| Implementation summary for reviewers | Stable | 2-6k char summary carried forward after team.reset() |

---

## B. What Still Depends on a Lead/Operator

These steps required manual intervention in every Training Mode run:

### B1. File Extraction Aborts

**Problem:** `MAX_FILES_PER_RUN = 10` in code_extractor.py. Feature-level tasks generate 15-35 files. When exceeded, extraction aborts entirely — zero files saved.

**Evidence:**
- Run 1 (Haiku): 20 files detected → aborted
- Run 2 (Sonnet): Implementation saved 7 files, Fix pass generated 35 → aborted
- Run 3 (Sonnet focused): Implementation saved 6 files, Fix pass generated 15 → aborted

**Operator action required:** Read logs, write Python script to extract code blocks, manually save to correct paths.

### B2. Subfolder Classification Is Flat

**Problem:** `SUBFOLDER_MAP` only knows 4 folders: `Views/`, `ViewModels/`, `Services/`, `Models/`. Agent output uses nested paths like `Views/Training/QuestionCardView.swift` or `Views/SkillMap/SkillMapView.swift`. Extractor flattens these to `Views/QuestionCardView.swift`.

**Evidence:** Run 3 saved `Views/AnswerRevealView.swift` instead of `Views/Training/AnswerRevealView.swift`.

**Operator action required:** Move files to correct subdirectories after extraction.

### B3. No Truncation Detection

**Problem:** Pipeline exits with status "success" even when generated files are incomplete. A file cut off mid-function (e.g., TrainingSessionViewModel ending at line 34) is saved without warning.

**Evidence:**
- Run 2: TrainingSessionViewModel truncated at `progressText` computed property
- Run 2: AnswerRevealView truncated at line 108
- Run 2: TrainingSessionView truncated at line 64
- Run 3: SkillMapView TopicCell truncated at `.strokeB`

**Operator action required:** Read every generated file, identify truncation, find better version in logs or re-run.

### B4. No Completion Verification

**Problem:** No check that the set of generated files matches the task requirements. Pipeline cannot compare "spec says 10 files" vs "extractor saved 7 files" and flag the gap.

**Evidence:** Run 2 generated 7 files (all Models + 1 ViewModel). Zero Views, zero Services. Pipeline reported success.

**Operator action required:** Compare file manifest against spec, identify missing components, run targeted follow-up.

### B5. No Cross-Run Artifact Merging

**Problem:** Each run starts fresh. Run 2 generated Models, Run 3 generated Views, but no system merges them. The `generated_code/` directory is cleaned at the start of each run.

**Evidence:** Operator had to write a Python script that:
1. Extracted code blocks from Run 2 log (22k lines)
2. Extracted code blocks from Run 3 log
3. Compared versions by length (longer = more complete)
4. Saved best version of each file to `projects/askfin_premium/generated/`

**Operator action required:** Manual merge script per run.

### B6. No Project-Aware Output Routing

**Problem:** `ProjectIntegrator` hardcodes target as `DriveAI/` (the MVP Xcode project). AskFin Premium output should go to `projects/askfin_premium/generated/`. No way to configure output path per run.

**Evidence:** Used `--approval off` to prevent integration, then manually copied files.

**Operator action required:** Disable integration, manually copy to correct project directory.

### B7. Log-Based Recovery Is Manual

**Problem:** When extraction aborts, the generated code still exists in the log file (20k+ lines). Recovering it requires regex parsing of markdown code blocks with path headers.

**Evidence:** Operator wrote 2 extraction scripts, found 57 Swift code blocks in Run 2 log, 64 in Run 3 log.

**Operator action required:** Write and run custom extraction scripts per failed run.

---

## C. Why This Is a Problem

### C1. File Chaos

Without automated placement, files end up in wrong directories, with wrong names, or not at all. The AskFin Premium run required 3 pipeline runs + 2 extraction scripts + 2 manual file completions to produce 31 files. A human had to make ~15 decisions about which version of which file to keep.

### C2. Hidden Failure Modes

The pipeline reports "success" for runs that produced zero usable output. Exit code 0 with "Swift files saved: 0" is a silent failure that only an experienced operator would catch. A new user would assume the run worked.

### C3. Non-Deterministic Output Volume

The same task prompt produces 7 files on one run and 35 on another, depending on which agents respond and how the SelectorGroupChat routes messages. The extraction limit is a static number that cannot adapt.

### C4. Scaling Impossibility

If the factory needs to generate 5 features for AskFin Premium (Training Mode, Exam Simulation, Progress Dashboard, Skill Map Detail, Motivational System), each requiring 2-3 runs + manual recovery, that is 10-15 operator-attended pipeline runs. This does not scale.

### C5. Knowledge Loss

Truncated files contain partial implementations that are lost. The fix pass often generates the complete version, but if extraction aborts, the complete version exists only in a 600KB log file that will eventually be archived or deleted.

---

## D. Maturity Rating

### Rating: Semi-Autonomous

| Level | Description | Factory Status |
|---|---|---|
| Prototype | Generates code, requires full manual handling | Past this |
| **Semi-Autonomous** | **Generates + reviews autonomously, but artifact handling is manual** | **Current** |
| Operationally Autonomous | Full pipeline including extraction, placement, verification, recovery | Target |
| Production-Ready | Reliable enough for unattended multi-feature generation | Future |

The factory's **generation and review layers** are at "Operationally Autonomous" quality. The **operations layer** (extraction, placement, verification, recovery) is at "Prototype" quality. The overall rating is determined by the weakest link.

---

## Summary

| Dimension | Rating |
|---|---|
| Agent quality | Strong — Sonnet produces well-structured, spec-aligned code |
| Review quality | Strong — Bug Hunter, CD, UX Psych all produce actionable findings |
| Knowledge system | Good — Injection + proposal loop working |
| Extraction | Weak — Static limit, flat classification, no truncation detection |
| Placement | Weak — Hardcoded target, no project routing |
| Verification | Missing — No completeness check |
| Recovery | Missing — No automated log recovery |
| **Overall** | **Semi-Autonomous** |
