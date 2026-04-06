// Features/Auth/Application/Tests/AuthViewModelTests.swift

import XCTest
@testable import DriveAI

@MainActor
final class AuthViewModelTests: XCTestCase {
    var sut: AuthViewModel!
    var mockAuthUseCase: MockAuthUseCase!
    var mockUserUseCase: MockUserUseCase!
    
    override func setUp() {
        super.setUp()
        mockAuthUseCase = MockAuthUseCase()
        mockUserUseCase = MockUserUseCase()
        sut = AuthViewModel(
            authUseCase: mockAuthUseCase,
            userUseCase: mockUserUseCase
        )
    }
    
    override func tearDown() {
        sut = nil
        mockAuthUseCase = nil
        mockUserUseCase = nil
        super.tearDown()
    }
    
    // MARK: - Happy Path
    
    func test_authStateInitiallyUnauthenticated() {
        XCTAssertEqual(sut.authState, .unauthenticated)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.errorMessage)
    }
    
    func test_observesAuthStateChanges() async {
        let testUser = AuthUser(
            id: "user-123",
            email: "test@example.com",
            createdAt: Date()
        )
        
        let stateStream = AsyncStream<AuthState> { continuation in
            continuation.yield(.authenticated(testUser))
        }
        mockAuthUseCase.authStateStreamResult = stateStream
        
        // Recreate ViewModel to observe changes
        sut = AuthViewModel(
            authUseCase: mockAuthUseCase,
            userUseCase: mockUserUseCase
        )
        
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1s for async propagation
        
        if case .authenticated(let user) = sut.authState {
            XCTAssertEqual(user.id, "user-123")
        } else {
            XCTFail("Expected authenticated state")
        }
    }
    
    func test_signOut_successClears authState() async {
        mockAuthUseCase.signOutShouldSucceed = true
        
        await sut.signOut()
        
        XCTAssertEqual(sut.authState, .unauthenticated)
        XCTAssertNil(sut.errorMessage)
        XCTAssertFalse(sut.isLoading)
    }
    
    // MARK: - Error Handling
    
    func test_signOut_failureSetsErrorMessage() async {
        mockAuthUseCase.signOutShouldSucceed = false
        mockAuthUseCase.signOutError = AuthError.unknown
        
        await sut.signOut()
        
        XCTAssertNotNil(sut.errorMessage)
        XCTAssertEqual(sut.authState, .unauthenticated)
    }
    
    // MARK: - Loading State
    
    func test_signOut_setsAndClearsLoadingState() async {
        mockAuthUseCase.signOutShouldSucceed = true
        
        let isLoadingDuringCall = false
        var capturedIsLoading = false
        
        // Capture state during async operation
        let task = Task {
            await sut.signOut()
        }
        
        try? await Task.sleep(nanoseconds: 1000) // Tiny delay to capture loading state
        capturedIsLoading = sut.isLoading
        
        await task.value
        
        XCTAssertFalse(sut.isLoading, "Loading state should be cleared after operation")
    }
    
    // MARK: - Error Clearing
    
    func test_clearError_removesErrorMessage() async {
        mockAuthUseCase.signOutShouldSucceed = false
        mockAuthUseCase.signOutError = AuthError.unknown
        
        await sut.signOut()
        XCTAssertNotNil(sut.errorMessage)
        
        sut.clearError()
        XCTAssertNil(sut.errorMessage)
    }
    
    // MARK: - Task Cancellation
    
    func test_deinit_cancelsAuthStateObserver() async {
        let testUser = AuthUser(
            id: "user-123",
            email: "test@example.com",
            createdAt: Date()
        )
        
        var vm: AuthViewModel? = AuthViewModel(
            authUseCase: mockAuthUseCase,
            userUseCase: mockUserUseCase
        )
        
        let initialTask = vm?.authStateTask
        vm = nil
        
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        XCTAssertTrue(initialTask?.isCancelled ?? false, "Task should be cancelled on deinit")
    }
}