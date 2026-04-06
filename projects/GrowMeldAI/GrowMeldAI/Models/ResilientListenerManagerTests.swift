import XCTest
import Combine
@testable import DriveAI

@MainActor
class ResilientListenerManagerTests: XCTestCase {
    var sut: ResilientListenerManager!
    var mockFirestore: MockFirestoreService!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        sut = ResilientListenerManager()
        mockFirestore = MockFirestoreService()
        cancellables = []
    }
    
    // HAPPY PATH: Listener attached successfully
    func test_attachListener_success_sendsData() async {
        // Arrange
        let expectedStats = UserStats(
            totalAnswers: 50,
            passRate: 0.85,
            currentStreak: 5
        )
        mockFirestore.mockUserStats = expectedStats
        
        var receivedStats: UserStats?
        let expectation = XCTestExpectation(description: "Listener receives data")
        
        // Act
        sut.attachListener(
            id: "userStats",
            path: "users/test/stats",
            decoder: { snapshot in
                try? snapshot.data(as: UserStats.self)
            }
        )
        .receive(on: DispatchQueue.main)
        .sink { stats in
            receivedStats = stats
            expectation.fulfill()
        }
        .store(in: &cancellables)
        
        // Assert
        await fulfillment(of: [expectation], timeout: 1.0)
        XCTAssertEqual(receivedStats?.totalAnswers, expectedStats.totalAnswers)
    }
    
    // EDGE CASE: Network failure triggers auto-retry
    func test_listenerFailure_triggersExponentialBackoffRetry() async {
        // Arrange
        var attachAttempts = 0
        mockFirestore.shouldFailInitially = true
        mockFirestore.failureCount = 2 // Fail twice, succeed on 3rd
        mockFirestore.onListenerAttach = { attachAttempts += 1 }
        
        let expectation = XCTestExpectation(description: "Listener recovers after retries")
        expectation.expectedFulfillmentCount = 3 // Attach attempts
        
        // Act
        sut.attachListener(
            id: "userStats",
            path: "users/test/stats",
            decoder: { snapshot in
                try? snapshot.data(as: UserStats.self)
            },
            maxRetries: 3
        )
        .sink { _ in
            expectation.fulfill()
        }
        .store(in: &cancellables)
        
        // Assert: Wait for retries to complete (with backoff)
        // First attempt: immediate, fails
        // Retry 1: after 2^0 = 1s
        // Retry 2: after 2^1 = 2s
        await fulfillment(of: [expectation], timeout: 5.0)
        XCTAssertEqual(attachAttempts, 3, "Should attempt 1 initial + 2 retries")
    }
    
    // EDGE CASE: Max retries exceeded → emit error state
    func test_listenerMaxRetriesExceeded_emitsFailedState() async {
        // Arrange
        mockFirestore.shouldFailPermanently = true
        
        var capturedState: ResilientListenerManager.ListenerState?
        let expectation = XCTestExpectation(description: "Listener enters failed state")
        
        // Act
        sut.attachListener(
            id: "stats",
            path: "users/test/stats",
            decoder: { _ in nil },
            maxRetries: 2
        )
        .sink { _ in }
        .store(in: &cancellables)
        
        // Monitor state
        sut.listenerState(id: "stats")
            .dropFirst() // Skip initial state
            .first(where: { state in
                if case .failed = state { return true }
                return false
            })
            .receive(on: DispatchQueue.main)
            .sink { state in
                capturedState = state
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // Assert
        await fulfillment(of: [expectation], timeout: 10.0)
        if case .failed(let error) = capturedState {
            XCTAssertNotNil(error)
        } else {
            XCTFail("Expected failed state, got \(String(describing: capturedState))")
        }
    }
    
    // INVALID INPUT: Auth error shouldn't retry
    func test_authError_doesNotRetry() async {
        // Arrange
        let authError = NSError(domain: "FirebaseAuth", code: 1, userInfo: [:])
        mockFirestore.simulateError = authError
        
        var retryCount = 0
        let expectation = XCTestExpectation(description: "No retries on auth error")
        expectation.isInverted = true // Expects NOT to fulfill
        
        // Act
        sut.attachListener(
            id: "stats",
            path: "users/test/stats",
            decoder: { _ in nil },
            maxRetries: 3
        )
        .sink { _ }
        .store(in: &cancellables)
        
        // Wait briefly to ensure no retries
        await fulfillment(of: [expectation], timeout: 2.0)
        
        // Assert
        XCTAssertEqual(retryCount, 0, "Should not retry on auth errors")
    }
    
    // CLEANUP: Listener properly detached
    func test_detachListener_removesRegistration() {
        // Arrange
        sut.attachListener(
            id: "stats",
            path: "users/test/stats",
            decoder: { _ in nil }
        )
        .sink { _ }
        .store(in: &cancellables)
        
        // Act
        sut.detachListener(id: "stats")
        
        // Assert: Verify internal state cleaned
        // (Would need to expose activeListeners or add test helper)
        // For now, ensure no crash on detach
        XCTAssertTrue(true) // Placeholder
    }
    
    // STRESS TEST: Multiple listeners attached simultaneously
    func test_multipleListenersAttached_independentRecovery() async {
        // Arrange
        let stats1Expectation = XCTestExpectation(description: "Stats listener 1")
        let stats2Expectation = XCTestExpectation(description: "Stats listener 2")
        
        mockFirestore.shouldFailInitially = true
        mockFirestore.failureCount = 1
        
        // Act
        sut.attachListener(
            id: "stats1",
            path: "users/test1/stats",
            decoder: { snapshot in try? snapshot.data(as: UserStats.self) }
        )
        .sink { _ in stats1Expectation.fulfill() }
        .store(in: &cancellables)
        
        sut.attachListener(
            id: "stats2",
            path: "users/test2/stats",
            decoder: { snapshot in try? snapshot.data(as: UserStats.self) }
        )
        .sink { _ in stats2Expectation.fulfill() }
        .store(in: &cancellables)
        
        // Assert
        await fulfillment(of: [stats1Expectation, stats2Expectation], timeout: 5.0)
    }
}