// MARK: - Test Suite: Consent State Persistence
class MetaAdServiceConsentTests: XCTestCase {
    var sut: MetaAdService!
    var mockDefaults: UserDefaults!
    
    override func setUp() {
        super.setUp()
        // Create isolated UserDefaults suite for testing
        mockDefaults = UserDefaults(suiteName: "test.meta.ads")
        mockDefaults?.removePersistentDomain(forName: "test.meta.ads")
        
        sut = MetaAdService()
        sut.userDefaults = mockDefaults  // Inject mock
    }
    
    override func tearDown() {
        mockDefaults?.removePersistentDomain(forName: "test.meta.ads")
        super.tearDown()
    }
    
    // HAPPY PATH: User accepts consent
    func test_acceptConsent_writesToUserDefaults() async throws {
        // Act
        await sut.acceptConsent()
        
        // Assert
        XCTAssertTrue(
            mockDefaults.bool(forKey: "meta_ads_consent"),
            "Consent key should be set to true"
        )
        XCTAssertNotNil(
            mockDefaults.object(forKey: "meta_ads_consent_timestamp"),
            "Timestamp should be recorded"
        )
        XCTAssertNil(
            mockDefaults.object(forKey: "meta_ads_consent_deferred"),
            "Deferred flag should be removed after acceptance"
        )
    }
    
    // HAPPY PATH: User defers consent
    func test_deferConsentDecision_setsOnlyDeferredFlag() async throws {
        // Act
        await sut.deferConsentDecision()
        
        // Assert
        XCTAssertFalse(
            mockDefaults.bool(forKey: "meta_ads_consent"),
            "Consent should remain false (undecided)"
        )
        XCTAssertTrue(
            mockDefaults.bool(forKey: "meta_ads_consent_deferred"),
            "Deferred flag should be set"
        )
    }
    
    // EDGE CASE: Multiple accept calls (idempotency)
    func test_acceptConsent_calledTwice_doesNotDuplicateState() async throws {
        // Act
        await sut.acceptConsent()
        let timestamp1 = mockDefaults.object(forKey: "meta_ads_consent_timestamp") as? Date
        
        try await Task.sleep(nanoseconds: 100_000_000)  // 0.1s delay
        
        await sut.acceptConsent()
        let timestamp2 = mockDefaults.object(forKey: "meta_ads_consent_timestamp") as? Date
        
        // Assert
        XCTAssertNotEqual(timestamp1, timestamp2, "Second call should update timestamp")
        XCTAssertTrue(mockDefaults.bool(forKey: "meta_ads_consent"))
    }
    
    // EDGE CASE: requestConsent returns correct state after accept
    func test_requestConsent_afterAccept_returnsGrantedTrue() async throws {
        // Arrange
        await sut.acceptConsent()
        
        // Act
        let consent = await sut.requestConsent()
        
        // Assert
        XCTAssertTrue(consent.isGranted, "Consent should be granted after accept")
        XCTAssertEqual(consent.source, .onboarding)
    }
    
    // EDGE CASE: requestConsent returns false before any decision
    func test_requestConsent_beforeDecision_returnsGrantedFalse() async throws {
        // Act (no prior decision)
        let consent = await sut.requestConsent()
        
        // Assert
        XCTAssertFalse(consent.isGranted, "Consent should be false when undecided")
    }
    
    // CRITICAL: Defer then accept should switch state
    func test_deferThenAccept_consentBecomesTrueAndDeferredRemoved() async throws {
        // Act 1: Defer
        await sut.deferConsentDecision()
        XCTAssertTrue(mockDefaults.bool(forKey: "meta_ads_consent_deferred"))
        
        // Act 2: Accept
        await sut.acceptConsent()
        
        // Assert
        XCTAssertTrue(mockDefaults.bool(forKey: "meta_ads_consent"))
        XCTAssertFalse(mockDefaults.bool(forKey: "meta_ads_consent_deferred"))
    }
    
    // RACE CONDITION TEST: Concurrent consent operations
    func test_concurrentAcceptAndDefer_noDatabaseCorruption() async throws {
        // Act: Fire both concurrently
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.sut.acceptConsent() }
            group.addTask { await self.sut.deferConsentDecision() }
        }
        
        // Assert: Final state should be valid (either accept or defer won, not mixed)
        let isConsented = mockDefaults.bool(forKey: "meta_ads_consent")
        let isDeferred = mockDefaults.bool(forKey: "meta_ads_consent_deferred")
        
        XCTAssertFalse(
            isConsented && isDeferred,
            "Both flags should never be true simultaneously"
        )
    }
    
    // DATA INTEGRITY: Timestamp format validation
    func test_acceptConsent_timestampIsValidDate() async throws {
        // Act
        await sut.acceptConsent()
        
        // Assert
        let timestamp = mockDefaults.object(forKey: "meta_ads_consent_timestamp") as? Date
        XCTAssertNotNil(timestamp)
        XCTAssertLessThan(
            Date().timeIntervalSince(timestamp ?? Date()),
            1.0,
            "Timestamp should be within last 1 second"
        )
    }
}