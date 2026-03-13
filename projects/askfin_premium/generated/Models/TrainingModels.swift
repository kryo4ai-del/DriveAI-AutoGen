import Foundation

// NOTE: TopicArea, CompetenceLevel, TopicCompetence, SessionQuestion, and QuestionType
// are each defined in their own dedicated files under Models/.
// Only unique Training Mode types remain here.

// MARK: - Spacing Item (spaced repetition queue)
struct SpacingItem: Identifiable, Codable {
    let id: String
    let topic: TopicArea
    var consecutiveCorrect: Int = 0
    var nextReviewDate: Date
    var reviewCount: Int = 0
    
    /// Interval thresholds: wrong → 1 day, then 3, 7, 14, 30
    static func nextInterval(after correctCount: Int) -> Int {
        switch correctCount {
        case 0: return 1    // 1 day after wrong answer
        case 1: return 3    // 3 days after 1 correct
        case 2: return 7    // 7 days
        case 3: return 14   // 14 days
        default: return 30  // 30 days (mastered)
        }
    }
}

// MARK: - Training Session
struct TrainingSession: Identifiable, Codable {
    let id: String
    let type: SessionType
    let startedAt: Date
    var endedAt: Date?
    let questionIds: [String]
    var userAnswers: [Int] = [] // indices of selected options
    
    enum SessionType: String, Codable {
        case dailyChallenge = "daily_challenge"
        case topicFocus = "topic_focus"
        case weakAreaReview = "weak_review"
        case fullSimulation = "full_sim"
    }
}