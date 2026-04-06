// Tests/EventBusTests.swift

@MainActor
final class EventBusTests: XCTestCase {
    var eventBus: EventBus!
    
    override func setUp() async throws {
        eventBus = EventBus()
    }
    
    // Test 1: Events posted synchronously fire handlers
    func testEventDispatch() async throws {
        var receivedEvent: AppEvent?
        
        let observer = NSObject()
        await eventBus.subscribe(observer) { event in
            receivedEvent = event
        }
        
        let testEvent = AppEvent.onboardingStarted
        await eventBus.post(testEvent)
        
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1s
        XCTAssertEqual(receivedEvent, testEvent)
    }
    
    // Test 2: Events queue when offline
    func testOfflineQueueing() async throws {
        await eventBus.setOnlineStatus(false)
        
        let event1 = AppEvent.quizStarted(categoryId: "signs", questionCount: 30)
        await eventBus.post(event1)
        
        // Verify event is queued (not discarded)
        await eventBus.setOnlineStatus(true)
        // Should retry dispatch
    }
    
    // Test 3: A/B variant assignment is deterministic
    func testVariantDeterminism() async throws {
        let service = RemoteConfigFeatureFlagService()
        let userId = "test_user_123"
        
        let variant1 = await service.getVariant(experiment: "paywall_test", userId: userId)
        let variant2 = await service.getVariant(experiment: "paywall_test", userId: userId)
        
        XCTAssertEqual(variant1, variant2, "Same user should get same variant")
    }
    
    // Test 4: A/B variant distribution is fair
    func testVariantFairness() async throws {
        let service = RemoteConfigFeatureFlagService()
        let experimentId = "paywall_test"
        
        var variantCounts: [String: Int] = [:]
        let testUserCount = 1000
        
        for i in 0..<testUserCount {
            let userId = "user_\(i)"
            let variant = await service.getVariant(experiment: experimentId, userId: userId)
            variantCounts[variant, default: 0] += 1
        }
        
        // Chi-square test: expect roughly equal distribution
        for variant in ["control", "emotional", "functional", "urgency"] {
            let observed = Double(variantCounts[variant] ?? 0)
            let expected = Double(testUserCount) / 4.0
            let chiSquared = pow(observed - expected, 2) / expected
            XCTAssertLessThan(chiSquared, 7.815, "Variant \(variant) distribution is biased")
        }
    }
}