protocol PersistenceServiceProtocol {
    func loadUserProfile() throws -> UserProfile
    func saveUserProfile(_ profile: UserProfile) throws
    func loadSessions() throws -> [UserSession]
    func saveSessions(_ sessions: [UserSession]) throws
}
