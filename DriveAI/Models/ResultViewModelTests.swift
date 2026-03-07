import XCTest
@testable import DriveAI  // Adjust the import according to your project structure

final class ResultViewModelTests: XCTestCase {
    
    var viewModel: ResultViewModel!

    override func setUp() {
        super.setUp()
        viewModel = ResultViewModel()
    }

    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }

    func testEvaluateResults_PassScenario() {
        viewModel.evaluateResults(userScore: 24)
        XCTAssertTrue(viewModel.state.isPassed)
        XCTAssertEqual(viewModel.state.feedbackMessage, "Gratulation! Sie haben bestanden! Bereiten Sie sich weiterhin vor.")
        XCTAssertEqual(viewModel.state.scoreBreakdown, ["Correct": 24, "Incorrect": 6])
    }
    
    func testEvaluateResults_FailScenario() {
        viewModel.evaluateResults(userScore: 17)
        XCTAssertFalse(viewModel.state.isPassed)
        XCTAssertEqual(viewModel.state.feedbackMessage, "Leider nicht bestanden. Besuchen Sie die Lernseite für zusätzliche Fragen.")
        XCTAssertEqual(viewModel.state.scoreBreakdown, ["Correct": 17, "Incorrect": 13])
    }
    
    func testEvaluateResults_MinimumPassingScore() {
        viewModel.evaluateResults(userScore: 18)
        XCTAssertTrue(viewModel.state.isPassed)
        XCTAssertEqual(viewModel.state.feedbackMessage, "Gratulation! Sie haben bestanden! Bereiten Sie sich weiterhin vor.")
        XCTAssertEqual(viewModel.state.scoreBreakdown, ["Correct": 18, "Incorrect": 12])
    }
    
    func testEvaluateResults_MaximumScore() {
        viewModel.evaluateResults(userScore: 30)
        XCTAssertTrue(viewModel.state.isPassed)
        XCTAssertEqual(viewModel.state.feedbackMessage, "Gratulation! Sie haben bestanden! Bereiten Sie sich weiterhin vor.")
        XCTAssertEqual(viewModel.state.scoreBreakdown, ["Correct": 30, "Incorrect": 0])
    }
    
    func testEvaluateResults_ZeroScore() {
        viewModel.evaluateResults(userScore: 0)
        XCTAssertFalse(viewModel.state.isPassed)
        XCTAssertEqual(viewModel.state.feedbackMessage, "Leider nicht bestanden. Besuchen Sie die Lernseite für zusätzliche Fragen.")
        XCTAssertEqual(viewModel.state.scoreBreakdown, ["Correct": 0, "Incorrect": 30])
    }
    
    func testEvaluateResults_NegativeScore() {
        viewModel.evaluateResults(userScore: -5)
        XCTAssertFalse(viewModel.state.isPassed) // Should remain false due to invalid input
        XCTAssertEqual(viewModel.state.scoreBreakdown, ["Correct": 0, "Incorrect": 30]) // Assumption: fallback to zero
    }
    
    func testEvaluateResults_ExceptionHandling() {
        viewModel.evaluateResults(userScore: Int.min)  // Testing extreme negative input
        XCTAssertEqual(viewModel.state.scoreBreakdown, ["Correct": 0, "Incorrect": 30]) // Reiterate fallback logic
    }

    func testValidateFeedbackGeneration() {
        viewModel.evaluateResults(userScore: 29)
        XCTAssertEqual(viewModel.state.feedbackMessage, "Gratulation! Sie haben bestanden! Bereiten Sie sich weiterhin vor.")
    }

    func testDynamicPassingRateChanges() {
        // Assuming the method setPassingRate(to:) is implemented in ResultViewModel
        viewModel.setPassingRate(to: 0.7) // This method should allow changing the passing criteria
        viewModel.evaluateResults(userScore: 21)
        XCTAssertFalse(viewModel.state.isPassed) // Should now be false due to the increased passing rate
        XCTAssertEqual(viewModel.state.feedbackMessage, "Leider nicht bestanden. Besuchen Sie die Lernseite für zusätzliche Fragen.")
    }
}