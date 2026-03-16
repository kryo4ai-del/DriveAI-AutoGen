# 040 Verlauf History Integration

**Status**: pending
**Ziel**: Training-Session-Abschluss in Verlauf/History eintragen

## Auftrag

### Schritt 1: Analyse

```bash
# Wie wird Verlauf/History befuellt?
grep -r "ExamHistoryView\|ExamHistory\|history" projects/askfin_v1-1/ --include="*.swift" | grep -v quarantine | head -20

# Welches Model nutzt Verlauf?
grep -A 20 "struct.*History\|class.*History" projects/askfin_v1-1/ -r --include="*.swift" | grep -v quarantine | head -30

# Wo wird die History-Liste initialisiert?
grep -r "history.*\[\]\|history.*=\|historyItems\|pastSessions" projects/askfin_v1-1/ --include="*.swift" | grep -v quarantine | head -15

# Wo endet eine Training-Session (Completion Event)?
grep -r "finishSession\|endSession\|completeSession\|sessionFinished\|onDismiss\|dismiss.*training" projects/askfin_v1-1/ --include="*.swift" | grep -v quarantine | head -15

# TrainingSessionViewModel — wie wird Session beendet?
grep -A 10 "func.*finish\|func.*end\|func.*complete\|summary\|phase.*==.*end" projects/askfin_v1-1/ -r --include="*.swift" | grep -v quarantine | head -30
```

### Schritt 2: Integration

1. Finde den Completion-Punkt in `TrainingSessionViewModel` (oder wo die Session endet)
2. Finde das History-Model (vermutlich ein Array von History-Entries)
3. Erstelle beim Session-Ende einen History-Entry:
   ```swift
   // Beispiel (anpassen an existierende Models):
   let entry = SessionHistoryEntry(
       id: UUID(),
       date: Date(),
       type: sessionType,  // .adaptive / .weaknessFocus / .topic
       questionsAnswered: answeredCount,
       correctAnswers: correctCount,
       score: Double(correctCount) / Double(answeredCount),
       duration: sessionDuration
   )
   ```
4. Speichere den Entry (gleicher Persistence-Mechanismus wie TopicCompetenceService — UserDefaults oder FileManager)
5. Stelle sicher dass `ExamHistoryView` die gespeicherten Entries laedt

### Schritt 3: Build + Runtime Verification

```bash
cd ~/DriveAI-AutoGen/projects/askfin_v1-1
xcodegen generate

xcodebuild -project AskFinPremium.xcodeproj -scheme AskFinPremium \
  -destination 'platform=iOS Simulator,name=iPhone 16' build 2>&1 | tail -5

# Reset App State fuer sauberen Test
xcrun simctl terminate booted com.askfin.premium 2>/dev/null
# Optional: App-Daten loeschen fuer Clean-State
# xcrun simctl privacy booted reset all com.askfin.premium

APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData -name "AskFinPremium.app" -path "*/Debug-iphonesimulator/*" | head -1)
xcrun simctl install booted "$APP_PATH"
xcrun simctl launch booted com.askfin.premium
sleep 3

# XCUITest: Session + Verlauf Check
xcodebuild test \
  -project AskFinPremium.xcodeproj \
  -scheme AskFinUITests \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -only-testing:AskFinUITests/PostSessionStateTests/testPostSessionStateReflection \
  2>&1 | tail -20

# Screenshot vom Verlauf Tab nach Session
xcrun simctl io booted screenshot ~/DriveAI-AutoGen/_commands/040_verlauf_after.png
```

## Report

Ergebnis in `_commands/040_verlauf_result.md`:

```
## Verlauf vorher
- Datenquelle: [was]
- Inhalt: [leer / statisch]

## Integration
- Completion Event: [wo/wie]
- History Model: [was]
- Persistence: [UserDefaults/FileManager/in-memory]

## Runtime nach Integration
- Session abgeschlossen: [ja]
- Verlauf Tab: [Entry sichtbar / leer / crash]
- Entry Details: [Datum, Score, Typ]

## Screenshot
- 040_verlauf_after.png
```

## Git

```bash
git add -A
git commit -m "feat: Verlauf history integration (Report 81-0)

- Training-Session-Completion → History Entry
- Verlauf zeigt abgeschlossene Sessions"
git push
```
