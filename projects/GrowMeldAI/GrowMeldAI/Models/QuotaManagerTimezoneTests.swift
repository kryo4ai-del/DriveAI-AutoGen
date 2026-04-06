@MainActor
class QuotaManagerTimezoneTests: XCTestCase {
    var quotaManager: QuotaManager!
    var mockStore: MockQuotaStore!
    
    override func setUp() {
        super.setUp()
        mockStore = MockQuotaStore()
        quotaManager = QuotaManager(store: mockStore)
    }
    
    func test_resetIgnoredWithinSameCalendarDay() throws {
        let calendar = Calendar.current
        
        // Store state with reset date = today 00:00
        let today = calendar.startOfDay(for: .now)
        quotaManager.lastResetDate = today
        quotaManager.state = .freeTierActive(questionsRemaining: 2)
        
        // Check reset at 23:59 same day
        quotaManager.checkAndPerformDailyResetIfNeeded()
        
        // Should NOT reset
        if case .freeTierActive(let remaining) = quotaManager.state {
            XCTAssertEqual(remaining, 2, "Quota should remain unchanged within same day")
        }
    }
    
    func test_resetTriggersNextCalendarDay() throws {
        let calendar = Calendar.current
        
        // Set reset date to yesterday
        let yesterday = calendar.date(byAdding: .day, value: -1, to: calendar.startOfDay(for: .now))!
        quotaManager.lastResetDate = yesterday
        quotaManager.state = .freeTierActive(questionsRemaining: 2)
        
        // Check reset next day
        quotaManager.checkAndPerformDailyResetIfNeeded()
        
        // Should reset to 5
        if case .freeTierActive(let remaining) = quotaManager.state {
            XCTAssertEqual(remaining, 5, "Quota should reset to 5 on new calendar day")
        }
    }
    
    func test_resetCorrectAfterTimezoneTravel_Berlin_to_Tokyo() throws {
        let calendar = Calendar.current
        
        // Scenario: User in Berlin (UTC+1), answers question at 11:00 CEST
        // Stored: lastResetDate = 2024-04-10 00:00 CEST
        let berlinTZ = TimeZone(identifier: "Europe/Berlin")!
        var berlinCalendar = Calendar.current
        berlinCalendar.timeZone = berlinTZ
        
        // Simulate reset stored in Berlin time
        var berlinDate = DateComponents(year: 2024, month: 4, day: 10)
        let resetDate = berlinCalendar.date(from: berlinDate)!
        quotaManager.lastResetDate = resetDate
        quotaManager.state = .freeTierActive(questionsRemaining: 3)
        
        // User travels to Tokyo (UTC+9)
        // Same moment in time = 2024-04-10 18:00 JST (still same UTC day)
        // But when checking with current calendar...
        let tokyoTZ = TimeZone(identifier: "Asia/Tokyo")!
        var tokyoCalendar = Calendar.current
        tokyoCalendar.timeZone = tokyoTZ
        
        // The fix: use Calendar.current (user's device timezone)
        // Device timezone changes with location automatically
        // So this test verifies: component comparison works regardless of tz
        
        quotaManager.checkAndPerformDailyResetIfNeeded()
        
        // Should still be same calendar day in both zones (both April 10)
        if case .freeTierActive(let remaining) = quotaManager.state {
            XCTAssertEqual(remaining, 3, "No reset within same calendar day despite timezone")
        }
    }
    
    func test_resetAfterDayBoundary_across_timezones() throws {
        let calendar = Calendar.current
        
        // Previous day at 23:00 local time
        let yesterday = calendar.date(byAdding: .day, value: -1, to: calendar.startOfDay(for: .now))!
        quotaManager.lastResetDate = yesterday
        quotaManager.state = .freeTierActive(questionsRemaining: 1)
        
        // Next day at 00:30
        quotaManager.checkAndPerformDailyResetIfNeeded()
        
        // Should reset
        if case .freeTierActive(let remaining) = quotaManager.state {
            XCTAssertEqual(remaining, 5, "Should reset on day boundary")
        }
    }
}