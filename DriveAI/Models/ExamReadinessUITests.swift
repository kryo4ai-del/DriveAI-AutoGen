// Tests/ExamReadiness/ExamReadinessUITests.swift
class ExamReadinessUITests: XCTestCase {
    func test_readinessScoreCard_displaysScore() {
        let app = XCUIApplication()
        app.launch()
        
        app.tabBars.buttons["Exam Readiness"].tap()
        
        let scoreText = app.staticTexts["readiness.score.78.percent"]
        XCTAssertTrue(scoreText.exists)
    }
}