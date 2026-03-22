import Foundation

/// Represents a navigation destination from quick access
enum QuickAccessNavigationPath: Equatable, Hashable {
    case resumeLastQuiz
    case quickReviewWeakAreas
    case practiceTodaysChallenge
    case reviewCategory(category: String)
    case custom(exerciseID: String, mode: String)
    
    var analyticsLabel: String {
        switch self {
        case .resumeLastQuiz:
            return "resume_last_quiz"
        case .quickReviewWeakAreas:
            return "weak_areas_review"
        case .practiceTodaysChallenge:
            return "todays_challenge"
        case .reviewCategory(let cat):
            return "category_\(cat.lowercased())"
        case .custom(let id, let mode):
            return "custom_\(id)_\(mode)"
        }
    }
}