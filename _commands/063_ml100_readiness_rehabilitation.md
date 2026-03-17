# 063 Ml100 Readiness Rehabilitation

**Status**: pending
**Erstellt**: 2026-03-17
**Quelle**: Prompt Pilot (automatisch)

## Auftrag

# mac-driveai-ml100-readiness-rehabilitation.md

Goal:
Rehabilitate `ReadinessService.swift` into the active AskFin baseline in a controlled and minimal way without destabilizing the protected system.

Prompt ist für Mac

Task:
Inspect `ReadinessService.swift` from quarantine and determine whether it can be safely rehabilitated into the active codebase.

Current confirmed state:
- Quarantine cleanup completed
- 10 files deleted, 11 retained
- `ReadinessService.swift` identified as top rehabilitation candidate (208 LOC, 6 references)
- Build SUCCEEDED
- Protected baseline is green

Important:
Do not start another generation/autonomy run.
Do not expand into new feature creation.
Do not redesign architecture.
Do not force full rehabilitation if unsafe.
The goal is a minimal, safe, high-confidence reintegration or explicit deferral.

Focus especially on:
- why `ReadinessService.swift` was originally quarantined
- which dependencies are missing or broken
- whether a minimal viable reintegration path exists
- whether partial extraction is safer than full restore
- preserving baseline stability at all costs

Required checks:
1. Inspect `ReadinessService.swift` and its references.
2. Identify why it was quarantined.
3. Decide:
   - full rehabilitation
   - partial extraction
   - keep quarantined
4. If safe, perform minimal rehabilitation or extraction.
5. Run build and golden gates if practical.
6. Record:
   - what was changed
   - whether it integrates cleanly
   - whether baseline remains green
7. If not safe, explicitly justify keeping it quarantined.
8. End with one single next recommended step.

Expected report:
1. File inspection summary
2. Original quarantine reason
3. Decision (rehabilitate / partial / keep)
4. Changes made (if any)
5. Build/gate outcome
6. Risks or blockers
7. Single next recommended step

## Nach Abschluss

1. Ergebnis in `_commands/063_ml100_readiness_rehabilitation_result.md`
2. `git add -A && git commit -m "ml100_readiness_rehabilitation: execute command 063" && git push`
