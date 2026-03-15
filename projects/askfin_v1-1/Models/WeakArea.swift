import Foundation
import SwiftUI

struct WeakArea: Identifiable, Codable {
    let id: UUID
    let categoryId: String
    let categoryName: String
    let score: Double
    let questionsAnswered: Int
    let correctAnswers: Int
    let priority: Priority
    
    enum Priority: String, Codable, Comparable {
        case critical = "CRITICAL"
        case high = "HIGH"
        case medium = "MEDIUM"
        
        static func < (lhs: Priority, rhs: Priority) -> Bool {
            let order: [Priority] = [.critical, .high, .medium]
            return order.firstIndex(of: lhs)! < order.firstIndex(of: rhs)!
        }
        
        var badgeColor: Color {
            switch self {
            case .critical: return .red
            case .high: return .orange
            case .medium: return .yellow
            }
        }
        
        var emoji: String {
            switch self {
            case .critical: return "🔴"
            case .high: return "🟠"
            case .medium: return "🟡"
            }
        }
        
        var accessibilityLabel: String {
            switch self {
            case .critical: return "Critical priority"
            case .high: return "High priority"
            case .medium: return "Medium priority"
            }
        }
    }
    
    var weaknessPercentage: Double {
        100 - score
    }
    
    var recommendedPracticeQuestions: Int {
        switch priority {
        case .critical:
            return ReadinessConfig.WeakAreaRecommendations.criticalQuestions
        case .high:
            return ReadinessConfig.WeakAreaRecommendations.highQuestions
        case .medium:
            return ReadinessConfig.WeakAreaRecommendations.mediumQuestions
        }
    }
    
    var estimatedStudyMinutes: Int {
        recommendedPracticeQuestions * ReadinessConfig.WeakAreaRecommendations.minutesPerQuestion
    }
}

struct PrepRecommendation: Identifiable, Codable {
    let id: UUID
    let weakAreaId: UUID
    let categoryId: String
    let suggestedQuestions: Int
    let estimatedMinutes: Int
    let priority: WeakArea.Priority
    let actionText: String
}