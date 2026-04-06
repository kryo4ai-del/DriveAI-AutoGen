import Foundation
import Combine

@MainActor
final class TrialExpiringViewModel: ObservableObject {
    @Published var daysRemaining: Int
    @Published var hasAnnouncedOnce = false
    
    private let accessibilityManager = AccessibilityAnnouncementManager.shared
    private var scenePhaseSubscription: AnyCancellable?
    
    init(daysRemaining: Int) {
        self.daysRemaining = daysRemaining
    }
    
    /// Announce trial status based on urgency.
    func announceTrialStatus() {
        guard !hasAnnouncedOnce else { return }
        
        let message: String
        if daysRemaining <= 3 {
            message = NSLocalizedString(
                SubscriptionLocalizations.Trial.expiringAnnouncement,
                comment: "Trial expiring urgent announcement"
            )
        } else {
            message = NSLocalizedString(
                SubscriptionLocalizations.Trial.expiringLabel,
                comment: "Trial expiring normal announcement"
            )
        }
        
        accessibilityManager.announce(
            message,
            priority: .important,
            debounce: true
        )
        
        hasAnnouncedOnce = true
    }
}