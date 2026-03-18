# 073 Ml110 Question Dataset

**Status**: pending
**Erstellt**: 2026-03-18
**Quelle**: Prompt Pilot (automatisch)

## Auftrag

# mac-driveai-ml110-question-dataset.md

Goal:
Introduce a real question dataset (JSON bundle) and integrate it into the existing system, replacing mock data.

Prompt ist für Mac

Task:
Design and integrate a JSON-based question dataset (200+ entries) and replace the current mock question provider.

Important:
Do not redesign architecture.
Reuse existing data flow.
Keep integration minimal and safe.

Focus:
- simple JSON schema
- loading mechanism
- replacing mock provider

Checks:
- questions load correctly
- flows still work
- baseline remains green

Expected:
1. Schema definition
2. Integration approach
3. Replacement of mock data
4. Build/gate result
5. Next step

## Nach Abschluss

1. Ergebnis in `_commands/073_ml110_question_dataset_result.md`
2. `git add -A && git commit -m "ml110_question_dataset: execute command 073" && git push`
