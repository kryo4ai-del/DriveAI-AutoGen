import Foundation

/// Status of an AI service
enum AIServiceStatus: String, Sendable, Codable {
    case healthy
    case degraded
    case unavailable
    case unknown
}

/// Snapshot of AI service health at a point in time
struct AIHealthSnapshot: Sendable {
    let status: AIServiceStatus
    let timestamp: Date
    let responseTime: TimeInterval?
    let cacheHitRate: Double
    let consecutiveFailures: Int
    
    var isCritical: Bool {
        consecutiveFailures > 3
    }
    
    var shouldRetryCaching: Bool {
        cacheHitRate < 0.7 && consecutiveFailures < 5
    }
}