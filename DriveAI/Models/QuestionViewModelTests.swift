class QuestionViewModelTests: XCTestCase {
    func testSubmitCorrectAnswer() {
        let viewModel = QuestionViewModel()
        viewModel.loadQuestion()
        let result = viewModel.submitAnswer(viewModel.currentQuestion.correctAnswer)
        XCTAssertTrue(result)
    }
    
    func testAdvanceToNextQuestion() {
        let viewModel = QuestionViewModel()
        viewModel.loadQuestion()
        let currentIndex = viewModel.currentQuestionIndex
        viewModel.advanceToNextQuestion()
        XCTAssertEqual(viewModel.currentQuestionIndex, currentIndex + 1)
    }
}