import Foundation

protocol SubscriptionPersistenceProtocol: AnyObject {
    func saveSubscriptionStatus(_ status: SubscriptionStatus) throws
    func loadSubscriptionStatus() -> SubscriptionStatus?
    func clearSubscriptionStatus() throws
}

final class UserDefaultsSubscriptionPersistence: SubscriptionPersistenceProtocol {
    private let defaults: UserDefaults
    private let statusKey = "com.driveai.subscription.status"
    private let expiresKey = "com.driveai.subscription.expires"
    
    init(userDefaults: UserDefaults = .standard) {
        self.defaults = userDefaults
    }
    
    func saveSubscriptionStatus(_ status: SubscriptionStatus) throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(status)
        defaults.set(data, forKey: statusKey)
    }
    
    func loadSubscriptionStatus() -> SubscriptionStatus? {
        guard let data = defaults.data(forKey: statusKey) else {
            return nil
        }
        
        let decoder = JSONDecoder()
        return try? decoder.decode(SubscriptionStatus.self, from: data)
    }
    
    func clearSubscriptionStatus() throws {
        defaults.removeObject(forKey: statusKey)
        defaults.removeObject(forKey: expiresKey)
    }
}