/// Feature availability reasons — helps communicate why a feature is locked
enum FeatureLockReason {
    case trialExpired(upgradeUrl: URL)
    case premiumRequired(upgradeUrl: URL)
    case dailyLimitExceeded(remainingQuestions: Int, resetTime: Date)
    case examAttemptsExceeded(remainingAttempts: Int, resetTime: Date)
    
    /// Localized explanation for accessibility (German)
    func a11yExplanation(localizer: Localizing) -> String {
        switch self {
        case .trialExpired:
            return localizer.localize("a11y.locked.trial_expired", arguments: [:])
        case .premiumRequired:
            return localizer.localize("a11y.locked.premium_required", arguments: [:])
        case .dailyLimitExceeded(let remaining, let resetTime):
            let resetText = formatTime(resetTime)
            return localizer.localize(
                "a11y.locked.daily_limit_exceeded",
                arguments: ["remaining": String(remaining), "resetTime": resetText]
            )
        case .examAttemptsExceeded(let remaining, let resetTime):
            let resetText = formatTime(resetTime)
            return localizer.localize(
                "a11y.locked.exam_attempts_exceeded",
                arguments: ["remaining": String(remaining), "resetTime": resetText]
            )
        }
    }
}
