@MainActor
final class FeatureMarketplaceViewModel: ObservableObject {
    private var purchaseTask: Task<Void, Never>?
    
    func purchaseFeature(_ feature: PurchasableFeature) {
        // Cancel previous purchase if still running
        purchaseTask?.cancel()
        
        purchaseTask = Task {
            isLoading = true
            defer { isLoading = false }
            
            guard !Task.isCancelled else { return }
            
            do {
                guard let product = try await StoreKitService.shared
                    .loadProducts()
                    .first(where: { $0.id == feature.id }) else {
                    throw PurchaseError.productNotFound
                }
                
                guard !Task.isCancelled else { return }
                
                let result = try await StoreKitService.shared.purchaseProduct(product)
                
                guard !Task.isCancelled else { return }
                
                try await purchaseRepo.completePurchase(feature: feature, storeKitTransaction: result)
                
                showPurchaseConfirmation = false
            } catch {
                purchaseRepo.lastError = error as? PurchaseError ?? .persistenceFailed(error.localizedDescription)
            }
        }
    }
    
    deinit {
        purchaseTask?.cancel()
    }
}