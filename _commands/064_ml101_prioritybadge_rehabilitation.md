# 064 Ml101 Prioritybadge Rehabilitation

**Status**: pending
**Erstellt**: 2026-03-17
**Quelle**: Prompt Pilot (automatisch)

## Auftrag

# mac-driveai-ml101-prioritybadge-rehabilitation.md

Goal:
Rehabilitate `PriorityBadgeView` from quarantine using the smallest safe fix set, then verify that the protected baseline remains green.

Prompt ist für Mac

Task:
Inspect `PriorityBadgeView` in quarantine, identify the reported 4 case-name mismatches, and determine whether the file can be safely rehabilitated into the active AskFin baseline with only a tightly bounded fix set.

Current confirmed state:
- `ReadinessService.swift` was correctly kept quarantined
- reason: 6 incompatible interfaces, 3+ active types would need to change
- protected baseline remains green
- next suggested rehab candidate: `PriorityBadgeView` (4 case-name fixes)

Important:
Do not start another generation/autonomy run.
Do not broaden into readiness-model refactors.
Do not change multiple active types unless absolutely unavoidable.
Do not force rehabilitation if the file is not actually safe.
The goal is a small, high-confidence rehabilitation decision and action pass.

Focus especially on:
- what the 4 case-name mismatches are
- whether they are the only blockers
- whether `PriorityBadgeView` can be restored without touching core active contracts
- whether full rehabilitation, partial extraction, or keep-quarantined is the safest outcome
- preserving the fully green protected baseline

Required checks:
1. Inspect `PriorityBadgeView` and identify the exact mismatch set.
2. Confirm whether the issue is truly limited to bounded case-name fixes.
3. Decide:
   - full rehabilitation
   - partial extraction
   - keep quarantined
4. If safe, implement the smallest bounded fix set.
5. Run build and golden gates afterward if practical.
6. Record whether:
   - the file is now safely active,
   - the baseline remains green,
   - or a concrete blocker appeared.
7. If unsafe, explicitly justify keeping it quarantined.
8. End with one single next recommended step.

Expected report:
1. File inspection summary
2. Exact mismatch set found
3. Decision (rehabilitate / partial / keep)
4. Changes made (if any)
5. Build/gate outcome
6. Risks or blockers
7. Single next recommended step

## Nach Abschluss

1. Ergebnis in `_commands/064_ml101_prioritybadge_rehabilitation_result.md`
2. `git add -A && git commit -m "ml101_prioritybadge_rehabilitation: execute command 064" && git push`
