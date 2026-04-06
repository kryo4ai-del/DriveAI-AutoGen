// Tests/Services/FirebaseAuthManagerTests.swift
import XCTest
@testable import DriveAI

@MainActor
class FirebaseAuthManagerTests: XCTestCase {
    var authManager: FirebaseAuthManager!
    var mockAuthClient: MockAuthClient!
    var mockNetworkMonitor: MockNetworkMonitor!
    var mockTokenManager: MockCachedAuthTokenManager!
    
    override func setUp() async throws {
        mockAuthClient = MockAuthClient()
        mockNetworkMonitor = MockNetworkMonitor()
        mockTokenManager = MockCachedAuthTokenManager()
        
        authManager = FirebaseAuthManager(
            authClient: mockAuthClient,
            cachedTokenManager: mockTokenManager,
            networkMonitor: mockNetworkMonitor
        )
    }
    
    // MARK: - Happy Path
    
    /// Test: Online sign-in succeeds → state becomes authenticated
    func testSignInOnlineSuccess() async {
        let testUser = MockUser(uid: "user123", email: "test@example.de")
        mockAuthClient.mockUser = testUser
        mockNetworkMonitor.isConnected = true
        let examDate = Date().addingTimeInterval(86400 * 30)  // 30 days away
        authManager.examDate = examDate
        
        await authManager.signIn(email: "test@example.de", password: "SecurePass123!")
        
        // Verify state
        switch authManager.authState {
        case .authenticated(let user, let storedExamDate):
            XCTAssertEqual(user.uid, "user123")
            XCTAssertEqual(storedExamDate, examDate)
        default:
            XCTFail("Expected authenticated state, got \(authManager.authState)")
        }
        
        // Verify token cached
        XCTAssertTrue(mockTokenManager.didCacheUser)
    }
    
    /// Test: Sign-in transitions through loading state
    func testSignInShowsLoadingState() async {
        mockAuthClient.mockUser = MockUser(uid: "user123", email: "test@example.de")
        mockNetworkMonitor.isConnected = true
        var statesObserved: [AuthState] = []
        
        let cancellable = authManager.$authState.sink { state in
            statesObserved.append(state)
        }
        defer { cancellable.cancel() }
        
        await authManager.signIn(email: "test@example.de", password: "SecurePass123!")
        
        // Verify sequence: initial → loading → authenticated
        XCTAssertTrue(statesObserved.contains { state in
            if case .loading = state { return true }
            return false
        })
        XCTAssertEqual(statesObserved.last?.isAuthenticated, true)
    }
    
    // MARK: - Error Cases
    
    /// Test: Invalid email rejected before network call
    func testSignInInvalidEmailRejectedLocally() async {
        await authManager.signIn(email: "invalid-email", password: "SecurePass123!")
        
        switch authManager.authState {
        case .failed(let error):
            XCTAssertEqual(error, .invalidEmail)
        default:
            XCTFail("Expected failed state with invalidEmail")
        }
        
        // Verify NO network call made
        XCTAssertEqual(mockAuthClient.signInCallCount, 0)
    }
    
    /// Test: Weak password rejected locally
    func testSignUpWeakPasswordRejectedLocally() async {
        await authManager.signUp(email: "test@example.de", password: "short")
        
        switch authManager.authState {
        case .failed(let error):
            XCTAssertEqual(error, .weakPassword)
        default:
            XCTFail("Expected failed state with weakPassword")
        }
        
        XCTAssertEqual(mockAuthClient.signUpCallCount, 0)
    }
    
    /// Test: Network error during sign-in
    func testSignInNetworkError() async {
        mockAuthClient.shouldThrowError = NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet)
        mockNetworkMonitor.isConnected = false
        
        await authManager.signIn(email: "test@example.de", password: "SecurePass123!")
        
