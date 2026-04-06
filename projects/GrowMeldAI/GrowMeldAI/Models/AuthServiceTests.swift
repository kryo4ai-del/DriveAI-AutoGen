import XCTest
@testable import DriveAI

@MainActor
final class AuthServiceTests: XCTestCase {
    
    var authService: AuthService!
    var mockFirebaseAdapter: MockFirebaseAuthAdapter!
    var mockKeychainService: MockKeychainService!
    var mockNetworkMonitor: MockNetworkMonitor!
    
    override func setUp() async throws {
        try await super.setUp()
        
        mockFirebaseAdapter = MockFirebaseAuthAdapter()
        mockKeychainService = MockKeychainService()
        mockNetworkMonitor = MockNetworkMonitor()
        
        authService = AuthService(
            firebaseAdapter: mockFirebaseAdapter,
            keychainService: mockKeychainService,
            networkMonitor: mockNetworkMonitor
        )
    }
    
    // MARK: - Happy Path Tests
    
    /// Test: User successfully signs up with valid email and password
    func testSignUpSuccess() async throws {
        let email = "user@example.com"
        let password = "SecurePassword123"
        let expectedUser = AuthUser(
            id: "uid-123",
            email: email,
            createdAt: Date(),
            displayName: nil,
            isEmailVerified: false
        )
        
        mockFirebaseAdapter.mockSignUpResult = expectedUser
        
        let result = try await authService.signUp(email: email, password: password)
        
        XCTAssertEqual(result.email, email)
        XCTAssertEqual(authService.authState, .loggedIn(expectedUser))
        XCTAssertTrue(mockKeychainService.userSaved)
    }
    
    /// Test: User successfully signs in with valid credentials
    func testSignInSuccess() async throws {
        let email = "user@example.com"
        let password = "SecurePassword123"
        let expectedUser = AuthUser(
            id: "uid-123",
            email: email,
            createdAt: Date(),
            displayName: nil,
            isEmailVerified: false
        )
        
        mockFirebaseAdapter.mockSignInResult = expectedUser
        mockNetworkMonitor.isConnected = true
        
        let result = try await authService.signIn(email: email, password: password)
        
        XCTAssertEqual(result.email, email)
        XCTAssertEqual(authService.authState, .loggedIn(expectedUser))
        XCTAssertTrue(mockKeychainService.userSaved)
    }
    
    /// Test: User successfully signs out
    func testSignOutSuccess() async throws {
        // Setup: User logged in
        let user = AuthUser(
            id: "uid-123",
            email: "user@example.com",
            createdAt: Date(),
            displayName: nil,
            isEmailVerified: false
        )
        authService.authState = .loggedIn(user)
        
        // Sign out
        try authService.signOut()
        
        // Verify
        XCTAssertEqual(authService.authState, .loggedOut)
        
        // Wait for async Keychain clear
        try await Task.sleep(nanoseconds: 100_000_000)
        XCTAssertTrue(mockKeychainService.wasCleared)
    }
    
    // MARK: - Email Validation Tests
    
    /// Test: Invalid email formats are rejected before Firebase call
    func testEmailValidationRejectsInvalidFormats() async throws {
        let invalidEmails = [
            "",
            "   ",
            "notanemail",
            "user@",
            "@example.com",
            "user@.com",
            "user..name@example.com"
        ]
        
        for invalidEmail in invalidEmails {
            do {
                _ = try await authService.signUp(email: invalidEmail, password: "Password123")
                XCTFail("Should have thrown invalidEmail for: \(invalidEmail)")
            } catch AuthError.invalidEmail {
                XCTAssertEqual(authService.authState, .error(.invalidEmail))
            } catch {
                XCTFail("Unexpected error: \(error)")
            }
        }
        
        // Verify Firebase was never called
        XCTAssertEqual(mockFirebaseAdapter.signUpCallCount, 0)
    }
    
