class ExamViewModelTests: XCTestCase {
    var sut: ExamViewModel! // System Under Test
    var mockDataService: MockLocalDataService!
    
    override func setUp() {
        super.setUp()
        mockDataService = MockLocalDataService()
        sut = ExamViewModel(dataService: mockDataService)
    }
    
    func test_submitAnswer_correctAnswerIncrementsScore() {
        // Arrange
        sut.loadExamQuestions()
        let question = sut.examQuestions[0]
        let correctAnswer = question.correctAnswer
        
        // Act
        sut.submitAnswer(correctAnswer)
        
        // Assert
        XCTAssertEqual(sut.score, 1)
        XCTAssertTrue(sut.isCorrect)
    }
    
    func test_examCompletion_30Questions_CalculatesPassFail() {
        // Arrange
        sut.loadExamQuestions()
        sut.answers = Array(repeating: true, count: 21) // 21/30 correct
        
        // Act
        let result = sut.getResult()
        
        // Assert
        XCTAssertTrue(result.isPassed) // ≥70% pass
        XCTAssertEqual(result.score, 21)
    }
}