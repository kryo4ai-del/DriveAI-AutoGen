// MARK: - Tests/IAPServiceTests/IAPServicePurchaseTests.swift

import XCTest
@testable import DriveAI

final class IAPServicePurchaseTests: XCTestCase {
  var sut: IAPService!
  var mockPersistence: MockPersistence!
  
  override func setUp() {
    super.setUp()
    mockPersistence = MockPersistence()
    sut = IAPService(persistence: mockPersistence)
  }
  
  // MARK: - Purchase Processing
  
  func test_purchase_success_updatesEntitlements() async throws {
    // GIVEN: User without premium
    XCTAssertFalse(sut.entitlements.isPremium)
    
    let products = try await sut.loadProducts()
    let monthlyProduct = products.first { $0.id == "premium.monthly" }!
    
    // WHEN: Purchase succeeds
    try await sut.purchase(product: monthlyProduct)
    
    // THEN: Entitlements updated
    XCTAssertTrue(sut.entitlements.isPremium)
    XCTAssertEqual(
      sut.entitlements.premiumProduct?.id,
      "premium.monthly"
    )
  }
  
  func test_purchase_success_persistsEntitlements() async throws {
    // GIVEN
    let products = try await sut.loadProducts()
    let product = products.first!
    
    // WHEN
    try await sut.purchase(product: product)
    
    // THEN: Persisted to storage
    let persisted = try mockPersistence.loadEntitlements()
    XCTAssertTrue(persisted?.isPremium ?? false)
  }
  
  func test_purchase_publishesEntitlementUpdate() async throws {
    // GIVEN
    let exp = expectation(description: "Entitlements updated")
    var entitlementsUpdated = false
    
    let products = try await sut.loadProducts()
    let product = products.first!
    
    sut.entitlementsPublisher
      .dropFirst() // Skip initial value
      .sink { entitlements in
        if entitlements.isPremium {
          entitlementsUpdated = true
          exp.fulfill()
        }
      }
      .store(in: &cancellables)
    
    // WHEN
    try await sut.purchase(product: product)
    
    // THEN
    await fulfillment(of: [exp], timeout: 5)
    XCTAssertTrue(entitlementsUpdated)
  }
  
  func test_purchase_invalidProduct_throws() async throws {
    // GIVEN: Non-existent product
    let fakeProduct = IAPProduct(
      id: "fake.product",
      displayName: "Fake",
      description: "Fake product",
      price: 0,
      displayPrice: "$0",
      type: .autoRenewable,
      isFamilyShareable: false,
      subscription: nil
    )
    
    // WHEN/THEN
    await XCTAssertThrowsError(sut.purchase(product: fakeProduct)) { error in
      XCTAssertEqual(error as? IAPError, .productsFetchFailed("Product not found"))
    }
  }
  
  var cancellables: Set<AnyCancellable> = []
}