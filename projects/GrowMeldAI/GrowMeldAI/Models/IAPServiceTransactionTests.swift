// MARK: - Tests/IAPServiceTests/IAPServiceTransactionTests.swift

import XCTest
@testable import DriveAI

final class IAPServiceTransactionTests: XCTestCase {
  var observer: TransactionObserver!
  var mockPersistence: MockPersistence!
  
  override func setUp() {
    super.setUp()
    mockPersistence = MockPersistence()
    observer = TransactionObserver(persistence: mockPersistence)
  }
  
  // MARK: - Replay Protection
  
  func test_recordTransaction_deduplicatesSameID() async throws {
    // GIVEN: Transaction to record
    let transaction = IAPTransaction(
      id: "tx123",
      productID: "premium.monthly",
      purchaseDate: Date(),
      expirationDate: Date().addingTimeInterval(30 * 86400),
      revocationDate: nil,
      isUpgraded: false,
      jwsRepresentation: "mock.jws"
    )
    
    // WHEN: Record twice
    try await observer.recordTransaction(transaction)
    try await observer.recordTransaction(transaction)
    
    // THEN: Only recorded once
    let processed = try mockPersistence.loadProcessedTransactionIDs()
    XCTAssertEqual(processed.count, 1)
    XCTAssertTrue(processed.contains("tx123"))
  }
  
  func test_recordTransaction_multipleDifferentTransactions() async throws {
    // GIVEN: Multiple transactions
    let tx1 = mockTransaction(id: "tx1")
    let tx2 = mockTransaction(id: "tx2")
    let tx3 = mockTransaction(id: "tx3")
    
    // WHEN: Record all
    try await observer.recordTransaction(tx1)
    try await observer.recordTransaction(tx2)
    try await observer.recordTransaction(tx3)
    
    // THEN: All tracked
    let processed = try mockPersistence.loadProcessedTransactionIDs()
    XCTAssertEqual(processed.count, 3)
  }
  
  func test_isTransactionProcessed_returnsTrueForKnownID() async throws {
    // GIVEN: Recorded transaction
    let transaction = mockTransaction(id: "known-tx")
    try await observer.recordTransaction(transaction)
    
    // WHEN/THEN
    XCTAssertTrue(observer.isTransactionProcessed("known-tx"))
    XCTAssertFalse(observer.isTransactionProcessed("unknown-tx"))
  }
  
  // MARK: - Helpers
  
  private func mockTransaction(id: String) -> IAPTransaction {
    IAPTransaction(
      id: id,
      productID: "premium.monthly",
      purchaseDate: Date(),
      expirationDate: Date().addingTimeInterval(30 * 86400),
      revocationDate: nil,
      isUpgraded: false,
      jwsRepresentation: "mock.jws"
    )
  }
}