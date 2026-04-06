// File: Services/RetryPolicy.swift (modification)

protocol RetryObserver {
    func retryWillAttempt(_ attempt: Int, of maxAttempts: Int)
    func retryWillWait(for nanoseconds: UInt64)
    func retryDidExhaust()
}

func withRetry<T>(
    policy: RetryPolicy = .default,
    shouldRetry: ((Error) -> Bool)? = nil,
    observer: RetryObserver? = nil,
    operation: () async throws -> T
) async throws -> T {
    let defaultShouldRetry: (Error) -> Bool = { error in
        if let cloudError = error as? CloudFunctionError {
            return cloudError.isRetryable
        }
        if let urlError = error as? URLError {
            return [.timedOut, .networkConnectionLost, .notConnectedToInternet]
                .contains(urlError.code)
        }
        return false
    }
    
    let retryCheck = shouldRetry ?? defaultShouldRetry
    var lastError: Error?
    
    for attempt in 1...policy.maxAttempts {
        do {
            return try await operation()
        } catch {
            lastError = error
            
            guard attempt < policy.maxAttempts && retryCheck(error) else {
                observer?.retryDidExhaust()
                throw error
            }
            
            observer?.retryWillAttempt(attempt, of: policy.maxAttempts)
            
            let delay = policy.delay(for: attempt)
            observer?.retryWillWait(for: delay)
            
            try await Task.sleep(nanoseconds: delay)
        }
    }
    
    throw lastError ?? CloudFunctionError.unknown("Max retries exceeded")
}