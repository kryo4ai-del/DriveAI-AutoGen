enum PurchaseAnalyticsEvent {
    case featureViewed(String)
    case purchaseInitiated(featureId: String, price: Decimal)
    case purchaseCompleted(featureId: String, transactionId: String)
    case purchaseFailed(featureId: String, error: String)
    case restoreInitiated
    case restoreCompleted(count: Int)
}