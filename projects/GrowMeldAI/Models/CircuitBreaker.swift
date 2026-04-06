@MainActor
final class CircuitBreaker {
    enum State {
        case closed      // Normal operation
        case open        // Failing, reject requests
        case halfOpen    // Testing recovery
    }
    
    private(set) var state: State = .closed
    private var failureCount = 0
    private var successCount = 0
    private var lastFailureTime: Date?
    
    private let failureThreshold: Int
    private let successThreshold: Int
    private let resetTimeout: TimeInterval
    private let cache: NSCache<NSString, NSArray>
    
    init(failureThreshold: Int = 5, successThreshold: Int = 2, resetTimeout: TimeInterval = 60) {
        self.failureThreshold = failureThreshold
        self.successThreshold = successThreshold
        self.resetTimeout = resetTimeout
        self.cache = NSCache()
    }
    
    func execute<T>(cacheKey: String? = nil, _ block: () async throws -> [T]) async throws -> [T] {
        switch state {
        case .closed:
            do {
                let result = try await block()
                if let key = cacheKey {
                    cache.setObject(result as NSArray, forKey: key as NSString)
                }
                failureCount = 0
                return result
            } catch {
                failureCount += 1
                if failureCount >= failureThreshold {
                    state = .open
                    lastFailureTime = Date()
                    IAPLogger.error("Circuit breaker opened after \(failureCount) failures")
                }
                
                // Try to return cached data
                if let key = cacheKey, let cached = cache.object(forKey: key as NSString) as? [T] {
                    IAPLogger.warning("Returning cached data due to error: \(error)")
                    return cached
                }
                throw error
            }
            
        case .open:
            // Check if enough time has passed to try recovery
            if let lastFailure = lastFailureTime,
               Date().timeIntervalSince(lastFailure) > resetTimeout {
                state = .halfOpen
                successCount = 0
                IAPLogger.info("Circuit breaker entering half-open state")
                return try await execute(cacheKey: cacheKey, block)
            }
            
            // Still open, return cached or fail
            if let key = cacheKey, let cached = cache.object(forKey: key as NSString) as? [T] {
                return cached
            }
            throw IAPError.circuitBreakerOpen
            
        case .halfOpen:
            do {
                let result = try await block()
                successCount += 1
                if successCount >= successThreshold {
                    state = .closed
                    failureCount = 0
                    IAPLogger.info("Circuit breaker closed, recovered from failure")
                }
                return result
            } catch {
                state = .open
                lastFailureTime = Date()
                failureCount = 0
                IAPLogger.error("Recovery attempt failed, circuit breaker reopened")
                throw error
            }
        }
    }
}