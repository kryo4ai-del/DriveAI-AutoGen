class UserDefaultsPersistenceManager: ProfilePersistenceManagerProtocol {
    private let userDefaults: UserDefaults
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        
        self.encoder = JSONEncoder()
        self.encoder.dateEncodingStrategy = .iso8601
        
        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601
        
        // Fallback for older iOS versions
        if #available(iOS 11.2, *) {
            // ISO8601 is safe
        } else {
            // Use custom date format for iOS < 11.2
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
            self.decoder.dateDecodingStrategy = .formatted(formatter)
            self.encoder.dateEncodingStrategy = .formatted(formatter)
        }
    }
}