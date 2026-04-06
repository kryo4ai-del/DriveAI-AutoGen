import Foundation
import CryptoKit

public struct UserIdentifier: Hashable, Codable {
    private let hashedValue: String

    public static func hash(userID: String, salt: String) -> UserIdentifier {
        let combined = userID + salt
        guard let data = combined.data(using: .utf8) else {
            return UserIdentifier(hashedValue: userID)
        }
        let digest = SHA256.hash(data: data)
        let hashString = digest.map { String(format: "%02x", $0) }.joined()
        return UserIdentifier(hashedValue: hashString)
    }
}