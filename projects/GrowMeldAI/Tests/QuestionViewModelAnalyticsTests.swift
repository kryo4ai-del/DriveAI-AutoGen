import XCTest
@testable import DriveAI

final class QuestionViewModelAnalyticsTests: XCTestCase {
    private var viewModel: QuestionViewModel!
    private var mockAnalytics: MockAnalyticsService!

    override func setUp() {
        super.setUp()
        mockAnalytics = MockAnalyticsService()
        viewModel = QuestionViewModel(analyticsService: mockAnalytics)
    }

    override func tearDown() {
        viewModel = nil
        mockAnalytics = nil
        super.tearDown()
    }

    func testSubmitAnswerLogsCorrectAnswer() {
        // Arrange
        let selectedOption = "A"
        let expectedEventName = "question_answered"

        // Act
        viewModel.submitAnswer(selectedOption: selectedOption)

        // Assert
        XCTAssertEqual(mockAnalytics.loggedEvents.count, 1)
        XCTAssertEqual(mockAnalytics.loggedEvents[0].0, expectedEventName)

        let parameters = mockAnalytics.loggedEvents[0].1
        XCTAssertEqual(parameters?["selected_option"] as? String, selectedOption)
    }

    func testSubmitAnswerLogsIncorrectAnswer() {
        // Arrange
        let selectedOption = "C" // Incorrect option
        let expectedEventName = "question_answered"

        // Act
        viewModel.submitAnswer(selectedOption: selectedOption)

        // Assert
        XCTAssertEqual(mockAnalytics.loggedEvents.count, 1)
        XCTAssertEqual(mockAnalytics.loggedEvents[0].0, expectedEventName)

        let parameters = mockAnalytics.loggedEvents[0].1
        XCTAssertEqual(parameters?["selected_option"] as? String, selectedOption)
        XCTAssertEqual(parameters?["is_correct"] as? Bool, false)
    }
}