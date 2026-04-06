class HybridSubscriptionPersistenceService: SubscriptionPersistenceService {
    private let keychainService: KeyChainSubscriptionPersistenceService
    private let userDefaultsKey = "com.driveai.subscription.state.fallback"
    
    func persistState(_ state: SubscriptionState) throws {
        let encoder = JSONEncoder()
        let encoded = try encoder.encode(state)
        
        // Try Keychain first
        do {
            try keychainService.persistState(state)
        } catch {
            // Fallback to UserDefaults
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
    
    func loadState() throws -> SubscriptionState? {
        // Try Keychain first
        if let state = try keychainService.loadState() {
            return state
        }
        
        // Fallback to UserDefaults
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey) else {
            return nil
        }
        
        return try JSONDecoder().decode(SubscriptionState.self, from: data)
    }
}