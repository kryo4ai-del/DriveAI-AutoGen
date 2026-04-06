import Foundation
import os

/// Handles local persistence of reminder configuration.
/// Uses UserDefaults for MVP; can migrate to SQLite in Phase 2.
final class ReminderPersistenceService {
    private let userDefaults: UserDefaults
    private let key = "DriveAI.ReminderConfiguration"
    private let logger = Logger(subsystem: "com.driveai.reminders", category: "persistence")
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    /// Save reminder configuration to persistent storage
    func save(_ configuration: ReminderConfiguration) throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        let data = try encoder.encode(configuration)
        userDefaults.set(data, forKey: key)
        
        logger.info("Reminder configuration saved")
    }
    
    /// Load reminder configuration from persistent storage
    func load() throws -> ReminderConfiguration? {
        guard let data = userDefaults.data(forKey: key) else {
            return nil
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        do {
            let config = try decoder.decode(ReminderConfiguration.self, from: data)
            logger.info("Reminder configuration loaded")
            return config
        } catch {
            logger.error("Failed to decode reminder configuration: \(error.localizedDescription)")
            throw ReminderError.persistenceFailed("Decoding failed: \(error.localizedDescription)")
        }
    }
    
    /// Delete reminder configuration
    func delete() throws {
        userDefaults.removeObject(forKey: key)
        logger.info("Reminder configuration deleted")
    }
}