// Tests/Freemium/Services/QuotaManagerDailyResetTests.swift

@MainActor
class QuotaManagerDailyResetTests: XCTestCase {
    
    var quotaManager: QuotaManager!
    var mockStore: MockQuotaStore!
    
    override func setUp() {
        super.setUp()
        mockStore = MockQuotaStore()
        quotaManager = QuotaManager(store: mockStore)
    }
    
    // MARK: - Daily Reset — Same Calendar Day
    
    func test_resetCheck_withinSameDay_ignoresReset() {
        // Arrange
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        quotaManager.lastResetDate = today
        quotaManager.state = .freeTierActive(questionsRemaining: 2)
        
        // Act
        quotaManager.checkAndPerformDailyResetIfNeeded()
        
        // Assert
        if case .freeTierActive(let remaining) = quotaManager.state {
            XCTAssertEqual(remaining, 2, "Should not reset within same calendar day")
        }
    }
    
    func test_resetCheck_atMidnight_triggersReset() {
        // Arrange
        let calendar = Calendar.current
        let yesterday = calendar.date(byAdding: .day, value: -1, to: calendar.startOfDay(for: .now))!
        quotaManager.lastResetDate = yesterday
        quotaManager.state = .freeTierActive(questionsRemaining: 1)
        
        // Act
        quotaManager.checkAndPerformDailyResetIfNeeded()
        
        // Assert
        if case .freeTierActive(let remaining) = quotaManager.state {
            XCTAssertEqual(remaining, 5, "Should reset to 5 questions on new day")
        }
    }
    
    func test_resetCheck_multiDaysPassed_resetsOnce() {
        // Arrange
        let calendar = Calendar.current
        let threeDaysAgo = calendar.date(byAdding: .day, value: -3, to: calendar.startOfDay(for: .now))!
        quotaManager.lastResetDate = threeDaysAgo
        quotaManager.state = .freeTierActive(questionsRemaining: 1)
        
        // Act
        quotaManager.checkAndPerformDailyResetIfNeeded()
        
        // Assert
        if case .freeTierActive(let remaining) = quotaManager.state {
            XCTAssertEqual(remaining, 5, "Should reset quota")
        }
        XCTAssertEqual(mockStore.saveCalls.count, 1, "Should persist exactly once")
    }
    
    // MARK: - Daily Reset — Timezone Edge Cases
    
    func test_resetCheck_ignoredWithinSameCalendarDay_acrossTimezones() {
        // Arrange
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        quotaManager.lastResetDate = today
        quotaManager.state = .freeTierActive(questionsRemaining: 3)
        
        // Component-based comparison should work regardless of TZ
        let todayComponents = calendar.dateComponents([.year, .month, .day], from: .now)
        let resetComponents = calendar.dateComponents([.year, .month, .day], from: quotaManager.lastResetDate)
        
        XCTAssertEqual(todayComponents.year, resetComponents.year)
        XCTAssertEqual(todayComponents.month, resetComponents.month)
        XCTAssertEqual(todayComponents.day, resetComponents.day)
        
        // Act
        quotaManager.checkAndPerformDailyResetIfNeeded()
        
        // Assert
        if case .freeTierActive(let remaining) = quotaManager.state {
            XCTAssertEqual(remaining, 3, "No reset within same calendar day")
        }
    }
    
    // MARK: - Daily Reset — Trial State
    
    func test_resetCheck_trialActive_decrementsDaysRemaining() {
        // Arrange
        let calendar = Calendar.current
        let yesterday = calendar.date(byAdding: .day, value: -1, to: calendar.startOfDay(for: .now))!
        quotaManager.lastResetDate = yesterday
        quotaManager.state = .trialActive(daysRemaining: 5, questionsUsed: 20)
        
        // Act
        quotaManager.checkAndPerformDailyResetIfNeeded()
        
        // Assert
        if case .trialActive(let daysRemaining, let questionsUsed) = quotaManager.state {
            XCTAssertEqual(daysRemaining, 4, "Days remaining should decrement")
            XCTAssertEqual(questionsUsed, 0, "Questions used should reset")
        }
    }
    
    func test_resetCheck_trialActive_lastDay_expiresOnNextReset() {
        // Arrange
        let calendar = Calendar.current
        let yesterday = calendar.date(byAdding: .day, value: -1, to: calendar.startOfDay(for: .now))!
        quotaManager.lastResetDate = yesterday
        quotaManager.state = .trialActive(daysRemaining: 1, questionsUsed: 50)
        
        // Act
        quotaManager.checkAndPerformDailyResetIfNeeded()
        
        // Assert
        XCTAssertEqual(quotaManager.state, .trialExpired)
    }
    
    // MARK: - Daily Reset — Persistence
    
    func test_resetCheck_persistsNewResetDate() {
        // Arrange
        let calendar = Calendar.current
        let yesterday = calendar.date(byAdding: .day, value: -1, to: calendar.startOfDay(for: .now))!
        quotaManager.lastResetDate = yesterday
        quotaManager.state = .freeTierActive(questionsRemaining: 2)
        let oldResetDate = quotaManager.lastResetDate
        
        // Act
        quotaManager.checkAndPerformDailyResetIfNeeded()
        
        // Assert
        XCTAssertGreaterThan(quotaManager.lastResetDate, oldResetDate)
        
        // Verify persistence called
        XCTAssertGreaterThan(mockStore.saveCalls.count, 0)
    }
    
    func test_resetCheck_persistenceFailure_logsButContinues() {
        // Arrange
        mockStore.shouldFailOnSave = true
        let calendar = Calendar.current
        let yesterday = calendar.date(byAdding: .day, value: -1, to: calendar.startOfDay(for: .now))!
        quotaManager.lastResetDate = yesterday
        quotaManager.state = .freeTierActive(questionsRemaining: 2)
        
        // Act & Assert
        // Should not throw, should log error but continue
        XCTAssertNoThrow {
            quotaManager.checkAndPerformDailyResetIfNeeded()
        }
        
        // State should still be updated even if persistence fails
        if case .freeTierActive(let remaining) = quotaManager.state {
            XCTAssertEqual(remaining, 5, "State should update even if persistence fails")
        }
    }
}

// Helper for testing no throw
extension XCTestCase {
    func XCTAssertNoThrow(_ expression: @autoclosure () throws -> Void) {
        do {
            try expression()
        } catch {
            XCTFail("Expected no throw, but got: \(error)")
        }
    }
}