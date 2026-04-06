enum SubscriptionError: Error {
    case purchaseCancelled
    case purchaseDeferred(String)
    case purchaseFailed(String)
}

enum SubscriptionPurchaseState {
    case success
    case pending
    case deferred  // Parent approval pending
    case userCancelled
    case error(SubscriptionError)
}

enum PurchaseResult {
    case success(String)
    case userCancelled
    case pending
}

func handlePurchase(result: PurchaseResult) {
    var error: SubscriptionError?

    // In purchase():
    switch result {
    case .success(let verification):
        // Handle immediately
        _ = verification

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

    _ = error
}