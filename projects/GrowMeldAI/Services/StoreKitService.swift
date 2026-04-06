class StoreKitService {
    static let shared = StoreKitService()
    
    let subscriptionDataService: SubscriptionDataService
    let privacyComplianceService: PrivacyComplianceService
    
    init(
        subscriptionDataService: SubscriptionDataService = .default,
        privacyComplianceService: PrivacyComplianceService = .default
    ) {
        self.subscriptionDataService = subscriptionDataService
        self.privacyComplianceService = privacyComplianceService
    }
}