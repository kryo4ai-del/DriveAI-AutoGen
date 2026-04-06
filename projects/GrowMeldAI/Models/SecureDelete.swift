struct SecureDelete {
       static func deleteKeychainItem(_ query: [String: Any]) throws {
           let status = SecItemDelete(query as CFDictionary)
           guard status == errSecSuccess else { throw KeychainError.deletionFailed }
       }
       
       static func secureSQLiteDelete(table: String, where condition: String) throws {
           try db.execute("DELETE FROM \(table) WHERE \(condition)")
           try db.execute("VACUUM") // Rebuild database, securely overwriting freed space
       }
   }