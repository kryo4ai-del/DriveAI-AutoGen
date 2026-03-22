// Models/SessionHistoryServiceProtocol.swift
import Foundation

protocol SessionHistoryServiceProtocol: Sendable {
    func getStats(for exerciseId: UUID) async throws -> UserSessionStats?
    func recordSession(_ result: SessionResult) async throws
    func getStatsForMultiple(exerciseIds: [UUID]) async -> [UUID: UserSessionStats]
}

struct SessionResult: Sendable {
    let exerciseId: UUID
    let score: Double
    let completedDate: Date
    let duration: Int // seconds
}
