extension LocalDataService {
    private enum StorageKey: String {
        case subscriptionState = "com.driveai.subscription_state_v1"
    }
    
    func loadSubscriptionState() -> SubscriptionState? {
        guard let data = UserDefaults.standard.data(forKey: StorageKey.subscriptionState.rawValue) else {
            return nil
        }
        return try? JSONDecoder().decode(SubscriptionState.self, from: data)
    }
    
    func saveSubscriptionState(_ state: SubscriptionState) {
        do {
            let encoded = try JSONEncoder().encode(state)
            UserDefaults.standard.set(encoded, forKey: StorageKey.subscriptionState.rawValue)
        } catch {
            Logger.error("Failed to save subscription state: \(error)")
        }
    }
    
    func deleteSubscriptionState() {
        UserDefaults.standard.removeObject(forKey: StorageKey.subscriptionState.rawValue)
    }
    
    func deleteAllUserData() {
        // GDPR compliance: delete subscription data on user request
        deleteSubscriptionState()
    }
}