@MainActor
final class FeatureFlagService: ObservableObject {
    private let purchaseRepository: PurchaseLocalRepository
    private let subscriptionService: SubscriptionService // Ref existing domain
    
    func isFeatureUnlocked(_ feature: UnlockableFeature) async -> Bool {
        // Precedence: Active subscription > One-time purchase
        let hasActiveSubscription = await subscriptionService.hasActiveSubscriptionFor(feature)
        if hasActiveSubscription { return true }
        
        let hasPurchase = (try? await purchaseRepository.isFeaturePurchased(feature)) ?? false
        return hasPurchase
    }
}