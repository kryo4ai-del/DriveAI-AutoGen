import Foundation

protocol ProgressRepositoryProtocol: AnyObject {
    func fetchStats(for categoryID: String) async throws -> CategoryStats
    func fetchCurrentStreak() async throws -> Int
    func fetchPreviousReadinessScore() async throws -> ReadinessScore?
}

struct CategoryStats {
    let attempted: Int
    let correct: Int
    let lastAttempted: Date?
}