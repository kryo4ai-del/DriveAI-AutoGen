// ❌ Current: No fields for legal/compliance metadata
   struct SubscriptionProduct {
       let product: Product
   }
   
   // ✅ Recommend adding:
   struct SubscriptionProduct {
       let product: Product
       
       // Compliance metadata (set from App Store Connect)
       let localizedTrialDisclosure: String?  // "Free 7-day trial, then €3.99/month"
       let localizedAutoRenewalTerms: String? // "Auto-renews unless cancelled in Settings"
       let cancellationInstructions: String?  // Link to help docs
   }