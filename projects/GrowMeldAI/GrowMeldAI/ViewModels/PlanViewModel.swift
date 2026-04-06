@MainActor
final class PlanViewModel: ObservableObject {
    func generatePlan() {
        // ... generate new plan ...
        
        // Announce to VoiceOver
        UIAccessibility.post(
            notification: .announcement,
            argument: plan?.accessibilityAnnouncement
        )
    }
}