struct PrivacyConsentSheet: View {
    @EnvironmentObject var privacyService: PrivacyConsentService
    @EnvironmentObject var analyticsCoordinator: AnalyticsCoordinator
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    
    var onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            // ... content
        }
        .padding()
        .transition(
            reduceMotion ? .opacity : .move(edge: .bottom) // ✅ Respect motion pref
        )
    }
}