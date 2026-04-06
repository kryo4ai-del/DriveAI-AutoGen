struct PurchaseIntent {
    let plan: SubscriptionPlan
    let initiatedAt: Date
}

// If retry needed later:
func retryFailedPurchase(_ intent: PurchaseIntent) async {
    // ... retry logic
}