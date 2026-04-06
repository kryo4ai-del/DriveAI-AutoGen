protocol AdServiceProtocol {
    func requestConsent() async throws -> AdConsent
    func deferConsentDecision() async throws
    func trackAdExposure(campaignId: String) async throws
    func logFeedback(_ feedback: AdFeedback) async throws
}