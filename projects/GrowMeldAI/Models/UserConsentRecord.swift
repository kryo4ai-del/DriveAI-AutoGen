import Foundation

struct UserConsentRecord: Codable, Sendable {
    let id: UUID
    let useCase: String                 // CameraUseCase rawValue
    let consentGranted: Bool
    let timestamp: Date
    let ipfsHashOfConsent: String?      // Optional: immutable record hash
    let userAgent: String?              // Optional: device info
    
    // GDPR Article 13 – Transparency
    let privacyNoticeShown: String      // Version of privacy notice shown
    let retentionPeriodDays: Int
    let userCanDeletePhotos: Bool = true
    
    // GDPR Article 7 – Withdrawal
    static func recordWithdrawal(for useCase: String) -> UserConsentRecord {
        UserConsentRecord(
            id: UUID(),
            useCase: useCase,
            consentGranted: false,
            timestamp: Date(),
            ipfsHashOfConsent: nil,
            userAgent: nil,
            privacyNoticeShown: "1.0",
            retentionPeriodDays: 0
        )
    }
}

// MARK: - Consent Manager (GDPR Article 6 Lawful Basis Tracking)
@MainActor
final class GDPRConsentManager: ObservableObject {
    @Published var consentRecords: [UserConsentRecord] = []
    
    private let storage: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    init(storage: UserDefaults = .standard) {
        self.storage = storage
        loadConsentHistory()
    }
    
    func recordConsent(useCase: String, granted: Bool) {
        let record = granted
            ? UserConsentRecord(
                id: UUID(),
                useCase: useCase,
                consentGranted: true,
                timestamp: Date(),
                ipfsHashOfConsent: nil,
                userAgent: nil,
                privacyNoticeShown: "1.0",
                retentionPeriodDays: CameraUseCase(rawValue: useCase)?.dataRetentionDays ?? 0
              )
            : UserConsentRecord.recordWithdrawal(for: useCase)
        
        consentRecords.append(record)
        saveConsentHistory()
    }
    
    func hasConsent(for useCase: String) -> Bool {
        consentRecords
            .filter { $0.useCase == useCase }
            .max(by: { $0.timestamp < $1.timestamp })?
            .consentGranted ?? false
    }
    
    // GDPR Article 17 – Right to Erasure
    func deleteAllConsentRecords() throws {
        consentRecords.removeAll()
        saveConsentHistory()
        // Also delete associated photos
        try CameraDataService.deleteAllPhotos()
    }
    
    private func loadConsentHistory() {
        guard let data = storage.data(forKey: "camera_consent_history") else { return }
        consentRecords = (try? decoder.decode([UserConsentRecord].self, from: data)) ?? []
    }
    
    private func saveConsentHistory() {
        let data = try? encoder.encode(consentRecords)
        storage.set(data, forKey: "camera_consent_history")
    }
}