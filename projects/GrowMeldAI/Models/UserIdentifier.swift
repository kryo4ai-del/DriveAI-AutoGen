// ✅ BETTER: Hash-based identification
public struct UserIdentifier: Hashable, Codable {
    private let hashedValue: String
    
    /// Create deterministic hash of user ID for experiment assignment consistency
    public static func hash(userID: String, salt: String) -> UserIdentifier {
        // Use HMAC-SHA256 for deterministic but irreversible hashing
        let hashed = HMAC<SHA256>.authenticationCode(
            for: Data(userID.utf8),
            using: SymmetricKey(data: Data(salt.utf8))
        )
        return UserIdentifier(hashedValue: Data(hashed).base64EncodedString())
    }
}
