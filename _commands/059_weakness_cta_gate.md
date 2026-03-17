# 059 Schwaechen-Trainieren CTA Golden Gate

**Status**: pending
**Ziel**: Schwaechen-trainieren CTA Pfad als Golden Gate schuetzen

## Auftrag

1. Inspiziere aktuelle Golden Gate / XCUITest Coverage um Result-Screen CTAs
2. Definiere den kleinsten kohaerenten Acceptance Gate:
   - Generalprobe starten
   - Simulation durchlaufen
   - Result Screen erreichen
   - "Schwaechen trainieren" CTA aktivieren
   - TrainingSessionView(.weaknessFocus) wird praesentiert
3. Implementiere oder erweitere die relevante Test-Coverage
4. Laufe die vollstaendige Golden Gate Suite
5. Dokumentiere Ergebnis

## Regeln

- Kein neuer Generation/Autonomy Run
- Kein neues Feature
- Kein Architektur-Redesign
- Ziel: Bewiesenes CTA-Verhalten als geschuetzten Gate konvertieren

## Nach Abschluss

1. Ergebnis in `_commands/059_weakness_cta_gate_result.md`
2. Report in `DeveloperReports/CodeAgent/100-0_Weakness CTA Gate Report.md`
3. `git add -A && git commit -m "gate: protect weakness-training CTA in golden suite" && git push`
