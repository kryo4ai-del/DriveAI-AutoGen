struct AuthUser: Identifiable, Codable, Equatable, Hashable {
    let id: String
    let email: String
    let createdAt: Date
    let displayName: String?
    let isEmailVerified: Bool
    
    enum CodingKeys: String, CodingKey {
        case id = "uid"
        case email
        case createdAt = "created_at"
        case displayName = "display_name"
        case isEmailVerified = "email_verified"
    }
}