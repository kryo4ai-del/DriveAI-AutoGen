import XCTest
@testable import DriveAI

final class ResilienceErrorTests: XCTestCase {
    
    // MARK: - Network Failure Tests
    
    func testNetworkConnectionLostError() {
        let error = ResilienceError.network(.connectionLost)
        
        XCTAssertEqual(error.errorDescription, "Netzwerkfehler: Verbindung verloren")
        XCTAssertNotNil(error.recoverySuggestion)
        
        if case .retryWithBackoff(let maxAttempts, _) = error.recoveryStrategy {
            XCTAssertGreaterThan(maxAttempts, 0)
        } else {
            XCTFail("Should have retry strategy")
        }
    }
    
    func testNetworkTimeoutError() {
        let error = ResilienceError.network(.timeout(seconds: 30))
        
        XCTAssertTrue(error.errorDescription?.contains("Zeitüberschreitung") ?? false)
        XCTAssertTrue(error.recoveryStrategy.shouldRetry)
    }
    
    func testServerError5xxShouldRetry() {
        let error = ResilienceError.network(.serverError(statusCode: 503))
        
        XCTAssertTrue(error.recoveryStrategy.shouldRetry)
        if case .retryWithBackoff(let maxAttempts, let initialDelayMs) = error.recoveryStrategy {
            XCTAssertEqual(maxAttempts, 3)
            XCTAssertEqual(initialDelayMs, 2000)
        }
    }
    
    func testServerError4xxShouldNotRetry() {
        let error = ResilienceError.network(.serverError(statusCode: 401))
        
        XCTAssertFalse(error.recoveryStrategy.shouldRetry)
    }
    
    func testOfflineDataStaleError() {
        let staleDate = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        let error = ResilienceError.offline(.cachedDataStale(lastUpdated: staleDate))
        
        XCTAssertTrue(error.errorDescription?.contains("Cache") ?? false)
        XCTAssertEqual(error.recoveryStrategy, .allowOfflineWithWarning)
    }
    
    func testSyncConflictError() {
        let error = ResilienceError.sync(.conflictDetected(resourceId: "q123"))
        
        XCTAssertTrue(error.errorDescription?.contains("Konflikt") ?? false)
        XCTAssertEqual(error.recoveryStrategy, .requireUserDecision)
    }
    
    // MARK: - Equatable Conformance
    
    func testErrorEquality() {
        let error1 = ResilienceError.network(.connectionLost)
        let error2 = ResilienceError.network(.connectionLost)
        let error3 = ResilienceError.network(.dnsFailure)
        
        XCTAssertEqual(error1, error2)
        XCTAssertNotEqual(error1, error3)
    }
    
    func testErrorTypesDifferent() {
        let networkError = ResilienceError.network(.connectionLost)
        let syncError = ResilienceError.sync(.conflictDetected(resourceId: "q1"))
        let offlineError = ResilienceError.offline(.insufficientLocalStorage)
        
        XCTAssertNotEqual(networkError, syncError)
        XCTAssertNotEqual(syncError, offlineError)
    }
}

// MARK: - Recovery Strategy Tests

final class ResiliencyStrategyTests: XCTestCase {
    
    func testRetryBackoffDelayCalculation() {
        let strategy = ResiliencyStrategy.retryWithBackoff(maxAttempts: 5, initialDelayMs: 1000)
        
        let delay1 = strategy.delayForAttempt(1)
        let delay2 = strategy.delayForAttempt(2)
        let delay3 = strategy.delayForAttempt(3)
        
        // Exponential growth (with jitter)
        XCTAssertGreaterThan(delay2, delay1)
        XCTAssertGreaterThan(delay3, delay2)
        
        // Should not exceed reasonable bounds
        XCTAssertLessThan(delay3, 10.0) // < 10 seconds
    }
    
    func testMaxAttemptsThreshold() {
        let strategy = ResiliencyStrategy.retryWithBackoff(maxAttempts: 3, initialDelayMs: 100)
        
        XCTAssertEqual(strategy.maxAttempts, 3)
        
        // Attempt > max should cap at max
        let delayAtMax = strategy.delayForAttempt(10)
        let delayAtThreshold = strategy.delayForAttempt(3)
        
        XCTAssertEqual(delayAtMax, delayAtThreshold)
    }
    
    func testQueueForSyncStrategy() {
        let strategy = ResiliencyStrategy.queueForSync(priority: .high)
        
        XCTAssertFalse(strategy.shouldRetry)
    }
}

// MARK: - Sync Policy Tests

final class SyncPolicyTests: XCTestCase {
    
    func testDefaultPolicy() {
        let policy = SyncPolicy.default
        
        XCTAssertEqual(policy.priority, .normal)
        XCTAssertEqual(policy.maxRetries, 3)
        XCTAssertEqual(policy.timeoutSeconds, 30)
        XCTAssertTrue(policy.allowOfflineQueueing)
    }
    
    func testHighPriorityPolicy() {
        let policy = SyncPolicy.highPriority
        
        XCTAssertEqual(policy.priority, .high)
        XCTAssertGreaterThan(policy.maxRetries, SyncPolicy.default.maxRetries)
        XCTAssertEqual(policy.timeoutSeconds, 60)
    }
    
    func testLowPriorityPolicy() {
        let policy = SyncPolicy.lowPriority
        
        XCTAssertEqual(policy.priority, .low)
        XCTAssertLessThan(policy.maxRetries, SyncPolicy.default.maxRetries)
    }
    
    func testDelayCalculationLinear() {
        let policy = SyncPolicy(
            priority: .normal,
            maxRetries: 3,
            backoffStrategy: .linear(baseMs: 500),
            timeoutSeconds: 30,
            allowOfflineQueueing: true
        )
        
        let delay1 = policy.delayForAttempt(1)
        let delay2 = policy.delayForAttempt(2)
        let delay3 = policy.delayForAttempt(3)
        
        XCTAssertGreaterThan(delay2, delay1)
        XCTAssertGreaterThan(delay3, delay2)
        
        // Linear should grow proportionally
        XCTAssertLessThan(delay3 - delay2, delay2 - delay1 + 0.1) // Allow small variance
    }
    
    func testDelayCalculationExponential() {
        let policy = SyncPolicy(
            priority: .normal,
            maxRetries: 5,
            backoffStrategy: .exponential(baseMs: 100),
            timeoutSeconds: 30,
            allowOfflineQueueing: true
        )
        
        let delay1 = policy.delayForAttempt(1)
        let delay2 = policy.delayForAttempt(2)
        let delay3 = policy.delayForAttempt(3)
        
        // Exponential growth should be significant
        XCTAssertGreaterThan(delay2, delay1 * 1.5)
        XCTAssertGreaterThan(delay3, delay2 * 1.5)
    }
    
    func testImmediateBackoffStrategy() {
        let policy = SyncPolicy(
            priority: .normal,
            maxRetries: 3,
            backoffStrategy: .immediate,
            timeoutSeconds: 30,
            allowOfflineQueueing: true
        )
        
        for attempt in 1...3 {
            let delay = policy.delayForAttempt(attempt)
            XCTAssertEqual(delay, 0, "Immediate strategy should have no delay")
        }
    }
    
    func testSyncPriorityOrdering() {
        XCTAssertLessThan(SyncPriority.low, SyncPriority.normal)
        XCTAssertLessThan(SyncPriority.normal, SyncPriority.high)
        XCTAssertLessThan(SyncPriority.high, SyncPriority.critical)
    }
}