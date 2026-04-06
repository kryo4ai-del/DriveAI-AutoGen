extension SubscriptionState {
    /// Accessibility-friendly days remaining text
    var daysRemainingLabel: String {
        guard let days = daysRemaining else { return "" }
        
        switch self {
        case .trial:
            return "\(days) Tage Testversion verbleibend"
        case .active:
            return "Abonnement erneuert in \(days) Tagen"
        case .paused:
            return "Pausiert seit \(days) Tagen"
        default:
            return "\(days) Tage"
        }
    }
}