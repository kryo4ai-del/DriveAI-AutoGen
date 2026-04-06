protocol AuthRepository {
    func signUp(
        email: String,
        password: String,
        examSchedule: ExamSchedule
    ) async throws -> AuthUser
    
    func verifyEmail(code: String) async throws -> AuthUser
    func signIn(email: String, password: String) async throws -> AuthUser
}

final class FirebaseAuthRepository: AuthRepository {
    private let firebaseService: FirebaseAuthService
    
    func signUp(email: String, password: String, examSchedule: ExamSchedule) async throws -> AuthUser {
        let user = try await firebaseService.createUser(email: email, password: password)
        // Save exam schedule to Firestore
        try await firebaseService.saveExamSchedule(examSchedule, for: user.uid)
        return AuthUser(
            id: user.uid,
            email: user.email ?? "",
            examSchedule: examSchedule,
            createdAt: Date()
        )
    }
    
    func verifyEmail(code: String) async throws -> AuthUser {
        // Firebase handles email verification via link; adjust as needed
        let user = try await firebaseService.getCurrentUser()
        return AuthUser(
            id: user.uid,
            email: user.email ?? "",
            examSchedule: .stub,
            createdAt: user.metadata?.creationDate ?? Date()
        )
    }
}