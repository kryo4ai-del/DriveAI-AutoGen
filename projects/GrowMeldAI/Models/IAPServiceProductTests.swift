// MARK: - Tests/IAPServiceTests/IAPServiceProductTests.swift

import XCTest
import Combine
@testable import DriveAI

final class IAPServiceProductTests: XCTestCase {
  var sut: IAPService!
  var mockPersistence: MockPersistence!
  var cancellables: Set<AnyCancellable>!
  
  override func setUp() {
    super.setUp()
    mockPersistence = MockPersistence()
    cancellables = []
  }
  
  override func tearDown() {
    sut = nil
    mockPersistence = nil
    cancellables = []
    super.tearDown()
  }
  
  // MARK: - Product Loading
  
  func test_loadProducts_success_returnsAllProducts() async throws {
    // GIVEN: StoreKit configured with 3 test products
    sut = IAPService(persistence: mockPersistence)
    
    // WHEN: loadProducts called
    let products = try await sut.loadProducts()
    
    // THEN: all products returned
    XCTAssertEqual(products.count, 3)
    XCTAssertTrue(products.contains { $0.id == "premium.monthly" })
    XCTAssertTrue(products.contains { $0.id == "premium.annual" })
  }
  
  func test_loadProducts_caches_resultsOnSecondCall() async throws {
    // GIVEN: Service initialized
    sut = IAPService(persistence: mockPersistence)
    let firstCall = try await sut.loadProducts()
    
    // WHEN: loadProducts called again
    let secondCall = try await sut.loadProducts()
    
    // THEN: results cached (same objects)
    XCTAssertEqual(firstCall, secondCall)
  }
  
  func test_loadProducts_invalidProductID_filtered() async throws {
    // GIVEN: StoreKit returns empty for invalid ID
    sut = IAPService(persistence: mockPersistence)
    
    // WHEN: loadProducts called
    let products = try await sut.loadProducts()
    
    // THEN: only valid products returned
    XCTAssertTrue(products.allSatisfy { !$0.id.isEmpty })
  }
  
  func test_loadProducts_mapsSubscriptionInfo_correctly() async throws {
    // GIVEN
    sut = IAPService(persistence: mockPersistence)
    
    // WHEN
    let products = try await sut.loadProducts()
    let monthlyProduct = products.first { $0.id == "premium.monthly" }!
    
    // THEN: subscription info present and correct
    XCTAssertNotNil(monthlyProduct.subscription)
    XCTAssertEqual(
      monthlyProduct.subscription?.period.unit,
      .month
    )
    XCTAssertEqual(monthlyProduct.subscription?.period.value, 1)
  }
}