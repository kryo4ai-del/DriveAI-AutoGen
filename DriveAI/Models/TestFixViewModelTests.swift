import XCTest
@testable import DriveAI

class TestFixViewModelTests: XCTestCase {
    var viewModel: TestFixViewModel!
    var mockService: MockTestFixService!

    override func setUp() {
        super.setUp()
        mockService = MockTestFixService()
        viewModel = TestFixViewModel(service: mockService)
    }

    override func tearDown() {
        viewModel = nil
        mockService = nil
        super.tearDown()
    }

    // Initialization Tests
    func testInitialization() {
        XCTAssertTrue(viewModel.questions.isEmpty, "Questions should be empty upon initialization.")
        XCTAssertFalse(viewModel.isLoading, "Loading should be false immediately after initialization.")
    }

    // Load Questions Tests
    func testLoadQuestionsSuccess() {
        mockService.shouldReturnValidQuestions = true
        viewModel.loadQuestions()
        
        XCTAssertFalse(viewModel.isLoading, "Loading should be false after questions are loaded.")
        XCTAssertGreaterThan(viewModel.questions.count, 0, "Questions should be loaded successfully.")
    }

    func testLoadQuestionsFailure() {
        mockService.shouldThrowError = true
        viewModel.loadQuestions()

        XCTAssertNotNil(viewModel.loadError, "Load error should be set when fetching fails.")
        XCTAssertEqual(viewModel.questions.count, 2, "Mock questions should be loaded as fallback.")
    }

    func testLoadQuestionsLoadingState() {
        viewModel.loadQuestions()
        XCTAssertTrue(viewModel.isLoading, "Loading should be true while questions are being fetched.")
    }

    // Answer Selection Tests
    func testValidAnswerSelection() {
        viewModel.loadQuestions()
        viewModel.selectAnswer(1) // Assuming index 1 is correct
        
        XCTAssertTrue(viewModel.isAnswerCorrect ?? false, "isAnswerCorrect should be true for a correct answer.")
        XCTAssertEqual(viewModel.score, 1, "Score should increase for correct answers.")
    }

    func testInvalidAnswerSelection() {
        viewModel.loadQuestions()
        viewModel.selectAnswer(-1)

        XCTAssertEqual(viewModel.loadError, "Ungültige Antwortauswahl.", "Should show error message for invalid selection.")
    }

    // Reset Functionality Tests
    func testResetFunctionality() {
        viewModel.loadQuestions()
        viewModel.selectAnswer(1)
        viewModel.resetTest()
        
        XCTAssertEqual(viewModel.currentQuestionIndex, 0, "currentQuestionIndex should reset to 0.")
        XCTAssertEqual(viewModel.score, 0, "Score should reset to 0.")
        XCTAssertNil(viewModel.loadError, "Load error should reset to nil.")
    }

    // Edge Cases Tests
    func testCurrentQuestionValidation() {
        viewModel.loadQuestions()
        viewModel.currentQuestionIndex = 10
        XCTAssertFalse(viewModel.isCurrentQuestionValid(), "should validate out-of-bounds index as false.")
    }

    // Failure Handling Tests
    func testErrorHandlingOnLoadFailure() {
        mockService.shouldThrowError = true
        viewModel.loadQuestions()

        XCTAssertNotNil(viewModel.loadError, "Proper error message should be set on load failure.")
        XCTAssertGreaterThan(viewModel.questions.count, 0, "Mock questions should be loaded during a fail.")
    }
}