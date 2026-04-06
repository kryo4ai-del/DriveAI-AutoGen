struct PerformanceMetrics {
    var currentStreak: Int = 0
    var lastAttemptDate: Date?
    var streakFrozenUntilDate: Date?  // Grace period
    
    mutating func recordAttempt(correct: Bool) {
        let daysSinceLastAttempt = Calendar.current.dateComponents(
            [.day],
            from: lastAttemptDate ?? Date(distantPast: ),
            to: Date()
        ).day ?? 0
        
        // If > 1 day passed, streak resets unless within grace period
        if daysSinceLastAttempt > 1 && Date() > (streakFrozenUntilDate ?? .distantPast) {
            currentStreak = 0
        }
        
        if correct {
            correctAnswers += 1
            currentStreak += 1
            longestStreak = max(longestStreak, currentStreak)
        } else {
            // Missed question — freeze streak for 24 hours (user can recover tomorrow)
            streakFrozenUntilDate = Date().addingTimeInterval(86400)
        }
        lastAttemptDate = Date()
    }
}