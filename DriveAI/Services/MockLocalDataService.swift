import XCTest
import Combine

// Mock LocalDataService for testing
class MockLocalDataService: LocalDataServiceProtocol {
    var shouldThrowError = false
    
    func fetchQuestions() throws -> [Question] {
        if shouldThrowError {
            throw NSError(domain: "", code: -1, userInfo: nil)
        }
        return [Question(text: "Was ist ein Fußgängerüberweg?", options: ["Stoppschild", "Zebra", "Ampel"], correctAnswerIndex: 1)]
    }
}

class TestFixViewModelTests: XCTestCase {
    var viewModel: TestFixViewModel!
    var mockService: MockLocalDataService!

    override func setUp() {
        super.setUp()
        mockService = MockLocalDataService()
        viewModel = TestFixViewModel(dataService: mockService)
    }

    override func tearDown() {
        viewModel = nil
        mockService = nil
        super.tearDown()
    }

    func testInitializationWithMockData() {
        XCTAssertGreaterThan(viewModel.questions.count, 0, "Questions should be populated with mock data.")
    }

    func testScoreInitialization() {
        XCTAssertEqual(viewModel.score, 0, "Score should start at zero.")
    }

    func testLoadQuestionsSuccess() {
        mockService.shouldThrowError = false
        viewModel.loadQuestions()
        
        XCTAssertEqual(viewModel.questions.count, 1, "Questions should be successfully fetched.")
        XCTAssertEqual(viewModel.questions.first?.text, "Was ist ein Fußgängerüberweg?", "Mock question text should match.")
    }

    func testLoadQuestionsFailure() {
        mockService.shouldThrowError = true
        viewModel.loadQuestions()
        
        XCTAssertEqual(viewModel.questions.count, 1, "Questions should contain mock data on failure.")
        XCTAssertEqual(viewModel.questions.first?.text, "Was ist ein Fußgängerüberweg?", "Fallback question text should match.")
    }
    
    func testValidAnswerSelection() {
        viewModel.questions = mockQuestions()
        viewModel.selectAnswer(1) // Assuming answer index 1 (correct)
        
        XCTAssertTrue(viewModel.isAnswerCorrect ?? false, "isAnswerCorrect should be true for a correct answer.")
        XCTAssertEqual(viewModel.score, 1, "Score should increment for a correct answer.")
    }

    func testInvalidAnswerSelection() {
        viewModel.questions = mockQuestions()
        viewModel.selectAnswer(0) // Assuming answer index 0 (incorrect)
        
        XCTAssertFalse(viewModel.isAnswerCorrect ?? true, "isAnswerCorrect should be false for an incorrect answer.")
        XCTAssertEqual(viewModel.score, 0, "Score should remain the same for an incorrect answer.")
    }

    func testMoveToNextQuestionOnAnswerSelection() {
        viewModel.questions = mockQuestions()
        viewModel.selectAnswer(1) // Answer the first question

        XCTAssertEqual(viewModel.currentQuestionIndex, 1, "Should move to the next question after answering.")
    }

    func testCompleteTestOnLastQuestion() {
        viewModel.questions = mockQuestions()
        viewModel.currentQuestionIndex = viewModel.questions.count - 1 // Set to last question
        viewModel.selectAnswer(1) // Answer last question
        
        XCTAssertTrue(viewModel.isTestCompleted, "isTestCompleted should be true after last question.")
    }

    func testResetFunctionality() {
        viewModel.resetTest()
        
        XCTAssertEqual(viewModel.currentQuestionIndex, 0, "currentQuestionIndex should be reset to 0.")
        XCTAssertEqual(viewModel.score, 0, "Score should be reset to 0.")
        XCTAssertFalse(viewModel.isTestCompleted, "isTestCompleted should be false after reset.")
    }

    func testResetCompletenessCallback() {
        let expectation = self.expectation(description: "Completion handler is called")
        
        viewModel.resetTest {
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testAnswerSelectionWithNoSelection() {
        viewModel.selectAnswer(nil) // Test invalid selection
        
        XCTAssertEqual(viewModel.currentQuestionIndex, 0, "currentQuestionIndex should not change.")
        XCTAssertNil(viewModel.isAnswerCorrect, "isAnswerCorrect should remain nil.")
    }

    func testAdvanceToNextQuestionFromLastQuestion() {
        viewModel.questions = mockQuestions()
        viewModel.currentQuestionIndex = viewModel.questions.count - 1 // On last question
        viewModel.selectAnswer(1) // Answer last question
        
        XCTAssertEqual(viewModel.currentQuestionIndex, viewModel.questions.count - 1, "Should not move past the last question.")
    }

    // Helper functions for mock data
    private func mockQuestions() -> [Question] {
        return [
            Question(text: "Was ist ein Fußgängerüberweg?", options: ["Stoppschild", "Zebra", "Ampel"], correctAnswerIndex: 1),
            Question(text: "Was zeigt das Rotlicht an?", options: ["Fahren", "Anhalten", "Biegen"], correctAnswerIndex: 1)
        ]
    }
}