// Core gating protocol
protocol TrialGated {
    var requiredStatus: TrialStatus { get }
    var fallbackView: AnyView { get }
}

// Reusable modifier
struct TrialGateModifier: ViewModifier {
    @EnvironmentObject var coordinator: TrialCoordinator
    let requirement: TrialStatus
    let fallback: AnyView
    
    func body(content: Content) -> some View {
        if coordinator.checkTrialStatus() >= requirement {
            content
        } else {
            fallback
        }
    }
}

// Usage
QuestionView()
    .trialGated(.active, fallback: TrialPaywallView())