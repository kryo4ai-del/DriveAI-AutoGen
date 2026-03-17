# 061 Quarantine Cleanup

**Status**: pending
**Erstellt**: 2026-03-17
**Quelle**: Prompt Pilot (automatisch)

## Auftrag

Goal:
Inspect the quarantined AskFin files and perform a first controlled cleanup pass.

Task:
Inspect the current quarantined file set and classify each item:
- delete
- rehabilitate
- keep quarantined
- extract useful fragment later

Then perform the safest high-confidence cleanup actions and verify that the protected baseline remains green.

Important:
Do not start another generation/autonomy run.
Do not broaden into major feature work.
Focus on controlled quarantine cleanup, not a big rewrite.

## Nach Abschluss

1. Ergebnis in `_commands/061_quarantine_cleanup_result.md`
2. `git add -A && git commit -m "quarantine_cleanup: execute command 061" && git push`
