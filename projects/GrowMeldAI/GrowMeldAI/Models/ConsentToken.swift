// Services/ConsentTokenEncryption.swift
import Foundation
import CryptoKit

struct ConsentToken: Codable {
    let userId: String
    let consentGiven: Bool
    let timestamp: Date
    let version: String
}

struct EncryptedToken: Codable {
    let nonce: Data
    let encryptedData: Data
    let tag: Data
}
