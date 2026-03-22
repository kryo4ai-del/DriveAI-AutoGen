import Foundation

struct ReadinessIndicator: Sendable, Equatable {
    enum Status: Sendable, Equatable {
        case notStarted    // No completions
        case notReady      // Score < 70% OR completions < threshold
        case almostReady   // Score 70-84% OR close to target sessions
        case ready         // Score ≥ 85% AND completions ≥ 3
        
        var priority: Int {
            switch self {
            case .ready: return 0        // Sort first
            case .almostReady: return 1
            case .notReady: return 2
            case .notStarted: return 3   // Sort last
            }
        }
    }
    
    let exerciseId: UUID
    let status: Status
    let completionPercentage: Double     // 0-100
    let sessionsRemaining: Int
    let recommendedNextStep: String
    let confidenceScore: Double          // 0-100
    
    var trafficLightEmoji: String {
        switch status {
        case .ready: return "🟢"
        case .almostReady: return "🟡"
        case .notReady, .notStarted: return "🔴"
        }
    }
}