// ViewModel test scaffold
class QuizSessionViewModelTests: XCTestCase {
    var sut: QuizSessionViewModel!
    var mockProgressService: MockProgressService!
    
    override func setUp() {
        super.setUp()
        mockProgressService = MockProgressService()
        sut = QuizSessionViewModel(progressService: mockProgressService)
    }
    
    @MainActor
    func testAnswerRecordedCorrectly() async {
        // Arrange
        let question = Question.mock
        
        // Act
        await sut.recordAnswer(question.id, isCorrect: true)
        
        // Assert
        XCTAssertEqual(mockProgressService.recordedAnswers.count, 1)
    }
}