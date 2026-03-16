# 049 Generalprobe Exam Simulation — Vertical Slice

**Status**: pending
**Ziel**: Kleinstes sinnvolles Exam-Simulation Feature auf dem geschuetzten Baseline.

## Kontext

- AskFin 4 Pillars: Training Mode ✅, Skill Map ✅, Readiness Score ✅, **Exam Simulation** ← jetzt
- Generalprobe-Tab existiert bereits in der Tab-Bar
- Training-Infrastruktur (Questions, Sessions, Persistence) ist vorhanden
- Golden Gates: 14/14 PASSED

## Aufgabe

1. Inspiziere aktuellen Generalprobe-Tab (was existiert schon?)
2. Bestimme kleinstes sinnvolles Vertical Slice:
   - z.B. Timed Exam Session (30 Fragen, Countdown, Ergebnis)
   - Oder: Quick Exam (10 Fragen, kein Timer, Pass/Fail Ergebnis)
   - Reuse existierende Question-Bank + Session-Infrastruktur
3. Implementiere bounded Feature
4. Fuehre Golden Gates aus: `cd projects/askfin_v1-1 && ./scripts/run_golden_gates.sh`
5. Dokumentiere Ergebnis

## Constraints

- Kein neuer Orchestration/Control Layer
- Kein volles Pruefungssimulator-System
- Reuse existierende Infrastruktur (MockQuestionBank, TrainingSessionView-Pattern)
- Golden Gates muessen danach gruen bleiben
- Feature muss im Generalprobe-Tab erreichbar sein

## Report

Schreibe Ergebnis in: `_commands/049_generalprobe_result.md`
Schreibe Report in: `DeveloperReports/CodeAgent/90-0_Generalprobe Feature Report.md`

Commit-Message: `feat: generalprobe exam simulation vertical slice (Report 90-0)`
