import Foundation

protocol LocalDataServiceProtocol: Sendable {
    func getCategoryStatistics() async throws -> [CategoryStat]
    func getTotalTimeSpentMinutes() async throws -> Int
    func getLearningStreakData() async throws -> ReadinessStreakData
    func getRecentPerformanceMetrics() async throws -> RecentMetrics
}

protocol UserProgressServiceProtocol: Sendable {
    func getOverallProgress() async throws -> Double
}

final class LocalDataService: LocalDataServiceProtocol, @unchecked Sendable {
    static let preview = LocalDataService()

    // Methods implemented in LocalDataService+Extension.swift
}
