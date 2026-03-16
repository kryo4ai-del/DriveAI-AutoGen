# 051 Generalprobe Golden Gate

**Status**: pending
**Ziel**: Validiertes Generalprobe-Verhalten als Golden Gate schuetzen.

## Kontext

- Generalprobe runtime-validiert (Report 91-0)
- GeneralprobeRuntimeTests existiert (testGeneralprobeFlow PASSED)
- Golden Gates: 14/14 PASSED (Gates 1-8)

## Aufgabe

1. Inspiziere GoldenGateTests.swift — aktuelle Gates (1-8)
2. Fuege **Gate 9: Generalprobe** hinzu:
   - Generalprobe-Tab oeffnen
   - Pre-Start rendert
   - Simulation startet
   - Mindestens 1 Frage beantwortbar
   - Kein Crash
3. Fuehre Golden Gates aus: `cd projects/askfin_v1-1 && ./scripts/run_golden_gates.sh`
4. Bestaetige alle Gates gruen

## Constraints

- Kein neues Feature
- Kein Architektur-Change
- Nur Gate hinzufuegen + validieren

## Report

Schreibe Ergebnis in: `_commands/051_generalprobe_gate_result.md`
Schreibe Report in: `DeveloperReports/CodeAgent/92-0_Generalprobe Gate Report.md`

Commit-Message: `test: add generalprobe golden gate (Report 92-0)`
