import Foundation
import CryptoKit

struct AuditLogSignature {
    static func sign(eventData: Data, key: SymmetricKey) -> Data {
        return Data(HMAC<SHA256>.authenticationCode(for: eventData, using: key))
    }
    
    static func verify(eventData: Data, signature: Data, key: SymmetricKey) -> Bool {
        return HMAC<SHA256>.isValidAuthenticationCode(signature, authenticating: eventData, using: key)
    }
}