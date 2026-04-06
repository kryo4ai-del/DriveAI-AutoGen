// ✅ Add for crash analytics:
   extension IAPError {
       var analyticsCode: String {
           switch self {
           case .productFetchFailed:
               return "IAP_001"
           case .purchaseFailed:
               return "IAP_002"
           // ...
           }
       }
   }