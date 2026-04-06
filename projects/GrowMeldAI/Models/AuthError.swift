import Foundation

enum AuthError: LocalizedError {
    case invalidEmail
    case weakPassword(String)
    // ...
    
    var errorDescription: String? {
        switch self {
        case .invalidEmail:
            return String(localized: "error.invalidEmail")
        case .weakPassword(let reason):
            return String(localized: "error.weakPassword \(reason)")
        // ...
        }
    }
}