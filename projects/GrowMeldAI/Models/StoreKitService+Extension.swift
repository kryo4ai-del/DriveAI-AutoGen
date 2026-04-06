// ❌ Current: No distinction between sandbox (testing) and production
   
   // ✅ Recommend:
   extension StoreKitService {
       var isRunningInSandbox: Bool {
           guard let appStoreReceiptURL = Bundle.main.appStoreReceiptURL else {
               return true // Assume sandbox if no receipt
           }
           return appStoreReceiptURL.lastPathComponent == "sandboxReceipt"
       }
       
       private func shouldVerifyWithApple() -> Bool {
           !isRunningInSandbox // In production, verify with Apple
       }
   }