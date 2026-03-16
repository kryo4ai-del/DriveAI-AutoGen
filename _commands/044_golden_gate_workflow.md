# 044 Golden Gate Workflow Integration

**Status**: pending
**Ziel**: Golden Acceptance Suite als echte Promotion-Barriere in den DriveAI-AutoGen Workflow integrieren.

## Kontext

- 12/12 Tests PASSED, 5 Golden Gates voll automatisiert
- AskFin Baseline ist durch XCUITests geschuetzt
- Aktuell: Tests existieren, aber nichts erzwingt deren Ausfuehrung vor Promotion

## Aufgabe

1. Inspiziere aktuellen Build/Test/Workflow-Pfad um AskFin
2. Definiere wo Golden Gates als Promotion-Barriere sitzen:
   - Nach jedem Mac-seitigen Code-Fix (vor Commit?)
   - Nach jedem Factory-Run-Output der integriert wird?
   - Als expliziter Gate-Check vor "Release-Ready" Deklaration?
3. Implementiere kleinstes nuetzliches Enforcement:
   - z.B. ein `scripts/run_golden_gates.sh` das:
     - xcodebuild test ausfuehrt
     - Exit-Code prueft
     - PASS/FAIL klar meldet
     - Optional: Gate-Result als JSON/MD speichert
   - Oder: Integration in bestehende `_commands/` Workflow-Docs
4. Definiere klar:
   - **Gate PASS**: Was darf passieren (Commit, Push, Promotion)
   - **Gate FAIL**: Was wird blockiert, was muss passieren
5. Fuehre den integrierten Pfad einmal aus um zu validieren
6. Bestaetige dass AskFin jetzt eine explizit gate-gesteuerte Baseline hat

## Validation

```bash
# Golden Gate Script ausfuehren:
cd projects/askfin_v1-1
./scripts/run_golden_gates.sh
# Erwartet: PASS mit 12/12 Tests
```

## Report

Schreibe Ergebnis in: `_commands/044_golden_gate_workflow_result.md`
Schreibe Report in: `DeveloperReports/CodeAgent/85-0_Golden Gate Workflow Report.md`

Commit-Message: `ops: integrate golden gates as promotion barrier (Report 85-0)`
