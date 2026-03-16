import XCTest

final class SkillMapRuntimeTests: XCTestCase {
    let app = XCUIApplication()

    override func setUp() {
        continueAfterFailure = true
        app.launch()
    }

    func testSkillMapRendersAfterTraining() {
        // 1. Screenshot Home baseline
        screenshot("01_home_baseline")

        // 2. Navigate to Lernstand tab
        let lernstandTab = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Lernstand'")).firstMatch
        guard lernstandTab.waitForExistence(timeout: 5) else { XCTFail("No Lernstand tab"); return }
        lernstandTab.tap()
        sleep(2)
        screenshot("02_lernstand_before_training")

        // 3. Collect visible texts
        let textsBeforeTraining = app.staticTexts.allElementsBoundByIndex.map { $0.label }
        print("=== LERNSTAND BEFORE ===")
        textsBeforeTraining.prefix(25).forEach { print("  \($0)") }

        // 4. Go back to Home, do a training session
        let homeTab = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Home'")).firstMatch
        homeTab.tap()
        sleep(1)

        let daily = app.buttons.matching(NSPredicate(format: "label CONTAINS 'ägliches Training'")).firstMatch
        guard daily.waitForExistence(timeout: 5) else { return }
        daily.tap()
        sleep(2)

        // Answer questions
        for _ in 0..<5 {
            let answers = app.buttons.allElementsBoundByIndex.filter { $0.exists && $0.isHittable && $0.frame.minY > 200 }
            guard let answer = answers.first else { break }
            answer.tap()
            sleep(1)
            let next = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Weiter' OR label CONTAINS 'ächste'")).firstMatch
            if next.waitForExistence(timeout: 1) { next.tap(); sleep(1) }
        }

        let beenden = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Beenden'")).firstMatch
        if beenden.waitForExistence(timeout: 3) { beenden.tap(); sleep(1) }

        // 5. Navigate to Lernstand again
        lernstandTab.tap()
        sleep(2)
        screenshot("03_lernstand_after_training")

        let textsAfterTraining = app.staticTexts.allElementsBoundByIndex.map { $0.label }
        print("=== LERNSTAND AFTER ===")
        textsAfterTraining.prefix(25).forEach { print("  \($0)") }

        // 6. Verify something is displayed
        XCTAssertFalse(textsAfterTraining.isEmpty, "Lernstand should show content")
    }

    private func screenshot(_ name: String) {
        let s = XCUIScreen.main.screenshot()
        let a = XCTAttachment(screenshot: s)
        a.name = name; a.lifetime = .keepAlways; add(a)
    }
}
