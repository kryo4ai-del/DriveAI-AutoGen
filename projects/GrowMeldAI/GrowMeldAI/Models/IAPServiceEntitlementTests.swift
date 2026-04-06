// MARK: - Tests/IAPServiceTests/IAPServiceEntitlementTests.swift

import XCTest
@testable import DriveAI

final class IAPServiceEntitlementTests: XCTestCase {
  var sut: IAPService!
  var mockPersistence: MockPersistence!
  
  override func setUp() {
    super.setUp()
    mockPersistence = MockPersistence()
    sut = IAPService(persistence: mockPersistence)
  }
  
  // MARK: - Entitlement Refresh
  
  func test_refreshEntitlements_loadsFromPersistence() async throws {
    // GIVEN: Saved entitlements in persistence
    let saved = IAPEntitlements(
      isPremium: true,
      premiumProduct: mockPremiumProduct(),
      activeSubscription: mockActiveTransaction(),
      expirationDate: Date().addingTimeInterval(30 * 86400)
    )
    try mockPersistence.saveEntitlements(saved)
    
    // Create fresh service (loads from persistence)
    sut = IAPService(persistence: mockPersistence)
    
    // WHEN
    try await sut.refreshEntitlements()
    
    // THEN
    XCTAssertTrue(sut.entitlements.isPremium)
    XCTAssertNotNil(sut.entitlements.activeSubscription)
  }
  
  func test_refreshEntitlements_withExpiredSubscription() async throws {
    // GIVEN: Expired subscription in persistence
    let expired = IAPTransaction(
      id: "tx1",
      productID: "premium.monthly",
      purchaseDate: Date().addingTimeInterval(-60 * 86400),
      expirationDate: Date().addingTimeInterval(-1 * 86400), // 1 day ago
      revocationDate: nil,
      isUpgraded: false,
      jwsRepresentation: "mock.jws"
    )
    
    mockPersistence.mockActiveTransaction = expired
    
    // WHEN
    sut = IAPService(persistence: mockPersistence)
    try await sut.refreshEntitlements()
    
    // THEN: Not premium anymore
    XCTAssertFalse(sut.entitlements.isPremium)
  }
  
  func test_refreshEntitlements_withGracePeriod() async throws {
    // GIVEN: Subscription expired 2 days ago (within 7-day grace period)
    let gracePeriod = IAPTransaction(
      id: "tx1",
      productID: "premium.monthly",
      purchaseDate: Date().addingTimeInterval(-60 * 86400),
      expirationDate: Date().addingTimeInterval(-2 * 86400),
      revocationDate: nil,
      isUpgraded: false,
      jwsRepresentation: "mock.jws"
    )
    
    mockPersistence.mockActiveTransaction = gracePeriod
    sut = IAPService(persistence: mockPersistence)
    
    // WHEN
    try await sut.refreshEntitlements()
    
    // THEN: Still active in grace period
    XCTAssertTrue(sut.entitlements.isPremium)
  }
  
  func test_hasAccess_toPremiumFeature_withActiveSubscription() async throws {
    // GIVEN: Premium entitlements
    let entitlements = IAPEntitlements(
      isPremium: true,
      premiumProduct: mockPremiumProduct(),
      activeSubscription: mockActiveTransaction(),
      expirationDate: Date().addingTimeInterval(30 * 86400)
    )
    try mockPersistence.saveEntitlements(entitlements)
    
    sut = IAPService(persistence: mockPersistence)
    
    // WHEN/THEN
    XCTAssertTrue(sut.hasAccess(to: .unlimitedExams))
    XCTAssertTrue(sut.hasAccess(to: .detailedStatistics))
    XCTAssertTrue(sut.hasAccess(to: .adFree))
  }
  
  func test_hasAccess_toPremiumFeature_withoutSubscription() async throws {
    // GIVEN: Free user
    sut = IAPService(persistence: mockPersistence)
    
    // WHEN/THEN
    XCTAssertFalse(sut.hasAccess(to: .unlimitedExams))
    XCTAssertFalse(sut.hasAccess(to: .adFree))
  }
  
  // MARK: - Helpers
  
  private func mockPremiumProduct() -> IAPProduct {
    IAPProduct(
      id: "premium.monthly",
      displayName: "Premium Monthly",
      description: "Test premium",
      price: 9.99,
      displayPrice: "€9.99",
      type: .autoRenewable,
      isFamilyShareable: true,
      subscription: IAPProduct.SubscriptionInfo(
        period: .init(value: 1, unit: .month),
        introductoryOffer: nil,
        promotionalOffers: []
      )
    )
  }
  
  private func mockActiveTransaction() -> IAPTransaction {
    IAPTransaction(
      id: "tx1",
      productID: "premium.monthly",
      purchaseDate: Date(),
      expirationDate: Date().addingTimeInterval(30 * 86400),
      revocationDate: nil,
      isUpgraded: false,
      jwsRepresentation: "mock.jws"
    )
  }
}