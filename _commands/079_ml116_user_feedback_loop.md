# 079 Ml116 User Feedback Loop

**Status**: pending
**Erstellt**: 2026-03-18
**Quelle**: Prompt Pilot (automatisch)

## Auftrag

# mac-driveai-ml116-user-feedback-loop.md

Goal:
Introduce a minimal user feedback signal (difficulty/confidence) into the adaptive learning system.

Prompt ist für Mac

Task:
Add a simple feedback mechanism (e.g. easy / medium / hard) after answering a question and integrate it into the existing learning signal model.

Important:
Do not redesign the system.
Reuse TopicCompetence.
Keep logic minimal.

Checks:
- feedback captured
- affects prioritization
- build remains green

Expected:
1. Feedback mechanism
2. Integration logic
3. Effect on selection
4. Build result
5. Next step

## Nach Abschluss

1. Ergebnis in `_commands/079_ml116_user_feedback_loop_result.md`
2. `git add -A && git commit -m "ml116_user_feedback_loop: execute command 079" && git push`
