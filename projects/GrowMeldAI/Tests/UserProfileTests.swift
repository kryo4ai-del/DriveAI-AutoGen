import XCTest
@testable import DriveAI

final class UserProfileTests: XCTestCase {
    var sut: UserProfile!
    let calendar = Calendar.current
    
    override func setUp() {
        super.setUp()
        sut = UserProfile()
    }
    
    // MARK: - Initialization Tests
    
    func testDefaultInitialization() {
        let profile = UserProfile()
        
        XCTAssertNotNil(profile.id)
        XCTAssertNil(profile.examDate)
        XCTAssertEqual(profile.overallScore, 0.0)
        XCTAssertEqual(profile.questionsAttempted, 0)
        XCTAssertEqual(profile.correctAnswers, 0)
        XCTAssertEqual(profile.currentStreak, 0)
        XCTAssertEqual(profile.longestStreak, 0)
        XCTAssertNotNil(profile.createdAt)
        XCTAssertNotNil(profile.lastUpdated)
    }
    
    func testCustomInitialization() {
        let id = UUID()
        let examDate = Date()
        let created = Date()
        let updated = Date()
        
        let profile = UserProfile(
            id: id,
            examDate: examDate,
            createdAt: created,
            lastUpdated: updated
        )
        
        XCTAssertEqual(profile.id, id)
        XCTAssertEqual(profile.examDate, examDate)
        XCTAssertEqual(profile.createdAt, created)
        XCTAssertEqual(profile.lastUpdated, updated)
    }
    
    // MARK: - Pass Rate Calculation Tests
    
    func testPassRateWithZeroAttempts() {
        XCTAssertEqual(sut.passRate, 0.0, "Pass rate should be 0 when no attempts")
    }
    
    func testPassRateAllCorrect() {
        sut.questionsAttempted = 10
        sut.correctAnswers = 10
        XCTAssertEqual(sut.passRate, 100.0, accuracy: 0.01)
    }
    
    func testPassRateAllIncorrect() {
        sut.questionsAttempted = 10
        sut.correctAnswers = 0
        XCTAssertEqual(sut.passRate, 0.0)
    }
    
    func testPassRatePartial() {
        sut.questionsAttempted = 20
        sut.correctAnswers = 15
        XCTAssertEqual(sut.passRate, 75.0, accuracy: 0.01)
    }
    
    func testPassRateSingleAttempt() {
        sut.questionsAttempted = 1
        sut.correctAnswers = 1
        XCTAssertEqual(sut.passRate, 100.0)
        
        sut.correctAnswers = 0
        XCTAssertEqual(sut.passRate, 0.0)
    }
    
    // MARK: - Days Until Exam Tests
    
    func testDaysUntilExamWhenNotSet() {
        XCTAssertNil(sut.daysUntilExam, "Should return nil when examDate not set")
    }
    
    func testDaysUntilExamToday() {
        sut.examDate = calendar.startOfDay(for: Date())
        XCTAssertEqual(sut.daysUntilExam, 0)
    }
    
