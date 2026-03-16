# 043 Golden Acceptance Gate Suite

**Status**: pending
**Ziel**: Erste automatisierte Acceptance-Gate-Suite die den bewiesenen AskFin-Baseline-Stand schuetzt.

## Kontext

Bewiesene Baseline-Wahrheiten:
- Xcode Build erfolgreich
- App startet im Simulator
- 4/4 Tabs funktionieren
- 3/3 Home Flows funktionieren
- Training Journey End-to-End funktioniert
- Verlauf reflektiert Session-History
- State persistiert ueber Cold Launch
- 7/7 bestehende Tests PASSED

## Aufgabe

1. Inspiziere bestehende Test/Build-Assets (`AskFinUITests/`, `project.yml`, etc.)
2. Definiere minimale Golden Gate Set:
   - **Gate 1: Build** — `xcodebuild build` erfolgreich
   - **Gate 2: Launch** — App startet ohne Crash
   - **Gate 3: Shell** — 4 Tabs navigierbar
   - **Gate 4: Flows** — 3 Home Entry Flows oeffnen
   - **Gate 5: Journey** — Mindestens 1 Training-Roundtrip
   - **Gate 6: Persistence** — State ueberlebt Restart
   - **Gate 7: History** — Verlauf zeigt abgeschlossene Session
3. Implementiere/scaffold die Gates als benannte XCUITests oder Shell-Script
4. Fuehre die Gate-Suite aus und dokumentiere Ergebnis
5. Klar benennen: Was ist automatisiert vs nur scaffolded

## Validation

```bash
# Gate-Suite ausfuehren:
xcodebuild test \
  -project AskFinPremium.xcodeproj \
  -scheme AskFinPremium \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
  -testPlan GoldenGates \
  2>&1 | tail -30
# Oder falls kein TestPlan: alle Tests laufen lassen
```

## Report

Schreibe Ergebnis in: `_commands/043_golden_gate_result.md`
Schreibe Report in: `DeveloperReports/CodeAgent/84-0_Golden Gate Suite Report.md`

Commit-Message: `test: golden acceptance gate suite (Report 84-0)`
