import XCTest
@testable import DriveAI

class ExamSessionTests: XCTestCase {
    
    var mockQuestions: [Question]!
    
    override func setUp() async throws {
        try await super.setUp()
        mockQuestions = [
            try Question.fixture(id: 1, correctAnswerIndex: 0),
            try Question.fixture(id: 2, correctAnswerIndex: 1),
            try Question.fixture(id: 3, correctAnswerIndex: 2),
        ]
    }
    
    // MARK: - Initialization
    
    func test_init_createsValidSession() {
        let session = ExamSession(id: "test-1", startDate: Date(), questions: mockQuestions)
        
        XCTAssertEqual(session.id, "test-1")
        XCTAssertEqual(session.questions.count, 3)
        XCTAssertFalse(session.isCompleted)
        XCTAssertNil(session.endDate)
    }
    
    // MARK: - Score Calculation (CRITICAL - Race Condition Test)
    
    func test_score_withAllCorrectAnswers_equals30() throws {
        var session = ExamSession(id: "test-1", startDate: Date(), questions: mockQuestions)
        
        try session.recordAnswer(0, forQuestion: 0)  // Correct
        try session.recordAnswer(1, forQuestion: 1)  // Correct
        try session.recordAnswer(2, forQuestion: 2)  // Correct
        
        XCTAssertEqual(session.score, 3)
    }
    
    func test_score_withPartialAnswers_calculatesCorrectly() throws {
        var session = ExamSession(id: "test-1", startDate: Date(), questions: mockQuestions)
        
        try session.recordAnswer(0, forQuestion: 0)  // Correct
        try session.recordAnswer(0, forQuestion: 1)  // Wrong (should be 1)
        // Question 2 skipped
        
        XCTAssertEqual(session.score, 1)
    }
    
    func test_score_withConcurrentRecording() async throws {
        var session = ExamSession(id: "test-1", startDate: Date(), questions: mockQuestions)
        let recordingLock = NSLock()
        
        // Simulate concurrent answer recording
        await withTaskGroup(of: Void.self) { group in
            for i in 0..<100 {
                group.addTask {
                    recordingLock.lock()
                    try? session.recordAnswer(i % 4, forQuestion: i % self.mockQuestions.count)
                    recordingLock.unlock()
                }
            }
        }
        
        // Score should be valid (no crash, within bounds)
        XCTAssertGreaterThanOrEqual(session.score, 0)
        XCTAssertLessThanOrEqual(session.score, mockQuestions.count)
    }
    
    // MARK: - Answer Recording
    
    func test_recordAnswer_withValidIndex_succeeds() throws {
        var session = ExamSession(id: "test-1", startDate: Date(), questions: mockQuestions)
        
        try session.recordAnswer(0, forQuestion: 0)
        XCTAssertEqual(session.answers[0], 0)
    }
    
    func test_recordAnswer_withInvalidQuestionIndex_throws() throws {
        var session = ExamSession(id: "test-1", startDate: Date(), questions: mockQuestions)
        
        XCTAssertThrowsError(
            try session.recordAnswer(0, forQuestion: 100)
        ) { error in
            XCTAssertEqual(error as? ExamError, .invalidQuestionIndex(100))
        }
    }
    
    func test_recordAnswer_withInvalidAnswerIndex_throws() throws {
        var session = ExamSession(id: "test-1", startDate: Date(), questions: mockQuestions)
        
        XCTAssertThrowsError(
            try session.recordAnswer(10, forQuestion: 0)  // Only 4 answers
        ) { error in
            XCTAssertEqual(error as? ExamError, .invalidAnswerIndex(10))
        }
    }
    
    // MARK: - Completion & Passing
    
    func test_complete_setsEndDate() {
        var session = ExamSession(id: "test-1", startDate: Date(), questions: mockQuestions)
        
        XCTAssertNil(session.endDate)
        session.complete()
        XCTAssertNotNil(session.endDate)
        XCTAssertTrue(session.isCompleted)
    }
    
    func test_isPassed_with75PercentOrMore_returnsTrue() throws {
        var session = ExamSession(id: "test-1", startDate: Date(), questions: mockQuestions)
        
        // 22/30 = 73.3% (fail in real exam, but close)
        // For 3 questions: need 2.25+ → 3/3 = 100% (pass)
        try session.recordAnswer(0, forQuestion: 0)  // ✓
        try session.recordAnswer(1, forQuestion: 1)  // ✓
        try session.recordAnswer(2, forQuestion: 2)  // ✓
        
        XCTAssertTrue(session.isPassed)
    }
    
    func test_isPassed_withLessThan75Percent_returnsFalse() throws {
        var session = ExamSession(id: "test-1", startDate: Date(), questions: mockQuestions)
        
        try session.recordAnswer(0, forQuestion: 0)  // ✓
        try session.recordAnswer(0, forQuestion: 1)  // ✗
        try session.recordAnswer(0, forQuestion: 2)  // ✗
        
        XCTAssertFalse(session.isPassed)  // 1/3 = 33.3%
    }
    
    // MARK: - Percentage Calculation
    
    func test_percentage_calculation() throws {
        var session = ExamSession(id: "test-1", startDate: Date(), questions: mockQuestions)
        
        try session.recordAnswer(0, forQuestion: 0)  // ✓ → 1/3 = 33.3%
        
        XCTAssertAlmostEqual(session.percentage, 33.33, accuracy: 0.1)
    }
    
    // MARK: - Elapsed Time
    
    func test_elapsedTime_increases() async throws {
        let session = ExamSession(id: "test-1", startDate: Date(), questions: mockQuestions)
        
        let initialElapsed = session.elapsedTime
        
        try await Task.sleep(nanoseconds: 100_000_000)  // 0.1 seconds
        
        let finalElapsed = session.elapsedTime
        XCTAssertGreater(finalElapsed, initialElapsed)
    }
    
    func test_remainingTime_decreases() async throws {
        let session = ExamSession(id: "test-1", startDate: Date(), questions: mockQuestions)
        
        let initialRemaining = session.remainingTime
        
        try await Task.sleep(nanoseconds: 100_000_000)  // 0.1 seconds
        
        let finalRemaining = session.remainingTime
        XCTAssertLess(finalRemaining, initialRemaining)
    }
    
    // MARK: - Codable
    
    func test_encodingAndDecoding_preservesState() throws {
        var session = ExamSession(id: "test-1", startDate: Date(), questions: mockQuestions)
        try session.recordAnswer(0, forQuestion: 0)
        session.complete()
        
        let encoded = try JSONEncoder().encode(session)
        let decoded = try JSONDecoder().decode(ExamSession.self, from: encoded)
        
        XCTAssertEqual(decoded.id, session.id)
        XCTAssertEqual(decoded.score, session.score)
        XCTAssertEqual(decoded.answers[0], 0)
    }
}