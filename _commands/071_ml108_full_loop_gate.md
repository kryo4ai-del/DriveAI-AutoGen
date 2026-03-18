# 071 Ml108 Full Loop Gate

**Status**: pending
**Erstellt**: 2026-03-18
**Quelle**: Prompt Pilot (automatisch)

## Auftrag

# mac-driveai-ml108-full-loop-gate.md

Goal:
Expand the AskFin golden acceptance suite so the complete insight-to-action loop becomes part of the protected baseline.

Prompt ist für Mac

Task:
Inspect the current golden gate/XCUITest suite and integrate the smallest coherent acceptance check that protects the validated full loop:
Exam -> Result -> Drilldown -> "Jetzt üben" -> Training -> Beenden.

Current confirmed state:
- Full insight-to-action loop validated
- XCUITest passed
- Build SUCCEEDED
- one flaky CTA timing issue already fixed

Important:
Do not start another generation/autonomy run.
Do not broaden into new feature work.
Do not redesign the flow architecture.
The goal is to convert the newly proven full loop into a protected golden gate.

Focus especially on:
- the smallest reliable acceptance slice for the full loop
- whether an existing XCUITest can be extended or a new one is cleaner
- keeping the implementation minimal, explicit, and reusable
- preserving the fully green protected baseline

Required checks:
1. Inspect current golden gate/XCUITest coverage around this loop.
2. Define the smallest coherent acceptance gate for the full loop.
3. Implement or extend the relevant automated test coverage.
4. Run the expanded gate/test path if practical.
5. Record whether:
   - the new gate works,
   - the full baseline remains green,
   - or a concrete blocker appears.
6. If a blocker appears, isolate the first concrete blocker exactly.
7. End with one single next recommended step.

Expected report:
1. Current gate/test coverage inspected
2. Full-loop acceptance slice chosen
3. Exact automated coverage added or extended
4. Gate/test run outcome
5. Any blockers found
6. Interpretation of whether remaining issues are test/gate/flow-related
7. Single next recommended step

## Nach Abschluss

1. Ergebnis in `_commands/071_ml108_full_loop_gate_result.md`
2. `git add -A && git commit -m "ml108_full_loop_gate: execute command 071" && git push`
