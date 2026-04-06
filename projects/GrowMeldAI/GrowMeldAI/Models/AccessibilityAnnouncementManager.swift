import Foundation

class AccessibilityAnnouncementManager: NSObject {
    static let shared = AccessibilityAnnouncementManager()
    
    private let announcementQueue = DispatchQueue(
        label: "com.driveai.accessibility.announcements",
        qos: .userInteractive,
        attributes: .serial
    )
    
    private var lastAnnouncementTime: Date = Date.distantPast
    private let minimumAnnouncementInterval: TimeInterval = 0.5 // Prevent overlapping announcements
    
    enum AnnouncementPriority {
        case standard
        case important
    }
    
    func announce(
        _ message: String,
        priority: AnnouncementPriority = .standard,
        debounce: Bool = true
    ) {
        announcementQueue.async { [weak self] in
            guard let self = self else { return }
            
            // Debounce to prevent rapid overlapping announcements
            if debounce {
                let timeSinceLastAnnouncement = Date().timeIntervalSince(self.lastAnnouncementTime)
                if timeSinceLastAnnouncement < self.minimumAnnouncementInterval {
                    return
                }
            }
            
            self.lastAnnouncementTime = Date()
            
            let notification: UIAccessibility.Notification = priority == .important
                ? .screenChanged
                : .announcement
            
            DispatchQueue.main.async {
                UIAccessibility.post(notification: notification, argument: message)
            }
        }
    }
    
    func announceStateChange(
        from oldState: SubscriptionState,
        to newState: SubscriptionState
    ) {
        let message = self.stateChangeMessage(from: oldState, to: newState)
        // High priority, no debouncing for state transitions
        announce(message, priority: .important, debounce: false)
    }
    
    private func stateChangeMessage(
        from: SubscriptionState,
        to: SubscriptionState
    ) -> String {
        switch to {
        case .trialExpiring(let daysRemaining):
            return String(
                localized: "trial_expiring_a11y",
                defaultValue: "Ihre Testversion endet in \(daysRemaining) Tagen. Ohne Premium verlieren Sie Zugriff auf erweiterte Funktionen."
            )
        case .expired:
            return String(
                localized: "subscription_expired_a11y",
                defaultValue: "Ihre Testversion ist abgelaufen. Sie können noch Fragen üben, aber erweiterte Funktionen sind blockiert."
            )
        case .active:
            return String(
                localized: "subscription_active_a11y",
                defaultValue: "Abonnement aktiv. Sie haben Zugriff auf alle Premium-Funktionen."
            )
        case .none:
            return String(
                localized: "subscription_none_a11y",
                defaultValue: "Kein aktives Abonnement. Wählen Sie einen Plan zum Upgraden."
            )
        }
    }
}