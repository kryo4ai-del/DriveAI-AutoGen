# 050 Generalprobe Runtime Validation

**Status**: pending
**Ziel**: Existierende Generalprobe/Exam Simulation im Simulator validieren.

## Kontext

- ExamSimulationView existiert (Views/Simulation/ExamSimulationView.swift)
- Phasen: preStart → inProgress → submitted → SimulationResultView
- Generalprobe-Tab ist gewired
- Golden Gates: 14/14 PASSED

## Aufgabe

1. Oeffne Generalprobe-Tab im Simulator
2. Dokumentiere Pre-Start Screen (Titel, Regeln, Button)
3. Starte Simulation ("Simulation starten")
4. Beantworte mindestens 3-5 Fragen
5. Pruefe:
   - Timer laeuft?
   - Fragen-Progression (X/30)?
   - Antwort-Auswahl funktioniert?
   - Kein Crash/Hang?
6. Falls moeglich: Simulation beenden oder alle Fragen beantworten
7. Pruefe Result-Screen:
   - Bestanden/Nicht bestanden?
   - Fehlerpunkte?
   - Zurueck-Navigation?
8. Screenshots wenn moeglich

## Constraints

- Kein neuer Code ausser wenn ein offensichtlicher Wiring-Bug gefunden wird
- Keine Architektur-Aenderung
- Reine Runtime-Validierung

## Report

Schreibe Ergebnis in: `_commands/050_generalprobe_runtime_result.md`
Schreibe Report in: `DeveloperReports/CodeAgent/91-0_Generalprobe Runtime Report.md`

Commit-Message: `test: generalprobe runtime validation (Report 91-0)`
