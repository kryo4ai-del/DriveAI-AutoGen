enum DataRetentionPolicy {
         case trial(days: Int = 90)  // Delete trial user data after 90 days if no conversion
         case activeSubscriber(indefinite: Bool = true)  // Keep while active + 7 years post-cancellation (tax)
         case cancelledAccount(days: Int = 2555)  // 7 years for tax compliance
     }