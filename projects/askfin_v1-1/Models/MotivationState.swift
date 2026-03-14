struct MotivationState {
    var currentStreak: Int // days of consecutive practice
    var lastPracticeDate: Date
    var dailyGoalMinutes: Int
    var todayMinutesSpent: Int
}

func checkStreakMilestone() -> StreakMilestone? // returns badge (7, 14, 30 days)
func getDailyGoalProgress() -> Double // 0–1
func generateMotivationalMessage() -> String // context-aware German text