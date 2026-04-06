import Foundation

/// Wraps Firebase Authentication SDK for dependency injection and testability.
/// Uses `actor` isolation to prevent concurrent mutations during auth state changes.
actor FirebaseAuthAdapter {
    static let shared = FirebaseAuthAdapter()
    
    enum AdapterError: LocalizedError, Equatable {
        case firebaseNotInitialized
        case invalidCredential
        case userNotAuthenticated
        case operationFailed(String)
        
        var errorDescription: String? {
            switch self {
            case .firebaseNotInitialized:
                return "Firebase not initialized"
            case .invalidCredential:
                return "Ungültige Zugangsdaten"
            case .userNotAuthenticated:
                return "Kein authentifizierter Benutzer"
            case .operationFailed(let msg):
                return msg
            }
        }
    }
    
    // MARK: - Public Interface
    
    /// Creates a new user account with email and password.
    func signUp(email: String, password: String) async throws -> AuthUser {
        // TODO: Integrate with FirebaseAuth when module is available
        throw AdapterError.firebaseNotInitialized
    }
    
    /// Signs in an existing user with email and password.
    func signIn(email: String, password: String) async throws -> AuthUser {
        // TODO: Integrate with FirebaseAuth when module is available
        throw AdapterError.firebaseNotInitialized
    }
    
    /// Signs out the current user.
    func signOut() throws {
        // TODO: Integrate with FirebaseAuth when module is available
        throw AdapterError.firebaseNotInitialized
    }
    
    /// Retrieves the currently authenticated user without async.
    func getCurrentUser() -> AuthUser? {
        // TODO: Integrate with FirebaseAuth when module is available
        return nil
    }
    
    /// Sends a password reset email.
    func sendPasswordReset(email: String) async throws {
        // TODO: Integrate with FirebaseAuth when module is available
        throw AdapterError.firebaseNotInitialized
    }
    
    /// Verifies user's email address.
    func sendEmailVerification() async throws {
        // TODO: Integrate with FirebaseAuth when module is available
        throw AdapterError.userNotAuthenticated
    }
    
    /// Checks if Firebase is properly configured.
    func isConfigured() -> Bool {
        // TODO: Integrate with FirebaseAuth when module is available
        return false
    }
    
    /// Deletes the current user account (GDPR compliance).
    func deleteAccount() async throws {
        // TODO: Integrate with FirebaseAuth when module is available
        throw AdapterError.userNotAuthenticated
    }
    
    /// Returns the current Firebase user's ID token (for API calls, Phase 2).
    func getIDToken() async throws -> String {
        // TODO: Integrate with FirebaseAuth when module is available
        throw AdapterError.userNotAuthenticated
    }
    
    // MARK: - Private Error Mapping
    
    /// Maps Firebase error codes to DriveAI AuthError.
    private func mapFirebaseError(_ error: Error) -> AuthError {
        let nsError = error as NSError
        
        switch nsError.code {
        case 17008:
            return .invalidEmail
        case 17026:
            let reason = nsError.localizedDescription
            return .weakPassword(reason)
        case 17011:
            return .userNotFound
        case 17005:
            return .unknown("Benutzer ist deaktiviert.")
        case 17007:
            return .userAlreadyExists
        case 17009:
            return .invalidPassword
        case 17020:
            return .networkError
        case 17010:
            return .unknown("Zu viele Anmeldeversuche. Versuchen Sie es später erneut.")
        default:
            return .unknown(nsError.localizedDescription)
        }
    }
}