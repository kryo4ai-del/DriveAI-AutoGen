// Services/PersistenceManager.swift
import Foundation

/// Thread-safe persistent storage for user profile.
/// - Thread Safety: All public methods are protected by NSLock to ensure
///   safe concurrent access from multiple threads.
/// - Note: Marked @unchecked Sendable because NSLock is not Sendable,
///   but manual locking guarantees thread safety.
class PersistenceManager: @unchecked Sendable {
    private let userDefaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let lock = NSLock()
    private let profileKey = "userProfile"
    
    init() {
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
    }
    
    /// Load user profile from persistent storage.
    /// - Throws: `AppError.noDataAvailable` if no profile exists, `AppError.decodingError` if corrupted.
    func loadUserProfile() throws -> UserProfile {
        lock.lock()
        defer { lock.unlock() }
        
        guard let data = userDefaults.data(forKey: profileKey) else {
            throw AppError.noDataAvailable
        }
        
        do {
            return try decoder.decode(UserProfile.self, from: data)
        } catch {
            throw AppError.decodingError(error.localizedDescription)
        }
    }
    
    /// Save user profile with verification.
    /// - Throws: `AppError.persistenceError` if write fails or verification fails.
    func saveUserProfile(_ profile: UserProfile) throws {
        lock.lock()
        defer { lock.unlock() }
        
        do {
            let data = try encoder.encode(profile)
            userDefaults.set(data, forKey: profileKey)
            
            // Force synchronous write to disk
            guard userDefaults.synchronize() else {
                throw AppError.persistenceError("UserDefaults synchronize failed")
            }
            
            // Verify write succeeded
            guard userDefaults.data(forKey: profileKey) != nil else {
                throw AppError.persistenceError("Profile verification failed after save")
            }
        } catch let error as AppError {
            throw error
        } catch {
            throw AppError.persistenceError("Failed to encode or persist profile: \(error.localizedDescription)")
        }
    }
    
    /// Clear all stored data (for testing or user account reset).
    func clearAll() throws {
        lock.lock()
        defer { lock.unlock() }
        
        userDefaults.removeObject(forKey: profileKey)
        guard userDefaults.synchronize() else {
            throw AppError.persistenceError("Failed to clear stored data")
        }
    }
}