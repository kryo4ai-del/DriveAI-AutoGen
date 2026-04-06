// Tests/Unit/ViewModelTests/QuestionScreenViewModelTests.swift
@MainActor
final class QuestionScreenViewModelTests: XCTestCase {
    var viewModel: QuestionScreenViewModel!
    var mockDataService: MockLocalDataService!
    
    override func setUp() {
        super.setUp()
        mockDataService = MockLocalDataService()
        viewModel = QuestionScreenViewModel(
            localDataService: mockDataService,
            userProgressService: MockUserProgressService(),
            category: .trafficSigns
        )
    }
    
    func testSelectCorrectAnswer() async {
        // Arrange
        let question = Question(id: UUID(), text: "Test", options: [...])
        viewModel.currentQuestion = question
        
        // Act
        viewModel.selectAnswer(question.options[0].id)
        
        // Assert
        XCTAssertTrue(viewModel.isCorrect ?? false)
        XCTAssertTrue(viewModel.showFeedback)
    }
    
    func testTimerCountdown() async {
        // Arrange
        let initialElapsed = viewModel.elapsedSeconds
        
        // Act
        viewModel.startTimer()
        try? await Task.sleep(nanoseconds: 1_100_000_000)  // 1.1 seconds
        
        // Assert
        XCTAssertGreaterThan(viewModel.elapsedSeconds, initialElapsed)
    }
}