# 039 Persistence Layer + Restart Verification

**Status**: pending
**Ziel**: Training-Session-Ergebnisse persistieren, nach Restart wiederherstellen

## Auftrag

### Schritt 1: Analyse

```bash
# Wo wird Session-State aktuell in-memory gespeichert?
grep -r "TopicCompetenceService\|competenceService" projects/askfin_v1-1/ --include="*.swift" | grep -v quarantine | head -20

# Welche State-Daten hat TopicCompetenceService?
grep -A 30 "class TopicCompetenceService\|struct TopicCompetence" projects/askfin_v1-1/ -r --include="*.swift" | grep -v quarantine | head -40

# Existiert schon ein TrainingSessionManager mit FileManager?
grep -r "TrainingSessionManager\|sessionManager" projects/askfin_v1-1/ --include="*.swift" | grep -v quarantine | head -10
```

### Schritt 2: Implementierung

Einfachster korrekter Ansatz: **JSON-Datei im App Documents Directory**

1. Erstelle/erweitere einen `PersistenceManager` oder nutze den existierenden `TrainingSessionManager`:

```swift
// Minimaler Ansatz:
// 1. Nach Session-Completion: State als JSON in Documents/ speichern
// 2. Beim App-Start: JSON laden und in TopicCompetenceService injizieren
```

2. Was persistieren:
   - Topic-Competence-Scores (pro Kategorie: correctCount, totalCount, lastPracticed)
   - Letzte Session-Ergebnisse (Datum, Score, Kategorie)
   - Readiness-Score (falls berechnet)

3. Wo speichern:
   ```swift
   let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
       .appendingPathComponent("competence_state.json")
   ```

4. Wann speichern:
   - Nach jeder `competenceService.record(result:)` Aufruf
   - Oder beim App-Background-Event (AppDelegate/SceneDelegate)

5. Wann laden:
   - In `AskFinApp.init()` oder `.onAppear` der Root-View
   - Vor dem ersten Tab-Render

### Schritt 3: Build + Restart-Test

```bash
cd ~/DriveAI-AutoGen/projects/askfin_v1-1
xcodegen generate

# Build
xcodebuild -project AskFinPremium.xcodeproj -scheme AskFinPremium \
  -destination 'platform=iOS Simulator,name=iPhone 16' build 2>&1 | tail -5

# Install + Launch
APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData -name "AskFinPremium.app" -path "*/Debug-iphonesimulator/*" | head -1)
xcrun simctl install booted "$APP_PATH"
xcrun simctl launch booted com.askfin.premium
sleep 3

# Screenshot Home vor Session
xcrun simctl io booted screenshot ~/DriveAI-AutoGen/_commands/039_before_session.png

# XCUITest: Session durchfuehren
xcodebuild test \
  -project AskFinPremium.xcodeproj \
  -scheme AskFinUITests \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -only-testing:AskFinUITests/TrainingJourneyTests/testDailyTrainingFullJourney \
  2>&1 | tail -10

# App beenden
xcrun simctl terminate booted com.askfin.premium
sleep 2

# App neu starten
xcrun simctl launch booted com.askfin.premium
sleep 3

# Screenshot Home nach Restart
xcrun simctl io booted screenshot ~/DriveAI-AutoGen/_commands/039_after_restart.png

# Pruefe ob persistierte Datei existiert
xcrun simctl get_app_container booted com.askfin.premium data 2>/dev/null
```

### Schritt 4: XCUITest fuer Restart-Verification

Optional: Erstelle `UITests/RestartStateTests.swift` der:
1. Session durchfuehrt
2. Home-State notiert (Readiness %)
3. App beendet + neu startet (via XCUIApplication)
4. Prueft ob State wiederhergestellt

## Report

Ergebnis in `_commands/039_persistence_result.md`:

```
## Persistence-Mechanismus
- Typ: [JSON/UserDefaults/CoreData]
- Datei: [Pfad]
- Daten: [was persistiert]

## Restart-Verification
- Session durchgefuehrt: [ja]
- App beendet: [ja]
- App neu gestartet: [ja]
- State nach Restart: [wiederhergestellt / leer / teilweise]
- Home Readiness: [vorher X% → nachher X%]
- Lernstand: [vorher → nachher]

## Screenshots
- 039_before_session.png
- 039_after_restart.png
```

## Git

```bash
git add -A
git commit -m "feat: session persistence layer + restart verification (Report 80-0)

- [Persistence-Typ] implementiert
- State ueberlebt App-Restart"
git push
```
