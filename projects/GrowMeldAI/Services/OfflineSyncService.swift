import Foundation
@MainActor
final class OfflineSyncService {
    static let shared = OfflineSyncService()
    
    private let userDefaults = UserDefaults.standard
    private let maxDataAgeInDays: Int = 30
    
    func shouldRefreshData() -> Bool {
        guard let lastUpdate = userDefaults.object(forKey: "data_last_updated") as? Date else {
            return true
        }
        
        let daysSinceUpdate = Calendar.current.dateComponents([.day], from: lastUpdate, to: Date()).day ?? 0
        return daysSinceUpdate > maxDataAgeInDays
    }
    
    func markDataAsUpdated() {
        userDefaults.set(Date(), forKey: "data_last_updated")
    }
}