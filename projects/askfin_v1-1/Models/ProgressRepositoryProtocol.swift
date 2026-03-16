import Foundation

protocol ProgressRepositoryProtocol: AnyObject {
    func fetchStats(for categoryID: String) async throws -> CategoryStats
    func fetchCurrentStreak() async throws -> Int
    func fetchPreviousReadinessScore() async throws -> ReadinessScore?
}