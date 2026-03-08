import XCTest
@testable import DriveAI

class DemoFlowViewModelTests: XCTestCase {
    var viewModel: DemoFlowViewModel!
    var mockDataService: MockLocalDataService!

    override func setUp() {
        super.setUp()
        mockDataService = MockLocalDataService()
        viewModel = DemoFlowViewModel(dataService: mockDataService)
    }

    func testLoadQuestionsSuccess() {
        viewModel.loadQuestions()
        XCTAssertFalse(viewModel.questions.isEmpty, "Questions should be loaded successfully.")
    }

    func testLoadQuestionsFailure() {
        mockDataService.shouldReturnError = true
        viewModel.loadQuestions()
        XCTAssertNotNil(viewModel.errorMessage, "Should have an error message on failure.")
    }

    func testSubmitCorrectAnswer() {
        viewModel.questions = [QuestionModel(id: UUID(), question: "Test?", answers: [], correctAnswer: UUID())]
        let correctAnswerId = viewModel.questions[0].correctAnswer

        viewModel.submitAnswer(selectedAnswer: correctAnswerId)
        XCTAssertEqual(viewModel.correctAnswers, 1, "Correct answers count should increment.")
        XCTAssertEqual(viewModel.feedbackMessage, "Correct!", "Feedback message should indicate correctness.")
    }

    func testSubmitIncorrectAnswer() {
        viewModel.questions = [QuestionModel(id: UUID(), question: "Test?", answers: [], correctAnswer: UUID())]
        let incorrectAnswerId = UUID() // Assume this is not equal to the correct answer

        viewModel.submitAnswer(selectedAnswer: incorrectAnswerId)
        XCTAssertEqual(viewModel.correctAnswers, 0, "Correct answers count should not increment.")
        XCTAssertEqual(viewModel.feedbackMessage, "Incorrect!", "Feedback message should indicate incorrectness.")
    }

    // Additional tests for result calculation and rapid answer submissions can be added
}