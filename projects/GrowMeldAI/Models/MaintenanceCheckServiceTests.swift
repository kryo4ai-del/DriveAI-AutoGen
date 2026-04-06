// 1. MaintenanceCheckServiceTests.swift
@MainActor
final class MaintenanceCheckServiceTests: XCTestCase {
    var sut: DefaultMaintenanceCheckService!
    var mockStatsService: MockStatsService!
    var mockCategoryService: MockCategoryService!
    
    // Test: runWeeklyChecks returns all check types
    func test_runWeeklyChecks_returnsAllCheckTypes() async throws { }
    
    // Test: staleCategoryAlert detected when category last practiced >7 days ago
    func test_detectStaleCategoryAlerts_whenCategoryNotPracticedFor7Days() async throws { }
    
    // Test: lowCompletionRate detected at <60%
    func test_detectLowCompletionRates_whenCompletionBelowThreshold() async throws { }
    
    // Test: streakBreak detected after 1-day gap
    func test_detectStreakBreaks_whenGapGreaterThan1Day() async throws { }
    
    // Test: resolveCheck marks check as resolved
    func test_resolveCheck_marksCheckResolved() async throws { }
    
    // Test: dismissCheck removes from unresolved list
    func test_dismissCheck_removesFromList() async throws { }
    
    // Test: error handling when StatsService fails
    func test_runWeeklyChecks_throwsWhenStatsServiceFails() async throws { }
}

// 2. MaintenanceSchedulerTests.swift
final class MaintenanceSchedulerTests: XCTestCase {
    var sut: MaintenanceScheduler!
    var mockCheckService: MockMaintenanceCheckService!
    
    func test_scheduleWeeklyChecks_schedulesAtCorrectTime() async throws { }
    func test_cancelScheduledChecks_cancelsTask() async throws { }
    func test_calculateNextRunDate_computesCorrectly() throws { }
}

// 3. MaintenanceModelsTests.swift
final class MaintenanceModelsTests: XCTestCase {
    func test_maintenanceCheck_encodesDecodesCorrectly() throws {
        let check = MaintenanceCheck(...)
        let encoded = try JSONEncoder().encode(check)
        let decoded = try JSONDecoder().decode(MaintenanceCheck.self, from: encoded)
        XCTAssertEqual(check, decoded)
    }
}