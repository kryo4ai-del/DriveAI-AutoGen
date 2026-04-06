// ❌ Current: Singleton pattern with hardcoded dependencies
   static let shared = StoreKitService()
   
   // ✅ Recommend: Allow injection for testing
   class StoreKitService {
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