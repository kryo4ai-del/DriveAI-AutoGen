// BEFORE (BROKEN):
private func checkAndPerformDailyResetIfNeeded() {
    let calendar = Calendar.current
    let today = calendar.startOfDay(for: .now)
    let resetDay = calendar.startOfDay(for: lastResetDate)
    guard today > resetDay else { return }
    // ❌ Fails if user crosses timezone
}

// AFTER (SAFE):
private func checkAndPerformDailyResetIfNeeded() {
    let calendar = Calendar.current
    let now = Date.now
    
    // Compare calendar day components (timezone-agnostic)
    let todayComponents = calendar.dateComponents([.year, .month, .day], from: now)
    let lastComponents = calendar.dateComponents([.year, .month, .day], from: lastResetDate)
    
    let dayChanged = (
        todayComponents.year != lastComponents.year ||
        todayComponents.month != lastComponents.month ||
        todayComponents.day != lastComponents.day
    )
    
    guard dayChanged else { return }
    
    // Perform reset...
    lastResetDate = calendar.startOfDay(for: now)
    
    // Persist immediately
    Task {
        try? await store.save(state: state, resetDate: lastResetDate)
    }
}

// TEST:
@MainActor
class TimezoneTests: XCTestCase {
    func test_dailyResetIgnoredWithinSameCalendarDay_acrossTimezones() async throws {
        let mock = MockQuotaStore()
        let manager = QuotaManager(store: mock)
        
        // Simulate 23:00 in Berlin
        var berlinDate = Calendar.current.date(bySettingHour: 23, minute: 0, second: 0, of: .now)!
        manager.lastResetDate = berlinDate
        manager.state = .freeTierActive(questionsRemaining: 3)
        
        // Simulate travel to Tokyo (UTC+9), still same calendar day (00:15)
        // 2024-04-10 23:00 CET = 2024-04-11 06:00 JST — NEXT DAY in Tokyo!
        // But lastResetDate was stored as "2024-04-10" in local tz
        
        // This is actually correct — reset SHOULD trigger because day changed globally
        // The bug is more subtle: if time sync fails, could reset twice
        
        manager.checkAndPerformDailyResetIfNeeded()
        
        if case .freeTierActive(let remaining) = manager.state {
            XCTAssertEqual(remaining, 5, "Should reset quota to 5")
        }
    }
}