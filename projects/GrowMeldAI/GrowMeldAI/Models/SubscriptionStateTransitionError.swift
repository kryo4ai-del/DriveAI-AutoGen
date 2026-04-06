enum SubscriptionStateTransitionError: LocalizedError {
    case invalidStateTransition(from: String, to: String)
    case planExpired
    
    var errorDescription: String? {
        switch self {
        case .invalidStateTransition(let from, let to):
            return "Ungültiger Übergang von \(from) zu \(to)"
        case .planExpired:
            return "Plan ist abgelaufen und kann nicht wiederhergestellt werden"
        }
    }
}

extension Subscription {
    mutating func resume() throws {
        guard case .paused(let plan, _) = state else {
            throw SubscriptionStateTransitionError.invalidStateTransition(
                from: String(describing: state),
                to: "active"
            )
        }
        
        let calendar = Calendar.current
        let renewsAt = calendar.date(byAdding: .day, value: plan.billingCycle.durationInDays ?? 365, to: .now) ?? .now
        self.state = .active(plan: plan, renewsAt: renewsAt)
        self.updatedAt = .now
    }
}