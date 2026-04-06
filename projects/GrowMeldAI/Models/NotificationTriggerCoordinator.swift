@MainActor
class NotificationTriggerCoordinator: ObservableObject {
    @Published var pendingTriggers: [PushNotificationTrigger] = []
    @Published var currentModalTrigger: PushNotificationTrigger?
    
    func evaluateTrigger(_ trigger: PushNotificationTrigger) {
        guard notificationService.shouldRequestConsent(for: trigger) else {
            return
        }
        
        pendingTriggers.append(trigger)
        showNextModal()
    }
    
    private func showNextModal() {
        guard !pendingTriggers.isEmpty else { return }
        
        // Sort by priority (exam > streak > other)
        pendingTriggers.sort { t1, t2 in
            triggerPriority(t1) > triggerPriority(t2)
        }
        
        currentModalTrigger = pendingTriggers.removeFirst()
    }
    
    func handleConsentDecision(_ decision: ConsentDecision) async {
        guard let trigger = currentModalTrigger else { return }
        
        try await notificationService.recordConsentDecision(decision, for: trigger)
        currentModalTrigger = nil
        showNextModal() // Show next pending trigger if any
    }
}