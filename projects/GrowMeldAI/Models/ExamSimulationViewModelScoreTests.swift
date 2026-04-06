import XCTest
@testable import DriveAI

@MainActor
final class ExamSimulationViewModelScoreTests: XCTestCase {
    var viewModel: ExamSimulationViewModel!
    var mockDataService: MockLocalDataService!
    var mockTimerService: TimerService!
    
    override func setUp() {
        super.setUp()
        mockDataService = MockLocalDataService()
        mockTimerService = TimerService()
        viewModel = ExamSimulationViewModel(
            dataService: mockDataService,
            timerService: mockTimerService
        )
    }
    
    // HAPPY PATH: Perfect score
    func testCalculateScorePerfect() async {
        // Arrange
        let questions = createMockQuestions(count: 30)
        viewModel.questions = questions
        
        var answers: [String: Int] = [:]
        for question in questions {
            answers[question.id] = question.correctAnswerIndex
        }
        viewModel.answers = answers
        
        // Act
        viewModel.finishExam()
        
        // Assert
        XCTAssertEqual(viewModel.score, 100, "Perfect score should be 100")
        XCTAssertTrue(viewModel.passed, "Should pass with 100%")
    }
    
    // HAPPY PATH: Passing score (≥70%)
    func testCalculateScorePassingGrade() async {
        // Arrange
        let questions = createMockQuestions(count: 30)
        viewModel.questions = questions
        
        var answers: [String: Int] = [:]
        for (index, question) in questions.enumerated() {
            // 21/30 = 70% exactly
            answers[question.id] = index < 21 ? question.correctAnswerIndex : 999
        }
        viewModel.answers = answers
        
        // Act
        viewModel.finishExam()
        
        // Assert
        XCTAssertEqual(viewModel.score, 70)
        XCTAssertTrue(viewModel.passed)
    }
    
    // EDGE CASE: Failing score (69%)
    func testCalculateScoreFailingGrade() async {
        // Arrange
        let questions = createMockQuestions(count: 30)
        viewModel.questions = questions
        
        var answers: [String: Int] = [:]
        for (index, question) in questions.enumerated() {
            // 20/30 = 66.67%
            answers[question.id] = index < 20 ? question.correctAnswerIndex : 999
        }
        viewModel.answers = answers
        
        // Act
        viewModel.finishExam()
        
        // Assert
        XCTAssertEqual(viewModel.score, 66)
        XCTAssertFalse(viewModel.passed, "Should fail below 70%")
    }
    
    // EDGE CASE: Zero score
    func testCalculateScoreZero() async {
        // Arrange
        let questions = createMockQuestions(count: 30)
        viewModel.questions = questions
        viewModel.answers = [:] // No answers submitted
        
        // Act
        viewModel.finishExam()
        
        // Assert
        XCTAssertEqual(viewModel.score, 0)
        XCTAssertFalse(viewModel.passed)
    }
    
    // EDGE CASE: Partial answers (11/30 answered)
    func testCalculateScorePartialAnswers() async {
        // Arrange
        let questions = createMockQuestions(count: 30)
        viewModel.questions = questions
        
        var answers: [String: Int] = [:]
        for i in 0..<11 {
            answers[questions[i].id] = questions[i].correctAnswerIndex
        }
        viewModel.answers = answers
        
        // Act
        viewModel.finishExam()
        
        // Assert: Score based on submitted answers only
        XCTAssertEqual(viewModel.score, 36) // 11/30 = 36.67%
        XCTAssertFalse(viewModel.passed)
    }
    
    // BUG TEST: Invalid answer index (out of bounds)
    func testCalculateScoreInvalidAnswerIndex() async {
        // Arrange
        let questions = createMockQuestions(count: 5)
        viewModel.questions = questions
        
        var answers: [String: Int] = [:]
        answers[questions[0].id] = questions[0].correctAnswerIndex // Valid
        answers[questions[1].id] = 999 // Invalid index
        answers[questions[2].id] = -1 // Negative index
        for i in 3..<5 {
            answers[questions[i].id] = questions[i].correctAnswerIndex
        }
        viewModel.answers = answers
        
        // Act
        viewModel.finishExam()
        
        // Assert: Invalid answers count as incorrect
        XCTAssertEqual(viewModel.score, 60) // 3/5 correct
    }
    
    // EDGE CASE: Empty questions array
    func testCalculateScoreEmptyQuestions() async {
        // Arrange
        viewModel.questions = []
        viewModel.answers = [:]
        
        // Act
        viewModel.finishExam()
        
        // Assert: Avoid division by zero
        XCTAssertEqual(viewModel.score, 0)
    }
    
    // Helper
    private func createMockQuestions(count: Int) -> [Question] {
        (0..<count).map { i in
            Question(
                id: "q\(i)",
                text: "Question \(i)?",
                category: "test",
                options: ["A", "B", "C", "D"],
                correctAnswerIndex: 0,
                explanation: "Correct is A"
            )
        }
    }
}