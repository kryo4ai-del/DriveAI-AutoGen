// Models/Domain/StreakData.swift
struct StreakData {
    var currentStreak: Int
    var longestStreak: Int
    mutating func recordPracticeSession() { /* ... */ }
}

// Models/User/UserProfile.swift

// Services/ProgressTrackingService.swift
func calculateStreak(from dailyAnswers: [Date]) -> (current: Int, longest: Int) {
    // ❌ Third implementation of streak logic!
}