// MARK: - Tests/IAPServiceStoreKitIntegrationTests.swift

import StoreKit
import StoreKitTest
import XCTest
@testable import DriveAI

final class IAPServiceStoreKitIntegrationTests: XCTestCase {
  var sut: IAPService!
  var testSession: SKTestSession!
  
  override func setUp() async throws {
    try await super.setUp()
    
    // Initialize real StoreKit test session
    testSession = try SKTestSession(
      configurationFileNamed: "StoreKitTestConfig"
    )
    try testSession.resetToDefaultState()
    
    // Real IAPService with real StoreKit (in test environment)
    sut = IAPService()
  }
  
  override func tearDown() async throws {
    try testSession.resetToDefaultState()
    try await super.tearDown()
  }
  
  // Now use REAL StoreKit in test environment
  func test_loadProducts_fromTestEnvironment() async throws {
    // StoreKitTestConfig.json defines test products
    let products = try await Product.products(for: ["premium.monthly", "premium.annual"])
    
    XCTAssertEqual(products.count, 2)
    XCTAssertEqual(products[0].id, "premium.monthly")
  }
  
  func test_purchaseFlow_inTestEnvironment() async throws {
    let product = try await Product.products(for: ["premium.monthly"]).first!
    
    // Simulate user purchase in test environment
    try testSession.buyProduct(productIdentifier: "premium.monthly")
    
    // Verify transaction
    var entitlements: Set<String> = []
    for await result in Transaction.all {
      if case .verified(let transaction) = result {
        entitlements.insert(transaction.productID)
      }
    }
    
    XCTAssertTrue(entitlements.contains("premium.monthly"))
  }
}