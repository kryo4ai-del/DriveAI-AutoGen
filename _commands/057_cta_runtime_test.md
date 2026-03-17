# 057 Post-Exam CTA Runtime Validation

**Status**: pending
**Ziel**: Runtime-Validierung der CTA-Pfade vom Generalprobe Result Screen

## Auftrag

1. Identifiziere die verfuegbaren CTAs auf dem Generalprobe Result Screen
2. Bestimme welcher CTA den hoechsten Runtime-Validierungswert hat
3. Fuehre eine repraesentative Generalprobe durch falls noetig
4. Aktiviere den gewaehlten CTA
5. Dokumentiere ob das Ziel:
   - sauber oeffnet
   - zum CTA-Versprechen passt
   - stabil bleibt
   - oder Runtime/Navigation/Kontext-Probleme zeigt
6. Falls ein CTA zu "Schwaechen trainieren" fuehrt: pruefe ob Schwaechen-Kontext uebergeben wird

## Regeln

- Kein neuer Generation/Autonomy Run
- Kein Architektur-Redesign
- Kein breites neues Feature
- Nur ein kleiner Blocker-Fix wenn strikt noetig fuer den CTA-Pfad
- Ziel: Runtime-Validierung des existierenden CTA-Flows

## Nach Abschluss

1. Ergebnis in `_commands/057_cta_runtime_result.md`
2. Report in `DeveloperReports/CodeAgent/98-0_CTA Runtime Report.md`
3. `git add -A && git commit -m "test: runtime validate post-exam CTA flow" && git push`
