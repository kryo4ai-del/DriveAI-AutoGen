final class SearchAdsAnalyticsAdapter {
    // ... existing code ...
    
    /// Track user progression through conversion funnel
    func trackConversionFunnel(step: ConversionStep) async {
        let timestamp = ISO8601DateFormatter().string(from: Date())
        
        var params: [String: String] = [
            "funnel_step": step.rawValue,
            "timestamp": timestamp
        ]
        
        // Attach ASA token for attribution
        if let token = try? await getAttributionToken() {
            params["asa_attribution_token"] = token
        }
        
        analyticsService.logEvent("conversion_funnel", parameters: params)
        logger.debug("Funnel step: \(step.rawValue)")
    }
}

enum ConversionStep: String {
    case asaClick = "asa_click"  // Tracked by Apple
    case appOpen = "app_open"
    case onboardingStart = "onboarding_start"
    case onboardingComplete = "onboarding_complete"
    case firstQuizStart = "first_quiz_start"
    case firstQuizComplete = "first_quiz_complete"
    case examStart = "exam_start"
    case examPass = "exam_pass"
}