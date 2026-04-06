/// Repository protocol (non-actor, callers handle isolation)
public protocol SubscriptionRepository {
    func fetchCurrentSubscription(userId: String) async throws -> UserSubscription?
    func saveSubscription(_ subscription: UserSubscription) async throws
    func isSubscriptionActive(userId: String) async throws -> Bool
    func clearSubscriptionData(userId: String) async throws
}

// Implementation with proper isolation:
final actor LocalSubscriptionRepository: SubscriptionRepository {
    private let defaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    // Thread-safe access to UserDefaults via actor isolation
    // All mutations happen on single actor executor
    
    nonisolated let keychainService: KeychainService
    
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.keychainService = KeychainService()
    }
    
    // All public methods are isolated by actor
    func fetchCurrentSubscription(userId: String) async throws -> UserSubscription? {
        let key = "subscription.\(userId)"
        guard let data = defaults.data(forKey: key) else {
            return nil
        }
        return try decoder.decode(UserSubscription.self, from: data)
    }
    
    func saveSubscription(_ subscription: UserSubscription) async throws {
        let key = "subscription.\(subscription.userId)"
        let data = try encoder.encode(subscription)
        defaults.set(data, forKey: key)
    }
    
    func isSubscriptionActive(userId: String) async throws -> Bool {
        guard let subscription = try await fetchCurrentSubscription(userId: userId) else {
            return false
        }
        return subscription.isActive
    }
    
    func clearSubscriptionData(userId: String) async throws {
        let key = "subscription.\(userId)"
        defaults.removeObject(forKey: key)
    }
}