// DriveAI/Features/GrowthTracking/Services/WeaknessAnalysisEngine.swift
import Foundation

/// Pure logic engine for detecting weaknesses from performance metrics
final class WeaknessAnalysisEngine {
    func detectWeakness(from metrics: PerformanceMetrics) -> WeaknessPattern {
        let correctPercentage = metrics.correctPercentage
        let recentAnswers = Array(metrics.performanceHistory.map { $0.correctPercentage > 0.5 }.suffix(5))

        return WeaknessPattern(
            id: UUID(),
            categoryID: metrics.categoryID,
            categoryName: metrics.categoryName,
            correctPercentage: correctPercentage,
            totalAttempts: metrics.totalAttempts,
            lastUpdated: metrics.lastAnsweredDate ?? Date(),
            recentAnswers: recentAnswers
        )
    }
}