// Tests/Models/StreakDataTests.swift
import XCTest
@testable import DriveAI

class StreakDataTests: XCTestCase {
    
    // MARK: - Streak Continuation
    
    func test_streak_updateWithTodayAndYesterdayAttempt_continuesStreak() {
        // Given
        let yesterday = Date().addingTimeInterval(-86400)
        var streak = StreakData()
        streak.current = 1
        streak.lastAttemptDate = yesterday
        
        // When
        streak.updateStreak(attemptedToday: true)
        
        // Then
        XCTAssertEqual(streak.current, 2)
        XCTAssertEqual(streak.longest, 2)
    }
    
    func test_streak_continuousAttempts_incrementsCorrectly() {
        var streak = StreakData()
        
        for i in 1...5 {
            let dateForDay = Date().addingTimeInterval(-86400 * Double(5 - i))
            streak.lastAttemptDate = dateForDay
            streak.updateStreak(attemptedToday: true)
        }
        
        XCTAssertEqual(streak.current, 5)
        XCTAssertEqual(streak.longest, 5)
    }
    
    // MARK: - Streak Breaks
    
    func test_streak_updateWithMissedDay_breaksStreak() {
        // Given: Last attempt was 2 days ago
        let twoDaysAgo = Date().addingTimeInterval(-86400 * 2)
        var streak = StreakData()
        streak.current = 5
        streak.longest = 5
        streak.lastAttemptDate = twoDaysAgo
        
        // When
        streak.updateStreak(attemptedToday: true)
        
        // Then: Streak resets to 1
        XCTAssertEqual(streak.current, 1)
        XCTAssertEqual(streak.longest, 5) // Longest preserved
    }
    
    func test_streak_noAttemptToday_doesNotUpdate() {
        let yesterday = Date().addingTimeInterval(-86400)
        var streak = StreakData()
        streak.current = 3
        streak.lastAttemptDate = yesterday
        
        streak.updateStreak(attemptedToday: false)
        
        XCTAssertEqual(streak.current, 3) // Unchanged
    }
    
    // MARK: - Edge Cases
    
    func test_streak_multipleAttemptsOnSameDay_countedOnce() {
        var streak = StreakData()
        
        // First attempt today
        streak.updateStreak(attemptedToday: true)
        XCTAssertEqual(streak.current, 1)
        
        // Second attempt same day (simulated)
        let today = Calendar.current.startOfDay(for: Date())
        streak.updateStreak(attemptedToday: Calendar.current.isDateInToday(today))
        
        XCTAssertEqual(streak.current, 1) // Should not increment
    }
    
    func test_streak_isStreakActive_withRecentAttempt_returnsTrue() {
        var streak = StreakData()
        streak.lastAttemptDate = Date().addingTimeInterval(-3600) // 1 hour ago
        
        XCTAssertTrue(streak.isStreakActive)
    }
    
    func test_streak_isStreakActive_withOldAttempt_returnsFalse() {
        var streak = StreakData()
        streak.lastAttemptDate = Date().addingTimeInterval(-86400 * 3) // 3 days ago
        
        XCTAssertFalse(streak.isStreakActive)
    }
    
    func test_streak_longestRecordPreservedAfterBreak() {
        var streak = StreakData()
        streak.current = 10
        streak.longest = 10
        
        // Break streak
        streak.lastAttemptDate = Date().addingTimeInterval(-86400 * 5)
        streak.updateStreak(attemptedToday: true)
        
        XCTAssertEqual(streak.current, 1)
        XCTAssertEqual(streak.longest, 10) // Preserved!
    }
}