    /// Test: Valid email formats are accepted
    func testEmailValidationAcceptsValidFormats() async throws {
        let validEmails = [
            "user@example.com",
            "john.doe+tag@example.co.uk",
            "test123@subdomain.example.com",
            "a@b.co"
        ]
        
        for validEmail in validEmails {
            mockFirebaseAdapter.mockSignUpResult = AuthUser(
                id: "uid",
                email: validEmail,
                createdAt: Date(),
                displayName: nil,
                isEmailVerified: false
            )
            
            do {
                _ = try await authService.signUp(email: validEmail, password: "ValidPass123")
            } catch AuthError.invalidEmail {
                XCTFail("Valid email rejected: \(validEmail)")
            }
        }
        
        XCTAssertEqual(mockFirebaseAdapter.signUpCallCount, validEmails.count)
    }
    
    // MARK: - Password Validation Tests
    
    /// Test: Passwords shorter than 8 characters are rejected
    func testPasswordValidationEnforcesMinimumLength() async throws {
        let shortPasswords = ["", "Pass", "Pass123"]
        
        for shortPassword in shortPasswords {
            do {
                _ = try await authService.signUp(
                    email: "valid@example.com",
                    password: shortPassword
                )
                XCTFail("Should reject short password: \(shortPassword)")
            } catch AuthError.weakPassword {
                // Expected
            } catch {
                XCTFail("Unexpected error: \(error)")
            }
        }
        
        XCTAssertEqual(mockFirebaseAdapter.signUpCallCount, 0)
    }
    
    /// Test: Passwords with 8+ characters are accepted (MVP validation)
    func testPasswordValidationAcceptsValidPasswords() async throws {
        let validPasswords = [
            "Password1",
            "12345678",
            "ValidPass123!@#"
        ]
        
        for password in validPasswords {
            mockFirebaseAdapter.mockSignUpResult = AuthUser(
                id: "uid",
                email: "user@example.com",
                createdAt: Date(),
                displayName: nil,
                isEmailVerified: false
            )
            
            do {
                _ = try await authService.signUp(
                    email: "valid@example.com",
                    password: password
                )
            } catch AuthError.weakPassword {
                XCTFail("Valid password rejected: \(password)")
            }
        }
    }
    
    // MARK: - Firebase Error Mapping Tests
    
    /// Test: Firebase auth errors are properly mapped to AuthError
    func testFirebaseErrorMapping() async throws {
        let testCases: [(error: Error, expectedAuthError: AuthError)] = [
            // Invalid email
            (createFirebaseError(code: 17008), AuthError.invalidEmail),
            // Weak password
            (createFirebaseError(code: 17026), AuthError.weakPassword("")),
            // User not found
            (createFirebaseError(code: 17011), AuthError.userNotFound),
            // User already exists
            (createFirebaseError(code: 17007), AuthError.userAlreadyExists),
            // Wrong password
            (createFirebaseError(code: 17009), AuthError.invalidPassword),
            // Network error
            (createFirebaseError(code: 17020), AuthError.networkError),
            // Too many requests
            (createFirebaseError(code: 17010), AuthError.unknown(""))
        ]
        
        for (firebaseError, expectedAuthError) in testCases {
            mockFirebaseAdapter.mockSignUpError = firebaseError as NSError
            
            do {
                _ = try await authService.signUp(
                    email: "user@example.com",
                    password: "Password123"
                )
                XCTFail("Should have thrown for Firebase error")
            } catch let error as AuthError {
                // Compare error types (not full description due to localization)
                XCTAssertTrue(error == expectedAuthError || 
                    "\(error)".contains(String(describing: expectedAuthError)))
            }
        }
    }
    
    // MARK: - Offline Fallback Tests
    
