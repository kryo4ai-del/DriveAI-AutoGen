import Foundation

protocol UserProfileRepositoryProtocol: AnyObject {
    func fetchProfile() async throws -> UserProfile
}

struct UserProfile {
    let examDate: Date?
    let displayName: String
}