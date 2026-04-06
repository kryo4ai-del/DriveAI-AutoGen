extension AnalyticsCoordinator {
    private func shouldTrack() -> Bool {
        switch consentService.state {
        case .granted:
            return true
        case .denied, .unasked, .revoked:
            return false
        }
    }
    
    func trackEvent(_ event: AnalyticsEvent) {
        guard shouldTrack() else { return }
        queue.enqueue(event)
    }
}