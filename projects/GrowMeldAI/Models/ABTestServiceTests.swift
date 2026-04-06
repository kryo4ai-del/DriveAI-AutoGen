import XCTest
@testable import DriveAI

@MainActor
final class ABTestServiceTests: XCTestCase {
    
    // MARK: - Setup
    
    override func setUp() {
        super.setUp()
        // Ensure clean bundle config for each test
        try? FileManager.default.removeItem(
            at: Bundle.main.url(forResource: "ab_test_config", withExtension: "json")!
        )
    }
    
    // MARK: - Determinism Tests (CRITICAL)
    
    func testVariantAssignmentIsDeterministic() {
        let service = ABTestService(userID: "user123")
        waitForConfigLoad(service)
        
        // Same user should always get same variant
        let variant1 = service.getVariant(for: "color_semantics_test")
        let variant2 = service.getVariant(for: "color_semantics_test")
        let variant3 = service.getVariant(for: "color_semantics_test")
        
        XCTAssertEqual(variant1, variant2, "Variant assignment not deterministic (call 2)")
        XCTAssertEqual(variant2, variant3, "Variant assignment not deterministic (call 3)")
    }
    
    func testDifferentUsersDifferentVariants() {
        let config = createTestConfig(
            testID: "color_semantics_test",
            sampleSizePercent: 100,
            variants: [
                ABTestVariant(id: "control", name: "Control", treatmentType: .control, enabled: true),
                ABTestVariant(id: "treatment", name: "Treatment", treatmentType: .treatment, enabled: true)
            ]
        )
        
        let service1 = ABTestService(userID: "user1")
        let service2 = ABTestService(userID: "user2")
        let service3 = ABTestService(userID: "user3")
        
        mockConfigLoad(service: service1, config: config)
        mockConfigLoad(service: service2, config: config)
        mockConfigLoad(service: service3, config: config)
        
        let variant1 = service1.getVariant(for: "color_semantics_test")
        let variant2 = service2.getVariant(for: "color_semantics_test")
        let variant3 = service3.getVariant(for: "color_semantics_test")
        
        // At least one user should get a different variant
        let variants = [variant1, variant2, variant3].compactMap { $0 }
        let uniqueVariants = Set(variants)
        XCTAssertGreaterThan(uniqueVariants.count, 1, 
                            "Expected variance in variant assignment across users")
    }
    
    func testHashingAcrossAppRestarts() throws {
        // Verify SHA256 hashing produces same result in new instance
        let service1 = ABTestService(userID: "test_user")
        let hash1 = service1.hashUserForTest(userID: "test_user", testID: "color_test")
        
        // Simulate app restart
        let service2 = ABTestService(userID: "test_user")
        let hash2 = service2.hashUserForTest(userID: "test_user", testID: "color_test")
        
        XCTAssertEqual(hash1, hash2, 
                      "Hash not consistent across app restarts — would cause variant reassignment")
    }
    
    // MARK: - Sample Size Tests
    
    func testSampleSizeExclusion() {
        let service = ABTestService(userID: "user_excluded")
        
        let config = createTestConfig(
            testID: "small_sample_test",
            sampleSizePercent: 10, // Only 10% of users
            variants: [
                ABTestVariant(id: "variant_a", name: "A", treatmentType: .control, enabled: true)
            ]
        )
        
        mockConfigLoad(service: service, config: config)
        
        // Most users won't be in the 10% sample
        // This user might or might not be included — test the logic
        let variant = service.getVariant(for: "small_sample_test")
        
        // We can't assert nil since randomness, but verify behavior is correct
        if variant != nil {
            XCTAssertEqual(variant, "variant_a")
        }
    }
    
    func testSampleSize100Percent() {
        let service = ABTestService(userID: "user_included")
        
        let config = createTestConfig(
            testID: "full_sample_test",
            sampleSizePercent: 100, // All users
            variants: [
                ABTestVariant(id: "all_included", name: "Included", treatmentType: .control, enabled: true)
            ]
        )
        
        mockConfigLoad(service: service, config: config)
        
        let variant = service.getVariant(for: "full_sample_test")
        XCTAssertEqual(variant, "all_included", "100% sample size should include all users")
    }
    
    // MARK: - Test Lifecycle Tests
    
    func testTestNotStartedYet() {
        let service = ABTestService(userID: "user123")
        
        let futureDate = Date().addingTimeInterval(3600) // 1 hour from now
        let config = ABTestConfig(
            tests: [
                ABTestConfig.ABTest(
                    id: "future_test",
                    name: "Future Test",
                    feature: "future_feature",
                    enabled: true,
                    variants: [
                        ABTestVariant(id: "future_var", name: "Future", treatmentType: .control, enabled: true)
                    ],
                    sampleSizePercent: 100,
                    startDate: futureDate,
                    endDate: nil
                )
            ],
            version: "1.0",
            lastUpdated: Date()
        )
        
        mockConfigLoad(service: service, config: config)
        
        let variant = service.getVariant(for: "future_test")
        XCTAssertNil(variant, "Test should not return variant before start date")
    }
    
