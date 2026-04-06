enum TrialAnalyticsEvent {
    case trialStarted(source: String)  // "onboarding" or "direct"
    case featureBlocked(feature: String, attempt: Int)
    case paywalShown(source: String)
    case purchaseInitiated
    case purchaseCompleted(tier: String)
    case trialExpired
}
