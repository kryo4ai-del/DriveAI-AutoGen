# Factory Run Failure Modes — Observed Checklist

Date: 2026-03-13
Source: AskFin Premium Training Mode runs (2026-03-13)

---

## How to Use

After every factory run, walk through this checklist. Each failure mode has been observed at least once in production runs.

---

## Extraction Failures

| # | Failure Mode | Symptom | Root Cause | Detection | Fix (Current) | Fix (Planned) |
|---|---|---|---|---|---|---|
| E1 | **File limit abort** | `run_manifest.json` shows 0 files saved despite agent output containing code | `MAX_FILES_PER_RUN` exceeded (default: 10, features generate 15-35) | Check `files_saved` in manifest | Temporarily increase limit before run | Template-aware limits (Step 1) |
| E2 | **Flat directory classification** | All Views in `Views/`, losing `Views/Training/` nesting | `SUBFOLDER_MAP` ignores agent path headers | Compare output structure to spec | Manual file relocation | output_integrator (Step 1) |
| E3 | **Agent tag leakage** | `[reviewer]` or `[swift_developer]` text inside .swift files | Code block extraction captures agent transition markers | Grep saved files for `\[.*_developer\]\|\[reviewer\]` | Manual cleanup | artifact_normalizer (Step 1) |
| E4 | **Markdown leakage** | `# Code Review:` or `### filename.swift` lines inside .swift files | Extraction boundary detection fails at truncation points | Grep for `^#` in .swift files | Manual cleanup | artifact_normalizer (Step 1) |

## Truncation Failures

| # | Failure Mode | Symptom | Root Cause | Detection | Fix (Current) | Fix (Planned) |
|---|---|---|---|---|---|---|
| T1 | **Mid-function truncation** | File ends abruptly without closing `}` | Agent hit message length limit | Check brace balance: `grep -c '{' file` vs `grep -c '}' file` | Manual completion from log | artifact_normalizer brace-close (Step 1) + recovery_runner (Step 4) |
| T2 | **Stub files** | File < 20 lines, contains only struct declaration and one TODO | Agent ran out of context, wrote placeholder | Check file size — stubs are typically < 300 bytes | Manual rewrite | completion_verifier flags (Step 2) + recovery_runner (Step 4) |
| T3 | **Duplicate definitions** | Same struct defined 3x across agent messages with different completeness | Multiple agents refine same file, extractor picks wrong version | Check log for duplicate filenames | Manual extraction — pick longest version | output_integrator: keep last occurrence per file |

## Pipeline Logic Failures

| # | Failure Mode | Symptom | Root Cause | Detection | Fix (Current) | Fix (Planned) |
|---|---|---|---|---|---|---|
| P1 | **Silent success with 0 output** | Pipeline reports "complete" but `generated/` is empty or near-empty | Extraction failed silently, no completeness check | Check file count post-run | Operator spot-check | completion_verifier (Step 2) |
| P2 | **Wrong model for task** | Haiku generates shallow stubs for complex feature | `dev` profile routes all agents to Haiku regardless of task complexity | Check `llm_profiles.json` active profile | Use `--env-profile standard` | Dynamic model routing (Step 5) |
| P3 | **Rate limit cascade** | All agents error within seconds, run produces nothing | Token rate limit (50k/min on Haiku) exceeded by accumulated context | Error messages in log: `rate_limit_error` | Switch to Sonnet (higher limits) | Token budget tracking (future) |
| P4 | **Selector agent confusion** | Agent produces content for wrong component or repeats another agent's work | SelectorGroupChat selects wrong next speaker | Review agent attribution in log | Re-run affected pass | Better agent descriptions + constrained selection (future) |

## Integration Failures

| # | Failure Mode | Symptom | Root Cause | Detection | Fix (Current) | Fix (Planned) |
|---|---|---|---|---|---|---|
| I1 | **Path conflicts across projects** | Files from different projects mixed in same output directory | Hardcoded output path in `project_integrator.py` | Check output dir before and after run | Use `--approval off` + manual copy | workspace_manager (Step 3) |
| I2 | **Stale files from previous run** | Old generated files persist alongside new ones | `_clean_generated_code()` only removes .swift from top-level `generated_code/` | Compare manifest to directory listing | Manual cleanup | workspace_manager handles per-run cleanup |

---

## Quick Post-Run Checklist

```
After every factory run, verify:

□ files_saved > 0 in run_manifest.json
□ File count matches expected range for template type
□ No [reviewer] / [swift_developer] tags in any .swift file
□ No markdown headers (# ) in any .swift file
□ All .swift files have balanced braces
□ No file < 300 bytes (stub detection)
□ Directory structure matches spec (nested, not flat)
□ No files from previous runs contaminating output
```

---

## Failure Frequency (from 3 observed runs)

| Failure | Run 1 (Haiku) | Run 2 (Sonnet) | Run 3 (Focused) |
|---|---|---|---|
| E1 File limit abort | ✗ | ✗ | — |
| E2 Flat directories | — | ✗ | ✗ |
| E3 Agent tag leakage | — | — | ✗ |
| T1 Mid-function truncation | — | ✗ | ✗ |
| T2 Stub files | — | — | ✗ |
| T3 Duplicate definitions | ✗ | — | — |
| P1 Silent success | ✗ | ✗ | — |
| P2 Wrong model | ✗ | — | — |
| P3 Rate limit cascade | ✗ | — | — |

**Key insight:** E1 (file limit) and P1 (silent success) are the most dangerous — they produce zero useful output with no warning. These are addressed by Steps 1 and 2 of the rollout plan.
