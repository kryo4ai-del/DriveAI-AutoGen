# 019 TrendAnalyzer / LocalDataService Conformance Fix

**Status**: pending
**Ziel**: LocalDataService Protocol-Conformance luecke schliessen + fetchUserAnswerHistory ergaenzen

## Auftrag

1. Lies `Models/TrendAnalyzer.swift` — wie wird LocalDataService/fetchUserAnswerHistory genutzt?
2. Lies `Models/LocalDataServiceProtocol.swift` — welche Methoden sind definiert?
3. Lies `Services/LocalDataService.swift` — welche Methoden sind implementiert?
4. Identifiziere die Luecke:
   - Fehlt `fetchUserAnswerHistory()` im Protocol? → Ergaenzen
   - Fehlt die Implementierung in LocalDataService? → Minimale Default-Impl ergaenzen
   - Beides? → Beides ergaenzen
5. Return-Type aus dem Aufruf in TrendAnalyzer ableiten
6. Policy: `consumer-declares-need` + `concrete-service-must-conform`

## Wichtig

- LocalDataService muss ALLE Methoden von LocalDataServiceProtocol implementieren
- Pruefe ob es noch weitere fehlende Conformance-Methoden gibt (nicht nur fetchUserAnswerHistory)
- Falls ja: Alle fehlenden Methoden mit minimalen Default-Implementierungen ergaenzen
- Minimale Impl = leere Arrays, nil, 0, false etc.

## Nach dem Fix

```bash
cd ~/DriveAI-AutoGen
xcrun swiftc -typecheck \
  projects/askfin_v1-1/**/*.swift \
  -sdk $(xcrun --show-sdk-path) \
  -target arm64-apple-macosx15.0 \
  2>&1 | head -60
```

## Report

Ergebnis in `_commands/019_trendanalyzer_conformance_result.md`:
- Welche Methoden fehlten (Protocol vs Service)
- Was ergaenzt + Return-Types
- Typecheck-Ergebnis nach Fix
- Naechster Blocker falls vorhanden

## Git

```bash
git add -A
git commit -m "fix: TrendAnalyzer/LocalDataService conformance completion (Report 60-0)

- fetchUserAnswerHistory + ggf. weitere fehlende Methoden ergaenzt
- Policy: consumer-declares-need + concrete-service-must-conform"
git push
```