    func testDaysUntilExamTomorrow() {
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: Date()))!
        sut.examDate = tomorrow
        XCTAssertEqual(sut.daysUntilExam, 1)
    }
    
    func testDaysUntilExamInSevenDays() {
        let sevenDaysFromNow = calendar.date(byAdding: .day, value: 7, to: calendar.startOfDay(for: Date()))!
        sut.examDate = sevenDaysFromNow
        XCTAssertEqual(sut.daysUntilExam, 7)
    }
    
    func testDaysUntilExamInPast() {
        let threeDaysAgo = calendar.date(byAdding: .day, value: -3, to: calendar.startOfDay(for: Date()))!
        sut.examDate = threeDaysAgo
        XCTAssertEqual(sut.daysUntilExam, -3)
    }
    
    func testDaysUntilExamIgnoresTimeComponent() {
        let today = calendar.startOfDay(for: Date())
        // Set exam to today at 10 AM
        var components = calendar.dateComponents([.year, .month, .day], from: today)
        components.hour = 10
        let examDate = calendar.date(from: components)!
        
        sut.examDate = examDate
        XCTAssertEqual(sut.daysUntilExam, 0, "Time component should be ignored")
    }
    
    // MARK: - Readiness Percentage Tests
    
    func testReadinessPercentageAtStart() {
        XCTAssertEqual(sut.readinessPercentage, 0.0)
    }
    
    func testReadinessPercentageWithPassRateOnly() {
        sut.questionsAttempted = 100
        sut.correctAnswers = 80  // 80% pass rate
        let expected = (0.8 * 0.6) * 100  // 48%
        XCTAssertEqual(sut.readinessPercentage, expected, accuracy: 0.1)
    }
    
    func testReadinessPercentageWithHighVolume() {
        sut.questionsAttempted = 500  // Max volume component
        sut.correctAnswers = 250  // 50% pass rate
        let expected = (0.5 * 0.6 * 100) + (1.0 * 0.4 * 100)  // 70%
        XCTAssertEqual(sut.readinessPercentage, expected, accuracy: 0.1)
    }
    
    func testReadinessPercentageMaxed() {
        sut.questionsAttempted = 1000
        sut.correctAnswers = 1000  // 100% pass rate
        XCTAssertGreaterThanOrEqual(sut.readinessPercentage, 95.0)
    }
    
    // MARK: - Streak Emoji Tests
    
    func testStreakEmojiNoStreak() {
        sut.currentStreak = 0
        XCTAssertEqual(sut.streakEmoji, "❄️")
    }
    
    func testStreakEmojiSproutPhase() {
        sut.currentStreak = 3
        XCTAssertEqual(sut.streakEmoji, "🌱")
    }
    
    func testStreakEmojiFirePhase() {
        sut.currentStreak = 7
        XCTAssertEqual(sut.streakEmoji, "🔥")
    }
    
    func testStreakEmojiExplosionPhase() {
        sut.currentStreak = 15
        XCTAssertEqual(sut.streakEmoji, "💥")
    }
    
    // MARK: - Record Question Attempt Tests
    
    func testRecordCorrectAttempt() {
        let beforeUpdate = Date()
        sut.recordQuestionAttempt(correct: true)
        let afterUpdate = Date()
        
        XCTAssertEqual(sut.questionsAttempted, 1)
        XCTAssertEqual(sut.correctAnswers, 1)
        XCTAssertEqual(sut.currentStreak, 1)
        XCTAssertEqual(sut.longestStreak, 1)
        XCTAssertGreaterThanOrEqual(sut.lastUpdated, beforeUpdate)
        XCTAssertLessThanOrEqual(sut.lastUpdated, afterUpdate)
    }
    
    func testRecordIncorrectAttempt() {
        sut.recordQuestionAttempt(correct: false)
        
        XCTAssertEqual(sut.questionsAttempted, 1)
        XCTAssertEqual(sut.correctAnswers, 0)
        XCTAssertEqual(sut.currentStreak, 0)
        XCTAssertEqual(sut.longestStreak, 0)
    }
    
    func testRecordMultipleCorrectAttempts() {
        for _ in 0..<5 {
            sut.recordQuestionAttempt(correct: true)
        }
        
        XCTAssertEqual(sut.questionsAttempted, 5)
        XCTAssertEqual(sut.correctAnswers, 5)
        XCTAssertEqual(sut.currentStreak, 5)
        XCTAssertEqual(sut.longestStreak, 5)
    }
    
    func testRecordStreakBreak() {
        // Build streak
        for _ in 0..<3 {
            sut.recordQuestionAttempt(correct: true)
        }
        XCTAssertEqual(sut.currentStreak, 3)
        XCTAssertEqual(sut.longestStreak, 3)
        
        // Break streak
        sut.recordQuestionAttempt(correct: false)
        XCTAssertEqual(sut.currentStreak, 0)
        XCTAssertEqual(sut.longestStreak, 3, "Longest streak should remain unchanged")
    }
    
    func testRecordStreakRebuild() {
        // Build streak to 3
        for _ in 0..<3 {
            sut.recordQuestionAttempt(correct: true)
        }
        
        // Break
        sut.recordQuestionAttempt(correct: false)
        
        // Rebuild to 5
        for _ in 0..<5 {
            sut.recordQuestionAttempt(correct: true)
        }
        
        XCTAssertEqual(sut.currentStreak, 5)
        XCTAssertEqual(sut.longestStreak, 5, "Longest streak should update when exceeded")
    }
    
    func testOverallScoreUpdatesAfterAttempt() {
        sut.recordQuestionAttempt(correct: true)
        XCTAssertEqual(sut.overallScore, 100.0)
        
        sut.recordQuestionAttempt(correct: false)
        XCTAssertEqual(sut.overallScore, 50.0, accuracy: 0.01)
    }
    
    // MARK: - Update Exam Date Tests
    
    func testUpdateExamDateFromNil() {
        XCTAssertNil(sut.examDate)
        let newDate = Date()
        sut.updateExamDate(newDate)
        XCTAssertEqual(sut.examDate, newDate)
    }
    
    func testUpdateExamDateToNil() {
        sut.examDate = Date()
        sut.updateExamDate(nil)
        XCTAssertNil(sut.examDate)
    }
    
    func testUpdateExamDateUpdatesTimestamp() {
        let beforeUpdate = Date()
        sut.updateExamDate(Date())
        let afterUpdate = Date()
        
        XCTAssertGreaterThanOrEqual(sut.lastUpdated, beforeUpdate)
        XCTAssertLessThanOrEqual(sut.lastUpdated, afterUpdate)
    }
    
    // MARK: - Reset Tests
    
    func testResetProfile() {
        // Build profile state
        for _ in 0..<10 {
            sut.recordQuestionAttempt(correct: true)
        }
        sut.updateExamDate(Date())
        
        XCTAssertGreaterThan(sut.questionsAttempted, 0)
        XCTAssertGreaterThan(sut.overallScore, 0)
        
        // Reset
        sut.reset()
        
        XCTAssertEqual(sut.questionsAttempted, 0)
        XCTAssertEqual(sut.correctAnswers, 0)
        XCTAssertEqual(sut.currentStreak, 0)
        XCTAssertEqual(sut.longestStreak, 0)
        XCTAssertEqual(sut.overallScore, 0.0)
        XCTAssertNotNil(sut.lastUpdated)
    }
    
    // MARK: - Codable Tests
    
    func testEncodableDecoding() throws {
        sut.questionsAttempted = 20
        sut.correctAnswers = 15
        sut.examDate = Date()
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(sut)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode(UserProfile.self, from: data)
        
        XCTAssertEqual(decoded.id, sut.id)
        XCTAssertEqual(decoded.questionsAttempted, sut.questionsAttempted)
        XCTAssertEqual(decoded.correctAnswers, sut.correctAnswers)
    }
    
    func testCodableRoundTrip() throws {
        let original = UserProfile(
            id: UUID(),
            examDate: Date().addingTimeInterval(86400 * 7)
        )
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(original)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode(UserProfile.self, from: data)
        
        XCTAssertEqual(decoded.id, original.id)
        XCTAssertEqual(decoded.createdAt.timeIntervalSince1970,
                      original.createdAt.timeIntervalSince1970,
                      accuracy: 1.0)
    }
}