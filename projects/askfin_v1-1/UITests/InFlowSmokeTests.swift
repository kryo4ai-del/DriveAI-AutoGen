import XCTest

final class InFlowSmokeTests: XCTestCase {
    let app = XCUIApplication()

    override func setUp() {
        continueAfterFailure = true
        app.launch()
    }

    func testDailyTrainingFlow() {
        let btn = app.buttons.matching(NSPredicate(format: "label CONTAINS 'ägliches Training'")).firstMatch
        guard btn.waitForExistence(timeout: 5) else {
            XCTFail("Tägliches Training button not found")
            return
        }
        btn.tap()
        sleep(2)

        let screenshot1 = XCUIScreen.main.screenshot()
        let attach1 = XCTAttachment(screenshot: screenshot1)
        attach1.name = "daily_training_opened"
        attach1.lifetime = .keepAlways
        add(attach1)

        let anyText = app.staticTexts.firstMatch
        XCTAssertTrue(anyText.exists, "Flow should show content")

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

        let firstButton = app.buttons.element(boundBy: 1)
        if firstButton.waitForExistence(timeout: 2) {
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

        let beenden = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Beenden'")).firstMatch
        if beenden.waitForExistence(timeout: 2) {
            beenden.tap()
        }
    }
}
