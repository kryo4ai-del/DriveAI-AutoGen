# 048 Persistent Learning Loop Gate

**Status**: pending
**Ziel**: Ein integrierter Gate-Test der den kompletten Lern-Loop schuetzt: Training → History sichtbar → Restart → History noch da.

## Kontext

- Gate 5 (Journey) testet Training-Roundtrip
- Gate 8 (Persistence) testet State-ueber-Restart
- Keiner testet die Kette: Training → Verlauf-Eintrag → Restart → Verlauf-Eintrag noch da
- 13/13 Tests PASSED

## Aufgabe

1. Fuege **Gate 6: Learning Loop** als einen integrierten Test hinzu:
   - Training-Session durchfuehren (min. 1 Frage)
   - Verlauf-Tab oeffnen → Eintrag vorhanden
   - App terminieren + kalt neu starten
   - Verlauf-Tab oeffnen → Eintrag immer noch vorhanden
2. Das ist NICHT einfach Gate 5 + Gate 8 nacheinander — der Mehrwert ist die **Kette** in einem Test
3. Fuehre Golden Gates aus
4. Bestaetige alle Gates gruen

## Constraints

- Kein neues Feature
- Kein Architektur-Change
- Ein einziger integrierter XCUITest

## Report

Schreibe Ergebnis in: `_commands/048_learning_loop_gate_result.md`
Schreibe Report in: `DeveloperReports/CodeAgent/89-0_Learning Loop Gate Report.md`

Commit-Message: `test: add persistent learning loop gate (Report 89-0)`
