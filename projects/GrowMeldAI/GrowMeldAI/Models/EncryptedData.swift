// Services/Backup/EncryptionService.swift

import CryptoKit
import CommonCrypto
import Foundation

struct EncryptedData {
    let ciphertext: Data
    let iv: Data
    let tag: Data
    let algorithm: String = "AES-256-GCM"
}

// MARK: - Keychain Service
