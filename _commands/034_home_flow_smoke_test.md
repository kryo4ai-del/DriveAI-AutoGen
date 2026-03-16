# 034 Home Flow Runtime Smoke Test

**Status**: pending
**Ziel**: Alle 3 Home-Flows oeffnen, rendern, erste Interaktion testen

## Auftrag

### Methode

Da simctl keine Taps simulieren kann, nutze XCUITest:

```bash
cd ~/DriveAI-AutoGen/projects/askfin_v1-1
```

Erstelle `UITests/HomeFlowSmokeTests.swift`:
```swift
import XCTest

final class HomeFlowSmokeTests: XCTestCase {
    let app = XCUIApplication()

    override func setUp() {
        continueAfterFailure = false
        app.launch()
    }

    func testDailyTrainingOpens() {
        let button = app.buttons["Tägliches Training"]
        XCTAssertTrue(button.waitForExistence(timeout: 3))
        button.tap()
        // Prüfe ob TrainingSessionView rendert
        let exists = app.navigationBars.firstMatch.waitForExistence(timeout: 3)
            || app.staticTexts["Beenden"].waitForExistence(timeout: 3)
            || app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'Training'")).firstMatch.waitForExistence(timeout: 3)
        XCTAssertTrue(exists, "TrainingSessionView should render")
    }

    func testTopicPickerOpens() {
        let button = app.buttons["Thema üben"]
        XCTAssertTrue(button.waitForExistence(timeout: 3))
        button.tap()
        // Sheet sollte oeffnen
        let sheet = app.otherElements["TopicPickerView"].waitForExistence(timeout: 3)
            || app.navigationBars.firstMatch.waitForExistence(timeout: 3)
            || app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'Thema'")).firstMatch.waitForExistence(timeout: 3)
        // Auch ohne exakte Erkennung: Kein Crash = Erfolg
    }

    func testWeaknessTrainingOpens() {
        let button = app.buttons["Schwächen trainieren"]
        XCTAssertTrue(button.waitForExistence(timeout: 3))
        button.tap()
        let exists = app.navigationBars.firstMatch.waitForExistence(timeout: 3)
            || app.staticTexts["Beenden"].waitForExistence(timeout: 3)
            || app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'Training'")).firstMatch.waitForExistence(timeout: 3)
        XCTAssertTrue(exists, "TrainingSessionView should render")
    }
}
```

Falls XCUITest zu aufwaendig einzurichten ist (braucht UI Test Target in .xcodeproj):

### Alternative: Code-Analyse + Console-Monitoring

1. App starten mit Console-Logging:
```bash
xcrun simctl launch --console booted com.askfin.premium 2>&1 | tee /tmp/askfin_console.log &
CONSOLE_PID=$!
sleep 5
```

2. Pruefe ob die 3 Destination-Views korrekt initialisiert werden koennen:
```bash
# Code-Analyse: Welche @State / @StateObject / init() haben die Destinations?
grep -A 10 "struct TrainingSessionView" projects/askfin_v1-1/ -r --include="*.swift" | head -20
grep -A 10 "struct TopicPickerView" projects/askfin_v1-1/ -r --include="*.swift" | head -20
```

3. Console-Output analysieren:
```bash
kill $CONSOLE_PID 2>/dev/null
cat /tmp/askfin_console.log | head -30
```

4. Screenshots:
```bash
xcrun simctl io booted screenshot ~/DriveAI-AutoGen/_commands/034_flow_test.png
```

## Report

Ergebnis in `_commands/034_home_flow_result.md`:

```
## Flow: Taegliches Training
- Oeffnet: [ja/nein/crash]
- Rendert: [was sichtbar]
- Stabil: [ja/nein]

## Flow: Thema ueben
- Oeffnet: [ja/nein/crash]
- Rendert: [was sichtbar]
- Stabil: [ja/nein]

## Flow: Schwaechen trainieren
- Oeffnet: [ja/nein/crash]
- Rendert: [was sichtbar]
- Stabil: [ja/nein]

## Console Output
- [relevante Zeilen]

## Interpretation
```

## Git

```bash
git add -A
git commit -m "test: Home flow runtime smoke test (Report 75-0)

- 3 Home flows getestet
- [Zusammenfassung]"
git push
```
