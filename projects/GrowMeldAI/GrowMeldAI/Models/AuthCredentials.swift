import Foundation

/// Represents cached authentication credentials for offline access and token management.
struct AuthCredentials: Codable, Equatable {
    let email: String
    let uid: String
    let idToken: String
    let refreshToken: String
    let expirationDate: Date
    
    var isExpired: Bool {
        return Date() > expirationDate
    }
    
    var isExpiringSoon: Bool {
        // Refresh if expiring within 5 minutes
        let threshold = Date().addingTimeInterval(5 * 60)
        return expirationDate < threshold
    }
}