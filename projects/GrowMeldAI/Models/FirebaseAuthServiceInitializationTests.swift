import XCTest
@testable import DriveAI

@MainActor
final class FirebaseAuthServiceInitializationTests: XCTestCase {
    var sut: FirebaseAuthService!
    var mockAuth: MockFirebaseAuth!
    var mockUserDefaults: UserDefaults!
    
    override func setUp() {
        super.setUp()
        mockAuth = MockFirebaseAuth()
        mockUserDefaults = UserDefaults(suiteName: UUID().uuidString)!
        
        sut = FirebaseAuthService(
            firebaseAuth: mockAuth,
            userDefaults: mockUserDefaults
        )
    }
    
    override func tearDown() {
        sut = nil
        mockAuth = nil
        mockUserDefaults?.removePersistentDomain(forName: mockUserDefaults.suiteName!)
        super.tearDown()
    }
    
    // Test 1.1: Init with no current user yields unauthenticated
    func test_initialization_noCurrentUser_yieldsUnauthenticated() async throws {
        let expectation = self.expectation(description: "Should yield unauthenticated")
        
        var firstState: AuthState?
        let task = Task {
            for await state in sut.authState {
                firstState = state
                expectation.fulfill()
                break
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
        
        if case .unauthenticated = firstState {
            // Pass
        } else {
            XCTFail("Expected unauthenticated, got \(String(describing: firstState))")
        }
        
        task.cancel()
    }
    
    // Test 1.2: Init with current user yields authenticated
    func test_initialization_withCurrentUser_yieldsAuthenticated() async throws {
        let mockUser = MockUser(uid: "123", email: "test@example.com")
        mockAuth.currentUser = mockUser
        
        // Reinitialize with mocked current user
        let authService = FirebaseAuthService(
            firebaseAuth: mockAuth,
            userDefaults: mockUserDefaults
        )
        
        let expectation = self.expectation(description: "Should yield authenticated")
        var capturedState: AuthState?
        
        let task = Task {
            for await state in authService.authState {
                capturedState = state
                expectation.fulfill()
                break
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
        
        if case .authenticated(let user) = capturedState {
            XCTAssertEqual(user.id, "123")
            XCTAssertEqual(user.email, "test@example.com")
        } else {
            XCTFail("Expected authenticated state")
        }
        
        task.cancel()
    }
    
    // Test 1.3: Deinit finishes AsyncStream (no hanging tasks)
    func test_deinit_finishesAsyncStream() async throws {
        var iterationCount = 0
        let expectation = self.expectation(description: "Stream should complete")
        
        let task = Task {
            for await _ in sut.authState {
                iterationCount += 1
                if iterationCount > 10 {
                    XCTFail("Stream should complete before many iterations")
                    break
                }
            }
            expectation.fulfill()
        }
        
        // Deinitialize service
        sut = nil
        
        // Give stream time to complete
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1s
        
        await fulfillment(of: [expectation], timeout: 2.0)
        task.cancel()
    }
    
    // Test 1.4: currentUser property returns cached user on cold start
    func test_currentUser_returnsCachedUserOnColdStart() async throws {
        let mockUser = MockUser(uid: "456", email: "cached@example.com", displayName: "John")
        mockAuth.currentUser = mockUser
        
        let authService = FirebaseAuthService(
            firebaseAuth: mockAuth,
            userDefaults: mockUserDefaults
        )
        
        let user = await authService.currentUser
        
        XCTAssertNotNil(user)
        XCTAssertEqual(user?.id, "456")
        XCTAssertEqual(user?.displayName, "John")
    }
}