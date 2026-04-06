// ViewModels/PurchaseViewModel.swift
@MainActor
final class PurchaseViewModel: ObservableObject {
    @Published var availableProducts: [PurchaseProduct] = []
    @Published var purchaseState: PurchaseState = .idle
    @Published var error: PurchaseError?
    @Published var unlockedFeatures: Set<UnlockableFeature> = []
    
    private let purchaseService: PurchaseService
    private let featureFlagService: FeatureFlagService
    private var transactionTask: Task<Void, Never>?
    
    init(
        purchaseService: PurchaseService,
        featureFlagService: FeatureFlagService
    ) {
        self.purchaseService = purchaseService
        self.featureFlagService = featureFlagService
        observeFeatureFlags()
        listenToTransactions()
    }
    
    // MARK: - Public Methods
    
    func loadAvailableProducts() async {
        purchaseState = .loading(productId: "")
        do {
            availableProducts = try await purchaseService.fetchProducts()
            purchaseState = .idle
        } catch {
            purchaseState = .error(.productNotFound)
            self.error = .productNotFound
        }
    }
    
    func purchase(_ product: PurchaseProduct) async {
        purchaseState = .loading(productId: product.id)
        do {
            let transaction = try await purchaseService.purchase(productId: product.id)
            
            purchaseState = .success(feature: transaction.feature)
            
            // Update feature flags
            await featureFlagService.refreshFeatureFlags()
            
            // Auto-dismiss after 2 seconds
            try? await Task.sleep(for: .seconds(2))
            purchaseState = .completed
            
        } catch let error as PurchaseError {
            purchaseState = .error(error)
            self.error = error
        } catch {
            let purchaseError = PurchaseError.purchaseFailed(error.localizedDescription)
            purchaseState = .error(purchaseError)
            self.error = purchaseError
        }
    }
    
    func restorePurchases() async {
        purchaseState = .restoring
        do {
            _ = try await purchaseService.restorePurchases()
            await featureFlagService.refreshFeatureFlags()
            purchaseState = .idle
        } catch let error as PurchaseError {
            purchaseState = .error(error)
            self.error = error
        } catch {
            let purchaseError = PurchaseError.transactionError(error.localizedDescription)
            purchaseState = .error(purchaseError)
            self.error = purchaseError
        }
    }
    
    // MARK: - Private Methods
    
    private func observeFeatureFlags() {
        Task {
            for await flags in featureFlagService.$unlockedFeatures.values {
                self.unlockedFeatures = flags
            }
        }
    }
    
    private func listenToTransactions() {
        transactionTask = Task {
            for await transaction in purchaseService.transactionUpdates {
                await featureFlagService.refreshFeatureFlags()
            }
        }
    }
    
    deinit {
        transactionTask?.cancel()
    }
}