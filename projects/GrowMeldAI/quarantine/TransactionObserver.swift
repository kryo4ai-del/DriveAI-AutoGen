private func mapTransaction(_ transaction: Transaction) -> IAPTransaction {
    IAPTransaction(
      id: String(transaction.id),
      productID: transaction.productID,
      purchaseDate: transaction.purchaseDate,
      expirationDate: transaction.expirationDate,
      revocationDate: transaction.revocationDate,
      isUpgraded: transaction.isUpgraded,
      jwsRepresentation: transaction.jwsRepresentation
    )
  }
  
  private func mapStoreKitError(_ error: StoreKitError) -> IAPError {
    switch error {
    case .networkError:
      return .networkUnavailable
    case .notAvailableInStorefront:
      return .storeKitUnavailable
    case .invalidArgumentError:
      return .billingIssue(retryable: false)
    case .unknown:
      return .unknown("StoreKit error")
    @unknown default:
      return .unknown("Unknown StoreKit error")
    }
  }
}

// MARK: - Transaction Observer
class TransactionObserver: Sendable {
  private let persistence: IAPPersistence
  private let processedTransactions = NSMutableSet() // Thread-safe
  
  init(persistence: IAPPersistence) {
    self.persistence = persistence
  }
  
  func recordTransaction(_ transaction: IAPTransaction) async throws {
    let txnKey = transaction.id
    
    // Replay protection: Skip if already processed
    if processedTransactions.contains(txnKey) {
      return
    }
    
    // Mark as processed
    processedTransactions.add(txnKey)
    
    // Store in persistent layer
    try persistence.recordTransaction(transaction)
  }
  
  func isTransactionProcessed(_ id: String) -> Bool {
    processedTransactions.contains(id)
  }
}