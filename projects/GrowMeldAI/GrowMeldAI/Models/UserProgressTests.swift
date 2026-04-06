import XCTest
@testable import DriveAI

final class UserProgressTests: XCTestCase {
    
    let categoryId = UUID()
    
    // MARK: - Happy Path Tests
    
    func testProgressInitialization() {
        let progress = UserProgress(
            categoryId: categoryId,
            categoryName: "Verkehrszeichen"
        )
        
        XCTAssertEqual(progress.totalQuestionsAnswered, 0)
        XCTAssertEqual(progress.correctAnswers, 0)
        XCTAssertEqual(progress.currentStreak, 0)
        XCTAssertEqual(progress.percentageCorrect, 0)
        XCTAssertNil(progress.lastReviewedDate)
    }
    
    func testRecordCorrectAnswer() {
        var progress = UserProgress(categoryId: categoryId, categoryName: "Test")
        
        let updated = progress.recordingCorrectAnswer()
        
        XCTAssertEqual(updated.totalQuestionsAnswered, 1)
        XCTAssertEqual(updated.correctAnswers, 1)
        XCTAssertEqual(updated.percentageCorrect, 100)
        XCTAssertNotNil(updated.lastReviewedDate)
    }
    
    func testRecordIncorrectAnswer() {
        var progress = UserProgress(categoryId: categoryId, categoryName: "Test")
        
        let updated = progress.recordingIncorrectAnswer()
        
        XCTAssertEqual(updated.totalQuestionsAnswered, 1)
        XCTAssertEqual(updated.correctAnswers, 0)
        XCTAssertEqual(updated.percentageCorrect, 0)
    }
    
    func testMultipleAnswers() {
        var progress = UserProgress(categoryId: categoryId, categoryName: "Test")
        
        // Answer 10 questions, 7 correct
        for i in 0..<10 {
            let isCorrect = i < 7
            progress = isCorrect 
                ? progress.recordingCorrectAnswer()
                : progress.recordingIncorrectAnswer()
        }
        
        XCTAssertEqual(progress.totalQuestionsAnswered, 10)
        XCTAssertEqual(progress.correctAnswers, 7)
        XCTAssertEqual(progress.percentageCorrect, 70)
    }
    
    func testIsStrengthArea() {
        var progress = UserProgress(categoryId: categoryId, categoryName: "Test")
        
        // Not strength area until >=5 answers
        progress = UserProgress(
            categoryId: categoryId,
            categoryName: "Test",
            totalQuestionsAnswered: 4,
            correctAnswers: 4
        )
        XCTAssertFalse(progress.isStrengthArea)
        
        // >= 80% and >= 5 answers
        progress = UserProgress(
            categoryId: categoryId,
            categoryName: "Test",
            totalQuestionsAnswered: 5,
            correctAnswers: 4 // 80%
        )
        XCTAssertTrue(progress.isStrengthArea)
    }
    
    func testIsWeakArea() {
        var progress = UserProgress(
            categoryId: categoryId,
            categoryName: "Test",
            totalQuestionsAnswered: 5,
            correctAnswers: 2 // 40%
        )
        
        XCTAssertTrue(progress.isWeakArea)
    }
    
    // MARK: - Edge Cases
    
    func testProgressWithZeroAnswers() {
        let progress = UserProgress(categoryId: categoryId, categoryName: "Test")
        
        XCTAssertEqual(progress.percentageCorrect, 0, "Should safely handle division by zero")
        XCTAssertFalse(progress.isStrengthArea)
        XCTAssertFalse(progress.isWeakArea)
    }
    
    func testProgressPercentageAccuracy() {
        let testCases: [(total: Int, correct: Int, expected: Double)] = [
            (1, 1, 100),
            (2, 1, 50),
            (3, 2, 66.66666),
            (10, 3, 30),
            (100, 99, 99)
        ]
        
        for (total, correct, expected) in testCases {
            let progress = UserProgress(
                categoryId: categoryId,
                categoryName: "Test",
                totalQuestionsAnswered: total,
                correctAnswers: correct
            )
            
            XCTAssertEqual(
                progress.percentageCorrect,
                expected,
                accuracy: 0.01,
                "Percentage for \(correct)/\(total) should be \(expected)"
            )
        }
    }
    
    func testProgressImmutability() {
        let original = UserProgress(categoryId: categoryId, categoryName: "Test")
        let updated = original.recordingCorrectAnswer()
        
        // Original unchanged
        XCTAssertEqual(original.totalQuestionsAnswered, 0)
        XCTAssertEqual(original.correctAnswers, 0)
        
        // New instance correct
        XCTAssertEqual(updated.totalQuestionsAnswered, 1)
        XCTAssertEqual(updated.correctAnswers, 1)
    }
    
    // MARK: - Codable Tests
    
    func testProgressCodableRoundTrip() throws {
        let original = UserProgress(
            categoryId: categoryId,
            categoryName: "Verkehrszeichen",
            totalQuestionsAnswered: 10,
            correctAnswers: 8,
            lastReviewedDate: Date(),
            currentStreak: 3,
            longestStreak: 5
        )
        
        let encoder = JSONEncoder()
        let encoded = try encoder.encode(original)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(UserProgress.self, from: encoded)
        
        XCTAssertEqual(original.categoryId, decoded.categoryId)
        XCTAssertEqual(original.totalQuestionsAnswered, decoded.totalQuestionsAnswered)
        XCTAssertEqual(original.correctAnswers, decoded.correctAnswers)
        XCTAssertEqual(original.currentStreak, decoded.currentStreak)
    }
}