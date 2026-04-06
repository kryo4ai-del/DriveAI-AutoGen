// ViewModels/PremiumFeatureViewModel.swift
@MainActor
final class PremiumFeatureViewModel: ObservableObject {
    
    @Published var isPremium: Bool = false
    @Published var subscriptionStatus: SubscriptionStatus = .inactive
    @Published var selectedProduct: Product?
    @Published var showPaywall: Bool = false
    @Published var isProcessing: Bool = false
    
    @ObservedObject private var storeKitManager: StoreKitManager
    private let localDataService: LocalDataService
    
    init(
        storeKitManager: StoreKitManager,
        localDataService: LocalDataService
    ) {
        self.storeKitManager = storeKitManager
        self.localDataService = localDataService
        
        setupBindings()
    }
    
    // MARK: - Bindings
    private func setupBindings() {
        // Monitor StoreKit state and update local cache
        storeKitManager.$purchasedProductIDs
            .receive(on: DispatchQueue.main)
            .sink { [weak self] productIDs in
                self?.updatePremiumStatus(from: productIDs)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Premium Status Logic
    private func updatePremiumStatus(from productIDs: Set<String>) {
        let hasPremium = !productIDs.isEmpty
        self.isPremium = hasPremium
        
        // Update local cache (used for offline access)
        localDataService.setUserPremiumStatus(hasPremium)
        
        // Determine subscription status
        if productIDs.contains("com.driveai.premium_monthly") {
            subscriptionStatus = .activeMonthly
        } else if productIDs.contains("com.driveai.premium_annual") {
            subscriptionStatus = .activeAnnual
        } else {
            subscriptionStatus = .inactive
        }
    }
    
    // MARK: - Purchase Flow
    func initiateSubscription(to product: Product) async {
        isProcessing = true
        defer { isProcessing = false }
        
        let transaction = await storeKitManager.purchase(product)
        
        if transaction != nil {
            // Purchase successful; StoreKitManager updates state → local cache
            showPaywall = false
            logAnalytics(event: "premium_purchase_success", productID: product.id)
        } else if let error = storeKitManager.lastError {
            logAnalytics(event: "premium_purchase_failed", reason: error.localizedDescription)
        }
    }
    
    // MARK: - Restoration
    func restoreSubscription() async {
        isProcessing = true
        defer { isProcessing = false }
        
        await storeKitManager.restorePurchases()
        
        if isPremium {
            logAnalytics(event: "premium_restore_success")
        } else if let error = storeKitManager.lastError {
            logAnalytics(event: "premium_restore_failed", reason: error.localizedDescription)
        }
    }
    
    // MARK: - Analytics (Privacy-Respecting)
    private func logAnalytics(event: String, productID: String? = nil, reason: String? = nil) {
        // Log conversion metrics without PII
        // (Implementation depends on analytics provider, e.g., Firebase)
    }
}

// MARK: - Supporting Types

private var cancellables: Set<AnyCancellable> = []