import Foundation
import os.lock

/// Core algorithm for exam readiness scoring and recommendation generation
final class ReadinessAnalysisService: Sendable {
    
    private let dataService: LocalDataService
    
    // MARK: - Thread-Safe Cache Management
    
    private let cacheLock = NSLock()
    private var cachedResult: (ExamReadinessResult, Date)?
    private let cacheTTL: TimeInterval = 300  // 5 minutes
    
    nonisolated init(dataService: LocalDataService) {
        self.dataService = dataService
    }
    
    // MARK: - Public API
    
    /// Calculate overall exam readiness with optional cache bypass
    /// Thread-safe and cancellation-aware
    func calculateReadiness(forceRefresh: Bool = false) async throws -> ExamReadinessResult {
        // Check cache first
        if !forceRefresh {
            cacheLock.lock()
            defer { cacheLock.unlock() }
            
            if let (result, timestamp) = cachedResult,
               Date().timeIntervalSince(timestamp) < cacheTTL {
                return result
            }
        }
        
        // Compute fresh result
        let result = try await _computeReadiness()
        
        // Update cache atomically
        cacheLock.lock()
        self.cachedResult = (result, .now)
        cacheLock.unlock()
        
        return result
    }
    
    // MARK: - Private Computation
    
    private func _computeReadiness() async throws -> ExamReadinessResult {
        let stats = try await dataService.getCategoryStatistics()
        let timeSpent = try await dataService.getTotalTimeSpentMinutes()
        let streakData = try await dataService.getLearningStreakData()
        let recentMetrics = try await dataService.getRecentPerformanceMetrics()
        
        // Calculate component scores
        let categoryPerformance = calculateCategoryPerformance(from: stats)
        let streakScore = calculateStreakScore(from: streakData)
        let timeInvestedScore = calculateTimeInvestedScore(minutes: timeSpent)
        let recentTrendScore = calculateRecentTrendScore(from: recentMetrics)
        
        // Calculate weighted overall score
        let overallScore = calculateOverallScore(
            categoryPerformance: categoryPerformance,
            streakScore: streakScore,
            timeInvestedScore: timeInvestedScore,
            recentTrendScore: recentTrendScore
        )
        
        // Extract category metrics
        let categoryMetrics = mapCategoryMetrics(from: stats)
        
        // Identify weak categories (below 75% threshold)
        let weakCategories = identifyWeakCategories(from: categoryMetrics)
        
        // Generate personalized recommendations
        let recommendations = generateRecommendations(
            weak: weakCategories,
            metrics: categoryMetrics
        )
        
        // Assemble metrics
        let metrics = ReadinessMetrics(
            timeInvestedMinutes: timeSpent,
            currentStreakDays: streakData.currentDays,
            categoriesStarted: stats.count,
            categoriesCompleted: stats.filter { $0.totalAttempts > 0 }.count,
            lastSessionDate: recentMetrics.lastSessionDate
        )
        
        return ExamReadinessResult(
            overallScore: overallScore,
            categoryMetrics: categoryMetrics,
            recommendations: recommendations.sorted { $0.impactScore > $1.impactScore }.prefix(5).map { $0 },
            weakCategories: weakCategories,
            metrics: metrics,
            generatedAt: .now
        )
    }
    
    // MARK: - Scoring Algorithms
    
    private func calculateCategoryPerformance(from stats: [CategoryStat]) -> Double {
        guard !stats.isEmpty else { return 0 }
        
        // Only include categories with at least one attempt
        let completedCategories = stats.filter { $0.totalAttempts > 0 }
        guard !completedCategories.isEmpty else { return 0 }
        
        let avgPercentage = completedCategories
            .compactMap { category -> Double? in
                guard category.totalAttempts > 0 else { return nil }
                return Double(category.correctCount) / Double(category.totalAttempts)
            }
            .reduce(0, +) / Double(completedCategories.count)
        
        return avgPercentage * 100
    }
    
    private func calculateStreakScore(from data: ReadinessStreakData) -> Double {
        // Normalize: current/longest, capped at 1.0
        guard data.longestDays > 0 else { return 0 }
        let multiplier = min(Double(data.currentDays) / Double(data.longestDays), 1.0)
        return multiplier * 100  // Return as 0–100
    }
    
    private func calculateTimeInvestedScore(minutes: Int) -> Double {
        // Log scale: 0 min → 0, 60 min → 60, 240 min (4h) → ~87, 600 min (10h) → ~99
        // Formula: log(minutes + 1) / log(600) * 100, capped at 100
        guard minutes > 0 else { return 0 }
        
        let score = (log(Double(minutes) + 1) / log(600)) * 100
        return min(score, 100)
    }
    
    private func calculateRecentTrendScore(from recent: RecentMetrics) -> Double {
        // Trend based on last 7 days
        guard recent.last7DaysAttempts > 0 else { return 0 }
        
        let recentAccuracy = Double(recent.last7DaysCorrect) / Double(recent.last7DaysAttempts)
        let consistencyBonus = min(Double(recent.last7DaysSessions) / 7.0, 1.0) * 20  // 0–20 point bonus
        
        return (recentAccuracy * 80) + consistencyBonus
    }
    
    private func calculateOverallScore(
        categoryPerformance: Double,
        streakScore: Double,
        timeInvestedScore: Double,
        recentTrendScore: Double
    ) -> Int {
        let weighted =
            (categoryPerformance * 0.40) +
            (streakScore * 0.25) +
            (timeInvestedScore * 0.20) +
            (recentTrendScore * 0.15)
        
        return Int(min(max(weighted, 0), 100))
    }
    
