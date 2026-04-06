import Foundation

// MARK: - Feedback Enumerations

enum FeedbackType: String, Codable {
    case quickReaction = "quick_reaction"
    case detailedForm = "detailed_form"
}

enum FeedbackCategory: String, Codable, CaseIterable {
    case contentAccuracy = "content_accuracy"
    case safetyConcern = "safety_concern"
    case regulatoryMismatch = "regulatory_mismatch"
    case quizDifficulty = "quiz_difficulty"
    case uiClarity = "ui_clarity"
    case featureRequest = "feature_request"
    case examRelevance = "exam_relevance"
    case other = "other"
    
    var localizedName: String {
        switch self {
        case .contentAccuracy:
            return "Inhaltliche Genauigkeit"
        case .safetyConcern:
            return "Sicherheitsbedenken"
        case .regulatoryMismatch:
            return "Behördliche Abweichung"
        case .quizDifficulty:
            return "Quiz-Schwierigkeit"
        case .uiClarity:
            return "UI-Klarheit"
        case .featureRequest:
            return "Funktionsanforderung"
        case .examRelevance:
            return "Prüfungsrelevanz"
        case .other:
            return "Sonstiges"
        }
    }
    
    var requiresEscalation: Bool {
        [.contentAccuracy, .safetyConcern, .regulatoryMismatch].contains(self)
    }
}

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