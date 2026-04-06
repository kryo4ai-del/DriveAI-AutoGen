@MainActor
final class SubscriptionViewModel: ObservableObject {
    @Published var subscriptionState: SubscriptionState = .loading {
        didSet {
            announceStateChange()
        }
    }
    
    private func announceStateChange() {
        let announcement = subscriptionState.accessibilityDescription
        UIAccessibility.post(
            notification: .announcement,
            argument: announcement
        )
        
        // Log for testing/debugging
        print("[Accessibility] \(announcement)")
    }
}