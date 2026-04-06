// NEW: SessionProgress.swift
import Foundation
struct SessionProgress: Identifiable {
    let id = UUID()
    let categoryID: String
    let questionsAnsweredInSession: Int
    let correctAnswersInSession: Int
    let sessionAccuracy: Double
    
    /// Incremental feedback every 5 questions
    var sessionFeedback: String {
        guard questionsAnsweredInSession > 0 else { return "" }
        
        switch questionsAnsweredInSession {
        case 1...5:
            let trend = correctAnswersInSession == questionsAnsweredInSession ? "📈 Perfect start!" : "🤔 Settling in..."
            return "\(trend) \(questionsAnsweredInSession)/5 answered."
        case 6...10:
            return "🔥 \(correctAnswersInSession)/\(questionsAnsweredInSession) correct. Keep the momentum!"
        case 11...15:
            return "💪 Nice consistency. \(Int(sessionAccuracy * 100))% accuracy in this session."
        default:
            return "🏆 Great session! \(questionsAnsweredInSession) questions, \(Int(sessionAccuracy * 100))% accuracy."
        }
    }
    
    /// Show how session contributes to closing the diagnostic gap
    func progressTowardGapClosure(gap: LearningGap) -> String {
        let progress = Double(correctAnswersInSession) / Double(gap.recommendedPracticeCount)
        let percentage = Int(min(progress * 100, 100))  // Cap at 100%
        return "Progress toward \(gap.category.name) mastery: \(percentage)%"
    }
}