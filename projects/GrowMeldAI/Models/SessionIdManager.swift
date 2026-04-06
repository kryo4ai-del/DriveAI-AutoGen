// Modules/Analytics/Service/SessionIdManager.swift

import Foundation

/// Manages daily session IDs for GDPR compliance (resets daily).
@MainActor
final class SessionIdManager {
    private let sessionIdKey = "analytics_session_id"
    private let sessionIdDateKey = "analytics_session_id_date"
    private let userDefaults: UserDefaults
    
    var currentSessionId: String {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Load stored ID and date
        let storedDate = UserDefaults.standard
            .object(forKey: sessionIdDateKey) as? Date
            .map { calendar.startOfDay(for: $0) }
        
        // Reuse if from today; otherwise create new
        if let storedDate = storedDate,
           storedDate == today,
           let storedId = UserDefaults.standard.string(forKey: sessionIdKey) {
            return storedId
        }
        
        // Generate new daily session ID
        let newId = UUID().uuidString
        UserDefaults.standard.set(newId, forKey: sessionIdKey)
        UserDefaults.standard.set(Date(), forKey: sessionIdDateKey)
        
        return newId
    }
    
    init(userDefaults: UserDefaults = UserDefaults.standard) {
        self.userDefaults = userDefaults
    }
}