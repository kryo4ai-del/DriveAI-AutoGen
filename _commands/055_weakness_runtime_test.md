# 055 Post-Exam Weakness Analysis Runtime Validation

**Status**: pending
**Ziel**: Runtime-Validierung der existierenden Schwaechen-Analyse nach Generalprobe

## Auftrag

1. Identifiziere wie man `SimulationResultView` in der laufenden App erreicht
2. Fuehre eine repraesentative Generalprobe durch (oder nutze bestehende Daten)
3. Inspiziere die sichtbare Schwaechen-Analyse:
   - Gap Analysis (Kategorien nach Fehlerpunkten)
   - Recommendations (personalisierte Empfehlungen)
   - Staerken ("Gut gemacht")
4. Teste die Training CTAs falls interaktiv:
   - Sind sie klickbar?
   - Fuehren sie zu einem gueltigen Ziel?
5. Dokumentiere ob das Feature:
   - sauber funktioniert
   - mit sichtbaren Problemen funktioniert
   - Runtime/State/Navigation Probleme zeigt

## Regeln

- Kein neuer Generation/Autonomy Run
- Kein Architektur-Redesign
- Ziel: Runtime-Validierung des existierenden Features

## Nach Abschluss

1. Ergebnis in `_commands/055_weakness_runtime_result.md`
2. Report in `DeveloperReports/CodeAgent/96-0_Weakness Runtime Report.md`
3. `git add -A && git commit -m "test: runtime validate post-exam weakness analysis" && git push`
