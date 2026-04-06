import Foundation

/// Tracks learning speed and consistency metrics
struct LearningVelocity: Codable, Sendable {
    let timestamp: Date
    let questionsAnsweredToday: Int
    let questionsAnsweredThisWeek: Int
    let questionsAnsweredThisMonth: Int
    let currentStreak: Int
    let longestStreak: Int
    let averageTimePerQuestion: TimeInterval
    
    // Computed properties
    var dailyVelocity: Double {
        guard questionsAnsweredThisWeek > 0 else { return 0 }
        return Double(questionsAnsweredThisWeek) / 7.0
    }
    
    var velocityTrend: VelocityTrend {
        if dailyVelocity > 8 { return .accelerating }
        if dailyVelocity > 5 { return .steady }
        if dailyVelocity > 2 { return .slow }
        return .inactive
    }
    
    var isStreakActive: Bool {
        currentStreak > 0
    }
}

enum VelocityTrend: String, Codable, Sendable {
    case accelerating = "accelerating"
    case steady = "steady"
    case slow = "slow"
    case inactive = "inactive"
}