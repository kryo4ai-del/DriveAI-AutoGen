import Foundation
import CryptoKit

enum EncryptionError: Error {
    case keychainError
    case encryptionFailed
    case decryptionFailed
    case invalidData
}
