// Option A: Local (Simpler, MVP-friendly)
@MainActor
final class EntitlementService: ObservableObject {
    func syncEntitlements() async throws {
        // Query StoreKit2 transaction history directly
        for await result in Transaction.all {
            let transaction = try validateTransaction(result)
            try saveEntitlements(from: transaction)
        }
    }
}

// Option B: Backend validation (Production-recommended)
@MainActor
final class EntitlementService: ObservableObject {
    func syncEntitlements() async throws {
        // Send receipt to your backend
        let receipt = try storeKitManager.getReceipt()
        let entitlements = try await backend.validateReceipt(receipt)
        try localDataService.saveEntitlements(entitlements)
    }
}