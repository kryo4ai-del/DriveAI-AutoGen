// DriveAI/Features/GrowthTracking/Services/GrowthTrackingService.swift
import Foundation

/// Facade service that coordinates analysis and recommendations
final class GrowthTrackingService {
    private let analysisEngine: WeaknessAnalysisEngine
    private let recommendationEngine: RecommendationEngine
    private let localDataService: LocalDataService

    init(
        analysisEngine: WeaknessAnalysisEngine = .init(),
        recommendationEngine: RecommendationEngine = .init(),
        localDataService: LocalDataService = .init()
    ) {
        self.analysisEngine = analysisEngine
        self.recommendationEngine = recommendationEngine
        self.localDataService = localDataService
    }

    func analyzeAndRecommend(forCategoryID id: String) async throws -> LearningRecommendation {
        let metrics = try await localDataService.fetchPerformanceMetrics(categoryID: id)
        let weakness = analysisEngine.detectWeakness(from: metrics)
        return recommendationEngine.generateRecommendation(from: weakness)
    }

    func fetchGrowthData() async throws -> GrowthData {
        let categories = try await localDataService.fetchAllCategories()
        let weaknesses = try await withThrowingTaskGroup(of: WeaknessPattern.self) { group in
            for category in categories {
                group.addTask {
                    let metrics = try await self.localDataService.fetchPerformanceMetrics(categoryID: category.id)
                    return self.analysisEngine.detectWeakness(from: metrics)
                }
            }

            var results: [WeaknessPattern] = []
            for try await weakness in group {
                results.append(weakness)
            }
            return results
        }

        let primaryWeakness = weaknesses.max(by: { $0.correctPercentage < $1.correctPercentage })
        let performanceTrend = try await fetchPerformanceTrend()

        return GrowthData(
            primaryWeakness: primaryWeakness,
            allWeaknesses: weaknesses,
            performanceTrend: performanceTrend
        )
    }

    private func fetchPerformanceTrend() async throws -> [PerformanceTrendData] {
        let history = try await localDataService.fetchPerformanceHistory()
        return history.map { snapshot in
            PerformanceTrendData(
                id: UUID(),
                date: snapshot.date,
                correctPercentage: snapshot.correctPercentage,
                attemptCount: snapshot.attemptCount,
                fahrtempo: calculateFahrtempo(from: snapshot.correctPercentage)
            )
        }
    }

    private func calculateFahrtempo(from percentage: Double) -> PerformanceTrendData.Fahrtempo {
        if percentage > 0.85 { return .accelerating }
        if percentage > 0.6 { return .steady }
        return .declining
    }
}

/// Container for all growth tracking data
struct GrowthData: Equatable {
    let primaryWeakness: WeaknessPattern?
    let allWeaknesses: [WeaknessPattern]
    let performanceTrend: [PerformanceTrendData]
}