class NotificationConsentService: NotificationConsentServiceProtocol {
    static let shared = NotificationConsentService()
    
    // Add notification event
    static let consentDidChangeNotification = NSNotification.Name("com.driveai.consentDidChange")
    
    private let userDefaults: UserDefaults
    private let key = "com.driveai.notificationConsent"
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    func saveConsent(_ decision: ConsentDecision) throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(decision)
        userDefaults.set(data, forKey: key)
        
        // ✅ Broadcast change so AppState and other observers can react
        NotificationCenter.default.post(
            name: Self.consentDidChangeNotification,
            object: decision
        )
    }
    
    // ... rest unchanged
}