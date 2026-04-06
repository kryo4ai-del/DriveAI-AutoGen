import XCTest
@testable import DriveAI

final class UserModelTests: XCTestCase {
    var sut: User!
    
    override func setUp() {
        super.setUp()
        sut = User(id: UUID())
    }
    
    // MARK: - Initialization Tests
    
    func test_userInitialization_createsUniqueID() {
        let user1 = User(id: UUID())
        let user2 = User(id: UUID())
        
        XCTAssertNotEqual(user1.id, user2.id)
    }
    
    func test_userInitialization_setsDefaultValues() {
        XCTAssertNil(sut.examDate)
        XCTAssertEqual(sut.currentStreak, 0)
        XCTAssertEqual(sut.longestStreak, 0)
        XCTAssertEqual(sut.totalQuestionsAnswered, 0)
        XCTAssertEqual(sut.correctAnswers, 0)
        XCTAssertTrue(sut.categoryProgress.isEmpty)
    }
    
    // MARK: - Overall Score Calculation
    
    func test_overallScore_withNoAnswers_returnsZero() {
        XCTAssertEqual(sut.overallScore, 0)
    }
    
    func test_overallScore_withPerfectAnswers_returns100() {
        sut.totalQuestionsAnswered = 10
        sut.correctAnswers = 10
        
        XCTAssertEqual(sut.overallScore, 100)
    }
    
    func test_overallScore_withHalfCorrect_returns50() {
        sut.totalQuestionsAnswered = 10
        sut.correctAnswers = 5
        
        XCTAssertEqual(sut.overallScore, 50)
    }
    
    func test_overallScore_roundsDownCorrectly() {
        sut.totalQuestionsAnswered = 3
        sut.correctAnswers = 1  // 33.33% -> 33%
        
        XCTAssertEqual(sut.overallScore, 33)
    }
    
    // MARK: - Days Until Exam
    
    func test_daysUntilExam_withoutScheduledDate_returnsNil() {
        sut.examDate = nil
        
        XCTAssertNil(sut.daysUntilExam)
    }
    
    func test_daysUntilExam_scheduledInFuture_returnsPositiveInt() {
        let futureDate = Calendar.current.date(byAdding: .day, value: 10, to: Date())!
        sut.examDate = futureDate
        
        let daysUntil = sut.daysUntilExam
        XCTAssertGreaterThan(daysUntil ?? 0, 0)
    }
    
    func test_daysUntilExam_scheduledInPast_returnsZero() {
        let pastDate = Calendar.current.date(byAdding: .day, value: -5, to: Date())!
        sut.examDate = pastDate
        
        XCTAssertEqual(sut.daysUntilExam, 0)
    }
    
    func test_daysUntilExam_scheduledToday_returnsZero() {
        let today = Calendar.current.startOfDay(for: Date())
        sut.examDate = today
        
        XCTAssertEqual(sut.daysUntilExam, 0)
    }
    
    // MARK: - Exam Urgency
    
    func test_examUrgency_noExamScheduled_returnsNoExam() {
        sut.examDate = nil
        
        XCTAssertEqual(sut.examUrgency, .noExam)
    }
    
    func test_examUrgency_14daysAway_returnsRelaxed() {
        let date14DaysAway = Calendar.current.date(byAdding: .day, value: 14, to: Date())!
        sut.examDate = date14DaysAway
        
        if case .relaxed(let days) = sut.examUrgency {
            XCTAssertEqual(days, 14)
        } else {
            XCTFail("Expected .relaxed(14), got \(sut.examUrgency)")
        }
    }
    
    func test_examUrgency_7daysAway_returnsModerate() {
        let date7DaysAway = Calendar.current.date(byAdding: .day, value: 7, to: Date())!
        sut.examDate = date7DaysAway
        
        if case .moderate(let days) = sut.examUrgency {
            XCTAssertEqual(days, 7)
        } else {
            XCTFail("Expected .moderate(7), got \(sut.examUrgency)")
        }
    }
    
    func test_examUrgency_3daysAway_returnsUrgent() {
        let date3DaysAway = Calendar.current.date(byAdding: .day, value: 3, to: Date())!
        sut.examDate = date3DaysAway
        
        if case .urgent(let days) = sut.examUrgency {
            XCTAssertEqual(days, 3)
        } else {
            XCTFail("Expected .urgent(3), got \(sut.examUrgency)")
        }
    }
    
    func test_examUrgency_today_returnsExamToday() {
        let today = Calendar.current.startOfDay(for: Date())
        sut.examDate = today
        
        XCTAssertEqual(sut.examUrgency, .examToday)
    }
    
    // MARK: - Streak Management
    
    func test_updateStreak_firstAnswer_setsStreakToOne() {
        sut.updateStreak()
        
        XCTAssertEqual(sut.currentStreak, 1)
        XCTAssertEqual(sut.longestStreak, 1)
    }
    
    func test_updateStreak_consecutiveDay_incrementsStreak() {
        sut.currentStreak = 5
        sut.longestStreak = 5
        sut.lastQuestionAnsweredAt = Calendar.current.date(byAdding: .day, value: -1, to: Date())
        
        sut.updateStreak()
        
        XCTAssertEqual(sut.currentStreak, 6)
        XCTAssertEqual(sut.longestStreak, 6)
    }
    
    func test_updateStreak_consecutiveDay_doesNotExceedLongestStreak() {
        sut.currentStreak = 3
        sut.longestStreak = 5
        sut.lastQuestionAnsweredAt = Calendar.current.date(byAdding: .day, value: -1, to: Date())
        
        sut.updateStreak()
        
        XCTAssertEqual(sut.currentStreak, 4)
        XCTAssertEqual(sut.longestStreak, 5) // Doesn't exceed
    }
    
    func test_updateStreak_sameDay_maintainsStreak() {
        sut.currentStreak = 3
        sut.lastQuestionAnsweredAt = Date()
        
        sut.updateStreak()
        
        XCTAssertEqual(sut.currentStreak, 3) // Unchanged
    }
    
    func test_updateStreak_afterGapOfDays_resetsStreak() {
        sut.currentStreak = 10
        sut.longestStreak = 10
        sut.lastQuestionAnsweredAt = Calendar.current.date(byAdding: .day, value: -3, to: Date())
        
        sut.updateStreak()
        
        XCTAssertEqual(sut.currentStreak, 1) // Reset
        XCTAssertEqual(sut.longestStreak, 10) // Maintained
    }
    
    // MARK: - Streak Indicator
    
    func test_shouldShowStreakIndicator_withZeroStreak_returnsFalse() {
        sut.currentStreak = 0
        
        XCTAssertFalse(sut.shouldShowStreakIndicator)
    }
    
    func test_shouldShowStreakIndicator_withPositiveStreak_returnsTrue() {
        sut.currentStreak = 3
        
        XCTAssertTrue(sut.shouldShowStreakIndicator)
    }
    
    // MARK: - Reset Progress
    
    func test_resetProgress_clearsAllData() {
        sut.totalQuestionsAnswered = 100
        sut.correctAnswers = 75
        sut.currentStreak = 5
        sut.longestStreak = 15
        sut.categoryProgress[UUID()] = CategoryProgress(categoryId: UUID(), questionsAnswered: 10)
        
        sut.resetProgress()
        
        XCTAssertEqual(sut.totalQuestionsAnswered, 0)
        XCTAssertEqual(sut.correctAnswers, 0)
        XCTAssertEqual(sut.currentStreak, 0)
        XCTAssertEqual(sut.longestStreak, 0)
        XCTAssertTrue(sut.categoryProgress.isEmpty)
    }
}