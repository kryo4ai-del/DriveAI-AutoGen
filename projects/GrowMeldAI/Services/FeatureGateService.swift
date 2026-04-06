struct FeatureGateService {
    private let subscriptionState: SubscriptionState
    
    enum FeatureAvailabilityReason {
        case premium
        case graceExpiry(Date)  // Expires at this date
        case expired
    }
    
    func getPremiumStatus() -> FeatureAvailabilityReason {
        switch subscriptionState.status {
        case .active(let expirationDate):
            return .premium
            
        case .expired(let expirationDate):
            let gracePeriodEnd = Calendar.current.date(
                byAdding: .hour, value: 72, to: expirationDate
            ) ?? expirationDate
            
            if Date() < gracePeriodEnd {
                return .graceExpiry(gracePeriodEnd)
            }
            return .expired
            
        default:
            return .expired
        }
    }
}