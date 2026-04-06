// Tests/Unit/Domain/ExamScoringServiceTests.swift
import XCTest
@testable import DriveAI

class ExamScoringServiceTests: XCTestCase {
    var sut: ExamScoringService!
    
    override func setUp() {
        super.setUp()
        sut = ExamScoringService()
    }
    
    // MARK: - Happy Path Tests
    
    func testPassingExamWithPerfectScore() throws {
        let session = makeCompleteSession(correctCount: 30)
        let result = try sut.calculateScore(session: session)
        
        XCTAssertTrue(result.passed)
        XCTAssertEqual(result.score, 30)
        XCTAssertEqual(result.percentage, 100.0)
    }
    
    func testPassingExamWithMinimumThreshold() throws {
        let session = makeCompleteSession(correctCount: 24)
        let result = try sut.calculateScore(session: session)
        
        XCTAssertTrue(result.passed)
        XCTAssertEqual(result.score, 24)
        XCTAssertEqual(result.percentage, 80.0, accuracy: 0.01)
    }
    
    func testFailingExamJustBelowThreshold() throws {
        let session = makeCompleteSession(correctCount: 23)
        let result = try sut.calculateScore(session: session)
        
        XCTAssertFalse(result.passed)
        XCTAssertEqual(result.score, 23)
    }
    
    // MARK: - Edge Cases: Answer Recording
    
    func testRecordAnswerValidIndex() throws {
        let session = ExamSession(
            id: "test",
            startTime: Date(),
            questions: [makeQuestion(id: "q1", answerCount: 4)]
        )
        
        try session.recordAnswer(questionId: "q1", answerIndex: 0)
        XCTAssertEqual(session.getUserAnswer(for: "q1"), 0)
        
        try session.recordAnswer(questionId: "q1", answerIndex: 3)
        XCTAssertEqual(session.getUserAnswer(for: "q1"), 3)
    }
    
    func testRecordAnswerNegativeIndexThrows() throws {
        let session = ExamSession(
            id: "test",
            startTime: Date(),
            questions: [makeQuestion(id: "q1")]
        )
        
        XCTAssertThrowsError(
            try session.recordAnswer(questionId: "q1", answerIndex: -1)
        ) { error in
            XCTAssertEqual(error as? DomainError, .invalidUserAnswer)
        }
    }
    
    func testRecordAnswerOutOfRangeThrows() throws {
        let session = ExamSession(
            id: "test",
            startTime: Date(),
            questions: [makeQuestion(id: "q1", answerCount: 2)]
        )
        
        XCTAssertThrowsError(
            try session.recordAnswer(questionId: "q1", answerIndex: 4)
        ) { error in
            XCTAssertEqual(error as? DomainError, .invalidUserAnswer)
        }
    }
    
    func testRecordAnswerInvalidQuestionThrows() throws {
        let session = ExamSession(
            id: "test",
            startTime: Date(),
            questions: [makeQuestion(id: "q1")]
        )
        
        XCTAssertThrowsError(
            try session.recordAnswer(questionId: "nonexistent", answerIndex: 0)
        ) { error in
            XCTAssertEqual(error as? DomainError, .invalidUserAnswer)
        }
    }
    
    // MARK: - Edge Cases: Time Limits
    
    func testTimeRemainingBeforeExpiry() {
        let now = Date()
        let session = ExamSession(
            id: "test",
            startTime: now.addingTimeInterval(-1800), // 30 min ago
            questions: [makeQuestion()],
            timeLimit: 3600 // 60 min
        )
        
        XCTAssertGreater(session.timeRemaining, 0)
        XCTAssertLess(session.timeRemaining, 3600)
        XCTAssertFalse(session.isTimeExpired)
    }
    
    func testTimeExpiredAfterLimit() {
        let now = Date()
        let session = ExamSession(
            id: "test",
            startTime: now.addingTimeInterval(-3700), // 61+ min ago
            questions: [makeQuestion()],
            timeLimit: 3600
        )
        
        XCTAssertEqual(session.timeRemaining, 0)
        XCTAssertTrue(session.isTimeExpired)
    }
    
    func testTimeRemainingExactlyAtLimit() {
        let now = Date()
        let session = ExamSession(
            id: "test",
            startTime: now.addingTimeInterval(-3600), // Exactly 60 min ago
            questions: [makeQuestion()],
            timeLimit: 3600
        )
        
        XCTAssertEqual(session.timeRemaining, 0)
        XCTAssertTrue(session.isTimeExpired)
    }
    
    // MARK: - Edge Cases: Incomplete/Invalid States
    
    func testIncompleteExamWithoutEndTime() throws {
        var session = makeCompleteSession(correctCount: 25)
        session.endTime = nil
        
        XCTAssertThrowsError(try sut.calculateScore(session: session)) { error in
            XCTAssertEqual(error as? DomainError, .incompleteExam)
        }
    }
    
    func testIncompleteExamWithMissingAnswers() throws {
        var session = makeCompleteSession(correctCount: 20)
        if let firstQuestion = session.questions.first {
            session.userAnswers.removeValue(forKey: firstQuestion.id)
        }
        
        XCTAssertThrowsError(try sut.calculateScore(session: session)) { error in
            if case .unansweredQuestions(let count) = error as? DomainError {
                XCTAssertEqual(count, 1)
            } else {
                XCTFail("Expected unansweredQuestions")
            }
        }
    }
    
