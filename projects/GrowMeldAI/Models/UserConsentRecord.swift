import Foundation

struct UserConsentRecord: Codable, Sendable {
    let id: UUID
    let useCase: String
    let consentGranted: Bool
    let timestamp: Date
    let ipfsHashOfConsent: String?
    let userAgent: String?
    let privacyNoticeShown: String
    let retentionPeriodDays: Int
    let userCanDeletePhotos: Bool

    init(
        id: UUID = UUID(),
        useCase: String,
        consentGranted: Bool,
        timestamp: Date = Date(),
        ipfsHashOfConsent: String? = nil,
        userAgent: String? = nil,
        privacyNoticeShown: String = "1.0",
        retentionPeriodDays: Int = 0,
        userCanDeletePhotos: Bool = true
    ) {
        self.id = id
        self.useCase = useCase
        self.consentGranted = consentGranted
        self.timestamp = timestamp
        self.ipfsHashOfConsent = ipfsHashOfConsent
        self.userAgent = userAgent
        self.privacyNoticeShown = privacyNoticeShown
        self.retentionPeriodDays = retentionPeriodDays
        self.userCanDeletePhotos = userCanDeletePhotos
    }

    static func recordWithdrawal(for useCase: String) -> UserConsentRecord {
        UserConsentRecord(
            id: UUID(),
            useCase: useCase,
            consentGranted: false,
            timestamp: Date(),
            ipfsHashOfConsent: nil,
            userAgent: nil,
            privacyNoticeShown: "1.0",
            retentionPeriodDays: 0,
            userCanDeletePhotos: true
        )
    }
}

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
        let record: UserConsentRecord
        if granted {
            record = UserConsentRecord(
                id: UUID(),
                useCase: useCase,
                consentGranted: true,
                timestamp: Date(),
                ipfsHashOfConsent: nil,
                userAgent: nil,
                privacyNoticeShown: "1.0",
                retentionPeriodDays: 30,
                userCanDeletePhotos: true
            )
        } else {
            record = UserConsentRecord.recordWithdrawal(for: useCase)
        }
        consentRecords.append(record)
        saveConsentHistory()
    }

    func hasConsent(for useCase: String) -> Bool {
        consentRecords
            .filter { $0.useCase == useCase }
            .max(by: { $0.timestamp < $1.timestamp })?
            .consentGranted ?? false
    }

    func deleteAllConsentRecords() throws {
        consentRecords.removeAll()
        saveConsentHistory()
        try deleteAllPhotosFromDisk()
    }

    private func deleteAllPhotosFromDisk() throws {
        let fileManager = FileManager.default
        let docs = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let photosDir = docs.appendingPathComponent("CameraPhotos", isDirectory: true)
        guard fileManager.fileExists(atPath: photosDir.path) else { return }
        try fileManager.removeItem(at: photosDir)
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