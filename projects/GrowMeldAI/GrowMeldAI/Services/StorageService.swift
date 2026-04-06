@MainActor
class StorageService: StorageServiceProtocol {
    private let queue = DispatchQueue(label: "com.driveai.storage")  // ✅ Serial
    
    func saveUserProfile(_ profile: UserProfile) throws {
        let encoded = try JSONEncoder().encode(profile)
        try queue.sync {  // ✅ Blocking sync
            UserDefaults.standard.set(encoded, forKey: userProfileKey)
        }
    }
    
    func loadUserProfile() -> UserProfile? {
        var result: UserProfile?
        queue.sync {
            if let data = UserDefaults.standard.data(forKey: userProfileKey),
               let decoded = try? JSONDecoder().decode(UserProfile.self, from: data) {
                result = decoded
            }
        }
        return result
    }
    
    // Apply same pattern to all save operations
}