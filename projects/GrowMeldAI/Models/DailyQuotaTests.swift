// Features/TrialMechanik/Tests/Domain/Models/TrialStatusTests.swift

import XCTest
@testable import DriveAI

@MainActor
final class DailyQuotaTests: XCTestCase {
    
    // MARK: - Happy Path
    
    func testInitialQuotaHasFiveQuestionsAvailable() {
        let quota = DailyQuota(lastResetDate: Date())
        
        XCTAssertEqual(quota.remainingToday, 5)
        XCTAssertEqual(quota.questionsUsed, 0)
        XCTAssertFalse(quota.isExhausted)
    }
    
    func testRecordingQuestionDecrementsQuota() {
        var quota = DailyQuota(lastResetDate: Date())
        
        quota.recordQuestion()
        XCTAssertEqual(quota.remainingToday, 4)
        XCTAssertEqual(quota.questionsUsed, 1)
        
        quota.recordQuestion()
        XCTAssertEqual(quota.remainingToday, 3)
        XCTAssertEqual(quota.questionsUsed, 2)
    }
    
    func testQuotaBecomesExhaustedAfterFiveQuestions() {
        var quota = DailyQuota(lastResetDate: Date())
        
        for _ in 0..<5 {
            XCTAssertFalse(quota.isExhausted)
            quota.recordQuestion()
        }
        
        XCTAssertTrue(quota.isExhausted)
        XCTAssertEqual(quota.remainingToday, 0)
    }
    
    func testQuotaCannotGoNegative() {
        var quota = DailyQuota(questionsUsed: 5, lastResetDate: Date())
        
        // Try to record beyond limit
        quota.recordQuestion()
        
        XCTAssertEqual(quota.questionsUsed, 5)
        XCTAssertEqual(quota.remainingToday, 0)
    }
    
    // MARK: - Reset Logic
    
    func testShouldResetIsFalseIfDateIsToday() {
        let quota = DailyQuota(lastResetDate: Date())
        
        XCTAssertFalse(quota.shouldReset)
    }
    
    func testShouldResetIsTrueIfDateIsYesterday() {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let quota = DailyQuota(lastResetDate: yesterday)
        
        XCTAssertTrue(quota.shouldReset)
    }
    
    func testResetClearsQuestionsAndUpdatesDate() {
        let oldDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        var quota = DailyQuota(questionsUsed: 5, lastResetDate: oldDate)
        
        let beforeReset = quota.lastResetDate
        quota.reset()
        let afterReset = quota.lastResetDate
        
        XCTAssertEqual(quota.questionsUsed, 0)
        XCTAssertEqual(quota.remainingToday, 5)
        XCTAssertNotEqual(beforeReset, afterReset)
        XCTAssertTrue(Calendar.current.isDateInToday(afterReset))
    }
    
    func testRecordQuestionTriggersResetIfNeeded() {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        var quota = DailyQuota(questionsUsed: 5, lastResetDate: yesterday)
        
        XCTAssertTrue(quota.shouldReset)
        
        quota.recordQuestion()
        
        // After reset + record: 1 used, 4 remaining
        XCTAssertEqual(quota.questionsUsed, 1)
        XCTAssertEqual(quota.remainingToday, 4)
        XCTAssertFalse(quota.shouldReset)
    }
    
    // MARK: - Edge Cases
    
    func testQuotaEncodingDecodingPreservesState() throws {
        var quota = DailyQuota(questionsUsed: 3, lastResetDate: Date())
        quota.recordQuestion()
        
        let encoded = try JSONEncoder().encode(quota)
        let decoded = try JSONDecoder().decode(DailyQuota.self, from: encoded)
        
        XCTAssertEqual(decoded, quota)
    }
    
    func testMultipleResetCyclesWork() {
        var quota = DailyQuota(lastResetDate: Date())
        
        // Day 1: use 2 questions
        quota.recordQuestion()
        quota.recordQuestion()
        XCTAssertEqual(quota.remainingToday, 3)
        
        // Simulate day 2
        let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        quota.lastResetDate = Calendar.current.date(byAdding: .day, value: -1, to: nextDay)!
        
        quota.recordQuestion()
        
        // Should reset + record on day 2
        XCTAssertEqual(quota.questionsUsed, 1)
        XCTAssertEqual(quota.remainingToday, 4)
    }
}

@MainActor

@MainActor
final class UserEntitlementsTests: XCTestCase {
    
    func testFreeEntitlementsHaveBasicAccess() {
        let free = UserEntitlements.free()
        
        XCTAssertFalse(free.canAccessExamMode)
        XCTAssertTrue(free.canAccessAllCategories)
        XCTAssertFalse(free.hasUnlimitedQuestions)
        XCTAssertFalse(free.canDownloadForOffline)
    }
    
    func testPremiumEntitlementsUnlockAllFeatures() {
        let premium = UserEntitlements.premium()
        
        XCTAssertTrue(premium.canAccessExamMode)
        XCTAssertTrue(premium.canAccessAllCategories)
        XCTAssertTrue(premium.hasUnlimitedQuestions)
        XCTAssertTrue(premium.canDownloadForOffline)
    }
}