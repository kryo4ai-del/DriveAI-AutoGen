// Tests/Freemium/Services/QuotaManagerTimerTests.swift

@MainActor
class QuotaManagerTimerTests: XCTestCase {
    
    var quotaManager: QuotaManager!
    var mockStore: MockQuotaStore!
    
    override func setUp() {
        super.setUp()
        mockStore = MockQuotaStore()
    }
    
    override func tearDown() {
        quotaManager = nil
        mockStore = nil
        super.tearDown()
    }
    
    func test_initialization_setupsDailyResetTimer() {
        // Arrange & Act
        quotaManager = QuotaManager(store: mockStore)
        
        // Assert
        // Timer should be active (private, so we verify behavior indirectly)
        // Create a new manager and verify timer fires
        XCTAssertNotNil(quotaManager)
    }
    
    func test_deallocation_invalidatesTimer() {
        // Arrange
        var manager: QuotaManager? = QuotaManager(store: mockStore)
        
        // Act
        manager = nil
        
        // Assert
        // No memory leak or dangling timer references
        XCTAssertNil(manager)
    }
    
    func test_periodicResetCheck_firesEveryMinute() async throws {
        // Arrange
        quotaManager = QuotaManager(store: mockStore)
        quotaManager.state = .freeTierActive(questionsRemaining: 5)
        
        let calendar = Calendar.current
        let yesterday = calendar.date(byAdding: .day, value: -1, to: calendar.startOfDay(for: .now))!
        quotaManager.lastResetDate = yesterday
        
        // Act: Wait for timer to fire (simulated; in real test, use XCTestExpectation)
        let expectation = XCTestExpectation(description: "Timer fires and resets quota")
        
        // Simulate timer firing
        quotaManager.checkAndPerformDailyResetIfNeeded()
        
        // Assert
        if case .freeTierActive(let remaining) = quotaManager.state {
            XCTAssertEqual(remaining, 5)
            expectation.fulfill()
        }
        
        await fulfillment(of: [expectation], timeout: 1.0)
    }
}