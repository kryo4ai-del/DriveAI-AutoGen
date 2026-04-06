// Services/StatisticsCalculationService.swift - IMPROVED
import Foundation
import Combine

protocol StatisticsCalculationServiceProtocol {
    func updateStatistics(questionAnswered: Bool, category: String) async throws
    func getStatistics() async throws -> UserStatistics
    func getStreakData() async throws -> StreakData
    func calculateReadinessPercentage() async throws -> Double
}

class StatisticsCalculationService: StatisticsCalculationServiceProtocol {
    private let persistence: ProfilePersistenceManagerProtocol
    private let statisticsKey = "user_statistics_v1"
    private let streakKey = "user_streak_v1"
    private let lastStreakUpdateKey = "last_streak_update_v1"
    
    init(persistence: ProfilePersistenceManagerProtocol) {
        self.persistence = persistence
    }
    
    func updateStatistics(questionAnswered: Bool, category: String) async throws {
        var stats = try getStatistics()
        
        stats.totalQuestionsAnswered += 1
        if questionAnswered {
            stats.totalCorrect += 1
        }
        stats.lastUpdated = Date()
        
        // Update category breakdown
        var categoryStats = stats.categoryBreakdown[category] ?? 
            .init(categoryName: category)
        categoryStats.questionsAnswered += 1
        if questionAnswered {
            categoryStats.questionsCorrect += 1
        }
        stats.categoryBreakdown[category] = categoryStats
        
        try persistence.save(stats, key: statisticsKey)
        
        // Update streak only once per day
        try updateStreakIfNeeded()
    }
    
    func getStatistics() async throws -> UserStatistics {
        return try persistence.load(key: statisticsKey, type: UserStatistics.self) ?? .empty
    }
    
    func getStreakData() async throws -> StreakData {
        return try persistence.load(key: streakKey, type: StreakData.self) ?? .init()
    }
    
    func calculateReadinessPercentage() async throws -> Double {
        let stats = try getStatistics()
        let passRate = stats.overallPassRate
        
        // Formula: (pass_rate * 0.7) + (questions_ratio * 0.3)
        let questionsRatio = min(Double(stats.totalQuestionsAnswered) / 100.0, 1.0)
        return (passRate * 0.7) + (questionsRatio * 0.3)
    }
    
    private func updateStreakIfNeeded() throws {
        let today = Calendar.current.startOfDay(for: Date())
        let lastUpdateData = try persistence.load(
            key: lastStreakUpdateKey,
            type: Date.self
        )
        let lastUpdateDay = lastUpdateData.map { 
            Calendar.current.startOfDay(for: $0) 
        }
        
        // Only update if not already updated today
        guard today != lastUpdateDay else { return }
        
        var streak = try getStreakData()
        streak.updateStreak(attemptedToday: true)
        
        try persistence.save(streak, key: streakKey)
        try persistence.save(Date(), key: lastStreakUpdateKey)
    }
}