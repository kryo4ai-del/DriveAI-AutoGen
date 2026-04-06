class SessionManager: ObservableObject {
    private let analyticsService: AnalyticsService
    private var sessionStart: Date?
    
    func beginSession() async {
        sessionStart = Date()
        await analyticsService.track(.sessionStarted)
    }
    
    func endSession() async {
        guard let start = sessionStart else { return }
        let duration = Int(Date().timeIntervalSince(start))
        
        await analyticsService.track(
            .sessionEnded(durationSeconds: duration)
        )
        sessionStart = nil
    }
    
    // Call from SceneDelegate or App lifecycle
}