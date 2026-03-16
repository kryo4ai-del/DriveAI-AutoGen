import XCTest

final class TrainingJourneyTests: XCTestCase {
    let app = XCUIApplication()

    override func setUp() {
        continueAfterFailure = true
        app.launch()
    }

    func testDailyTrainingFullJourney() {
        // 1. Open Daily Training
        let dailyBtn = app.buttons.matching(NSPredicate(format: "label CONTAINS 'ägliches Training'")).firstMatch
        guard dailyBtn.waitForExistence(timeout: 5) else {
            XCTFail("Daily Training button not found")
            return
        }
        dailyBtn.tap()
        sleep(2)
        screenshot("01_training_opened")

        // 2. Check for Brief phase / Start button
        let startBtn = app.buttons.matching(NSPredicate(
            format: "label CONTAINS 'Start' OR label CONTAINS 'Weiter' OR label CONTAINS 'Beginnen' OR label CONTAINS 'Los'"
        )).firstMatch

        if startBtn.waitForExistence(timeout: 3) {
            startBtn.tap()
            sleep(1)
            screenshot("02_after_start")
        }

        // 3. Try to answer questions
        var answeredCount = 0
        for attempt in 0..<5 {
            sleep(1)

            let allButtons = app.buttons.allElementsBoundByIndex
            let tappableAnswers = allButtons.filter { btn in
                btn.exists && btn.isHittable && btn.frame.minY > 200
            }

            if tappableAnswers.isEmpty {
                break
            }

            if let firstAnswer = tappableAnswers.first {
                firstAnswer.tap()
                answeredCount += 1
                sleep(1)
                screenshot("03_answered_\(attempt + 1)")

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

        // 4. Dismiss
        let beendenBtn = app.buttons.matching(NSPredicate(
            format: "label CONTAINS 'Beenden' OR label CONTAINS 'Fertig' OR label CONTAINS 'Schließen' OR label CONTAINS 'Home'"
        )).firstMatch

        if beendenBtn.waitForExistence(timeout: 3) {
            beendenBtn.tap()
            sleep(1)
        }

        screenshot("05_back_home")

        // 5. Verify Home
        let homeVisible = app.buttons.matching(NSPredicate(
            format: "label CONTAINS 'ägliches Training'"
        )).firstMatch.waitForExistence(timeout: 3)

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
