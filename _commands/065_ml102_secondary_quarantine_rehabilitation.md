# 065 Ml102 Secondary Quarantine Rehabilitation

**Status**: pending
**Erstellt**: 2026-03-17
**Quelle**: Prompt Pilot (automatisch)

## Auftrag

# mac-driveai-ml102-secondary-quarantine-rehabilitation.md

Goal:
Inspect the remaining quarantined files, identify the next safest low-scope rehabilitation candidate, and rehabilitate it only if the change remains tightly bounded and baseline-safe.

Prompt ist für Mac

Task:
Inspect the remaining quarantined file set after `PriorityBadgeView` rehabilitation, rank the candidates by safety/boundedness, choose the safest next rehabilitation target, and rehabilitate it only if the required fix set is small and does not endanger the protected baseline.

Current confirmed state:
- `PriorityBadgeView` rehabilitation succeeded
- Build SUCCEEDED
- quarantine debt reduced from 11 -> 10 files
- `ReadinessService.swift` correctly remains quarantined as unsafe
- protected baseline is green

Important:
Do not start another generation/autonomy run.
Do not broaden into a multi-file rehab sweep.
Do not force rehabilitation if the next candidate is not truly low-risk.
Do not introduce core type/model refactors.
The goal is one controlled, evidence-based next rehab step.

Focus especially on:
- which remaining quarantined file is the safest next candidate
- how bounded the required fix set is
- whether the file can be restored without changing core active contracts
- whether full rehabilitation, partial extraction, or keep-quarantined is safest
- preserving the fully green protected baseline

Required checks:
1. Inspect the remaining quarantined files.
2. Rank or summarize the strongest rehab candidates by safety.
3. Choose the safest next candidate and justify why.
4. Decide:
   - full rehabilitation
   - partial extraction
   - keep quarantined
5. If safe, implement the smallest bounded fix set.
6. Run build and golden gates afterward if practical.
7. Record whether:
   - the file is now safely active,
   - the baseline remains green,
   - quarantine debt decreased,
   - or a concrete blocker appeared.
8. If unsafe, explicitly justify keeping it quarantined.
9. End with one single next recommended step.

Expected report:
1. Remaining quarantine inventory summary
2. Candidate ranking / selection
3. Decision (rehabilitate / partial / keep)
4. Changes made (if any)
5. Build/gate outcome
6. Remaining quarantine debt summary
7. Risks or blockers
8. Single next recommended step

## Nach Abschluss

1. Ergebnis in `_commands/065_ml102_secondary_quarantine_rehabilitation_result.md`
2. `git add -A && git commit -m "ml102_secondary_quarantine_rehabilitation: execute command 065" && git push`
