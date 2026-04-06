import UIKit
import CryptoKit
import os

private let log = OSLog(subsystem: "com.driveai.abtesting", category: "segmentation")

class UserSegmentationService {
    static let shared = UserSegmentationService()
    
    private let userIDHashKey = "driveai_user_id_hash_v1"
    private let queue = DispatchQueue(
        label: "com.driveai.segmentation",
        attributes: []  // Serial queue (thread-safe)
    )
    
    // MARK: - Public API
    
    /// Get a stable, privacy-safe user identifier hash.
    /// Thread-safe, generated once per device, stored locally, never transmitted.
    func getUserIDHash() -> String {
        return queue.sync {
            // Return cached hash if available
            if let cached = UserDefaults.standard.string(forKey: userIDHashKey) {
                os_log("Retrieved cached userID hash", log: log, type: .debug)
                return cached
            }
            
            // Generate new hash (device UUID + bundle ID)
            let hash = generateUserHash()
            UserDefaults.standard.set(hash, forKey: userIDHashKey)
            os_log("Generated new userID hash: %{public}@", 
                   log: log, type: .info, String(hash.prefix(8)))
            return hash
        }
    }
    
    /// Reset user hash (for testing purposes only).
    func resetHashForTesting() {
        queue.sync {
            UserDefaults.standard.removeObject(forKey: userIDHashKey)
            os_log("Reset userID hash (test only)", log: log, type: .debug)
        }
    }
    
    // MARK: - Private Methods
    
    private func generateUserHash() -> String {
        let uuid = UIDevice.current.identifierForVendor?.uuidString ?? "unknown_device"
        let bundleID = Bundle.main.bundleIdentifier ?? "com.driveai.app"
        let combined = "\(uuid)_\(bundleID)_driveai_v1"
        
        let data = combined.data(using: .utf8) ?? Data()
        let digest = SHA256.hash(data: data)
        
        return digest.map { String(format: "%02hhx", $0) }.joined()
    }
}