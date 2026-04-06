// Domain/Domains/UserProgressDomain.swift

import Foundation

struct ReviewPrompt {
    let categoryID: String
    let categoryName: String
    let daysSinceReview: Int
    let priority: ReviewPriority
}

enum ReviewPriority: Comparable {
    case low
    case medium
    case high
    case critical
    
    var daysUntilDue: Int {
        switch self {
        case .low: return 30
        case .medium: return 14
        case .high: return 7
        case .critical: return 3
        }
    }
}
