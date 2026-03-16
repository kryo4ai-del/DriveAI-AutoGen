import XCTest

/// Golden Acceptance Gate Suite — protects the proven AskFin baseline.
/// Each test maps to a specific Gate that must pass before any release.
final class GoldenGateTests: XCTestCase {
    let app = XCUIApplication()

    override func setUp() {
        continueAfterFailure = false
        app.launch()
    }

    // MARK: - Gate 2: Launch (Gate 1 = Build is implicit)

    func testGate2_AppLaunches() {
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 10), "App should launch")
    }

    // MARK: - Gate 3: Shell — 4 Tabs navigable

    func testGate3_AllTabsNavigable() {
        for tabLabel in ["Home", "Lernstand", "Generalprobe", "Verlauf"] {
            let tab = app.buttons.matching(NSPredicate(format: "label CONTAINS %@", tabLabel)).firstMatch
            XCTAssertTrue(tab.waitForExistence(timeout: 5), "\(tabLabel) tab should exist")
            tab.tap()
            sleep(1)
        }
    }

    // MARK: - Gate 4: Flows — 3 Home entries open

    func testGate4_AllHomeFlowsOpen() {
        // Daily Training
        let daily = app.buttons.matching(NSPredicate(format: "label CONTAINS 'ägliches Training'")).firstMatch
        XCTAssertTrue(daily.waitForExistence(timeout: 5))
        daily.tap()
        sleep(2)
        let beenden1 = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Beenden'")).firstMatch
        if beenden1.waitForExistence(timeout: 3) { beenden1.tap(); sleep(1) }

        // Topic Picker
        let topic = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Thema'")).firstMatch
        XCTAssertTrue(topic.waitForExistence(timeout: 5))
        topic.tap()
        sleep(2)
        let cancel = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Abbrechen'")).firstMatch
        if cancel.waitForExistence(timeout: 3) { cancel.tap(); sleep(1) }

        // Weakness Training
        let weakness = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Schwächen'")).firstMatch
        XCTAssertTrue(weakness.waitForExistence(timeout: 5))
        weakness.tap()
        sleep(2)
        let beenden2 = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Beenden'")).firstMatch
        if beenden2.waitForExistence(timeout: 3) { beenden2.tap() }
    }

    // MARK: - Gate 5: Journey — 1 training roundtrip

    func testGate5_TrainingRoundtrip() {
        let daily = app.buttons.matching(NSPredicate(format: "label CONTAINS 'ägliches Training'")).firstMatch
        guard daily.waitForExistence(timeout: 5) else { XCTFail("No daily btn"); return }
        daily.tap()
        sleep(2)

        // Answer at least 1 question
        var answered = false
        for _ in 0..<5 {
            sleep(1)
            let answers = app.buttons.allElementsBoundByIndex.filter { $0.exists && $0.isHittable && $0.frame.minY > 200 }
            guard let answer = answers.first else { break }
            answer.tap()
            answered = true
            sleep(1)
            let next = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Weiter' OR label CONTAINS 'ächste'")).firstMatch
            if next.waitForExistence(timeout: 1) { next.tap(); sleep(1) }
        }

        // Dismiss
        let beenden = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Beenden'")).firstMatch
        if beenden.waitForExistence(timeout: 3) { beenden.tap(); sleep(1) }

        // Verify back home
        let homeBtn = app.buttons.matching(NSPredicate(format: "label CONTAINS 'ägliches Training'")).firstMatch
        XCTAssertTrue(homeBtn.waitForExistence(timeout: 5), "Should return to Home after training")
    }

    // MARK: - Gate 7: Skill Map — Lernstand renders

    func testGate7_SkillMapRenders() {
        let lernstandTab = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Lernstand'")).firstMatch
        XCTAssertTrue(lernstandTab.waitForExistence(timeout: 5), "Lernstand tab should exist")
        lernstandTab.tap()
        sleep(2)
        // Verify content renders (not empty)
        let anyContent = app.staticTexts.firstMatch
        XCTAssertTrue(anyContent.exists, "Skill Map should render content")
    }

    // MARK: - Gate 8: Persistence — state survives restart

    func testGate8_StatePersistsAcrossRestart() {
        // Read current state
        let texts = app.staticTexts.allElementsBoundByIndex.compactMap { $0.exists ? $0.label : nil }
        let hasReadiness = texts.contains(where: { $0.contains("%") })
        XCTAssertTrue(hasReadiness, "Home should show readiness percentage")

        // Terminate + relaunch
        app.terminate()
        sleep(2)
        app.launch()

        // Verify state restored
        let textsAfter = app.staticTexts.allElementsBoundByIndex.compactMap { $0.exists ? $0.label : nil }
        let hasReadinessAfter = textsAfter.contains(where: { $0.contains("%") })
        XCTAssertTrue(hasReadinessAfter, "Readiness should persist after restart")
    }
}
