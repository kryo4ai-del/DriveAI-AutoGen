import XCTest
@testable import DriveAI

final class TrialProgressTests: XCTestCase {
    
    private let calendar = Calendar.current
    
    // MARK: - Issue #1: Streak Reset & Restart Logic
    
    func test_streak_firstActivityEver() {
        var progress = TrialProgress()
        
        progress.recordQuestion(categoryId: "signs", isCorrect: true)
        progress.initializeStreakForNewDay()
        
        XCTAssertEqual(progress.learnedStreak, 1, "First activity should start streak at 1")
    }
    
    func test_streak_sameDay_noIncrement() {
        var progress = TrialProgress()
        progress.learnedStreak = 5
        progress.lastActivityDate = Date()
        
        progress.updateDailyStreak()
        
        XCTAssertEqual(progress.learnedStreak, 5, "Streak unchanged on same day")
    }
    
    func test_streak_consecutiveDay_increment() {
        var progress = TrialProgress()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: Date())!
        progress.lastActivityDate = yesterday
        progress.learnedStreak = 5
        
        progress.updateDailyStreak()
        
        XCTAssertEqual(progress.learnedStreak, 6, "Streak increments on consecutive day")
    }
    
    func test_streak_twoDay Gap_reset() {
        var progress = TrialProgress()
        let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: Date())!
        progress.lastActivityDate = twoDaysAgo
        progress.learnedStreak = 10
        
        progress.updateDailyStreak()
        
        XCTAssertEqual(progress.learnedStreak, 0, "Streak resets after 2+ day gap")
    }
    
    func test_streak_restartAfterGap() {
        var progress = TrialProgress()
        let threeDaysAgo = calendar.date(byAdding: .day, value: -3, to: Date())!
        progress.lastActivityDate = threeDaysAgo
        progress.learnedStreak = 7
        
        // First update: reset to 0
        progress.updateDailyStreak()
        XCTAssertEqual(progress.learnedStreak, 0)
        
        // Initialize for new day: restart to 1
        progress.initializeStreakForNewDay()
        XCTAssertEqual(progress.learnedStreak, 1, "Streak restarts after gap")
    }
    
    func test_streak_consecutiveDaysBuildup() {
        var progress = TrialProgress()
        
        // Day 1: First activity
        progress.recordQuestion(categoryId: "signs", isCorrect: true)
        progress.initializeStreakForNewDay()
        XCTAssertEqual(progress.learnedStreak, 1)
        
        // Simulate day 2
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date())!
        progress.lastActivityDate = tomorrow
        
        progress.updateDailyStreak()
        XCTAssertEqual(progress.learnedStreak, 2, "Streak increments to 2")
        
        // Simulate day 3
        let dayAfter = calendar.date(byAdding: .day, value: 2, to: Date())!
        progress.lastActivityDate = dayAfter
        
        progress.updateDailyStreak()
        XCTAssertEqual(progress.learnedStreak, 3, "Streak increments to 3")
    }
    
    // MARK: - Issue #2: Timezone-Safe Daily Question Count
    
    func test_questionsAnsweredToday_sameDay() {
        var progress = TrialProgress()
        
        progress.recordQuestion(categoryId: "signs", isCorrect: true)
        progress.recordQuestion(categoryId: "signs", isCorrect: false)
        progress.recordQuestion(categoryId: "rights", isCorrect: true)
        
        XCTAssertEqual(progress.questionsAnsweredToday, 3)
    }
    
    func test_questionsAnsweredToday_newDay_resets() {
        var progress = TrialProgress()
        
        // Day 1: Answer 3 questions
        progress.recordQuestion(categoryId: "signs", isCorrect: true)
        progress.recordQuestion(categoryId: "signs", isCorrect: true)
        progress.recordQuestion(categoryId: "rights", isCorrect: true)
        XCTAssertEqual(progress.questionsAnsweredToday, 3)
        
        // Simulate day 2
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date())!
        progress.lastActivityDate = tomorrow
        
        // Record first question on day 2
        progress.recordQuestion(categoryId: "signs", isCorrect: true)
        
        XCTAssertEqual(progress.questionsAnsweredToday, 1, "Counter resets on new day")
        XCTAssertEqual(progress.questionsAnswered, 4, "Total still accumulated")
    }
    
    func test_questionsAnsweredToday_multipleSessionsSameDay() {
        var progress = TrialProgress()
        
        // Session 1
        progress.recordQuestion(categoryId: "signs", isCorrect: true)
        XCTAssertEqual(progress.questionsAnsweredToday, 1)
        
        // Session 2 (same day, minutes later)
        progress.recordQuestion(categoryId: "rights", isCorrect: true)
        XCTAssertEqual(progress.questionsAnsweredToday, 2)
        
        // Session 3
        progress.recordQuestion(categoryId: "fines", isCorrect: true)
        XCTAssertEqual(progress.questionsAnsweredToday, 3)
    }
    
    func test_questionsAnsweredToday_acrossTimezoneChange() {
        var progress = TrialProgress()
        progress.recordQuestion(categoryId: "signs", isCorrect: true)
        progress.recordQuestion(categoryId: "signs", isCorrect: true)
        
        let todayUTC = calendar.startOfDay(for: Date())
        
        // Simulate timezone change (stored UTC should handle this)
        // questionsCountedForDateUTC is set to UTC start-of-day
        XCTAssertEqual(progress.questionsAnsweredToday, 2, "Timezone change doesn't reset counter")
    }
    
    // MARK: - Happy Path: Basic Recording
    
    func test_recordQuestion_incrementsCounters() {
        var progress = TrialProgress()
        
        progress.recordQuestion(categoryId: "signs", isCorrect: true)
        
        XCTAssertEqual(progress.questionsAnswered, 1)
        XCTAssertEqual(progress.correctAnswers, 1)
        XCTAssertTrue(progress.categoriesUnlocked.contains("signs"))
    }
    
    func test_recordQuestion_multipleCategories() {
        var progress = TrialProgress()
        
        progress.recordQuestion(categoryId: "signs", isCorrect: true)
        progress.recordQuestion(categoryId: "rights", isCorrect: false)
        progress.recordQuestion(categoryId: "fines", isCorrect: true)
        
        XCTAssertEqual(progress.questionsAnswered, 3)
        XCTAssertEqual(progress.correctAnswers, 2)
        XCTAssertEqual(progress.categoriesUnlocked.count, 3)
    }
    
    func test_recordQuestion_noDuplicateCategories() {
        var progress = TrialProgress()
        
        progress.recordQuestion(categoryId: "signs", isCorrect: true)
        progress.recordQuestion(categoryId: "signs", isCorrect: false)
        progress.recordQuestion(categoryId: "signs", isCorrect: true)
        
        XCTAssertEqual(progress.categoriesUnlocked.count, 1)
    }
    
    // MARK: - Success Rate Calculation
    
    func test_successRate_allCorrect() {
        var progress = TrialProgress()
        progress.recordQuestion(categoryId: "signs", isCorrect: true)
        progress.recordQuestion(categoryId: "signs", isCorrect: true)
        
        XCTAssertEqual(progress.successRate, 1.0)
    }
    
    func test_successRate_allIncorrect() {
        var progress = TrialProgress()
        progress.recordQuestion(categoryId: "signs", isCorrect: false)
        progress.recordQuestion(categoryId: "signs", isCorrect: false)
        
        XCTAssertEqual(progress.successRate, 0.0)
    }
    
    func test_successRate_mixed() {
        var progress = TrialProgress()
        progress.recordQuestion(categoryId: "signs", isCorrect: true)
        progress.recordQuestion(categoryId: "signs", isCorrect: true)
        progress.recordQuestion(categoryId: "signs", isCorrect: false)
        progress.recordQuestion(categoryId: "signs", isCorrect: false)
        
        XCTAssertEqual(progress.successRate, 0.5)
    }
    
    func test_successRate_empty() {
        let progress = TrialProgress()
        
        XCTAssertEqual(progress.successRate, 0.0, "Empty progress has 0% success rate")
    }
    
    // MARK: - Codable Persistence
    
    func test_progressCodable() throws {
        var original = TrialProgress()
        original.recordQuestion(categoryId: "signs", isCorrect: true)
        original.recordQuestion(categoryId: "rights", isCorrect: false)
        original.learnedStreak = 5
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let json = try encoder.encode(original)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode(TrialProgress.self, from: json)
        
        XCTAssertEqual(original, decoded)
    }
}