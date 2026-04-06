import Foundation

/// Domain-level auth service protocol (implementation-agnostic)
protocol AuthServiceProtocol: Sendable {
    /// Stream of authentication state changes
    var authState: AsyncStream<AuthState> { get }
    
    /// Current authenticated user (thread-safe)
    var currentUser: AuthUser? { get async }
    
    /// Sign in with email and password
    func signIn(with credentials: AuthCredentials) async throws -> AuthUser
    
    /// Create new account
    func signUp(with credentials: AuthCredentials) async throws -> AuthUser
    
    /// Sign out current user
    func signOut() async throws
    
    /// Permanently delete current account
    func deleteAccount() async throws
    
    /// Update user profile (name + exam date)
    func updateProfile(displayName: String, examDate: Date) async throws -> AuthUser
    
    /// Update exam date only
    func updateExamDate(_ date: Date) async throws -> AuthUser
    
    /// Send password reset email
    func sendPasswordResetEmail(to email: String) async throws
}