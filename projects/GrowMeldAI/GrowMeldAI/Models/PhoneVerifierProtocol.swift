// Services/Protocols/PhoneVerifierProtocol.swift
protocol PhoneVerifierProtocol: Sendable {
    func requestVerification(phone: String) async throws -> String
    func completeVerification(verificationId: String, code: String) async throws -> String
}

// Services/Auth/LocalPhoneVerifier.swift
actor LocalPhoneVerifier: PhoneVerifierProtocol {
    private let storage = UserDefaults.standard
    
    func requestVerification(phone: String) async throws -> String {
        let verificationId = UUID().uuidString
        storage.set(verificationId, forKey: "verification_\(phone)")
        return verificationId
    }
    
    func completeVerification(
        verificationId: String,
        code: String
    ) async throws -> String {
        // Local: accept any code in MVP
        return UUID().uuidString
    }
}

// Services/Auth/FirebasePhoneVerifier.swift
actor FirebasePhoneVerifier: PhoneVerifierProtocol {
    private let provider = PhoneAuthProvider.provider()
    
    func requestVerification(phone: String) async throws -> String {
        return try await provider.verifyPhoneNumber(phone, uiDelegate: nil)
    }
    
    func completeVerification(
        verificationId: String,
        code: String
    ) async throws -> String {
        let credential = provider.credential(withVerificationID: verificationId, verificationCode: code)
        let result = try await Auth.auth().signIn(with: credential)
        return result.user.uid
    }
}

// Services/Auth/BaseAuthService.swift (shared logic)
actor BaseAuthService: AuthServiceProtocol {
    private let verifier: PhoneVerifierProtocol
    private let userRepository: UserRepositoryProtocol
    private let logger: Logger
    
    nonisolated private let statePublisher = PassthroughSubject<AuthStateChange, Never>()
    
    private var state: AuthState = .unauthenticated
    
    init(
        verifier: PhoneVerifierProtocol,
        userRepository: UserRepositoryProtocol,
        logger: Logger = .shared
    ) {
        self.verifier = verifier
        self.userRepository = userRepository
        self.logger = logger
    }
    
    // MARK: - Shared Implementation
    func signIn(phone: String) async throws -> String {
        // 1. Request verification (backend-agnostic)
        let verificationId = try await verifier.requestVerification(phone: phone)
        self.state = .awaitingVerificationCode(phone, verificationId)
        
        statePublisher.send(.verificationCodeRequested)
        return verificationId
    }
    
    func verifyCode(_ code: String) async throws -> String {
        guard case .awaitingVerificationCode(let phone, let verificationId) = state else {
            throw AuthError.invalidState
        }
        
        // 2. Complete verification (backend-agnostic)
        let userId = try await verifier.completeVerification(
            verificationId: verificationId,
            code: code
        )
        
        // 3. Create/fetch user (consistent across backends)
        let user = User(id: userId, phoneNumber: phone, createdAt: Date(), locale: localeCode)
        try await userRepository.saveUser(user)
        
        self.state = .authenticated(userId)
        statePublisher.send(.authenticated(userId))
        
        logger.info("User authenticated: \(userId)")
        return userId
    }
    
    func signOut() async throws {
        try await userRepository.logout()
        self.state = .unauthenticated
        statePublisher.send(.signedOut)
    }
    
    // Expose state publisher for SwiftUI
    nonisolated var authStateChanges: AnyPublisher<AuthStateChange, Never> {
        statePublisher.eraseToAnyPublisher()
    }
}

enum AuthStateChange: Equatable {
    case verificationCodeRequested
    case authenticated(String)
    case signedOut
}