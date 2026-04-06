import Foundation

private let answersKey = "userAnswers"
private let answersBackupKey = "userAnswers.backup"
private let answersMetadataKey = "userAnswers.metadata"

struct AnswersMetadata: Codable {
    let version: Int
    let lastSavedDate: Date
    let checksumHash: String

    init(version: Int = 1, lastSavedDate: Date, checksumHash: String) {
        self.version = version
        self.lastSavedDate = lastSavedDate
        self.checksumHash = checksumHash
    }
}

private var userDefaults: UserDefaults { .standard }

private func loadAnswersFromDisk() -> [String: UserAnswer] {
    // Try primary
    if let data = userDefaults.data(forKey: answersKey) {
        do {
            let decoded = try JSONDecoder().decode([String: UserAnswer].self, from: data)
            // Verify checksum
            if let metadata = loadMetadata(),
               validateChecksum(decoded, against: metadata.checksumHash) {
                return decoded
            }
        } catch {
            print("[AnswersMetadata] ERROR: Primary answers corrupted: \(error)")
        }
    }

    // Try backup
    if let backupData = userDefaults.data(forKey: answersBackupKey) {
        do {
            let decoded = try JSONDecoder().decode([String: UserAnswer].self, from: backupData)
            print("[AnswersMetadata] WARNING: Recovered answers from backup")
            userDefaults.set(backupData, forKey: answersKey)  // Restore
            return decoded
        } catch {
            print("[AnswersMetadata] ERROR: Backup also corrupted: \(error)")
        }
    }

    // Total loss
    print("[AnswersMetadata] ERROR: No valid answers found — starting fresh")
    return [:]
}

@discardableResult
private func saveAnswersToDisk(_ answers: [String: UserAnswer]) -> Bool {
    do {
        let encoded = try JSONEncoder().encode(answers)

        // Atomic write with backup
        if let current = userDefaults.data(forKey: answersKey) {
            userDefaults.set(current, forKey: answersBackupKey)  // Backup first
        }

        userDefaults.set(encoded, forKey: answersKey)

        // Save metadata for validation
        let metadata = AnswersMetadata(lastSavedDate: Date(), checksumHash: checksum(answers))
        if let metadataEncoded = try? JSONEncoder().encode(metadata) {
            userDefaults.set(metadataEncoded, forKey: answersMetadataKey)
        }

        return true
    } catch {
        print("[AnswersMetadata] ERROR: Failed to save answers: \(error)")
        return false
    }
}

private func checksum(_ answers: [String: UserAnswer]) -> String {
    let encoded = try? JSONEncoder().encode(answers)
    return (encoded?.map { String(format: "%02x", $0) }.joined() ?? "")
        .prefix(16)
        .description
}

private func validateChecksum(_ answers: [String: UserAnswer], against stored: String) -> Bool {
    checksum(answers) == stored
}

private func loadMetadata() -> AnswersMetadata? {
    guard let data = userDefaults.data(forKey: answersMetadataKey) else { return nil }
    return try? JSONDecoder().decode(AnswersMetadata.self, from: data)
}