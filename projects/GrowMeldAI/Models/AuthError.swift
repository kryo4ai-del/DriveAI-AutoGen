import Foundation

enum AuthError: LocalizedError {
    case invalidEmail
    case weakPassword(String)

    var errorDescription: String? {
        switch self {
        case .invalidEmail:
            return "Invalid email address."
        case .weakPassword(let reason):
            return "Weak password: \(reason)"
        }
    }
}