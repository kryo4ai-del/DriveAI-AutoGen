// Services/ProfilePersistenceService.swift
/// Thread-safe service for persisting UserProfile to local JSON.
/// Does NOT use @MainActor—handles I/O on background queues only.
final class ProfilePersistenceService: Sendable {
    static let shared = ProfilePersistenceService()
    
    private let fileManager = FileManager.default
    
    nonisolated private var profileURL: URL {
        let documentDirectory = fileManager.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )[0]
        return documentDirectory.appendingPathComponent("profile.json")
    }
    
    nonisolated init() {}
    
    // ✅ Create encoders/decoders per-call (JSON classes not Sendable)
    nonisolated func loadProfile() throws -> UserProfile {
        guard fileManager.fileExists(atPath: profileURL.path) else {
            throw ProfilePersistenceError.fileNotFound
        }
        
        let data = try Data(contentsOf: profileURL)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(UserProfile.self, from: data)
    }
    
    nonisolated func saveProfile(_ profile: UserProfile) throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(profile)
        
        try data.write(
            to: profileURL,
            options: [.atomic, .completeFileProtection]
        )
    }
    
    nonisolated func initializeIfNeeded() throws -> UserProfile {
        do {
            return try loadProfile()
        } catch ProfilePersistenceError.fileNotFound {
            let newProfile = UserProfile()
            try saveProfile(newProfile)
            return newProfile
        }
    }
    
    nonisolated func deleteProfile() throws {
        if fileManager.fileExists(atPath: profileURL.path) {
            try fileManager.removeItem(at: profileURL)
        }
    }
}