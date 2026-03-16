# 036 Happy-Path Training Journey Test

**Status**: pending
**Ziel**: Einen vollstaendigen Training-Durchlauf testen (Open → Frage → Antwort → Naechste → Ende)

## Auftrag

### XCUITest: End-to-End Journey

Ergaenze `UITests/InFlowSmokeTests.swift` (oder neue Datei `UITests/TrainingJourneyTests.swift`):

```swift
import XCTest

final class TrainingJourneyTests: XCTestCase {
    let app = XCUIApplication()

    override func setUp() {
        continueAfterFailure = true
        app.launch()
    }

    func testDailyTrainingFullJourney() {
        // 1. Oeffne Taegliches Training
        let dailyBtn = app.buttons.matching(NSPredicate(format: "label CONTAINS 'ägliches Training'")).firstMatch
        guard dailyBtn.waitForExistence(timeout: 5) else {
            XCTFail("Daily Training button not found")
            return
        }
        dailyBtn.tap()
        sleep(2)
        screenshot("01_training_opened")

        // 2. Pruefe ob Brief-Phase sichtbar ist
        //    (Briefing vor dem Training)
        let startBtn = app.buttons.matching(NSPredicate(
            format: "label CONTAINS 'Start' OR label CONTAINS 'Weiter' OR label CONTAINS 'Beginnen' OR label CONTAINS 'Los'"
        )).firstMatch

        if startBtn.waitForExistence(timeout: 3) {
            startBtn.tap()
            sleep(1)
            screenshot("02_after_start")
        }

        // 3. Pruefe ob Frage sichtbar ist
        //    Suche nach Antwort-Buttons (A/B/C/D oder Text-Buttons)
        let answerButtons = app.buttons.matching(NSPredicate(
            format: "label.length > 0"
        ))

        var answeredCount = 0
        for attempt in 0..<5 {  // Maximal 5 Fragen versuchen
            sleep(1)

            // Suche nach tappbaren Antwort-Elementen
            let allButtons = app.buttons.allElementsBoundByIndex
            let tappableAnswers = allButtons.filter { btn in
                btn.exists && btn.isHittable && btn.frame.minY > 200  // Unterhalb der Frage
            }

            if tappableAnswers.isEmpty {
                // Kein Antwort-Button → vielleicht Summary oder Ende
                break
            }

            // Tappe erste verfuegbare Antwort
            if let firstAnswer = tappableAnswers.first {
                firstAnswer.tap()
                answeredCount += 1
                sleep(1)
                screenshot("03_answered_\(attempt + 1)")

                // Suche "Weiter" / "Naechste Frage" Button
                let nextBtn = app.buttons.matching(NSPredicate(
                    format: "label CONTAINS 'Weiter' OR label CONTAINS 'ächste' OR label CONTAINS 'Next'"
                )).firstMatch

                if nextBtn.waitForExistence(timeout: 2) {
                    nextBtn.tap()
                    sleep(1)
                }
            }
        }

        screenshot("04_journey_end")

        // 4. Pruefe ob Beenden moeglich ist
        let beendenBtn = app.buttons.matching(NSPredicate(
            format: "label CONTAINS 'Beenden' OR label CONTAINS 'Fertig' OR label CONTAINS 'Schließen' OR label CONTAINS 'Home'"
        )).firstMatch

        if beendenBtn.waitForExistence(timeout: 3) {
            beendenBtn.tap()
            sleep(1)
        }

        screenshot("05_back_home")

        // Pruefe ob wir zurueck auf Home sind
        let homeVisible = app.buttons.matching(NSPredicate(
            format: "label CONTAINS 'ägliches Training'"
        )).firstMatch.waitForExistence(timeout: 3)

        // Report
        print("=== JOURNEY RESULT ===")
        print("Questions answered: \(answeredCount)")
        print("Back to Home: \(homeVisible)")
        print("=== END ===")
    }

    private func screenshot(_ name: String) {
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
```

### Ausfuehren

```bash
cd ~/DriveAI-AutoGen/projects/askfin_v1-1
xcodegen generate

xcodebuild test \
  -project AskFinPremium.xcodeproj \
  -scheme AskFinUITests \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -only-testing:AskFinUITests/TrainingJourneyTests/testDailyTrainingFullJourney \
  -resultBundlePath /tmp/askfin_journey_results \
  2>&1 | tail -30

# Screenshots aus Result Bundle extrahieren (falls moeglich)
find /tmp/askfin_journey_results -name "*.png" -exec cp {} ~/DriveAI-AutoGen/_commands/ \; 2>/dev/null
```

## Report

Ergebnis in `_commands/036_journey_result.md`:

```
## Journey: Taegliches Training

### Schritt 1: Open
- [was passiert]

### Schritt 2: Brief/Start
- [Brief sichtbar? Start getappt?]

### Schritt 3: Fragen
- Fragen beantwortet: [Anzahl]
- Antwort-UI: [Buttons sichtbar / nicht sichtbar]
- Progression: [naechste Frage / gleiche Frage / Ende]

### Schritt 4: Ende/Summary
- Summary sichtbar: [ja/nein]
- Beenden moeglich: [ja/nein]

### Schritt 5: Zurueck Home
- Home erreicht: [ja/nein]

## Screenshots
- [Liste falls vorhanden]

## Interpretation
- Journey-Tiefe erreicht: [nur Open / Brief / Fragen / Summary / Komplett]
- Naechster Blocker: [was fehlt fuer vollstaendige Journey]
```

## Git

```bash
git add -A
git commit -m "test: happy-path training journey test (Report 77-0)

- End-to-end Training Journey getestet
- [Zusammenfassung]"
git push
```
