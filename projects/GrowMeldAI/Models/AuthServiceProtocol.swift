import Foundation

/// Domain-level auth service protocol (implementation-agnostic)
protocol AuthServiceProtocol: Sendable {
    /// Stream of authentication state changes
    var authState: AsyncStream<AuthState> { get }
    
    /// Current authenticated user (thread-safe)
    var currentUser: Models.AuthUser? { get }
    
    /// Sign in with email and password
    func signIn(with credentials: AuthCredentials) async throws -> Models.AuthUser
    
    /// Create new account
    func signUp(with credentials: AuthCredentials) async throws -> Models.AuthUser
    
    /// Sign out current user
    func signOut() async throws
    
    /// Permanently delete current account
    func deleteAccount() async throws
    
    /// Update user profile (name + exam date)
    func updateProfile(displayName: String, examDate: Date) async throws -> Models.AuthUser
    
    /// Update exam date only
    func updateExamDate(_ date: Date) async throws -> Models.AuthUser
    
    /// Send password reset email
    func sendPasswordResetEmail(to email: String) async throws
}