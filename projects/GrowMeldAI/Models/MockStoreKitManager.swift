// MARK: - Tests/Mocks/MockStoreKitManager.swift (Revised)

/// Matches actual StoreKit2 transaction behavior
class MockStoreKitManager {
  var mockProducts: [IAPProduct] = []
  var allTransactions: [MockIAPTransaction] = []
  var transactionUpdates: [MockIAPTransaction] = []
  
  @MainActor
  func getProducts() async throws -> [IAPProduct] {
    return mockProducts
  }
  
  /// Simulates Transaction.all async sequence
  func makeTransactionSequence() -> AsyncStream<MockIAPTransaction> {
    return AsyncStream { continuation in
      for transaction in allTransactions {
        continuation.yield(transaction)
      }
      continuation.finish()
    }
  }
  
  /// Simulates Transaction.updates async sequence
  func makeUpdatesSequence() -> AsyncStream<MockIAPTransaction> {
    return AsyncStream { continuation in
      for update in transactionUpdates {
        continuation.yield(update)
      }
      continuation.finish()
    }
  }
}

// Usage in test
func test_observeTransactionUpdates() async {
  let manager = MockStoreKitManager()
  manager.transactionUpdates = [.premiumMonthly()]
  
  for await transaction in manager.makeUpdatesSequence() {
    XCTAssertEqual(transaction.productID, "premium.monthly")
  }
}