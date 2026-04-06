// ✅ Add method for GDPR compliance:
   extension SubscriptionStatus {
       /// Returns data suitable for GDPR deletion (PII anonymized, but legal-hold data retained).
       func anonymizedForGDPRDeletion() -> SubscriptionStatus {
           // Keep transactionID (tax law hold), but strip user-identifiable metadata
           // Example: Remove originalPurchaseDate, keep only anonymized transaction record
       }
   }