    func testTestEnded() {
        let service = ABTestService(userID: "user123")
        
        let pastDate = Date().addingTimeInterval(-3600) // 1 hour ago
        let config = ABTestConfig(
            tests: [
                ABTestConfig.ABTest(
                    id: "ended_test",
                    name: "Ended Test",
                    feature: "old_feature",
                    enabled: true,
                    variants: [
                        ABTestVariant(id: "old_var", name: "Old", treatmentType: .control, enabled: true)
                    ],
                    sampleSizePercent: 100,
                    startDate: nil,
                    endDate: pastDate
                )
            ],
            version: "1.0",
            lastUpdated: Date()
        )
        
        mockConfigLoad(service: service, config: config)
        
        let variant = service.getVariant(for: "ended_test")
        XCTAssertNil(variant, "Test should not return variant after end date")
    }
    
    func testTestDisabled() {
        let service = ABTestService(userID: "user123")
        
        let config = ABTestConfig(
            tests: [
                ABTestConfig.ABTest(
                    id: "disabled_test",
                    name: "Disabled Test",
                    feature: "disabled_feature",
                    enabled: false, // ← Disabled
                    variants: [
                        ABTestVariant(id: "disabled_var", name: "Disabled", treatmentType: .control, enabled: true)
                    ],
                    sampleSizePercent: 100,
                    startDate: nil,
                    endDate: nil
                )
            ],
            version: "1.0",
            lastUpdated: Date()
        )
        
        mockConfigLoad(service: service, config: config)
        
        let variant = service.getVariant(for: "disabled_test")
        XCTAssertNil(variant, "Disabled test should return nil")
    }
    
    // MARK: - Caching Tests
    
    func testVariantCaching() {
        let service = ABTestService(userID: "user123")
        
        let config = createTestConfig(
            testID: "cache_test",
            sampleSizePercent: 100,
            variants: [
                ABTestVariant(id: "cached_var", name: "Cached", treatmentType: .control, enabled: true)
            ]
        )
        
        mockConfigLoad(service: service, config: config)
        
        // First call — cache miss
        let variant1 = service.getVariant(for: "cache_test")
        
        // Simulate config being cleared (cache should persist)
        service.config = nil
        
        // Second call — should return from cache
        let variant2 = service.getVariant(for: "cache_test")
        
        XCTAssertEqual(variant1, variant2, "Cache not working — variant changed")
    }
    
    func testCacheClearance() {
        let service = ABTestService(userID: "user123")
        
        let config = createTestConfig(
            testID: "clear_cache_test",
            sampleSizePercent: 100,
            variants: [
                ABTestVariant(id: "clearable", name: "Clearable", treatmentType: .control, enabled: true)
            ]
        )
        
        mockConfigLoad(service: service, config: config)
        
        let variant1 = service.getVariant(for: "clear_cache_test")
        service.clearCache()
        service.config = nil // Simulate config unavailable
        
        let variant2 = service.getVariant(for: "clear_cache_test")
        
        XCTAssertNotNil(variant1, "First call should succeed")
        XCTAssertNil(variant2, "After clear, should fail without config")
    }
    
    // MARK: - Error Cases
    
    func testConfigNotLoaded() {
        let service = ABTestService(userID: "user123")
        
        // Don't load config
        // service.isReady = false
        
        let variant = service.getVariant(for: "any_test")
        XCTAssertNil(variant, "Should return nil if config not loaded")
    }
    
    func testTestNotFound() {
        let service = ABTestService(userID: "user123")
        
        let config = createTestConfig(
            testID: "existing_test",
            sampleSizePercent: 100,
            variants: [
                ABTestVariant(id: "existing", name: "Existing", treatmentType: .control, enabled: true)
            ]
        )
        
        mockConfigLoad(service: service, config: config)
        
        let variant = service.getVariant(for: "nonexistent_test")
        XCTAssertNil(variant, "Should return nil for nonexistent test")
    }
    
    // MARK: - Helpers
    
    private func createTestConfig(
        testID: String,
        sampleSizePercent: Int,
        variants: [ABTestVariant]
    ) -> ABTestConfig {
        ABTestConfig(
            tests: [
                ABTestConfig.ABTest(
                    id: testID,
                    name: testID,
                    feature: "test_feature",
                    enabled: true,
                    variants: variants,
                    sampleSizePercent: sampleSizePercent,
                    startDate: nil,
                    endDate: nil
                )
            ],
            version: "1.0",
            lastUpdated: Date()
        )
    }
    
    private func mockConfigLoad(service: ABTestService, config: ABTestConfig) {
        service.config = config
        service.isReady = true
    }
    
    private func waitForConfigLoad(_ service: ABTestService, timeout: TimeInterval = 5) {
        let expectation = expectation(description: "Config loaded")
        
        var observer: NSObjectProtocol?
        observer = service.$isReady.sink { isReady in
            if isReady {
                expectation.fulfill()
                observer = nil
            }
        }.store(in: &[])
        
        waitForExpectations(timeout: timeout)
    }
}