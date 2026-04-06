enum SubscriptionPurchaseState {
    case success
    case pending
    case deferred  // Parent approval pending
    case userCancelled
    case error(SubscriptionError)
}

// In purchase():
switch result {
case .success(let verification):
    // Handle immediately
    
case .userCancelled:
    error = SubscriptionError.purchaseCancelled
    
case .pending:
    // Explicitly deferred (Ask to Buy)
    error = SubscriptionError.purchaseDeferred(
        "Warte auf Genehmigung des Betreuer"
    )
    
@unknown default:
    error = SubscriptionError.purchaseFailed("Unknown")
}