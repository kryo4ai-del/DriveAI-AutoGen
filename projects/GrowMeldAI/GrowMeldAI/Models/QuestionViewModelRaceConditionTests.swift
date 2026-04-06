@MainActor
final class QuestionViewModelRaceConditionTests: XCTestCase {
    var viewModel: QuestionViewModel!
    var mockExamService: MockExamService!
    
    override func setUp() {
        super.setUp()
        mockExamService = MockExamService()
        viewModel = QuestionViewModel(
            questionRepository: MockQuestionRepository(),
            examService: mockExamService
        )
    }
    
    func testSubmitAnswerStateIsImmediatelyConsistent() async {
        // Arrange
        let question = Question(
            id: UUID(),
            categoryId: UUID(),
            text: "Test",
            imageUrl: nil,
            options: [
                AnswerOption(id: UUID(), text: "A"),
                AnswerOption(id: UUID(), text: "B")
            ],
            correctAnswerId: UUID(),
            explanation: "Correct answer",
            difficulty: 1,
            timesAnsweredCorrectly: 0,
            timesAnsweredWrong: 0
        )
        
        viewModel.currentQuestion = question
        let selectedId = question.options[0].id
        
        // Act
        viewModel.submitAnswer(selectedId)
        
        // Assert (state is consistent immediately)
        XCTAssertEqual(viewModel.selectedAnswerId, selectedId)
        XCTAssertNotNil(viewModel.feedback)
        XCTAssertEqual(viewModel.feedback?.isCorrect, selectedId == question.correctAnswerId)
        
        // Give async recording time to complete
        try await Task.sleep(nanoseconds: 100_000_000)
    }
}