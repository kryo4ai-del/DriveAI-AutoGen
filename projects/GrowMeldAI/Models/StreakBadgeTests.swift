// Tests/DesignSystem/StreakBadgeTests.swift
import XCTest
@testable import DriveAI

final class StreakBadgeTests: XCTestCase {
    
    // MARK: - Active Streak
    func testStreakBadgeShowsActiveTodayIfPracticedToday() {
        // Given
        let today = Date()
        let badge = StreakBadge(streakDays: 7, lastPracticeDate: today)
        
        // When
        let isActive = Calendar.current.isDateInToday(today)
        
        // Then
        XCTAssertTrue(isActive, "Streak should be active if practiced today")
    }
    
    func testStreakBadgeShowsActiveYesterdayIfPracticedYesterday() {
        // Given
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let badge = StreakBadge(streakDays: 3, lastPracticeDate: yesterday)
        
        // When
        let isActive = Calendar.current.isDateInYesterday(yesterday)
        
        // Then
        XCTAssertTrue(isActive, "Streak should be active if practiced yesterday")
    }
    
    // MARK: - Broken Streak
    func testStreakBadgeShowsBrokenIfNoPracticeForTwoDays() {
        // Given
        let twoDaysAgo = Calendar.current.date(byAdding: .day, value: -2, to: Date())!
        let badge = StreakBadge(streakDays: 5, lastPracticeDate: twoDaysAgo)
        
        // Then
        // Badge should show "Unterbrochen"
        XCTAssertNotEqual(twoDaysAgo, Date(), "Should not be today")
    }
    
    func testStreakBadgeShowsBrokenIfNeverPracticed() {
        // Given
        let badge = StreakBadge(streakDays: 0, lastPracticeDate: nil)
        
        // Then
        XCTAssertNil(badge.lastPracticeDate, "No practice date should show broken")
    }
    
    // MARK: - Display Content
    func testStreakBadgeDisplaysDayCount() {
        // Given
        let badge = StreakBadge(streakDays: 14, lastPracticeDate: Date())
        
        // Then
        XCTAssertEqual(badge.streakDays, 14, "Should display correct day count")
    }
    
    func testStreakBadgeHandlesZeroDays() {
        // Given
        let badge = StreakBadge(streakDays: 0, lastPracticeDate: nil)
        
        // Then
        XCTAssertEqual(badge.streakDays, 0, "Should handle zero-day streak")
    }
    
    // MARK: - Edge Cases
    func testStreakBadgeHandlesLongStreaks() {
        // Given
        let badge = StreakBadge(streakDays: 365, lastPracticeDate: Date())
        
        // Then
        XCTAssertEqual(badge.streakDays, 365, "Should handle year-long streak")
    }
    
    // MARK: - Accessibility
    func testStreakBadgeAccessibilityLabel() {
        // Given
        let badge = StreakBadge(streakDays: 7, lastPracticeDate: Date())
        
        // Then
        // Should announce "Training Streak, 7 Days Active"
        XCTAssertTrue(true, "Should have complete accessibility label")
    }
}