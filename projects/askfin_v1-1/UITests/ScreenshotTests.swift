import XCTest

final class ScreenshotTests: XCTestCase {
    let app = XCUIApplication()

    override func setUp() {
        continueAfterFailure = true
        app.launch()
    }

    func testCaptureAllScreens() {
        // 1. Home
        sleep(2)
        screenshot("01_home")

        // 2. Lernstand
        let lernstand = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Lernstand'")).firstMatch
        if lernstand.waitForExistence(timeout: 3) { lernstand.tap(); sleep(2) }
        screenshot("02_lernstand")

        // 3. Generalprobe
        let generalprobe = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Generalprobe'")).firstMatch
        if generalprobe.waitForExistence(timeout: 3) { generalprobe.tap(); sleep(2) }
        screenshot("03_generalprobe")

        // 4. Verlauf
        let verlauf = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Verlauf'")).firstMatch
        if verlauf.waitForExistence(timeout: 3) { verlauf.tap(); sleep(2) }
        screenshot("04_verlauf")

        // 5. Training session (open from Home)
        let home = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Home'")).firstMatch
        if home.waitForExistence(timeout: 3) { home.tap(); sleep(1) }
        let daily = app.buttons.matching(NSPredicate(format: "label CONTAINS 'ägliches Training'")).firstMatch
        if daily.waitForExistence(timeout: 3) { daily.tap(); sleep(3) }
        screenshot("05_training")

        // Answer one question to get reveal screen
        let answers = app.buttons.allElementsBoundByIndex.filter { $0.exists && $0.isHittable && $0.frame.minY > 200 }
        if let answer = answers.first { answer.tap(); sleep(2) }
        screenshot("06_reveal")
    }

    private func screenshot(_ name: String) {
        let s = XCUIScreen.main.screenshot()
        let a = XCTAttachment(screenshot: s)
        a.name = name; a.lifetime = .keepAlways; add(a)
        // Also save to disk
        let data = s.pngRepresentation
            let url = URL(fileURLWithPath: "/Users/andreasott/DriveAI-AutoGen/projects/askfin_v1-1/screenshots/\(name).png")
            try? data.write(to: url)
    }
}
