import CryptoKit
import Foundation

extension ABTestService {
    /// Deterministic hash using SHA256 — consistent across app sessions
    private func hashUserForTest(userID: String, testID: String) -> Int {
        let combined = "\(userID):\(testID)" // Use delimiter to prevent collisions
        guard let data = combined.data(using: .utf8) else {
            return Int.random(in: 0..<100) // Fallback (shouldn't happen)
        }

        let digest = SHA256.hash(data: data)

        // Extract consistent integer from hash bytes
        let hashBytes = Array(digest)
        let value = hashBytes.prefix(4).withUnsafeBytes {
            $0.load(as: UInt32.self).bigEndian
        }

        return Int(value % 100)
    }

    /// Verify determinism (unit test helper)
    func verifyDeterminism(userID: String, testID: String, iterations: Int = 10) -> Bool {
        let hashes = (0..<iterations).map { _ in
            hashUserForTest(userID: userID, testID: testID)
        }
        return Set(hashes).count == 1 // All hashes identical
    }
}