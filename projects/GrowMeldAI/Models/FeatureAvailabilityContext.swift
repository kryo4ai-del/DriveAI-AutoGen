public struct FeatureAvailabilityContext {
    let tier: SubscriptionTier
    let region: String  // "DE", "AT", "CH"
    let isTrialActive: Bool
    let experimentVariant: String?  // For A/B testing paywall copy
}

extension SubscriptionFeature {
    /// Determine if feature is available in a specific context
    public static func isAvailable(
        _ feature: SubscriptionFeature,
        in context: FeatureAvailabilityContext
    ) -> Bool {
        // Region-aware availability
        switch (feature, context.region) {
        case (.detailedAnalytics, "CH"):
            return context.tier == .yearly  // Hypothetical regional rule
        default:
            return available(for: context.tier).contains(feature)
        }
    }
}