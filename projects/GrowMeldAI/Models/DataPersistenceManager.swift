import Foundation

/// Handles atomic writes, backup recovery, and corruption detection
@MainActor
final class DataPersistenceManager {
    private let userDefaults: UserDefaults
    private let fileManager: FileManager
    
    struct PersistenceOptions {
        let createBackup: Bool = true
        let validateChecksum: Bool = true
        let maxRetries: Int = 3
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
            
            // Backup existing data
            if options.createBackup,
               let existing = userDefaults.data(forKey: key) {
                userDefaults.set(existing, forKey: key + ".backup")
            }
            
            // Write new data
            userDefaults.set(encoded, forKey: key)
            
            // Validate write
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
        // Try primary
        if let data = userDefaults.data(forKey: key) {
            do {
                return .success(try JSONDecoder().decode(T.self, from: data))
            } catch {
                AppLogger.error("Primary data corrupted for key '\(key)': \(error)")
            }
        }
        
        // Fallback to backup
        if fallbackToBackup {
            if let backupData = userDefaults.data(forKey: key + ".backup") {
                do {
                    let decoded = try JSONDecoder().decode(T.self, from: backupData)
                    AppLogger.warn("Recovered from backup for key '\(key)'")
                    
                    // Restore backup as primary
                    userDefaults.set(backupData, forKey: key)
                    return .success(decoded)
                } catch {
                    AppLogger.error("Backup also corrupted for key '\(key)': \(error)")
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
