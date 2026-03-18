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

extension GeneralprobeRuntimeTests {
    func testCTAButtonsAfterExam() {
        // Navigate to Generalprobe + complete exam
        let tab = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Generalprobe'")).firstMatch
        guard tab.waitForExistence(timeout: 5) else { return }
        tab.tap()
        sleep(2)

        let startBtn = app.buttons.matching(NSPredicate(
            format: "label CONTAINS 'Simulation starten' OR label CONTAINS 'Start'"
        )).firstMatch
        guard startBtn.waitForExistence(timeout: 5) else { return }
        startBtn.tap()
        sleep(2)

        // Answer all questions (wrong answers to trigger "not passed")
        for _ in 0..<35 {
            let answers = app.buttons.allElementsBoundByIndex.filter { $0.exists && $0.isHittable && $0.frame.minY > 150 }
            guard let answer = answers.last else { break } // pick LAST = likely wrong
            answer.tap()
            usleep(300000)
        }
        sleep(3)

        // Check which CTAs are visible
        let schwaechen = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Schwächen'")).firstMatch
        let antworten = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Antworten'")).firstMatch
        let nochmal = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Nochmal'")).firstMatch
        let fertig = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Fertig'")).firstMatch

        print("=== CTAs VISIBLE ===")
        print("  Schwächen trainieren: \(schwaechen.exists)")
        print("  Alle Antworten: \(antworten.exists)")
        print("  Nochmal simulieren: \(nochmal.exists)")
        print("  Fertig: \(fertig.exists)")

        // Tap "Alle Antworten ansehen" if available (opens sheet)
        if antworten.waitForExistence(timeout: 3) {
            antworten.tap()
            sleep(2)
            screenshot("cta_answer_review")

            // Dismiss sheet
            let dismissBtn = app.navigationBars.buttons.firstMatch
            if dismissBtn.waitForExistence(timeout: 3), dismissBtn.isHittable { dismissBtn.tap(); sleep(1) }
        }

        // Tap "Nochmal simulieren" if available
        if nochmal.waitForExistence(timeout: 3) {
            nochmal.tap()
            sleep(2)
            screenshot("cta_retry")
            // Should restart simulation — no crash = success
        }
    }
}

extension GeneralprobeRuntimeTests {
    func testFullInsightToActionLoop() {
        // 1. Generalprobe tab
        let tab = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Generalprobe'")).firstMatch
        guard tab.waitForExistence(timeout: 5) else { XCTFail("No Generalprobe tab"); return }
        tab.tap()
        sleep(2)

        // 2. Start simulation
        let startBtn = app.buttons.matching(NSPredicate(
            format: "label CONTAINS 'Simulation starten' OR label CONTAINS 'Start'"
        )).firstMatch
        guard startBtn.waitForExistence(timeout: 5) else { return }
        startBtn.tap()
        sleep(2)

        // 3. Answer all questions (pick last = likely wrong for fail result)
        for _ in 0..<35 {
            let answers = app.buttons.allElementsBoundByIndex.filter { $0.exists && $0.isHittable && $0.frame.minY > 150 }
            guard let answer = answers.last else { break }
            answer.tap()
            usleep(300000)
        }
        sleep(3)
        screenshot("loop_01_result")

        // 4. Result screen — tap a gap entry (if visible)
        let gapButtons = app.buttons.allElementsBoundByIndex.filter {
            $0.exists && $0.isHittable && $0.frame.minY > 200 && $0.frame.minY < 600
        }
        if let gapBtn = gapButtons.first {
            gapBtn.tap()
            sleep(2)
            screenshot("loop_02_drilldown")

            // 5. "Jetzt üben" CTA
            let trainBtn = app.buttons.matching(NSPredicate(
                format: "label CONTAINS 'Jetzt' OR label CONTAINS 'üben'"
            )).firstMatch
            if trainBtn.waitForExistence(timeout: 3) {
                trainBtn.tap()
                sleep(2)
                screenshot("loop_03_training")

                // 6. Training opened — dismiss
                let beenden = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Beenden'")).firstMatch
                if beenden.waitForExistence(timeout: 5) {
                    beenden.tap()
                    sleep(1)
                }
            } else {
                // Dismiss drilldown
                let fertig = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Fertig'")).firstMatch
                if fertig.waitForExistence(timeout: 3) { fertig.tap() }
            }
        }

        screenshot("loop_04_end")
        // No crash = full loop validated
    }
}
