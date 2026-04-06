// Models/TrialProgress.swift (FIXED)
import Foundation

struct TrialProgress: Codable, Equatable {
    var questionsAnswered: Int = 0
    var correctAnswers: Int = 0
    var categoriesUnlocked: [String] = []
    var lastActivityDate: Date?
    var learnedStreak: Int = 0
    
    // Track which UTC day we counted questions for (Issue #2)
    private var questionsCountedForDateUTC: Date?
    private(set) var questionsAnsweredToday: Int = 0
    
    /// Record a question answer.
    /// Does NOT modify streak—call `updateDailyStreak()` separately.
    mutating func recordQuestion(categoryId: String, isCorrect: Bool) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Reset daily counter if it's a new day (in UTC)
        if let countedDate = questionsCountedForDateUTC,
           calendar.dateComponents([.day], from: countedDate, to: today).day ?? 0 > 0 {
            questionsAnsweredToday = 0
        }
        
        questionsAnswered += 1
        if isCorrect { correctAnswers += 1 }
        questionsAnsweredToday += 1
        questionsCountedForDateUTC = today
        
        if !categoriesUnlocked.contains(categoryId) {
            categoriesUnlocked.append(categoryId)
        }
        lastActivityDate = Date()
    }
    
    /// Update the learning streak based on consecutive days of activity.
    /// Call this once per app session (e.g., in AppDelegate or SceneDelegate).
    mutating func updateDailyStreak() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        guard let lastDate = lastActivityDate else {
            // Never tracked before
            learnedStreak = 0
            return
        }
        
        let lastDay = calendar.startOfDay(for: lastDate)
        let daysDifference = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0
        
        switch daysDifference {
        case 0:
            // Same day—no change to streak
            return
        case 1:
            // Consecutive day—increment
            learnedStreak += 1
        default:
            // Gap of 2+ days—reset streak to 0
            // Will restart to 1 on next `initializeStreakForNewDay()`
            learnedStreak = 0
        }
    }
    
    /// Initialize or restart streak when first activity happens on a new day.
    /// Call this before the first `recordQuestion()` of the day.
    mutating func initializeStreakForNewDay() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        guard let lastDate = lastActivityDate else {
            // First ever activity
            learnedStreak = 1
            return
        }
        
        let lastDay = calendar.startOfDay(for: lastDate)
        let daysDifference = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0
        
        switch daysDifference {
        case 0:
            // Same day—streak already initialized
            return
        case 1:
            // Consecutive day—will be incremented by updateDailyStreak()
            return
        default:
            // Gap exists—restarting streak
            learnedStreak = 1
        }
    }
    
    var successRate: Double {
        guard questionsAnswered > 0 else { return 0 }
        return Double(correctAnswers) / Double(questionsAnswered)
    }
}