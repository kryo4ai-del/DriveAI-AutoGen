import Foundation

/// Wraps feedback with retry metadata for offline queue
struct FeedbackQueueItem: Identifiable, Codable {
    let id: UUID
    var feedback: UserFeedback
    var retryCount: Int = 0
    var lastRetryTime: Date?
    var nextRetryTime: Date?
    
    enum Status: String, Codable {
        case pending = "pending"
        case syncing = "syncing"
        case synced = "synced"
        case failed = "failed"
    }
    
    var status: Status {
        if feedback.isSynced {
            return .synced
        } else if retryCount > 3 {
            return .failed
        } else {
            return .pending
        }
    }
    
    init(feedback: UserFeedback) {
        self.id = feedback.id
        self.feedback = feedback
        self.retryCount = 0
        self.lastRetryTime = nil
        self.nextRetryTime = nil
    }
    
    /// Calculate exponential backoff for retry
    mutating func scheduleNextRetry() {
        let baseDelay: TimeInterval = 5  // 5 seconds
        let delayMultiplier = pow(2.0, Double(retryCount))
        let randomJitter = Double.random(in: 0...1000) / 1000.0
        let delay = baseDelay * delayMultiplier + randomJitter
        
        nextRetryTime = Date(timeIntervalSinceNow: delay)
        retryCount += 1
    }
}