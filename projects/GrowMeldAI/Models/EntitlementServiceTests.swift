// Tests/EntitlementServiceTests.swift
@MainActor
class EntitlementServiceTests: XCTestCase {
    var sut: EntitlementService!
    var mockStoreKit: MockStoreKitManager!
    var mockLocalData: MockLocalDataService!
    
    override func setUp() {
        super.setUp()
        mockStoreKit = MockStoreKitManager()
        mockLocalData = MockLocalDataService()
        sut = EntitlementService(
            storeKitManager: mockStoreKit,
            localDataService: mockLocalData
        )
    }
    
    func test_hasFeatureAccess_returnsTrueWhenEntitlementValid() async throws {
        // Given
        let entitlements = UserEntitlements(
            userId: "user1",
            premiumFeatures: ["unlimited_exams"]
        )
        mockLocalData.entitlements = entitlements
        
        // When
        let hasAccess = sut.hasFeatureAccess("unlimited_exams")
        
        // Then
        XCTAssertTrue(hasAccess)
    }
    
    func test_hasFeatureAccess_returnsFalseWhenSubscriptionExpired() async throws {
        // Given
        let expiredStatus = SubscriptionStatus.expired(wasAutoRenewable: true)
        let entitlements = UserEntitlements(
            userId: "user1",
            subscriptionStatus: expiredStatus
        )
        mockLocalData.entitlements = entitlements
        
        // When
        let hasAccess = sut.hasFeatureAccess("unlimited_exams")
        
        // Then
        XCTAssertFalse(hasAccess)
    }
}

// ✅ GOOD: Test business logic independently of StoreKit2
// Use mocks for external dependencies