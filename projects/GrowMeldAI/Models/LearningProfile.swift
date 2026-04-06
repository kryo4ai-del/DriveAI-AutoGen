// MARK: - Domain/Entities/LearningProfile.swift

import Foundation

/// Represents a user's aggregated learning state across all categories.
///
/// This is the single source of truth for user progress. It aggregates quiz
/// attempts across categories and enables computation of overall metrics.
///
/// - Invariant: All category profiles reflect the current state; computed
///   properties (`totalQuizzesAttempted`, `overallAccuracy`) are derived
///   from category data and never stored redundantly.
struct LearningProfile: Identifiable, Codable {
    let id: UUID
    let userId: String
    
    /// Per-category performance data
    var categoryProfiles: [String: CategoryProfile]
    
    /// User's declared exam date
    var targetExamDate: Date
    
    /// Current streak of consecutive study days
    var streak: Int
    
    /// Timestamp of last study session
    var lastStudyDate: Date
    
    /// Creation timestamp
    let createdAt: Date
    
    // MARK: - Initialization
    
    init(
        id: UUID = UUID(),
        userId: String,
        targetExamDate: Date,
        createdAt: Date = .now
    ) {
        self.id = id
        self.userId = userId
        self.categoryProfiles = [:]
        self.targetExamDate = targetExamDate
        self.streak = 0
        self.lastStudyDate = createdAt
        self.createdAt = createdAt
    }
    
    // MARK: - Computed Properties (Never stored, always derived)
    
    /// Total quizzes attempted across all categories
    var totalQuizzesAttempted: Int {
        categoryProfiles.values.reduce(0) { $0 + $1.questionsAttempted }
    }
    
    /// Overall accuracy as percentage (0-100)
    var overallAccuracy: Double {
        let totalCorrect = categoryProfiles.values.reduce(0) { $0 + $1.correctAnswers }
        guard totalQuizzesAttempted > 0 else { return 0 }
        return (Double(totalCorrect) / Double(totalQuizzesAttempted)) * 100
    }
    
    /// True if user has fewer than 3 quizzes
    var isNovice: Bool {
        totalQuizzesAttempted < 3
    }
    
    // MARK: - Mutations (Immutable pattern: return updated copy)
    
    /// Records a quiz attempt, updating the category profile
    /// - Returns: Updated copy with new attempt recorded
    func recordingQuizAttempt(
        categoryId: String,
        categoryName: String,
        isCorrect: Bool,
        date: Date = .now
    ) -> LearningProfile {
        var updated = self
        
        // Get or create category profile
        var categoryProfile = updated.categoryProfiles[categoryId]
            ?? CategoryProfile(categoryId: categoryId, categoryName: categoryName, lastAttemptDate: date)
        
        // Update category profile immutably
        categoryProfile = categoryProfile.recordedAttempt(isCorrect, date: date)
        updated.categoryProfiles[categoryId] = categoryProfile
        
        // Update top-level tracking
        updated.lastStudyDate = date
        
        return updated
    }
    
    /// Update exam date
    /// - Returns: Updated copy with new exam date
    func withExamDate(_ date: Date) -> LearningProfile {
        var updated = self
        updated.targetExamDate = date
        return updated
    }
    
    /// Update streak
    /// - Returns: Updated copy with new streak value
    func withStreak(_ newStreak: Int) -> LearningProfile {
        var updated = self
        updated.streak = newStreak
        updated.lastStudyDate = .now
        return updated
    }
}

// MARK: - Domain/Entities/CategoryProfile.swift

/// Represents performance in a single category
/// 
/// Value type with immutable update pattern:
///