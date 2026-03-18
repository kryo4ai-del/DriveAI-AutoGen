# 076 Ml113 Learning Signal Persistence

**Status**: pending
**Erstellt**: 2026-03-18
**Quelle**: Prompt Pilot (automatisch)

## Auftrag

# mac-driveai-ml113-learning-signal-persistence.md

Goal:
Persist and update minimal learning signals so adaptive selection improves across sessions.

Prompt ist für Mac

Task:
Introduce minimal persistence for topic-level signals (e.g., weakness score, lastSeen, coverage count), update them after sessions, and load them on app start.

Important:
Do not redesign architecture.
Reuse existing persistence layer if available.
Keep schema minimal.

Checks:
- signals persist across restarts
- adaptive selection changes after training
- no regressions
- build remains green

Expected:
1. Signal schema
2. Persistence approach
3. Update logic
4. Validation result
5. Next step

## Nach Abschluss

1. Ergebnis in `_commands/076_ml113_learning_signal_persistence_result.md`
2. `git add -A && git commit -m "ml113_learning_signal_persistence: execute command 076" && git push`
