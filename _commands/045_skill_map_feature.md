# 045 Skill Map / Lernstand Feature

**Status**: pending
**Ziel**: Kleinste kohaerente Skill Map Visualisierung auf dem geschuetzten AskFin-Baseline.

## Kontext

- AskFin 4 Pillars: Training Mode, Exam Simulation, **Skill Map**, Readiness Score
- Lernstand-Tab existiert, zeigt aktuell basic Progress
- TopicCompetenceService persistiert Lern-Fortschritt pro Thema (UserDefaults)
- Golden Gates: 11/11 PASSED, Baseline geschuetzt
- Kein neuer LLM-Run noetig — reine Feature-Arbeit auf dem Mac

## Aufgabe

1. Inspiziere aktuellen Lernstand-Tab und TopicCompetenceService
2. Bestimme kleinstes sinnvolles Skill Map Feature:
   - z.B. Kategorie-basierte Fortschrittsanzeige (Balken/Ring pro Thema)
   - Oder: Staerken/Schwaechen-Uebersicht basierend auf Antwort-Historie
   - Reuse existierende persistierte Daten
3. Implementiere bounded Feature
4. Fuehre Golden Gates aus: `cd projects/askfin_v1-1 && ./scripts/run_golden_gates.sh`
5. Dokumentiere Ergebnis

## Constraints

- Kein neuer Orchestration/Control Layer
- Keine Exam Simulation (anderer Pillar)
- Kein Quarantine-Cleanup ausser wenn direkt blockierend
- Feature muss auf existierendem persistiertem State aufbauen
- Golden Gates muessen danach immer noch gruen sein

## Report

Schreibe Ergebnis in: `_commands/045_skill_map_result.md`
Schreibe Report in: `DeveloperReports/CodeAgent/86-0_Skill Map Feature Report.md`

Commit-Message: `feat: skill map visualization on Lernstand tab (Report 86-0)`
