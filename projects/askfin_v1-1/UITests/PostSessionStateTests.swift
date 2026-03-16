import XCTest

final class PostSessionStateTests: XCTestCase {
    let app = XCUIApplication()

    override func setUp() {
        continueAfterFailure = true
        app.launch()
    }

    func testPostSessionStateReflection() {
        // 1. Complete a training session
        let dailyBtn = app.buttons.matching(NSPredicate(format: "label CONTAINS 'ägliches Training'")).firstMatch
        guard dailyBtn.waitForExistence(timeout: 5) else { XCTFail("No daily btn"); return }
        dailyBtn.tap()
        sleep(2)

        // Answer all available questions
        for _ in 0..<10 {
            let answers = app.buttons.allElementsBoundByIndex.filter { $0.exists && $0.isHittable && $0.frame.minY > 200 }
            guard let answer = answers.first else { break }
            answer.tap()
            sleep(1)
            let next = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Weiter' OR label CONTAINS 'ächste'")).firstMatch
            if next.waitForExistence(timeout: 1) { next.tap(); sleep(1) }
        }

        // Dismiss
        let beenden = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Beenden' OR label CONTAINS 'Fertig'")).firstMatch
        if beenden.waitForExistence(timeout: 3) { beenden.tap(); sleep(1) }

        screenshot("01_home_after_session")

        // 2. Check Home state
        let homeTexts = app.staticTexts.allElementsBoundByIndex.map { $0.label }
        print("=== HOME STATE ===")
        homeTexts.prefix(15).forEach { print("  \($0)") }

        // 3. Check Verlauf tab
        let verlaufTab = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Verlauf'")).firstMatch
        if verlaufTab.waitForExistence(timeout: 3) {
            verlaufTab.tap()
            sleep(2)
            screenshot("02_verlauf_after_session")
            let verlaufTexts = app.staticTexts.allElementsBoundByIndex.map { $0.label }
            print("=== VERLAUF STATE ===")
            verlaufTexts.prefix(15).forEach { print("  \($0)") }
        }

        // 4. Check Lernstand tab
        let lernstandTab = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Lernstand'")).firstMatch
        if lernstandTab.waitForExistence(timeout: 3) {
            lernstandTab.tap()
            sleep(2)
            screenshot("03_lernstand_after_session")
            let lernstandTexts = app.staticTexts.allElementsBoundByIndex.map { $0.label }
            print("=== LERNSTAND STATE ===")
            lernstandTexts.prefix(15).forEach { print("  \($0)") }
        }

        // Back to Home
        let homeTab = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Home'")).firstMatch
        if homeTab.waitForExistence(timeout: 3) { homeTab.tap() }
    }

    private func screenshot(_ name: String) {
        let s = XCUIScreen.main.screenshot()
        let a = XCTAttachment(screenshot: s)
        a.name = name; a.lifetime = .keepAlways; add(a)
    }
}
