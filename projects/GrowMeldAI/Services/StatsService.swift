// StatsService.swift
import Foundation

protocol StatsService {
    func getRecentPerformanceScore() async throws -> Double
    func getQuestionsAnsweredLast7Days() async throws -> Int
}

final class MockStatsService: StatsService {
    func getRecentPerformanceScore() async throws -> Double {
        // Simulate performance score between 0.5 and 0.95
        return Double.random(in: 0.5...0.95)
    }

    func getQuestionsAnsweredLast7Days() async throws -> Int {
        return Int.random(in: 5...50)
    }
}