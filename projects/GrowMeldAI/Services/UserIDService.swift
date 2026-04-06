// Services/UserIdentification/UserIDService.swift
protocol UserIDService: Sendable {
    func getUserID() async -> String
    func resetUserID() async
    func isAnalyticsEnabled() async -> Bool
}

@MainActor
final class DefaultUserIDService: UserIDService {
    private let defaults = UserDefaults.standard
    private let userIDKey = "driveai_analytics_user_id"
    private let analyticsEnabledKey = "driveai_analytics_enabled"
    
    func getUserID() async -> String {
        if let existing = defaults.string(forKey: userIDKey) {
            return existing
        }
        
        let newID = UUID().uuidString
        defaults.set(newID, forKey: userIDKey)
        
        #if DEBUG
        print("📊 Generated new user ID: \(newID)")
        print("💾 Stored locally in UserDefaults — not sent anywhere without consent")
        #endif
        
        return newID
    }
    
    func resetUserID() async {
        defaults.removeObject(forKey: userIDKey)
    }
    
    func isAnalyticsEnabled() async -> Bool {
        return defaults.bool(forKey: analyticsEnabledKey)
    }
}

// In Privacy Settings View
VStack {
    Text("Analytik-Status")
        .font(.headline)
    
    if let userID = await userIDService.getUserID() {
        Text("ID: \(userID)")
            .font(.caption)
            .accessibilityLabel("Ihre eindeutige Analyse-ID")
            .accessibilityHint("Diese ID wird lokal gespeichert und ermöglicht es uns, Ihre Lernfortschritte zu verfolgen, ohne Sie zu identifizieren.")
    }
    
    Button("Analyse-Daten zurücksetzen") {
        Task {
            await userIDService.resetUserID()
        }
    }
    .accessibilityLabel("Analyse-Daten zurücksetzen")
    .accessibilityHint("Löscht Ihre lokale Analyse-ID. Eine neue wird beim nächsten Start generiert.")
}