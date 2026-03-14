import Foundation

/// Aggregate user statistics across all categories.
/// Single source of truth for profile/dashboard stats.
/// Immutable value type. Thread-safe.
struct UserStatistics: Codable {
    let userId: UUID
    var totalAttempts: Int
    var totalCorrect: Int
    var categoriesStarted: Int
    var categoriesCompleted: Int  // Categories with ≥80% + ≥10 attempts
    var longestStreak: Int
    var totalStudyDays: Int  // Calendar days with ≥1 correct answer
    let firstStudyDate: Date
    var lastStudyDate: Date
    
    // MARK: - Computed Properties
    
    /// Overall correct rate across all attempts (0–100%).
    var overallCorrectRate: Double {
        guard totalAttempts > 0 else { return 0 }
        return (Double(totalCorrect) / Double(totalAttempts)) * 100
    }
    
    /// Percentage of categories completed (0–100%).
    var categoryCompletionRate: Double {
        guard categoriesStarted > 0 else { return 0 }
        return (Double(categoriesCompleted) / Double(categoriesStarted)) * 100
    }
    
    /// Days elapsed since first study session.
    var daysSinceStart: Int {
        Calendar.current.dateComponents([.day], from: firstStudyDate, to: .now).day ?? 0
    }
    
    /// Motivation score (0–100) based on engagement metrics.
    /// Composite of: streak (30 pts) + accuracy (40 pts) + completion (30 pts).
    /// Used to surface motivational UI (e.g., "You're on fire! 🔥").
    var motivationScore: Double {
        var score: Double = 0
        
        // Streak component: 1 day = 0.5 points, max 30 points
        let streakPoints = min(
            Double(longestStreak) * ProgressConfig.Motivation.streakPointsPerDay,
            ProgressConfig.Motivation.streakMaxPoints
        )
        score += streakPoints
        
        // Accuracy component: 100% = 40 points
        score += (overallCorrectRate / 100) * ProgressConfig.Motivation.accuracyMaxPoints
        
        // Completion component: 100% categories = 30 points
        score += categoryCompletionRate * ProgressConfig.Motivation.completionMaxPoints
        
        return min(score, 100)
    }
    
    /// Human-readable summary for profile header.
    /// Example: "281/342 richtig · 82% Erfolgsquote".
    var summaryText: String {
        let percentage = String(format: "%.0f", overallCorrectRate)
        return String(
            format: NSLocalizedString("stats_summary_%d_%d_%s", comment: "Overall stats"),
            totalCorrect, totalAttempts, percentage
        )
    }
    
    // MARK: - Initializers
    
    init(
        userId: UUID = UUID(),
        totalAttempts: Int = 0,
        totalCorrect: Int = 0,
        categoriesStarted: Int = 0,
        categoriesCompleted: Int = 0,
        longestStreak: Int = 0,
        totalStudyDays: Int = 1,
        firstStudyDate: Date = .now,
        lastStudyDate: Date = .now
    ) {
        // Validate invariants
        precondition(totalAttempts >= 0, "totalAttempts must be non-negative")
        precondition(totalCorrect >= 0, "totalCorrect must be non-negative")
        precondition(totalCorrect <= totalAttempts, "totalCorrect cannot exceed totalAttempts")
        precondition(categoriesCompleted <= categoriesStarted, "completed cannot exceed started")
        
        self.userId = userId
        self.totalAttempts = totalAttempts
        self.totalCorrect = totalCorrect
        self.categoriesStarted = categoriesStarted
        self.categoriesCompleted = categoriesCompleted
        self.longestStreak = longestStreak
        self.totalStudyDays = totalStudyDays
        self.firstStudyDate = firstStudyDate
        self.lastStudyDate = lastStudyDate
    }
    
    // MARK: - Mutations (Value Semantics)
    
    /// Returns updated statistics after a question is answered.
    /// - Parameters:
    ///   - correct: Whether the answer was correct.
    ///   - categoryCompleted: Whether this was the final question to complete a category.
    /// - Returns: New `UserStatistics` with incremented counters.
    func recordAttempt(correct: Bool, categoryCompleted: Bool = false) -> UserStatistics {
        var updated = self
        updated.totalAttempts += 1
        if correct {
            updated.totalCorrect += 1
        }
        if categoryCompleted {
            updated.categoriesCompleted += 1
        }
        updated.lastStudyDate = .now
        return updated
    }
    
    /// Returns updated statistics with new longest streak value.
    /// Called by `ProgressViewModel` after streak calculation.
    /// - Parameter newStreak: Longest streak value to set (if greater than current).
    /// - Returns: New `UserStatistics` with updated `longestStreak`.
    func updateLongestStreak(_ newStreak: Int) -> UserStatistics {
        var updated = self
        updated.longestStreak = max(newStreak, longestStreak)
        return updated
    }
    
    /// Returns updated statistics incrementing study day counter (if it's a new calendar day).
    /// Called by `ProgressViewModel` when first correct answer of day is recorded.
    /// - Parameter isNewDay: Whether today's date differs from `lastStudyDate`.
    /// - Returns: New `UserStatistics` with `totalStudyDays` incremented if `isNewDay == true`.
    func recordStudyDay(if isNewDay: Bool) -> UserStatistics {
        var updated = self
        if isNewDay {
            updated.totalStudyDays += 1
        }
        updated.lastStudyDate = .now
        return updated
    }
    
    /// Initializes a new user with defaults (first study date = today).
    static func newUser() -> UserStatistics {
        UserStatistics(
            userId: UUID(),
            totalStudyDays: 0,
            firstStudyDate: .now,
            lastStudyDate: .now
        )
    }
    
    // MARK: - Codable
    
    enum CodingKeys: String, CodingKey {
        case userId, totalAttempts, totalCorrect, categoriesStarted, categoriesCompleted
        case longestStreak, totalStudyDays, firstStudyDate, lastStudyDate
    }
}

// MARK: - Defaults & Preview Data

extension UserStatistics {
    /// Default empty statistics (new user).
    static let `default` = UserStatistics()
    
    /// Typical mid-progress user: 342 attempts, 82% accuracy, 5/8 categories complete, 14-day streak.
    static let preview = UserStatistics(
        userId: UUID(),
        totalAttempts: 342,
        totalCorrect: 281,
        categoriesStarted: 8,
        categoriesCompleted: 5,
        longestStreak: 14,
        totalStudyDays: 28,
        firstStudyDate: Date(timeIntervalSinceNow: -60 * 86400),  // 60 days ago
        lastStudyDate: Date(timeIntervalSinceNow: -3600)  // 1 hour ago
    )
    
    /// Just started: 15 attempts, 60% accuracy, 2 categories, 3-day streak.
    static let beginner = UserStatistics(
        userId: UUID(),
        totalAttempts: 15,
        totalCorrect: 9,
        categoriesStarted: 2,
        categoriesCompleted: 0,
        longestStreak: 3,
        totalStudyDays: 3,
        firstStudyDate: Date(timeIntervalSinceNow: -3 * 86400),  // 3 days ago
        lastStudyDate: .now
    )
    
    /// Advanced: 812 attempts, 92% accuracy, all categories complete, 45-day streak.
    static let advanced = UserStatistics(
        userId: UUID(),
        totalAttempts: 812,
        totalCorrect: 748,
        categoriesStarted: 10,
        categoriesCompleted: 10,
        longestStreak: 45,
        totalStudyDays: 60,
        firstStudyDate: Date(timeIntervalSinceNow: -120 * 86400),  // 120 days ago
        lastStudyDate: Date(timeIntervalSinceNow: -7200)  // 2 hours ago
    )
}