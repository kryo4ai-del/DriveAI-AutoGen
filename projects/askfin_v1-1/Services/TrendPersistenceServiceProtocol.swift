import Foundation

protocol TrendPersistenceServiceProtocol: Sendable {
    func saveTrendPoint(_ point: ReadinessTrendPoint) async throws
    func fetchTrendPoints() async throws -> [ReadinessTrendPoint]
    func deleteTrendPointsOlderThan(_ date: Date) async throws
}