    func testExamWithAllUnansweredQuestions() throws {
        var session = makeCompleteSession(correctCount: 0)
        session.userAnswers.removeAll()
        
        XCTAssertThrowsError(try sut.calculateScore(session: session)) { error in
            if case .unansweredQuestions(let count) = error as? DomainError {
                XCTAssertEqual(count, 30)
            } else {
                XCTFail("Expected unansweredQuestions")
            }
        }
    }
    
    // MARK: - Edge Cases: Question Count Validation
    
    func testTooFewQuestionsThrows() throws {
        let questions = (0..<15).map { makeQuestion(id: "q\($0)") }
        var session = ExamSession(
            id: "test",
            startTime: Date(),
            questions: questions
        )
        session.endTime = Date()
        
        for question in questions {
            try session.recordAnswer(questionId: question.id, answerIndex: 0)
        }
        
        XCTAssertThrowsError(try sut.calculateScore(session: session)) { error in
            if case .insufficientQuestions(let required, let available) = error as? DomainError {
                XCTAssertEqual(required, 30)
                XCTAssertEqual(available, 15)
            } else {
                XCTFail("Expected insufficientQuestions")
            }
        }
    }
    
    // MARK: - Category Breakdown Tests
    
    func testCategoryBreakdownMultipleCategories() throws {
        let session = makeSessionWithCategories([
            ("signs", 3, 5),      // 60%
            ("parking", 2, 5),    // 40%
            ("speed", 5, 5),      // 100%
            ("fines", 14, 15)     // 93%
        ])
        let result = try sut.calculateScore(session: session)
        
        XCTAssertEqual(result.categoryBreakdown.count, 4)
        
        let signsResult = result.categoryBreakdown.first { $0.categoryId == "signs" }
        XCTAssertEqual(signsResult?.percentage, 60.0, accuracy: 0.01)
    }
    
    func testCategoryBreakdownEmptyCategory() throws {
        let questions = (0..<30).map { makeQuestion(id: "q\($0)", categoryId: "single") }
        var session = ExamSession(id: "test", startTime: Date(), questions: questions)
        session.endTime = Date()
        
        for question in questions {
            try session.recordAnswer(questionId: question.id, answerIndex: question.correctAnswerIndex)
        }
        
        let result = try sut.calculateScore(session: session)
        XCTAssertEqual(result.categoryBreakdown.count, 1)
        XCTAssertEqual(result.categoryBreakdown[0].percentage, 100.0, accuracy: 0.01)
    }
    
    // MARK: - Boundary Tests
    
    func testScoreBoundaries() {
        let testCases: [(score: Int, total: Int, expectedPass: Bool)] = [
            (23, 30, false),  // 76.67%
            (24, 30, true),   // 80%
            (30, 30, true),   // 100%
            (0, 30, false),   // 0%
            (15, 30, false),  // 50%
        ]
        
        for testCase in testCases {
            let result = sut.isPassing(score: testCase.score, totalQuestions: testCase.total)
            XCTAssertEqual(
                result,
                testCase.expectedPass,
                "Score \(testCase.score)/\(testCase.total) should be \(testCase.expectedPass ? "passing" : "failing")"
            )
        }
    }
    
    // MARK: - Performance Tests
    
    func testScorCalculationPerformance() {
        let session = makeCompleteSession(correctCount: 20)
        
        measure {
            _ = try? sut.calculateScore(session: session)
        }
    }
    
    // MARK: - Helpers
    
    private func makeCompleteSession(correctCount: Int) -> ExamSession {
        let questions = (0..<30).map { makeQuestion(id: "q\($0)") }
        var session = ExamSession(id: UUID().uuidString, startTime: Date(), questions: questions)
        session.endTime = Date()
        
        for (idx, question) in questions.enumerated() {
            let answerIdx = idx < correctCount ? question.correctAnswerIndex : (question.correctAnswerIndex + 1) % 2
            try? session.recordAnswer(questionId: question.id, answerIndex: answerIdx)
        }
        
        return session
    }
    
    private func makeSessionWithCategories(_ specs: [(categoryId: String, correct: Int, total: Int)]) -> ExamSession {
        var questions: [Question] = []
        
        for (categoryId, _, total) in specs {
            for i in 0..<total {
                questions.append(makeQuestion(id: "q\(questions.count)", categoryId: categoryId))
            }
        }
        
        // Pad to 30 questions
        while questions.count < 30 {
            questions.append(makeQuestion(id: "q\(questions.count)"))
        }
        
        var session = ExamSession(id: UUID().uuidString, startTime: Date(), questions: questions)
        session.endTime = Date()
        
        var questionIdx = 0
        for (_, correct, total) in specs {
            for i in 0..<total {
                let question = questions[questionIdx]
                let answerIdx = i < correct ? question.correctAnswerIndex : (question.correctAnswerIndex + 1) % 2
                try? session.recordAnswer(questionId: question.id, answerIndex: answerIdx)
                questionIdx += 1
            }
        }
        
        // Fill remaining with correct
        for i in questionIdx..<questions.count {
            try? session.recordAnswer(questionId: questions[i].id, answerIndex: questions[i].correctAnswerIndex)
        }
        
        return session
    }
    
    private func makeQuestion(id: String = "q1", categoryId: String = "default", answerCount: Int = 2) -> Question {
        let answers = (0..<answerCount).map { Answer(id: "a\($0)", text: "Option \($0)") }
        return Question(
            id: id,
            text: "Test question?",
            answers: answers,
            correctAnswerIndex: 0,
            explanation: "Explanation",
            citation: "StVO §1",
            categoryId: categoryId,
            difficulty: .medium,
            imageUrl: nil
        )
    }
}