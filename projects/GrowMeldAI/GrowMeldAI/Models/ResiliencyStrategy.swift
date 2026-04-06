// File: Domain/Models/ResiliencyStrategy.swift
import Foundation

/// Defines how the app should respond to a given error
enum ResiliencyStrategy: Equatable {
    /// Retry with exponential backoff
    case retryWithBackoff(maxAttempts: Int, initialDelayMs: Int)
    
    /// Fallback to cached data (if available)
    case fallbackToCache
    
    /// Allow offline mode with user warning
    case allowOfflineWithWarning
    
    /// Require user decision (e.g., conflict resolution)
    case requireUserDecision
    
    /// Fail immediately (no recovery)
    case fail
    
    /// Queue operation for later retry when connection restored
    case queueForSync(priority: SyncPriority)
    
    // MARK: - Computed Properties
    
    var shouldRetry: Bool {
        if case .retryWithBackoff = self { return true }
        return false
    }
    
    var maxAttempts: Int {
        if case .retryWithBackoff(let max, _) = self {
            return max
        }
        return 0
    }
    
    /// Calculate delay for retry attempt
    func delayForAttempt(_ attempt: Int) -> TimeInterval {
        guard case .retryWithBackoff(let maxAttempts, let initialDelayMs) = self else {
            return 0
        }
        
        let attempt = min(attempt, maxAttempts)
        let exponentialDelay = Double(initialDelayMs) * pow(2, Double(attempt - 1))
        let jitter = Double.random(in: 0..<(exponentialDelay * 0.1))
        
        return (exponentialDelay + jitter) / 1000.0
    }
}