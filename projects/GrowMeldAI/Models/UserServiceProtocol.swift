import Foundation

protocol UserServiceProtocol: AnyObject {
    func loadProfile() async throws -> UserProfile
    func saveProfile(_ profile: UserProfile) async throws
    func updateExamDate(_ date: Date?) async throws
}

class UserService: UserServiceProtocol {
    static let shared = UserService()
    
    private let userDefaults = UserDefaults.standard
    private let profileKey = "driveai_user_profile"
    
    func loadProfile() async throws -> UserProfile {
        guard let data = userDefaults.data(forKey: profileKey) else {
            return UserProfile()
        }
        return try JSONDecoder().decode(UserProfile.self, from: data)
    }
    
    func saveProfile(_ profile: UserProfile) async throws {
        let encoded = try JSONEncoder().encode(profile)
        userDefaults.set(encoded, forKey: profileKey)
    }
    
    func updateExamDate(_ date: Date?) async throws {
        var profile = try await loadProfile()
        profile.examDate = date
        try await saveProfile(profile)
    }
}

private struct UserServiceKey: EnvironmentKey {
    static let defaultValue: UserServiceProtocol = UserService.shared
}

extension EnvironmentValues {
    var userService: UserServiceProtocol {
        get { self[UserServiceKey.self] }
        set { self[UserServiceKey.self] = newValue }
    }
}