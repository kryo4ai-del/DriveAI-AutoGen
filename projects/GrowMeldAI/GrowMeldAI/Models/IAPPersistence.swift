// MARK: - Services/IAPPersistence.swift

import Foundation

protocol IAPPersistence {
  func loadEntitlements() throws -> IAPEntitlements?
  func saveEntitlements(_ entitlements: IAPEntitlements) throws
  func recordTransaction(_ transaction: IAPTransaction) throws
  func loadProcessedTransactionIDs() throws -> Set<String>
}

// MARK: - UserDefaults Implementation
class UserDefaultsPersistence: IAPPersistence {
  private let defaults: UserDefaults
  private let queue = DispatchQueue(label: "com.driveai.iap.persistence")
  
  private enum Keys {
    static let entitlements = "iap_entitlements"
    static let processedTransactions = "iap_processed_transactions"
    static let lastSyncDate = "iap_last_sync_date"
  }
  
  init(userDefaults: UserDefaults = .standard) {
    self.defaults = userDefaults
  }
  
  func loadEntitlements() throws -> IAPEntitlements? {
    return try queue.sync {
      guard let data = defaults.data(forKey: Keys.entitlements) else {
        return nil
      }
      
      let decoder = JSONDecoder()
      decoder.dateDecodingStrategy = .iso8601
      return try decoder.decode(IAPEntitlements.self, from: data)
    }
  }
  
  func saveEntitlements(_ entitlements: IAPEntitlements) throws {
    try queue.sync {
      let encoder = JSONEncoder()
      encoder.dateEncodingStrategy = .iso8601
      let data = try encoder.encode(entitlements)
      
      defaults.set(data, forKey: Keys.entitlements)
      defaults.set(Date(), forKey: Keys.lastSyncDate)
    }
  }
  
  func recordTransaction(_ transaction: IAPTransaction) throws {
    try queue.sync {
      var processed = (try? loadProcessedTransactionIDs()) ?? []
      processed.insert(transaction.id)
      
      let encoder = JSONEncoder()
      encoder.dateEncodingStrategy = .iso8601
      let data = try encoder.encode(Array(processed))
      
      defaults.set(data, forKey: Keys.processedTransactions)
    }
  }
  
  func loadProcessedTransactionIDs() throws -> Set<String> {
    return try queue.sync {
      guard let data = defaults.data(forKey: Keys.processedTransactions) else {
        return []
      }
      
      let decoder = JSONDecoder()
      let ids = try decoder.decode([String].self, from: data)
      return Set(ids)
    }
  }
}

// MARK: - Keychain Implementation (for sensitive data)
class KeychainPersistence: IAPPersistence {
  private let service = "com.driveai.iap"
  
  func loadEntitlements() throws -> IAPEntitlements? {
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: service,
      kSecAttrAccount as String: "entitlements",
      kSecReturnData as String: true
    ]
    
    var result: AnyObject?
    let status = SecItemCopyMatching(query as CFDictionary, &result)
    
    guard status == errSecSuccess, let data = result as? Data else {
      return nil
    }
    
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    return try decoder.decode(IAPEntitlements.self, from: data)
  }
  
  func saveEntitlements(_ entitlements: IAPEntitlements) throws {
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    let data = try encoder.encode(entitlements)
    
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: service,
      kSecAttrAccount as String: "entitlements",
      kSecValueData as String: data
    ]
    
    SecItemDelete(query as CFDictionary)
    let status = SecItemAdd(query as CFDictionary, nil)
    
    guard status == errSecSuccess else {
      throw IAPError.persistenceFailed("Keychain save failed: \(status)")
    }
  }
  
  func recordTransaction(_ transaction: IAPTransaction) throws {
    // Transaction IDs are non-sensitive, use UserDefaults
    try UserDefaultsPersistence().recordTransaction(transaction)
  }
  
  func loadProcessedTransactionIDs() throws -> Set<String> {
    try UserDefaultsPersistence().loadProcessedTransactionIDs()
  }
}