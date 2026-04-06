import Foundation

class ConsentRecordingService {
    private let persistenceQueue = DispatchQueue(
        label: "com.driveai.consent.persistence",
        attributes: .concurrent
    )

    func recordConsent(_ consent: ConsentRecord) {
        persistenceQueue.async(flags: .barrier) {
            // Atomic write operation
            self.persist(consent)
        }
    }

    private func persist(_ consent: ConsentRecord) {
        guard let encoded = try? JSONEncoder().encode(consent) else { return }

        let fileURL = ConsentRecordingService.storageURL(for: consent.id)
        try? encoded.write(to: fileURL, options: .atomic)
    }

    func fetchConsent(id: String) -> ConsentRecord? {
        var result: ConsentRecord?
        persistenceQueue.sync {
            let fileURL = ConsentRecordingService.storageURL(for: id)
            guard let data = try? Data(contentsOf: fileURL) else { return }
            result = try? JSONDecoder().decode(ConsentRecord.self, from: data)
        }
        return result
    }

    func fetchAllConsents() -> [ConsentRecord] {
        var results: [ConsentRecord] = []
        persistenceQueue.sync {
            let directory = ConsentRecordingService.storageDirectory
            guard let urls = try? FileManager.default.contentsOfDirectory(
                at: directory,
                includingPropertiesForKeys: nil
            ) else { return }

            results = urls.compactMap { url in
                guard let data = try? Data(contentsOf: url) else { return nil }
                return try? JSONDecoder().decode(ConsentRecord.self, from: data)
            }
        }
        return results
    }

    func revokeConsent(id: String) {
        persistenceQueue.async(flags: .barrier) {
            let fileURL = ConsentRecordingService.storageURL(for: id)
            try? FileManager.default.removeItem(at: fileURL)
        }
    }

    // MARK: - Storage Helpers

    private static var storageDirectory: URL {
        let base = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let dir = base.appendingPathComponent("ConsentRecords", isDirectory: true)
        if !FileManager.default.fileExists(atPath: dir.path) {
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }

    private static func storageURL(for id: String) -> URL {
        storageDirectory.appendingPathComponent("\(id).json")
    }
}

// MARK: - ConsentRecord Model

struct ConsentRecord: Codable, Identifiable {
    let id: String
    let userID: String
    let consentType: ConsentType
    let granted: Bool
    let timestamp: Date
    let version: String
    let metadata: [String: String]

    init(
        id: String = UUID().uuidString,
        userID: String,
        consentType: ConsentType,
        granted: Bool,
        timestamp: Date = Date(),
        version: String = "1.0",
        metadata: [String: String] = [:]
    ) {
        self.id = id
        self.userID = userID
        self.consentType = consentType
        self.granted = granted
        self.timestamp = timestamp
        self.version = version
        self.metadata = metadata
    }
}

enum ConsentType: String, Codable {
    case dataProcessing = "data_processing"
    case marketing = "marketing"
    case analytics = "analytics"
    case thirdPartySharing = "third_party_sharing"
    case notifications = "notifications"
}