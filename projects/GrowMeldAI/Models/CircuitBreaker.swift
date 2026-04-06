import Foundation

@MainActor
final class CircuitBreaker {
    enum State {
        case closed
        case open
        case halfOpen
    }

    private(set) var state: State = .closed
    private var failureCount = 0
    private var successCount = 0
    private var lastFailureTime: Date?

    private let failureThreshold: Int
    private let successThreshold: Int
    private let resetTimeout: TimeInterval
    private var cache: [String: Any] = [:]

    init(failureThreshold: Int = 5, successThreshold: Int = 2, resetTimeout: TimeInterval = 60) {
        self.failureThreshold = failureThreshold
        self.successThreshold = successThreshold
        self.resetTimeout = resetTimeout
    }

    func execute<T>(cacheKey: String? = nil, _ block: () async throws -> [T]) async throws -> [T] {
        switch state {
        case .closed:
            do {
                let result = try await block()
                if let key = cacheKey {
                    cache[key] = result
                }
                failureCount = 0
                return result
            } catch {
                failureCount += 1
                if failureCount >= failureThreshold {
                    state = .open
                    lastFailureTime = Date()
                }
                if let key = cacheKey, let cached = cache[key] as? [T] {
                    return cached
                }
                throw error
            }

        case .open:
            if let lastFailure = lastFailureTime,
               Date().timeIntervalSince(lastFailure) > resetTimeout {
                state = .halfOpen
                successCount = 0
                return try await execute(cacheKey: cacheKey, block)
            }
            if let key = cacheKey, let cached = cache[key] as? [T] {
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
                }
                return result
            } catch {
                state = .open
                lastFailureTime = Date()
                failureCount = 0
                throw error
            }
        }
    }
}