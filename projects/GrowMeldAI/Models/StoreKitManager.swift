// ✅ GOOD: Explicit MainActor for UI updates
@MainActor
final class StoreKitManager: NSObject {
    @Published var isPurchasing = false
    
    func purchaseProduct(_ product: IAPProduct) async throws -> Transaction {
        await MainActor.run {
            self.isPurchasing = true
        }
        defer { 
            Task { @MainActor in self.isPurchasing = false }
        }
        
        // Non-blocking network call
        return try await someAsyncCall()
    }
}

// ✅ GOOD: ViewModels dispatch to MainActor-bound managers
@MainActor
class PaywallViewModel: ObservableObject {
    func purchase() async {
        do {
            _ = try await storeKitManager.purchaseProduct(product)
            @Sendable in
            await entitlementService.syncEntitlements()
        } catch {
            self.error = error
        }
    }
}

// ❌ AVOID: DispatchQueue.main.async or Thread.isMainThread checks
// MainActor handles this automatically