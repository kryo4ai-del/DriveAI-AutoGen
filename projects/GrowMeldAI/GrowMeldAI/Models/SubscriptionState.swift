enum SubscriptionState {
    case loading
    case free
    case activeSubscription(tier: SubscriptionTier, expiryDate: Date, autoRenew: Bool)
    case activeTrialSubscription(tier: SubscriptionTier, endDate: Date)
    case expiredSubscription(lastTier: SubscriptionTier)
    case error(SubscriptionError)
}