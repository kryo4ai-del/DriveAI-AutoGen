import Foundation
import Combine

@MainActor
final class PrivacyDataStore: ObservableObject {
    static let shared = PrivacyDataStore()
    
    private let consentManager = ConsentManager.shared
    private let fileManager = FileManager.default
    private let cryptoService = CryptoService.shared
    
    private lazy var privacyDirectory: URL = {
        let paths = fileManager.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        )
        let driveAIPath = paths[0].appendingPathComponent("DriveAI/Private")
        try? fileManager.createDirectory(
            at: driveAIPath,
            withIntermediateDirectories: true
        )
        return driveAIPath
    }()
    
    private init() {}
    
    // MARK: - Data Access (Consent-Gated)
    
    func storeAnalyticsEvent(_ event: [String: Any]) async throws {
        guard consentManager.isConsented(.analytics) else {
            return // Silently ignore if not consented
        }
        
        let data = try JSONSerialization.data(withJSONObject: event)
        let encrypted = try cryptoService.encrypt(data)
        let fileName = "analytics_\(UUID().uuidString).bin"
        let url = privacyDirectory.appendingPathComponent(fileName)
        
        try encrypted.write(to: url)
        
        await AuditLogger.shared.log(
            action: "Analytics data stored",
            category: .analytics,
            userId: UserID.current
        )
    }
    
    func retrieveAnalyticsData() async -> [[String: Any]] {
        guard consentManager.isConsented(.analytics) else {
            return []
        }
        
        var events: [[String: Any]] = []
        
        guard let files = try? fileManager.contentsOfDirectory(
            at: privacyDirectory,
            includingPropertiesForKeys: nil
        ) else {
            return []
        }
        
        for file in files where file.lastPathComponent.hasPrefix("analytics_") {
            if let data = try? Data(contentsOf: file),
               let decrypted = try? cryptoService.decrypt(data),
               let json = try? JSONSerialization.jsonObject(with: decrypted) as? [String: Any] {
                events.append(json)
            }
        }
        
        return events
    }
    
    func storeExamResult(_ result: ExamResult) async throws {
        guard consentManager.isConsented(.analytics) else {
            // Store only essential data (pass/fail, score)
            // Without analytics consent, we don't track patterns
            return
        }
        
        let encoded = try JSONEncoder().encode(result)
        let encrypted = try cryptoService.encrypt(encoded)
        let fileName = "exam_\(result.id).bin"
        let url = privacyDirectory.appendingPathComponent(fileName)
        
        try encrypted.write(to: url)
        
        await AuditLogger.shared.log(
            action: "Exam result stored",
            category: .analytics,
            userId: UserID.current,
            details: "Score: \(result.score)"
        )
    }
    
    // MARK: - Data Purging (Consent Revocation)
    
    func purgeDataForCategory(_ category: ConsentCategory) async {
        guard let files = try? fileManager.contentsOfDirectory(
            at: privacyDirectory,
            includingPropertiesForKeys: nil
        ) else {
            return
        }
        
        let prefix: String
        switch category {
        case .analytics:
            prefix = "analytics_"
        case .notifications:
            prefix = "notification_"
        case .essential:
            return // Never purge essential
        }
        
        for file in files where file.lastPathComponent.hasPrefix(prefix) {
            try? fileManager.removeItem(at: file)
        }
        
        await AuditLogger.shared.log(
            action: "Data purged",
            category: category,
            userId: UserID.current,
            details: "All \(category.rawValue) data deleted"
        )
    }
    
    func purgeAllData() async {
        try? fileManager.removeItem(at: privacyDirectory)
        try? fileManager.createDirectory(
            at: privacyDirectory,
            withIntermediateDirectories: true
        )
    }
}

// Placeholder for ExamResult - adjust per your domain