# 058 Wire Schwaechen-Trainieren CTA

**Status**: pending
**Ziel**: Schwaechen-trainieren CTA vom Generalprobe Result Screen zu echtem Weakness-Training verdrahten

## Auftrag

1. Inspiziere die aktuelle `Schwaechen trainieren` CTA Implementierung im SimulationResultView
2. Identifiziere das kleinste kohaerente Ziel:
   - Wahrscheinlich `TrainingSessionView(.weaknessFocus)` — existiert bereits auf Home
   - Falls moeglich: Schwaechen-Kontext (welche Kategorien schwach) mitgeben
3. Ersetze den aktuellen `onDismiss()` Soft-Wire durch echte Navigation/Presentation
4. Bewahre alle aktuell funktionierenden CTAs (Alle Antworten, Nochmal, Fertig)
5. Runtime-Verifikation des neuen CTA-Pfads
6. Golden Gate Suite laufen lassen

## Regeln

- Kein neuer Generation/Autonomy Run
- Kein breites Weakness-Training Architecture Buildout
- Kein Result-Screen Redesign
- Ziel: Eng begrenztes CTA-Wiring fuer den wertvollsten verbleibenden Button

## Nach Abschluss

1. Ergebnis in `_commands/058_wire_weakness_cta_result.md`
2. Report in `DeveloperReports/CodeAgent/99-0_Wire Weakness CTA Report.md`
3. `git add -A && git commit -m "feat: wire Schwaechen trainieren CTA to real training flow" && git push`
