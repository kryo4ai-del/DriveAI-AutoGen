import XCTest
@testable import DriveAI

@MainActor
final class RememberedQuestionTests: XCTestCase {
    
    // MARK: - Initialization
    
    func testInitializeNewQuestion() {
        let question = RememberedQuestion(questionId: "Q1", categoryId: "traffic-signs")
        
        XCTAssertEqual(question.questionId, "Q1")
        XCTAssertEqual(question.categoryId, "traffic-signs")
        XCTAssertEqual(question.reviewCount, 0)
        XCTAssertEqual(question.correctCount, 0)
        XCTAssertNil(question.lastReviewDate)
        XCTAssertEqual(question.difficulty, .medium)
        XCTAssertEqual(question.intervalDays, 1)
        XCTAssertEqual(question.easeFactor, 2.5)
        XCTAssertFalse(question.userFlaggedHard)
        XCTAssertFalse(question.userFlaggedEasy)
    }
    
    // MARK: - Accuracy Computation
    
    func testAccuracyWithNoReviews() {
        let question = RememberedQuestion(questionId: "Q1", categoryId: "cat")
        XCTAssertEqual(question.accuracy, 0.0)
    }
    
    func testAccuracyWithPerfectReviews() {
        var question = RememberedQuestion(questionId: "Q1", categoryId: "cat")
        question = question.recordCorrectAnswer()
        question = question.recordCorrectAnswer()
        question = question.recordCorrectAnswer()
        
        XCTAssertEqual(question.reviewCount, 3)
        XCTAssertEqual(question.correctCount, 3)
        XCTAssertEqual(question.accuracy, 1.0)
    }
    
    func testAccuracyWithMixedReviews() {
        var question = RememberedQuestion(questionId: "Q1", categoryId: "cat")
        question = question.recordCorrectAnswer()
        question = question.recordIncorrectAnswer()
        question = question.recordCorrectAnswer()
        
        XCTAssertEqual(question.reviewCount, 3)
        XCTAssertEqual(question.correctCount, 2)
        XCTAssertEqual(question.accuracy, 2.0 / 3.0)
    }
    
    // MARK: - Record Correct Answer
    
    func testRecordCorrectAnswerIncrementsCounters() {
        var question = RememberedQuestion(questionId: "Q1", categoryId: "cat")
        let updated = question.recordCorrectAnswer()
        
        XCTAssertEqual(updated.reviewCount, 1)
        XCTAssertEqual(updated.correctCount, 1)
        XCTAssertEqual(updated.intervalDays, 3)  // SM-2: first success → 3 days
    }
    
    func testRecordCorrectAnswerSetsLastReviewDate() {
        let before = Date()
        let question = RememberedQuestion(questionId: "Q1", categoryId: "cat")
        let updated = question.recordCorrectAnswer()
        let after = Date()
        
        XCTAssertNotNil(updated.lastReviewDate)
        XCTAssert(updated.lastReviewDate! >= before && updated.lastReviewDate! <= after)
    }
    
    func testRecordCorrectAnswerSchedulesNextReview() {
        let question = RememberedQuestion(questionId: "Q1", categoryId: "cat")
        let updated = question.recordCorrectAnswer()
        
        // Next review should be ~3 days from now
        let daysBetween = Calendar.current.dateComponents(
            [.day],
            from: Date(),
            to: updated.nextReviewDate
        ).day ?? 0
        
        XCTAssertGreaterThanOrEqual(daysBetween, 2)  // Allow 1 day variance
        XCTAssertLessThanOrEqual(daysBetween, 4)
    }
    
    func testRecordCorrectAnswerWithExplanationViewed() {
        let question = RememberedQuestion(questionId: "Q1", categoryId: "cat")
        let updated = question.recordCorrectAnswer(explanationViewed: true)
        
        XCTAssertTrue(updated.hasExplanationRead)
    }
    
    // MARK: - Record Incorrect Answer
    
    func testRecordIncorrectAnswerIncrementsReviewOnly() {
        var question = RememberedQuestion(questionId: "Q1", categoryId: "cat")
        question = question.recordCorrectAnswer()  // First: correct
        let updated = question.recordIncorrectAnswer()  // Second: incorrect
        
        XCTAssertEqual(updated.reviewCount, 2)
        XCTAssertEqual(updated.correctCount, 1)  // No increment
    }
    