    // MARK: - Category Analysis
    
    private func mapCategoryMetrics(from stats: [CategoryStat]) -> [CategoryMetric] {
        stats.map { stat in
            let percentage = stat.totalAttempts > 0
                ? (Double(stat.correctCount) / Double(stat.totalAttempts) * 100)
                : 0
            
            return CategoryMetric(
                categoryID: stat.categoryID,
                categoryName: stat.categoryName,
                correctCount: stat.correctCount,
                totalAttempts: stat.totalAttempts,
                correctPercentage: Int(percentage)
            )
        }
    }
    
    private func identifyWeakCategories(from metrics: [CategoryMetric]) -> [WeakCategory] {
        let passThreshold = 75
        
        return metrics.compactMap { metric in
            guard metric.correctPercentage < passThreshold && metric.totalAttempts > 0 else {
                return nil
            }
            
            let gap = passThreshold - metric.correctPercentage
            let remaining = estimateQuestionsToPass(
                currentCorrect: metric.correctCount,
                currentTotal: metric.totalAttempts,
                targetPercentage: passThreshold
            )
            
            return WeakCategory(
                categoryID: metric.categoryID,
                categoryName: metric.categoryName,
                correctPercentage: metric.correctPercentage,
                gapToPass: gap,
                questionsRemaining: remaining
            )
        }.sorted { $0.gapToPass > $1.gapToPass }
    }
    
    private func estimateQuestionsToPass(
        currentCorrect: Int,
        currentTotal: Int,
        targetPercentage: Int
    ) -> Int {
        let targetPercent = Double(targetPercentage) / 100.0
        let targetCorrect = Double(currentTotal) * targetPercent
        
        if Double(currentCorrect) >= targetCorrect {
            return 0  // Already passed
        }
        
        // Assume 75% success rate on new questions
        let neededCorrect = Int(ceil(targetCorrect)) - currentCorrect
        let estimatedQuestions = Int(ceil(Double(neededCorrect) / 0.75))
        
        return min(estimatedQuestions, 50)  // Cap at 50
    }
    
    private func generateRecommendations(
        weak: [WeakCategory],
        metrics: [CategoryMetric]
    ) -> [ReadinessRecommendation] {
        var recommendations: [ReadinessRecommendation] = []
        
        for weakCategory in weak {
            let timeNeeded = estimateTimeForCategory(weakCategory)
            let impactGain = calculateImpactScore(for: weakCategory)
            
            let recommendation = ReadinessRecommendation(
                categoryID: weakCategory.categoryID,
                categoryName: weakCategory.categoryName,
                suggestion: generateSuggestionText(for: weakCategory),
                estimatedMinutes: timeNeeded,
                impactScore: impactGain
            )
            
            recommendations.append(recommendation)
            
            // Cap at 5 recommendations
            if recommendations.count >= 5 {
                break
            }
        }
        
        // If no weak categories, suggest review of lower-scoring passing categories
        if recommendations.isEmpty && !metrics.isEmpty {
            let sortedByScore = metrics.sorted { $0.correctPercentage < $1.correctPercentage }
            for metric in sortedByScore.prefix(2) where metric.correctPercentage < 90 {
                let recommendation = ReadinessRecommendation(
                    categoryID: metric.categoryID,
                    categoryName: metric.categoryName,
                    suggestion: "Festige dein Wissen in \(metric.categoryName) – 10 Minuten",
                    estimatedMinutes: 10,
                    impactScore: 0.4
                )
                recommendations.append(recommendation)
            }
        }
        
        return recommendations
    }
    
    private func estimateTimeForCategory(_ category: WeakCategory) -> Int {
        // 2 minutes per question + 5 min overhead
        return (category.questionsRemaining * 2) + 5
    }
    
    private func calculateImpactScore(for weak: WeakCategory) -> Double {
        let gap = Double(weak.gapToPass)
        let questionsRatio = Double(weak.questionsRemaining) / 50.0  // Normalize to typical max
        
        // Impact: how much score improvement is possible (gap * question availability)
        let potentialGain = (gap / 100.0) * (questionsRatio * 0.5 + 0.5)
        return min(max(potentialGain, 0), 1.0)
    }
    
    private func generateSuggestionText(for category: WeakCategory) -> String {
        let questionsText = category.questionsRemaining == 1 ? "Frage" : "Fragen"
        return "Fokussiere auf \(category.categoryName) – \(category.questionsRemaining) \(questionsText) offen"
    }
    
    // MARK: - Cache Management
    
    func invalidateCache() {
        cacheLock.lock()
        self.cachedResult = nil
        cacheLock.unlock()
    }
}

// MARK: - Supporting Types (Sendable)

struct ReadinessStreakData: Sendable, Codable {
    let currentDays: Int
    let longestDays: Int

    enum CodingKeys: String, CodingKey {
        case currentDays = "current_days"
        case longestDays = "longest_days"
    }
}

struct RecentMetrics: Sendable, Codable {
    let last7DaysAttempts: Int
    let last7DaysCorrect: Int
    let last7DaysSessions: Int
    let lastSessionDate: Date
    
    enum CodingKeys: String, CodingKey {
        case last7DaysAttempts = "last_7_days_attempts"
        case last7DaysCorrect = "last_7_days_correct"
        case last7DaysSessions = "last_7_days_sessions"
        case lastSessionDate = "last_session_date"
    }
}