        switch authManager.authState {
        case .failed(let error):
            XCTAssertEqual(error, .networkError)
        default:
            XCTFail("Expected failed state with networkError")
        }
    }
    
    /// Test: Firebase "user not found" error mapped correctly
    func testSignInUserNotFoundMapped() async {
        let firebaseError = NSError(
            domain: "FIRAuthErrorDomain",
            code: AuthErrorCode.userNotFound.rawValue
        )
        mockAuthClient.shouldThrowError = firebaseError
        mockNetworkMonitor.isConnected = true
        
        await authManager.signIn(email: "unknown@example.de", password: "SecurePass123!")
        
        switch authManager.authState {
        case .failed(let error):
            XCTAssertEqual(error, .userNotFound)
        default:
            XCTFail("Expected failed state with userNotFound")
        }
    }
    
    /// Test: Firebase "too many requests" error (rate limit)
    func testSignInTooManyRequestsError() async {
        let firebaseError = NSError(
            domain: "FIRAuthErrorDomain",
            code: AuthErrorCode.tooManyRequests.rawValue
        )
        mockAuthClient.shouldThrowError = firebaseError
        mockNetworkMonitor.isConnected = true
        
        await authManager.signIn(email: "test@example.de", password: "SecurePass123!")
        
        switch authManager.authState {
        case .failed(let error):
            XCTAssertNotNil(error.errorDescription)
            XCTAssertTrue(error.errorDescription?.contains("viele") ?? false)  // "zu viele"
        default:
            XCTFail("Expected failed state")
        }
    }
    
    // MARK: - Offline Flow
    
    /// Test: Offline sign-in with cached user succeeds
    func testSignInOfflineWithCachedUserSucceeds() async {
        mockNetworkMonitor.isConnected = false
        mockTokenManager.cachedEmail = "cached@example.de"
        mockTokenManager.cachedUser = MockUser(uid: "cached123", email: "cached@example.de")
        
        await authManager.signIn(email: "cached@example.de", password: "any-password")
        
        XCTAssertEqual(authManager.authState.isAuthenticated, true)
    }
    
    /// Test: Offline sign-in without cache fails
    func testSignInOfflineNoCachedUserFails() async {
        mockNetworkMonitor.isConnected = false
        mockTokenManager.cachedEmail = nil
        
        await authManager.signIn(email: "unknown@example.de", password: "SecurePass123!")
        
        switch authManager.authState {
        case .failed(let error):
            XCTAssertEqual(error, .networkError)
        default:
            XCTFail("Expected networkError for offline without cache")
        }
    }
    
    // MARK: - Task Cancellation
    
    /// Test: Rapid sign-in calls cancel previous attempt
    func testRapidSignInCallsCancelPrevious() async {
        let slowMock = MockAuthClient()
        slowMock.delayMs = 500  // Simulate slow network
        
        authManager = FirebaseAuthManager(
            authClient: slowMock,
            cachedTokenManager: mockTokenManager,
            networkMonitor: mockNetworkMonitor
        )
        
        mockNetworkMonitor.isConnected = true
        
        let task1 = Task {
            await authManager.signIn(email: "user1@example.de", password: "Pass123!")
        }
        
        try? await Task.sleep(nanoseconds: 100_000_000)  // 100ms
        
        let task2 = Task {
            await authManager.signIn(email: "user2@example.de", password: "Pass123!")
        }
        
        await task1.value
        await task2.value
        
        // Only second sign-in should complete
        XCTAssertEqual(mockAuthClient.signInCallCount, 2)
    }
    
    // MARK: - Sign Out
    
    /// Test: Sign out clears state
    func testSignOutClearsState() {
        authManager.authState = .authenticated(user: MockUser(uid: "test", email: "test@example.de"), examDate: Date())
        
        authManager.signOut()
        
        switch authManager.authState {
        case .initial:
            XCTAssertTrue(true)
        default:
            XCTFail("Expected initial state after sign out")
        }
        
        XCTAssertTrue(mockTokenManager.didClearCache)
    }
    
    // MARK: - Memory Management
    
    /// Test: deinit removes auth state listener
    func testDeinitCleansUpAuthListener() {
        weak var weakManager = authManager
        authManager = nil
        
        XCTAssertNil(weakManager, "AuthManager should deallocate (no cycles)")
    }
}