    func testRecordIncorrectAnswerResetsInterval() {
        var question = RememberedQuestion(questionId: "Q1", categoryId: "cat")
        question = question.recordCorrectAnswer()  // interval = 3
        let updated = question.recordIncorrectAnswer()
        
        XCTAssertEqual(updated.intervalDays, 1)  // Reset to 1
    }
    
    func testRecordIncorrectAnswerSchedulesNextDayReview() {
        let question = RememberedQuestion(questionId: "Q1", categoryId: "cat")
        let updated = question.recordIncorrectAnswer()
        
        let daysBetween = Calendar.current.dateComponents(
            [.day],
            from: Date(),
            to: updated.nextReviewDate
        ).day ?? 0
        
        XCTAssertEqual(daysBetween, 1)
    }
    
    // MARK: - Difficulty Management
    
    func testWithDifficultyHard() {
        let question = RememberedQuestion(questionId: "Q1", categoryId: "cat")
        let updated = question.withDifficulty(.hard)
        
        XCTAssertEqual(updated.difficulty, .hard)
        XCTAssertTrue(updated.userFlaggedHard)
    }
    
    func testWithDifficultyEasy() {
        let question = RememberedQuestion(questionId: "Q1", categoryId: "cat")
        let updated = question.withDifficulty(.easy)
        
        XCTAssertEqual(updated.difficulty, .easy)
        XCTAssertTrue(updated.userFlaggedEasy)
    }
    
    // MARK: - Reset
    
    func testResetClearsAllMetrics() {
        var question = RememberedQuestion(questionId: "Q1", categoryId: "cat")
        question = question.recordCorrectAnswer()
        question = question.recordCorrectAnswer()
        question = question.withDifficulty(.hard)
        
        let reset = question.reset()
        
        XCTAssertEqual(reset.reviewCount, 0)
        XCTAssertEqual(reset.correctCount, 0)
        XCTAssertEqual(reset.difficulty, .medium)
        XCTAssertEqual(reset.intervalDays, 1)
        XCTAssertFalse(reset.userFlaggedHard)
        XCTAssertNil(reset.lastReviewDate)
    }
    
    // MARK: - Immutability
    
    func testImmutability() {
        let question1 = RememberedQuestion(questionId: "Q1", categoryId: "cat")
        let question2 = question1.recordCorrectAnswer()
        
        // Original unchanged
        XCTAssertEqual(question1.reviewCount, 0)
        XCTAssertEqual(question1.correctCount, 0)
        
        // New instance has updates
        XCTAssertEqual(question2.reviewCount, 1)
        XCTAssertEqual(question2.correctCount, 1)
    }
    
    // MARK: - Hashable & Equatable
    
    func testHashingByID() {
        let id = UUID()
        let q1 = RememberedQuestion(id: id, questionId: "Q1", categoryId: "cat",
                                    reviewCount: 0, correctCount: 0,
                                    lastReviewDate: nil, nextReviewDate: Date(),
                                    difficulty: .medium, intervalDays: 1,
                                    easeFactor: 2.5, userFlaggedHard: false,
                                    userFlaggedEasy: false, hasExplanationRead: false)
        
        let q2 = RememberedQuestion(id: id, questionId: "Q1", categoryId: "cat",
                                    reviewCount: 5, correctCount: 5,  // Different state
                                    lastReviewDate: Date(), nextReviewDate: Date(),
                                    difficulty: .hard, intervalDays: 10,
                                    easeFactor: 3.0, userFlaggedHard: true,
                                    userFlaggedEasy: false, hasExplanationRead: true)
        
        // Same ID = equal
        XCTAssertEqual(q1, q2)
        XCTAssertEqual(q1.hashValue, q2.hashValue)
    }
    
    // MARK: - Codable
    
    func testCodable() throws {
        let question = RememberedQuestion(questionId: "Q1", categoryId: "cat")
        
        let encoded = try JSONEncoder().encode(question)
        let decoded = try JSONDecoder().decode(RememberedQuestion.self, from: encoded)
        
        XCTAssertEqual(question.id, decoded.id)
        XCTAssertEqual(question.questionId, decoded.questionId)
        XCTAssertEqual(question.categoryId, decoded.categoryId)
    }
}