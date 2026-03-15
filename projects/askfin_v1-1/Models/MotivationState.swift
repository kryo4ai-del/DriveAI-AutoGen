struct MotivationState {
    var currentStreak: Int // days of consecutive practice
    var lastPracticeDate: Date
    var dailyGoalMinutes: Int
    var todayMinutesSpent: Int
}

// [FK-019 sanitized] func checkStreakMilestone() -> StreakMilestone? // returns badge (7, 14, 30 days)
// [FK-019 sanitized] func getDailyGoalProgress() -> Double // 0–1
// [FK-019 sanitized] func generateMotivationalMessage() -> String // context-aware German text