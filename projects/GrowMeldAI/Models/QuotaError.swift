import Foundation

enum QuotaError: LocalizedError {
    case quotaExceeded(remainingToday: Int)
    case persistenceFailure(String)
    case trialExpired
    
    var errorDescription: String? {
        switch self {
        case .quotaExceeded:
            return "Tägliches Limit erreicht"
        case .persistenceFailure(let msg):
            return "Speicherfehler: \(msg)"
        case .trialExpired:
            return "Testversion abgelaufen. Premium aktivieren?"
        }
    }
}

/// Thread-safe quota manager using actor isolation
@MainActor
class QuotaManager {
}