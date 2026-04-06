func storeAnalyticsEvent(_ event: [String: Any]) async throws {
    guard consentManager.isConsented(.analytics) else {
        throw DataStoreError.noConsentForCategory(.analytics)
    }
    
    let data = try JSONSerialization.data(withJSONObject: event)
    let encrypted = try cryptoService.encrypt(data)
    let fileName = "analytics_\(UUID().uuidString).bin"
    let url = privacyDirectory.appendingPathComponent(fileName)
    
    try encrypted.write(to: url)
    
    await AuditLogger.shared.log(
        action: "Analytics event stored",
        category: .analytics,
        userId: userID,
        details: "Event keys: \(event.keys.joined(separator: ","))"
    )
}

enum DataStoreError: LocalizedError {
    case noConsentForCategory(ConsentCategory)
    case encryptionFailed
    case writeFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .noConsentForCategory(let cat):
            return "Cannot store data for \(cat.rawValue) without consent"
        case .encryptionFailed:
            return "Failed to encrypt data"
        case .writeFailed(let err):
            return "Failed to write data: \(err.localizedDescription)"
        }
    }
}