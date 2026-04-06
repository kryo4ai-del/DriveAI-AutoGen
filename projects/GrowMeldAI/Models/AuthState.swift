import Foundation

enum AuthError: LocalizedError, Equatable {
    case unknown
    case invalidCredentials
    case networkError(String)

    var errorDescription: String? {
        switch self {
        case .unknown:
            return "An unknown error occurred."
        case .invalidCredentials:
            return "Invalid credentials."
        case .networkError(let msg):
            return "Network error: \(msg)"
        }
    }
}

struct AuthUser: Equatable {
    let id: String
    let email: String
    let displayName: String
}

enum AuthState: Equatable {
    case loggedOut
    case loggedIn(AuthUser)
    case loading
    case error(AuthError)

    var isLoggedIn: Bool {
        if case .loggedIn = self {
            return true
        }
        return false
    }

    var user: AuthUser? {
        if case .loggedIn(let user) = self {
            return user
        }
        return nil
    }

    var isLoading: Bool {
        if case .loading = self {
            return true
        }
        return false
    }
}