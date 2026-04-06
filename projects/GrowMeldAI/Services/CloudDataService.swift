// ⚠️ MISSING: Encryption at rest
class CloudDataService {
    func saveProfile(_ profile: UserProfile, userId: String) async throws {
        // ❌ Data sent to Firestore unencrypted (TLS in-transit only)
        // ❌ Stored on Google Cloud servers unencrypted at rest
        // ❌ DSGWO compliance: Where is the data geographically?
        
        let data = try Firestore.Encoder().encode(profile)
        try await db.collection("users").document(userId).collection("profile").document("info").setData(data)
    }
}

// ✅ BETTER: Client-side encryption
class CloudDataService {
    private let encryptionService: ClientEncryptionService
    
    func saveProfile(_ profile: UserProfile, userId: String) async throws {
        let data = try Firestore.Encoder().encode(profile)
        let encrypted = try encryptionService.encrypt(data, keyId: userId)  // E2E encryption
        try await db.collection("users").document(userId).collection("encrypted").document("profile").setData([
            "ciphertext": encrypted.ciphertext,
            "keyId": encrypted.keyId
        ])
    }
}