    /// Test: Sign-in uses cached user when network unavailable
    func testSignInOfflineFallbackWithCachedUser() async throws {
        let email = "user@example.com"
        let password = "Password123"
        let cachedUser = AuthUser(
            id: "uid-123",
            email: email,
            createdAt: Date(),
            displayName: nil,
            isEmailVerified: false
        )
        
        // Setup: Network down, cached user in Keychain
        mockNetworkMonitor.isConnected = false
        mockKeychainService.cachedUser = cachedUser
        mockFirebaseAdapter.mockSignInError = NSError(domain: "", code: 17020) // Network error
        
        let result = try await authService.signIn(email: email, password: password)
        
        XCTAssertEqual(result.email, email)
        XCTAssertEqual(authService.authState, .loggedIn(cachedUser))
    }
    
    /// Test: Sign-in fails when network unavailable and no cache
    func testSignInOfflineFailsWithoutCache() async throws {
        mockNetworkMonitor.isConnected = false
        mockKeychainService.cachedUser = nil
        mockFirebaseAdapter.mockSignInError = NSError(domain: "", code: 17020)
        
        do {
            _ = try await authService.signIn(
                email: "user@example.com",
                password: "Password123"
            )
            XCTFail("Should fail without cached user")
        } catch AuthError.networkError {
            // Expected
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    // MARK: - Loading State Tests
    
    /// Test: Loading state is set during sign-up
    func testLoadingStateSetDuringSignUp() async throws {
        let expectation = XCTestExpectation(description: "Loading state emitted")
        var stateHistory: [AuthState] = []
        
        mockFirebaseAdapter.mockSignUpResult = AuthUser(
            id: "uid",
            email: "user@example.com",
            createdAt: Date(),
            displayName: nil,
            isEmailVerified: false
        )
        
        // Monitor state changes
        let task = Task {
            var previousState: AuthState?
            for _ in 0..<50 {
                if authService.authState != previousState {
                    stateHistory.append(authService.authState)
                    previousState = authService.authState
                }
                try await Task.sleep(nanoseconds: 10_000_000)
            }
        }
        
        _ = try await authService.signUp(
            email: "user@example.com",
            password: "Password123"
        )
        
        await task.value
        
        // Verify loading state was present
        let hasLoadingState = stateHistory.contains { state in
            if case .loading = state {
                return true
            }
            return false
        }
        XCTAssertTrue(hasLoadingState)
    }
    
    // MARK: - Firebase Configuration Tests
    
    /// Test: Operations fail gracefully if Firebase not configured
    func testOperationsFailIfFirebaseNotConfigured() async throws {
        mockFirebaseAdapter.isConfiguredResult = false
        
        do {
            _ = try await authService.signUp(
                email: "user@example.com",
                password: "Password123"
            )
            XCTFail("Should fail without Firebase config")
        } catch AuthError.firebaseConfigMissing {
            XCTAssertEqual(authService.authState, .error(.firebaseConfigMissing))
        }
    }
    
    // MARK: - Concurrent Operations Tests
    
    /// Test: Rapid successive sign-up calls don't create race conditions
    func testRapidSuccessiveSignUpsHandleRaceConditions() async throws {
        mockFirebaseAdapter.mockSignUpResult = AuthUser(
            id: "uid",
            email: "user@example.com",
            createdAt: Date(),
            displayName: nil,
            isEmailVerified: false
        )
        
        // Attempt 3 rapid sign-ups
        async let task1 = try authService.signUp(
            email: "user1@example.com",
            password: "Password123"
        )
        async let task2 = try authService.signUp(
            email: "user2@example.com",
            password: "Password123"
        )
        async let task3 = try authService.signUp(
            email: "user3@example.com",
            password: "Password123"
        )
        
        _ = try await (task1, task2, task3)
        
        // Should handle gracefully (last one wins)
        XCTAssertTrue(authService.authState.isLoggedIn)
    }
    
    // MARK: - Helper Methods
    
    private func createFirebaseError(code: Int) -> Error {
        return NSError(
            domain: "com.firebase.auth",
            code: code,
            userInfo: [NSLocalizedDescriptionKey: "Firebase error"]
        )
    }
}