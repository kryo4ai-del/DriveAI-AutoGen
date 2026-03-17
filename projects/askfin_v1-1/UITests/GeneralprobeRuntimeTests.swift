import XCTest

final class GeneralprobeRuntimeTests: XCTestCase {
    let app = XCUIApplication()

    override func setUp() {
        continueAfterFailure = true
        app.launch()
    }

    func testGeneralprobeFlow() {
        // 1. Navigate to Generalprobe tab
        let tab = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Generalprobe'")).firstMatch
        guard tab.waitForExistence(timeout: 5) else { XCTFail("No Generalprobe tab"); return }
        tab.tap()
        sleep(2)
        screenshot("01_generalprobe_prestart")

        // 2. Check pre-start content
        let preStartTexts = app.staticTexts.allElementsBoundByIndex.map { $0.label }
        print("=== PRE-START ===")
        preStartTexts.prefix(10).forEach { print("  \($0)") }

        // 3. Start simulation
        let startBtn = app.buttons.matching(NSPredicate(
            format: "label CONTAINS 'Simulation starten' OR label CONTAINS 'Starten' OR label CONTAINS 'Start'"
        )).firstMatch

        guard startBtn.waitForExistence(timeout: 5) else {
            print("No start button found — pre-start may need data loading")
            screenshot("01b_no_start_button")
            return
        }
        startBtn.tap()
        sleep(2)
        screenshot("02_simulation_started")

        // 4. Answer 3-5 questions
        var answered = 0
        for _ in 0..<5 {
            sleep(1)
            // Look for answer buttons (A/B/C/D style)
            let answerBtns = app.buttons.allElementsBoundByIndex.filter {
                $0.exists && $0.isHittable && $0.frame.minY > 150
            }
            guard let answer = answerBtns.first else { break }
            answer.tap()
            answered += 1
            sleep(1)
        }

        screenshot("03_after_answers")
        print("=== ANSWERED: \(answered) ===")

        // 5. Check current state
        let currentTexts = app.staticTexts.allElementsBoundByIndex.map { $0.label }
        print("=== CURRENT STATE ===")
        currentTexts.prefix(10).forEach { print("  \($0)") }
    }

    private func screenshot(_ name: String) {
        let s = XCUIScreen.main.screenshot()
        let a = XCTAttachment(screenshot: s)
        a.name = name; a.lifetime = .keepAlways; add(a)
    }
}

extension GeneralprobeRuntimeTests {
    func testWeaknessAnalysisAfterExam() {
        let tab = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Generalprobe'")).firstMatch
        guard tab.waitForExistence(timeout: 5) else { XCTFail("No Generalprobe tab"); return }
        tab.tap()
        sleep(2)

        let startBtn = app.buttons.matching(NSPredicate(
            format: "label CONTAINS 'Simulation starten' OR label CONTAINS 'Start'"
        )).firstMatch
        guard startBtn.waitForExistence(timeout: 5) else { return }
        startBtn.tap()
        sleep(2)

        for _ in 0..<35 {
            let answers = app.buttons.allElementsBoundByIndex.filter { $0.exists && $0.isHittable && $0.frame.minY > 150 }
            guard let answer = answers.first else { break }
            answer.tap()
            usleep(300000)
        }

        sleep(3)
        screenshot("weakness_result_screen")

        let resultTexts = app.staticTexts.allElementsBoundByIndex.map { $0.label }
        print("=== RESULT SCREEN ===")
        resultTexts.prefix(20).forEach { print("  \($0)") }

        XCTAssertFalse(resultTexts.isEmpty, "Result screen should show content")
    }
}
