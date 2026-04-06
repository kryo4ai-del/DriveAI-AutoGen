// Features/TrialMechanik/Tests/TrialUITests.swift

class TrialUITests: XCTestCase {
    func testQuotaExhaustedFlow() {
        app.launch()
        
        // Answer 5 questions
        for i in 0..<5 {
            answerQuestion(option: "A")
        }
        
        // Verify paywall overlay appears
        XCTAssert(app.staticTexts["quotaExhaustedTitle"].exists)
    }
}