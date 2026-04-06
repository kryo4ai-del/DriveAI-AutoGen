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

private func loadAnswersFromDisk() -> [String: [String: String]] {
    if let data = userDefaults.data(forKey: answersKey) {
        do {
            let decoded = try JSONDecoder().decode([String: [String: String]].self, from: data)
            if let metadata = loadMetadata(),
               validateChecksum(decoded, against: metadata.checksumHash) {
                return decoded
            }
        } catch {
            print("[AnswersMetadata] ERROR: Primary answers corrupted: \(error)")
        }
    }

    if let backupData = userDefaults.data(forKey: answersBackupKey) {
        do {
            let decoded = try JSONDecoder().decode([String: [String: String]].self, from: backupData)
            print("[AnswersMetadata] WARNING: Recovered answers from backup")
            userDefaults.set(backupData, forKey: answersKey)
            return decoded
        } catch {
            print("[AnswersMetadata] ERROR: Backup also corrupted: \(error)")
        }
    }

    print("[AnswersMetadata] ERROR: No valid answers found — starting fresh")
    return [:]
}

@discardableResult
private func saveAnswersToDisk(_ answers: [String: [String: String]]) -> Bool {
    do {
        let encoded = try JSONEncoder().encode(answers)

        if let current = userDefaults.data(forKey: answersKey) {
            userDefaults.set(current, forKey: answersBackupKey)
        }

        userDefaults.set(encoded, forKey: answersKey)

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

private func checksum(_ answers: [String: [String: String]]) -> String {
    let encoded = try? JSONEncoder().encode(answers)
    return (encoded?.map { String(format: "%02x", $0) }.joined() ?? "")
        .prefix(16)
        .description
}

private func validateChecksum(_ answers: [String: [String: String]], against stored: String) -> Bool {
    checksum(answers) == stored
}

private func loadMetadata() -> AnswersMetadata? {
    guard let data = userDefaults.data(forKey: answersMetadataKey) else { return nil }
    return try? JSONDecoder().decode(AnswersMetadata.self, from: data)
}