// Extend OfflineError enum with explicit recovery paths
enum OfflineError: LocalizedError {
    case networkUnavailable(duration: TimeInterval?)
    case syncConflict(attemptCount: Int, lastAttempt: Date)
    case dataCorruption(affectedRecords: Int)
    case examModeUnavailable(reason: String)
    
    var recoveryStrategy: RecoveryStrategy {
        switch self {
        case .networkUnavailable:
            return .offerOfflineMode
        case .syncConflict:
            return .requireUserDecision  // Keep existing logic
        case .dataCorruption:
            return .requestDataRefresh
        case .examModeUnavailable:
            return .blockExamMode
        }
    }
}

enum RecoveryStrategy {
    case offerOfflineMode          // Use cached questions
    case requireUserDecision       // Present options
    case requestDataRefresh        // Retry sync
    case blockExamMode             // Disable exam until online
    case fallbackToLegacy          // Use bundled questions
}