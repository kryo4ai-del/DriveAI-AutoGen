@MainActor
final class EdgeCaseTests: XCTestCase {
    private var viewModel: QuestionViewModel!
    
    override func setUp() {
        super.setUp()
        viewModel = QuestionViewModel(
            dataService: MockLocalDataService(),
            progressService: MockProgressService()
        )
    }
    
    func testSelectAnswer_WithIndexOutOfRange_DoesNotCrash() {
        let question = Question(
            id: "Q1",
            text: "Test?",
            answers: ["A", "B"],
            correctIndex: 0,
            explanation: "A"
        )
        viewModel.currentQuestion = question
        
        // Out of bounds — should be handled gracefully
        viewModel.selectAnswer(10)
        
        XCTAssertNil(viewModel.selectedAnswer)
        XCTAssertFalse(viewModel.showFeedback)
    }
    
    func testQuestionWithEmptyAnswers_IsRejected() throws {
        let invalidJson = """
        {
            "id": "Q1",
            "text": "Test?",
            "answers": [],
            "correctIndex": 0,
            "explanation": "A"
        }
        """
        
        XCTAssertThrowsError(
            try JSONDecoder().decode(Question.self, from: invalidJson.data(using: .utf8)!)
        )
    }
    
    func testExamWith0SecondsRemaining_DoesNotCrash() async throws {
        let examVM = ExamSimulationViewModel(examService: MockExamService())
        examVM.startExam()
        examVM.timeRemaining = 0
        
        // Trying to select answer should fail gracefully
        examVM.selectAnswer(0)
        
        XCTAssertFalse(examVM.canSelectAnswer)
    }
}