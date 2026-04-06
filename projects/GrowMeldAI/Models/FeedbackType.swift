import Foundation

// MARK: - Feedback Enumerations

enum FeedbackType: String, Codable {
    case quickReaction = "quick_reaction"
    case detailedForm = "detailed_form"
}

// Enum FeedbackCategory declared in Models/FeedbackCategory.swift

enum FeedbackSeverity: String, Codable {
    case low = "low"
    case medium = "medium"
    case high = "high"           // 48-hour SLA
    case critical = "critical"   // Immediate escalation
}

// MARK: - User Feedback Model (GDPR-Compliant)

// MARK: - Quick Reaction (Lightweight Feedback)

struct QuickReactionFeedback: Codable {
    enum ReactionType: String, Codable {
        case helpful = "helpful"
        case tooHard = "too_hard"
        case unclear = "unclear"
        
        var emoji: String {
            switch self {
            case .helpful:
                return "👍"
            case .tooHard:
                return "😰"
            case .unclear:
                return "🤔"
            }
        }
        
        var label: String {
            switch self {
            case .helpful:
                return "Hilfreich"
            case .tooHard:
                return "Zu schwer"
            case .unclear:
                return "Unklar"
            }
        }
    }
    
    let type: ReactionType
    let questionID: UUID
    let consentGiven: Bool
}

// MARK: - Queue Status

enum OfflineQueueStatus: Equatable {
    case synced
    case syncing
    case hasPending(count: Int)
    case failedSync(count: Int)
    case error(String)
}