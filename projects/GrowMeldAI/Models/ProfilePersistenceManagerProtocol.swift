// Services/ProfilePersistenceManager.swift - IMPROVED
import Foundation
import os.log

protocol ProfilePersistenceManagerProtocol {
    func save<T: Codable>(_ object: T, key: String) throws
    func load<T: Codable>(key: String, type: T.Type) throws -> T?
    func delete(key: String) throws
    func deleteAll() throws
}

// Services/UserProfileService.swift - UPDATED WITH RECOVERY