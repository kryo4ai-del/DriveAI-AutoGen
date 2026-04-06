// Services/PremiumFeatureService.swift
import Combine
import os.log

/// Manages premium feature state with offline support
/// Uses local cache to enable premium feature access even if network unavailable
@MainActor
final class PremiumFeatureService: ObservableObject {
    
    @Published var userHasPremium: Bool = false
    @Published var activeSubscriptionProductID: String?
    @Published var lastSyncDate: Date?
    @Published var isOffline: Bool = false
    
    private let userDefaultsKey = "com.driveai.premium_status"
    private let subscriptionProductIDKey = "com.driveai.subscription_product_id"
    private let lastSyncDateKey = "com.driveai.last_premium_sync"
    private let logger = Logger(subsystem: "com.driveai.iap", category: "PremiumFeatureService")
    
    @ObservedObject private var storeKitManager: StoreKitManager
    private var cancellables: Set<AnyCancellable> = []
    
    init(storeKitManager: StoreKitManager) {
        self.storeKitManager = storeKitManager
        setupBindings()
        loadCachedState()
    }
    
    // MARK: - Setup
    private func setupBindings() {
        // Monitor StoreKit state and update cache
        storeKitManager.$purchasedProductIDs
            .receive(on: DispatchQueue.main)
            .sink { [weak self] productIDs in
                self?.syncPremiumStatus(from: productIDs)
            }
            .store(in: &cancellables)
        
        // Monitor active subscription for display
        storeKitManager.$activeSubscriptionProduct
            .receive(on: DispatchQueue.main)
            .sink { [weak self] product in
                self?.activeSubscriptionProductID = product?.id
                self?.cacheSubscriptionStatus()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - State Sync
    private func syncPremiumStatus(from productIDs: Set<String>) {
        let hasPremium = !productIDs.isEmpty
        
        // Only update if changed
        if self.userHasPremium != hasPremium {
            self.userHasPremium = hasPremium
            self.lastSyncDate = Date()
            
            logger.info("Premium status synced: \(hasPremium ? "active" : "inactive")")
            
            // Update persistent cache
            cacheSubscriptionStatus()
        }
    }
    
    // MARK: - Caching
    private func cacheSubscriptionStatus() {
        UserDefaults.standard.set(userHasPremium, forKey: userDefaultsKey)
        UserDefaults.standard.set(activeSubscriptionProductID, forKey: subscriptionProductIDKey)
        UserDefaults.standard.set(Date(), forKey: lastSyncDateKey)
    }
    
    private func loadCachedState() {
        userHasPremium = UserDefaults.standard.bool(forKey: userDefaultsKey)
        activeSubscriptionProductID = UserDefaults.standard.string(forKey: subscriptionProductIDKey)
        lastSyncDate = UserDefaults.standard.object(forKey: lastSyncDateKey) as? Date
        
        logger.info("Loaded cached premium status: \(self.userHasPremium ? "active" : "inactive")")
    }
    
    // MARK: - Offline Detection
    /// Detect if user is offline and premium features should use cache
    func updateOfflineStatus(_ isOffline: Bool) {
        self.isOffline = isOffline
        logger.info("Offline status: \(isOffline ? "offline" : "online")")
    }
    
    // MARK: - Feature Access
    /// Check if user can access premium feature (online or offline with cache)
    func canAccessPremiumFeature() -> Bool {
        if userHasPremium {
            return true
        }
        
        // If offline, use cached status
        if isOffline {
            logger.info("Using cached premium status (offline mode)")
            return userHasPremium
        }
        
        return false
    }
    
    // MARK: - Subscription Display
    var subscriptionDisplayName: String {
        guard let productID = activeSubscriptionProductID else {
            return "Abonnement"
        }
        
        switch productID {
        case "com.driveai.premium_monthly":
            return "Premium (monatlich)"
        case "com.driveai.premium_annual":
            return "Premium (jährlich)"
        default:
            return "Premium"
        }
    }
}