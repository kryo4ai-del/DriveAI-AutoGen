// Services/SessionHistoryService.swift
import Foundation
import CoreData

protocol SessionHistoryServiceProtocol: Sendable {
    func getStats(for exerciseId: UUID) async throws -> UserSessionStats?
    func recordSession(_ result: SessionResult) async throws
    func getStatsForMultiple(exerciseIds: [UUID]) async -> [UUID: UserSessionStats]
}

actor SessionHistoryService: SessionHistoryServiceProtocol {
    private let container: NSPersistentContainer
    
    nonisolated let backgroundQueue = DispatchQueue(
        label: "com.driveai.sessionhistory",
        qos: .userInitiated
    )
    
    init(container: NSPersistentContainer) {
        self.container = container
    }
    
    func getStats(for exerciseId: UUID) async throws -> UserSessionStats? {
        let context = container.viewContext
        
        let request = NSFetchRequest<SessionEntity>(entityName: "Session")
        request.predicate = NSPredicate(format: "exerciseId == %@", exerciseId as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \SessionEntity.completedDate, ascending: false)]
        
        let results = try context.fetch(request)
        
        guard !results.isEmpty else { return nil }
        
        return aggregateStats(from: results, for: exerciseId)
    }
    
    /// Fetch stats for multiple exercises concurrently
    func getStatsForMultiple(exerciseIds: [UUID]) async -> [UUID: UserSessionStats] {
        var stats: [UUID: UserSessionStats] = [:]
        
        await withTaskGroup(of: (UUID, UserSessionStats?).self) { group in
            for id in exerciseIds {
                group.addTask {
                    let stat = try? await self.getStats(for: id)
                    return (id, stat)
                }
            }
            
            for await (id, stat) in group {
                if let stat = stat {
                    stats[id] = stat
                }
            }
        }
        
        return stats
    }
    
    func recordSession(_ result: SessionResult) async throws {
        let context = container.viewContext
        let entity = SessionEntity(context: context)
        entity.exerciseId = result.exerciseId
        entity.score = result.score
        entity.completedDate = result.completedDate
        entity.duration = Int32(result.duration)
        
        try context.save()
    }
    
    // MARK: - Private
    
    private func aggregateStats(from results: [SessionEntity], for exerciseId: UUID) -> UserSessionStats {
        let completedCount = results.count
        let scores = results.compactMap { $0.score as? Double }
        let averageScore = scores.isEmpty ? 0 : scores.reduce(0, +) / Double(scores.count)
        let bestScore = scores.max() ?? 0
        let lastAttempt = results.first?.completedDate
        
        return UserSessionStats(
            exerciseId: exerciseId,
            completedCount: completedCount,
            averageScore: averageScore,
            lastAttemptDate: lastAttempt,
            bestScore: bestScore
        )
    }
}

struct SessionResult {
    let exerciseId: UUID
    let score: Double
    let completedDate: Date
    let duration: Int // seconds
}