import Foundation
import Security
import CryptoKit

// MARK: - ConsentRecord Model

struct GrowMeldConsentRecord: Codable {
    let userId: String
    let consentGiven: Bool
    let consentDate: Date
    let consentVersion: String
    let dataCollectionConsented: Bool
    let analyticsConsented: Bool

    init(
        userId: String,
        consentGiven: Bool,
        consentDate: Date = Date(),
        consentVersion: String = "1.0",
        dataCollectionConsented: Bool = false,
        analyticsConsented: Bool = false
    ) {
        self.userId = userId
        self.consentGiven = consentGiven
        self.consentDate = consentDate
        self.consentVersion = consentVersion
        self.dataCollectionConsented = dataCollectionConsented
        self.analyticsConsented = analyticsConsented
    }
}

// MARK: - Protocol
protocol ConsentStorageServiceProtocol {
    func saveConsentRecord(_ record: GrowMeldConsentRecord) throws
    func loadConsentRecord() -> GrowMeldConsentRecord?
    func deleteConsentRecord() throws
    func isConsentValid() -> Bool
}

// MARK: - Error Type
enum ConsentStorageError: LocalizedError {
    case encryptionFailed
    case keychainError(OSStatus)

    var errorDescription: String? {
        switch self {
        case .encryptionFailed:
            return "Could not encrypt consent record"
        case .keychainError(let status):
            return "Keychain operation failed: \(status)"
        }
    }
}

// MARK: - Implementation
final class ConsentStorageService: ConsentStorageServiceProtocol {

    private let keychainKey = "com.growmeldai.consentRecord"
    private let consentExpiryDays: Int = 365

    func saveConsentRecord(_ record: GrowMeldConsentRecord) throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data: Data
        do {
            data = try encoder.encode(record)
        } catch {
            throw ConsentStorageError.encryptionFailed
        }

        let query: [String: Any] = [
            kSecClass as String:       kSecClassGenericPassword,
            kSecAttrAccount as String: keychainKey,
            kSecValueData as String:   data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        ]

        // Delete any existing record first
        SecItemDelete(query as CFDictionary)

        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw ConsentStorageError.keychainError(status)
        }
    }

    func loadConsentRecord() -> GrowMeldConsentRecord? {
        let query: [String: Any] = [
            kSecClass as String:       kSecClassGenericPassword,
            kSecAttrAccount as String: keychainKey,
            kSecReturnData as String:  true,
            kSecMatchLimit as String:  kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess, let data = result as? Data else {
            return nil
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try? decoder.decode(GrowMeldConsentRecord.self, from: data)
    }

    func deleteConsentRecord() throws {
        let query: [String: Any] = [
            kSecClass as String:       kSecClassGenericPassword,
            kSecAttrAccount as String: keychainKey
        ]

        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw ConsentStorageError.keychainError(status)
        }
    }

    func isConsentValid() -> Bool {
        guard let record = loadConsentRecord(), record.consentGiven else {
            return false
        }
        let expiryDate = Calendar.current.date(
            byAdding: .day,
            value: consentExpiryDays,
            to: record.consentDate
        ) ?? Date.distantPast
        return Date() < expiryDate
    }
}