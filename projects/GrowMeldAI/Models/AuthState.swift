import Foundation

/// Represents the current authentication state of the app.
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