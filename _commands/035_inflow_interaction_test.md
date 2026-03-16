# 035 In-Flow Interaction Smoke Test

**Status**: pending
**Ziel**: Erste Interaktion innerhalb der 3 Flows testen

## Auftrag

### Methode: XCUITest

Erstelle einen UI Test Target und fuehre gezielte Interaction-Tests aus.

#### 1. UI Test Target einrichten

Ergaenze `project.yml` um ein UI Test Target:
```yaml
  AskFinUITests:
    type: bundle.ui-testing
    platform: iOS
    deploymentTarget: "17.0"
    sources:
      - path: UITests
    dependencies:
      - target: AskFinPremium
    settings:
      SWIFT_VERSION: "5.9"
```

Erstelle `UITests/InFlowSmokeTests.swift`:
```swift
import XCTest

final class InFlowSmokeTests: XCTestCase {
    let app = XCUIApplication()

    override func setUp() {
        continueAfterFailure = true
        app.launch()
    }

    func testDailyTrainingFlow() {
        // Tap "Tägliches Training"
        let btn = app.buttons.matching(NSPredicate(format: "label CONTAINS 'ägliches Training'")).firstMatch
        guard btn.waitForExistence(timeout: 5) else {
            XCTFail("Tägliches Training button not found")
            return
        }
        btn.tap()
        sleep(2)

        // Screenshot nach Oeffnen
        let screenshot1 = XCUIScreen.main.screenshot()
        let attach1 = XCTAttachment(screenshot: screenshot1)
        attach1.name = "daily_training_opened"
        attach1.lifetime = .keepAlways
        add(attach1)

        // Pruefe ob irgendein interaktives Element sichtbar ist
        let anyButton = app.buttons.firstMatch
        let anyText = app.staticTexts.firstMatch
        XCTAssertTrue(anyText.exists || anyButton.exists, "Flow should show content")

        // Versuche erste Interaktion (z.B. "Start" oder erste Antwort)
        let startBtn = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Start' OR label CONTAINS 'Weiter' OR label CONTAINS 'Beginnen'")).firstMatch
        if startBtn.waitForExistence(timeout: 2) {
            startBtn.tap()
            sleep(1)
            let screenshot2 = XCUIScreen.main.screenshot()
            let attach2 = XCTAttachment(screenshot: screenshot2)
            attach2.name = "daily_training_after_start"
            attach2.lifetime = .keepAlways
            add(attach2)
        }

        // Dismiss
        let beenden = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Beenden'")).firstMatch
        if beenden.waitForExistence(timeout: 2) {
            beenden.tap()
        }
    }

    func testTopicPickerFlow() {
        let btn = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Thema'")).firstMatch
        guard btn.waitForExistence(timeout: 5) else {
            XCTFail("Thema üben button not found")
            return
        }
        btn.tap()
        sleep(2)

        let screenshot = XCUIScreen.main.screenshot()
        let attach = XCTAttachment(screenshot: screenshot)
        attach.name = "topic_picker_opened"
        attach.lifetime = .keepAlways
        add(attach)

        // Versuche erstes Topic zu tappen
        let firstCell = app.cells.firstMatch
        let firstButton = app.buttons.element(boundBy: 1) // Skip first (might be close)
        if firstCell.waitForExistence(timeout: 2) {
            firstCell.tap()
            sleep(1)
        } else if firstButton.waitForExistence(timeout: 2) {
            firstButton.tap()
            sleep(1)
        }

        let screenshot2 = XCUIScreen.main.screenshot()
        let attach2 = XCTAttachment(screenshot: screenshot2)
        attach2.name = "topic_picker_after_select"
        attach2.lifetime = .keepAlways
        add(attach2)
    }

    func testWeaknessTrainingFlow() {
        let btn = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Schwächen'")).firstMatch
        guard btn.waitForExistence(timeout: 5) else {
            XCTFail("Schwächen trainieren button not found")
            return
        }
        btn.tap()
        sleep(2)

        let screenshot = XCUIScreen.main.screenshot()
        let attach = XCTAttachment(screenshot: screenshot)
        attach.name = "weakness_training_opened"
        attach.lifetime = .keepAlways
        add(attach)

        // Dismiss
        let beenden = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Beenden'")).firstMatch
        if beenden.waitForExistence(timeout: 2) {
            beenden.tap()
        }
    }
}
```

#### 2. Generieren + Testen

```bash
cd ~/DriveAI-AutoGen/projects/askfin_v1-1
xcodegen generate

xcodebuild test \
  -project AskFinPremium.xcodeproj \
  -scheme AskFinUITests \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -resultBundlePath /tmp/askfin_uitest_results \
  2>&1 | tail -40
```

Falls XCUITest-Setup zu komplex: **Fallback auf Code-Analyse**

#### Fallback: Code-basierte Interaktions-Analyse

```bash
# Was passiert nach erstem Tap in TrainingSessionView?
grep -A 30 "phaseContent\|\.brief\|\.question\|answerTapped\|nextQuestion" \
  projects/askfin_v1-1/ -r --include="*.swift" | grep -v quarantine | head -60

# Was passiert nach Topic-Selection in TopicPickerView?
grep -A 20 "onSelectTopic\|topicSelected\|NavigationLink" \
  projects/askfin_v1-1/ -r --include="*.swift" | grep "TopicPicker\|onSelect" | head -20
```

## Report

Ergebnis in `_commands/035_inflow_result.md`:

```
## Flow: Taegliches Training — Erste Interaktion
- Phase nach Open: [brief/question/...]
- Interaktion: [was getappt]
- Ergebnis: [rendert/crash/hang]

## Flow: Thema ueben — Erste Interaktion
- Sheet offen: [ja]
- Interaktion: [Topic getappt]
- Ergebnis: [was passiert]

## Flow: Schwaechen trainieren — Erste Interaktion
- Phase nach Open: [brief/question/...]
- Interaktion: [was getappt]
- Ergebnis: [rendert/crash/hang]

## Screenshots (falls XCUITest)
- [Liste]
```

## Git

```bash
git add -A
git commit -m "test: in-flow interaction smoke test (Report 76-0)

- 3 Flows erste Interaktion getestet
- [Zusammenfassung]"
git push
```
