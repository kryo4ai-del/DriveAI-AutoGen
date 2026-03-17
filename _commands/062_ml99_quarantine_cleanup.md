# 062 Ml99 Quarantine Cleanup

**Status**: pending
**Erstellt**: 2026-03-17
**Quelle**: Prompt Pilot (automatisch)

## Auftrag

# mac-driveai-ml99-quarantine-cleanup.md

Goal:
Inspect the quarantined AskFin files and perform a first controlled cleanup/rehabilitation pass so the project reduces deferred structural debt without endangering the protected baseline.

Prompt ist für Mac

Task:
Inspect the current quarantined file set and classify each item into the smallest useful action category:
- delete
- rehabilitate
- keep quarantined
- extract useful fragment later

Then perform the safest high-confidence cleanup actions and verify that the protected baseline remains green.

Current confirmed state:
- MEMORY.md now documents the AskFin Mac baseline
- 4 pillars, 13 golden gates, 20 tests, persistence, insight-to-action loop, quarantine, and outside-scope boundaries are documented
- protected baseline is green

Important:
Do not start another generation/autonomy run.
Do not broaden into major feature work.
Do not try to rehabilitate everything at once.
Do not reintroduce risky quarantined code unless clearly justified.
The goal is a controlled quarantine cleanup/decision pass, not a big rewrite.

Focus especially on:
- which quarantined items are clearly dead/stale/duplicate
- which items have realistic rehabilitation value
- which items should remain quarantined intentionally
- avoiding ambiguity and keeping decisions explicit
- preserving the protected baseline and running the gates afterward if practical

Required checks:
1. Inspect the current quarantined file set.
2. Classify each item into:
   - delete
   - rehabilitate
   - keep quarantined
   - extract useful fragment later
3. Perform the safest high-confidence cleanup actions.
4. If practical, run the golden gate suite afterward.
5. Record:
   - what was deleted
   - what remains quarantined
   - what is a rehabilitation candidate
   - whether the baseline stayed green
6. If a blocker appears, isolate the first concrete blocker exactly.
7. End with one single next recommended step.

Expected report:
1. Quarantine inventory inspected
2. Classification summary
3. Cleanup actions taken
4. Golden gate outcome
5. Remaining quarantine debt summary
6. Any blockers found
7. Single next recommended step

## Nach Abschluss

1. Ergebnis in `_commands/062_ml99_quarantine_cleanup_result.md`
2. `git add -A && git commit -m "ml99_quarantine_cleanup: execute command 062" && git push`
