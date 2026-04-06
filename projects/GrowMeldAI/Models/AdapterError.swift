import Foundation
import FirebaseAuth

/// Wraps Firebase Authentication SDK for dependency injection and testability.
/// Uses `actor` isolation to prevent concurrent mutations during auth state changes.
actor FirebaseAuthAdapter {
    static let shared = FirebaseAuthAdapter()
    
    private let auth = Auth.auth()
    
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
        do {
            let result = try await auth.createUser(withEmail: email, password: password)
            let authUser = AuthUser.from(firebaseUser: result.user)
            
            #if DEBUG
            print("✅ User signed up: \(authUser.id)")
            #endif
            
            return authUser
        } catch {
            throw mapFirebaseError(error)
        }
    }
    
    /// Signs in an existing user with email and password.
    func signIn(email: String, password: String) async throws -> AuthUser {
        do {
            let result = try await auth.signIn(withEmail: email, password: password)
            let authUser = AuthUser.from(firebaseUser: result.user)
            
            #if DEBUG
            print("✅ User signed in: \(authUser.id)")
            #endif
            
            return authUser
        } catch {
            throw mapFirebaseError(error)
        }
    }
    
    /// Signs out the current user.
    func signOut() throws {
        do {
            try auth.signOut()
            #if DEBUG
            print("✅ User signed out")
            #endif
        } catch {
            throw mapFirebaseError(error)
        }
    }
    
    /// Retrieves the currently authenticated user without async.
    func getCurrentUser() -> AuthUser? {
        guard let firebaseUser = auth.currentUser else {
            return nil
        }
        return AuthUser.from(firebaseUser: firebaseUser)
    }
    
    /// Sends a password reset email.
    func sendPasswordReset(email: String) async throws {
        do {
            try await auth.sendPasswordReset(withEmail: email)
            #if DEBUG
            print("✅ Password reset email sent to \(email)")
            #endif
        } catch {
            throw mapFirebaseError(error)
        }
    }
    
    /// Verifies user's email address.
    func sendEmailVerification() async throws {
        guard let user = auth.currentUser else {
            throw AdapterError.userNotAuthenticated
        }
        
        do {
            try await user.sendEmailVerification()
            #if DEBUG
            print("✅ Verification email sent")
            #endif
        } catch {
            throw mapFirebaseError(error)
        }
    }
    
    /// Checks if Firebase is properly configured.
    func isConfigured() -> Bool {
        return FirebaseApp.app() != nil
    }
    
    /// Deletes the current user account (GDPR compliance).
    func deleteAccount() async throws {
        guard let user = auth.currentUser else {
            throw AdapterError.userNotAuthenticated
        }
        
        do {
            try await user.delete()
            #if DEBUG
            print("✅ User account deleted")
            #endif
        } catch {
            throw mapFirebaseError(error)
        }
    }
    
    /// Returns the current Firebase user's ID token (for API calls, Phase 2).
    func getIDToken() async throws -> String {
        guard let user = auth.currentUser else {
            throw AdapterError.userNotAuthenticated
        }
        
        do {
            let result = try await user.getIDTokenResult()
            return result.token
        } catch {
            throw mapFirebaseError(error)
        }
    }
    
    // MARK: - Private Error Mapping
    
    /// Maps Firebase error codes to DriveAI AuthError.
    private func mapFirebaseError(_ error: Error) -> AuthError {
        let nsError = error as NSError
        
        guard let errorCode = AuthErrorCode(rawValue: nsError.code) else {
            return .unknown(nsError.localizedDescription)
        }
        
        switch errorCode {
        case .invalidEmail:
            return .invalidEmail
        case .weakPassword:
            let reason = nsError.localizedDescription
            return .weakPassword(reason)
        case .userNotFound:
            return .userNotFound
        case .userDisabled:
            return .unknown("Benutzer ist deaktiviert.")
        case .emailAlreadyInUse:
            return .userAlreadyExists
        case .wrongPassword:
            return .invalidPassword
        case .networkError:
            return .networkError
        case .tooManyRequests:
            return .unknown("Zu viele Anmeldeversuche. Versuchen Sie es später erneut.")
        default:
            return .unknown(nsError.localizedDescription)
        }
    }
}