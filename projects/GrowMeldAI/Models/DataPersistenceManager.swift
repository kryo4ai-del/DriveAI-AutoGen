import Foundation

enum PersistenceError: LocalizedError {
    case encodingFailed(String)
    case decodingFailed(String)
    case writeValidationFailed
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .encodingFailed(let msg):
            return "Encoding failed: \(msg)"
        case .decodingFailed(let msg):
            return "Decoding failed: \(msg)"
        case .writeValidationFailed:
            return "Write validation failed: data mismatch after write"
        case .unknown(let msg):
            return "Unknown persistence error: \(msg)"
        }
    }
}

@MainActor
final class DataPersistenceManager {
    private let userDefaults: UserDefaults
    private let fileManager: FileManager

    struct PersistenceOptions {
        let createBackup: Bool
        let validateChecksum: Bool
        let maxRetries: Int

        init(createBackup: Bool = true, validateChecksum: Bool = true, maxRetries: Int = 3) {
            self.createBackup = createBackup
            self.validateChecksum = validateChecksum
            self.maxRetries = maxRetries
        }
    }

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        self.fileManager = FileManager.default
    }

    // MARK: - Atomic Write with Backup

    func saveJSON<T: Encodable>(
        _ value: T,
        forKey key: String,
        options: PersistenceOptions = .init()
    ) -> Result<Void, PersistenceError> {
        do {
            let encoded = try JSONEncoder().encode(value)

            if options.createBackup,
               let existing = userDefaults.data(forKey: key) {
                userDefaults.set(existing, forKey: key + ".backup")
            }

            userDefaults.set(encoded, forKey: key)

            if options.validateChecksum {
                let written = userDefaults.data(forKey: key)
                guard written == encoded else {
                    return .failure(.writeValidationFailed)
                }
            }

            return .success(())
        } catch let encodeError as EncodingError {
            return .failure(.encodingFailed(encodeError.localizedDescription))
        } catch {
            return .failure(.unknown(error.localizedDescription))
        }
    }

    // MARK: - Load with Fallback

    func loadJSON<T: Decodable>(
        forKey key: String,
        fallbackToBackup: Bool = true
    ) -> Result<T, PersistenceError> {
        if let data = userDefaults.data(forKey: key) {
            do {
                return .success(try JSONDecoder().decode(T.self, from: data))
            } catch {
                print("[DataPersistenceManager] Primary data corrupted for key '\(key)': \(error)")
            }
        }

        if fallbackToBackup {
            if let backupData = userDefaults.data(forKey: key + ".backup") {
                do {
                    let decoded = try JSONDecoder().decode(T.self, from: backupData)
                    print("[DataPersistenceManager] Recovered from backup for key '\(key)'")
                    userDefaults.set(backupData, forKey: key)
                    return .success(decoded)
                } catch {
                    print("[DataPersistenceManager] Backup also corrupted for key '\(key)': \(error)")
                }
            }
        }

        return .failure(.decodingFailed("No valid data for key '\(key)'"))
    }

    // MARK: - Cleanup

    func removeData(forKey key: String) {
        userDefaults.removeObject(forKey: key)
        userDefaults.removeObject(forKey: key + ".backup")
    }
}