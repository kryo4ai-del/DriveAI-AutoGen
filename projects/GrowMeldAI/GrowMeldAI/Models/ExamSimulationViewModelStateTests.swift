@MainActor
final class ExamSimulationViewModelStateTests: XCTestCase {
    var viewModel: ExamSimulationViewModel!
    var mockDataService: MockLocalDataService!
    
    override func setUp() {
        super.setUp()
        mockDataService = MockLocalDataService()
        viewModel = ExamSimulationViewModel(
            dataService: mockDataService,
            timerService: TimerService()
        )
    }
    
    // HAPPY PATH: Complete exam flow
    func testCompleteExamFlow() async {
        // Arrange
        mockDataService.mockQuestions = createMockQuestions(count: 30)
        
        // Act 1: Start exam
        await viewModel.startExam()
        
        // Assert
        XCTAssertEqual(viewModel.examState, .active)
        XCTAssertEqual(viewModel.questions.count, 30)
        XCTAssertEqual(viewModel.currentIndex, 0)
        
        // Act 2: Answer questions
        for i in 0..<30 {
            viewModel.submitAnswer(0, for: viewModel.questions[i].id)
            viewModel.nextQuestion()
        }
        
        // Act 3: Finish exam
        viewModel.finishExam()
        
        // Assert
        XCTAssertEqual(viewModel.examState, .submitted)
        XCTAssertNotNil(viewModel.score)
    }
    
    // EDGE CASE: Exam without answering any questions
    func testExamWithoutAnswers() async {
        // Arrange
        mockDataService.mockQuestions = createMockQuestions(count: 30)
        
        // Act
        await viewModel.startExam()
        viewModel.finishExam()
        
        // Assert
        XCTAssertEqual(viewModel.score, 0)
        XCTAssertFalse(viewModel.passed)
    }
    
    // ERROR CASE: Fail to fetch questions
    func testExamStartFailure() async {
        // Arrange
        mockDataService.shouldFail = true
        
        // Act
        await viewModel.startExam()
        
        // Assert
        XCTAssertEqual(viewModel.examState, .failed)
    }
    
    private func createMockQuestions(count: Int) -> [Question] {
        (0..<count).map { i in
            Question(
                id: "q\(i)",
                text: "Question \(i)?",
                category: "test",
                options: ["A", "B", "C", "D"],
                correctAnswerIndex: i % 4,
                explanation: "Explanation"
            )
        }
    }
}