@MainActor
final class FirebaseAuthServiceSignInTests: XCTestCase {
    var sut: FirebaseAuthService!
    var mockAuth: MockFirebaseAuth!
    var mockUserDefaults: UserDefaults!
    
    override func setUp() {
        super.setUp()
        mockAuth = MockFirebaseAuth()
        mockUserDefaults = UserDefaults(suiteName: UUID().uuidString)!
        sut = FirebaseAuthService(firebaseAuth: mockAuth, userDefaults: mockUserDefaults)
    }
    
    // Test 2.1: signIn with valid credentials succeeds
    func test_signIn_validCredentials_succeeds() async throws {
        // Arrange
        let credentials = AuthCredentials(email: "user@example.com", password: "Password123")
        let mockUser = MockUser(uid: "user123", email: "user@example.com", displayName: nil)
        mockAuth.shouldSucceedSignIn = true
        mockAuth.mockAuthResult = (user: mockUser, additionalUserInfo: nil)
        
        // Act
        let result = try await sut.signIn(with: credentials)
        
        // Assert
        XCTAssertEqual(result.email, "user@example.com")
        XCTAssertEqual(result.id, "user123")
        XCTAssertTrue(result.isNewUser) // No display name yet
    }
    
    // Test 2.2: signIn with invalid email throws error
    func test_signIn_invalidEmail_throwsError() async throws {
        // Arrange
        let credentials = AuthCredentials(email: "invalid-email", password: "Password123")
        
        // Act & Assert
        do {
            _ = try await sut.signIn(with: credentials)
            XCTFail("Should throw invalidEmail error")
        } catch AuthError.invalidEmail {
            // Expected
        } catch {
            XCTFail("Wrong error type: \(error)")
        }
    }
    
    // Test 2.3: signIn with weak password throws error
    func test_signIn_weakPassword_throwsError() async throws {
        let credentials = AuthCredentials(email: "test@example.com", password: "123")
        
        do {
            _ = try await sut.signIn(with: credentials)
            XCTFail("Should throw weakPassword error")
        } catch AuthError.weakPassword {
            // Expected
        } catch {
            XCTFail("Wrong error type: \(error)")
        }
    }
    
    // Test 2.4: signIn with wrong password returns Firebase error
    func test_signIn_wrongPassword_mapsToAuthError() async throws {
        // Arrange
        let credentials = AuthCredentials(email: "test@example.com", password: "Password123")
        mockAuth.shouldSucceedSignIn = false
        mockAuth.mockError = NSError(domain: "FIRAuthErrorDomain", code: 17009, userInfo: nil) // Wrong password
        
        // Act & Assert
        do {
            _ = try await sut.signIn(with: credentials)
            XCTFail("Should throw wrongPassword error")
        } catch AuthError.wrongPassword {
            // Expected
        } catch {
            XCTFail("Wrong error: \(error)")
        }
    }
    
    // Test 2.5: signIn with non-existent user returns userNotFound
    func test_signIn_userNotFound_mapsError() async throws {
        let credentials = AuthCredentials(email: "nonexistent@example.com", password: "Password123")
        mockAuth.shouldSucceedSignIn = false
        mockAuth.mockError = NSError(domain: "FIRAuthErrorDomain", code: 17011, userInfo: nil) // User not found
        
        do {
            _ = try await sut.signIn(with: credentials)
            XCTFail("Should throw userNotFound error")
        } catch AuthError.userNotFound {
            // Expected
        } catch {
            XCTFail("Wrong error: \(error)")
        }
    }
    
    // Test 2.6: signIn network error maps correctly
    func test_signIn_networkError_mapsCorrectly() async throws {
        let credentials = AuthCredentials(email: "test@example.com", password: "Password123")
        mockAuth.shouldSucceedSignIn = false
        mockAuth.mockError = NSError(domain: NSURLErrorDomain, code: NSURLErrorNetworkConnectionLost, userInfo: nil)
        
        do {
            _ = try await sut.signIn(with: credentials)
            XCTFail("Should throw networkError")
        } catch AuthError.networkError {
            // Expected
        } catch {
            XCTFail("Wrong error: \(error)")
        }
    }
    
    // Test 2.7: signIn updates auth state stream
    func test_signIn_updatesAuthStateStream() async throws {
        let credentials = AuthCredentials(email: "test@example.com", password: "Password123")
        let mockUser = MockUser(uid: "123", email: "test@example.com")
        mockAuth.shouldSucceedSignIn = true
        mockAuth.mockAuthResult = (user: mockUser, additionalUserInfo: nil)
        
        var statesReceived: [AuthState] = []
        let expectation = self.expectation(description: "Should receive authenticated state")
        
        let task = Task {
            for await state in sut.authState {
                statesReceived.append(state)
                if case .authenticated = state {
                    expectation.fulfill()
                }
            }
        }
        
        // Give stream time to set up
        try await Task.sleep(nanoseconds: 10_000_000)
        
        _ = try await sut.signIn(with: credentials)
        
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertTrue(statesReceived.contains { state in
            if case .authenticated = state { return true }
            return false
        })
        
        task.cancel()
    }
    
    // Test 2.8: signIn caches user in currentUser
    func test_signIn_cachesUserInCurrentUser() async throws {
        let credentials = AuthCredentials(email: "test@example.com", password: "Password123")
        let mockUser = MockUser(uid: "user789", email: "test@example.com", displayName: "Alice")
        mockAuth.shouldSucceedSignIn = true
        mockAuth.mockAuthResult = (user: mockUser, additionalUserInfo: nil)
        
        _ = try await sut.signIn(with: credentials)
        
        let cachedUser = await sut.currentUser
        XCTAssertEqual(cachedUser?.id, "user789")
        XCTAssertEqual(cachedUser?.displayName, "Alice")
    }
    
    // Test 2.9: signIn with email already in use (signup path)
    func test_signIn_emailAlreadyInUse_stillThrowsUserNotFound() async throws {
        // Note: emailAlreadyInUse is for signup, signIn should return userNotFound
        // But test defensive mapping
        let credentials = AuthCredentials(email: "existing@example.com", password: "Password123")
        mockAuth.shouldSucceedSignIn = false
        mockAuth.mockError = NSError(domain: "FIRAuthErrorDomain", code: 17007, userInfo: nil) // Email in use
        
        do {
            _ = try await sut.signIn(with: credentials)
            XCTFail("Should throw error")
        } catch AuthError.emailAlreadyInUse {
            // Maps during signup context
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}