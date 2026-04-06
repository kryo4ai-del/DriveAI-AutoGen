struct RetryPolicy: Sendable {
    // ... existing code ...
    
    func delay(for attempt: Int) -> Duration {
        let ms = delayMs(for: attempt)
        return .milliseconds(Int(ms))
    }
}

// Usage:
try await Task.sleep(for: retryPolicy.delay(for: attempt))  // More readable