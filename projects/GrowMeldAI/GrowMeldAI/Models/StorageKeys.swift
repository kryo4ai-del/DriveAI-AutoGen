actor LocalSubscriptionRepository: SubscriptionRepository {
    private let defaults: UserDefaults
    private let keychainService: KeychainService
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    private enum StorageKeys {
        static func userSubscriptionKey(userId: String) -> String {
            "subscription.\(userId)"
        }
        static let availableProducts = "subscription.products"
        static func trialUsedKey(userId: String) -> String {
            "trial.used.\(userId)"
        }
    }
    
    init(
        defaults: UserDefaults = .standard,
        keychainService: KeychainService = KeychainService()
    ) {
        self.defaults = defaults
        self.keychainService = keychainService
    }
    
    // MARK: - SubscriptionRepository
    
    func fetchCurrentSubscription(userId: String) async throws -> UserSubscription? {
        let key = StorageKeys.userSubscriptionKey(userId: userId)
        guard let data = defaults.data(forKey: key) else {
            return nil
        }
        return try decoder.decode(UserSubscription.self, from: data)
    }
    
    func fetchAvailableProducts() async throws -> [SubscriptionProduct] {
        // Load from local JSON bundle or hardcoded list
        // TODO: Implement after Phase 3
        return []
    }
    
    // ... remaining protocol methods
}