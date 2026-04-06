import Foundation
import SwiftUI

// MARK: - Supporting Types

struct ExamReadinessScore: Codable, Sendable {
    let probability: Double
    let label: String

    static let empty = ExamReadinessScore(probability: 0.0, label: "Not started")
}

struct LearningVelocity: Codable, Sendable {
    let questionsPerDay: Double

    static let empty = LearningVelocity(questionsPerDay: 0.0)
}

struct WeaknessPattern: Codable, Identifiable, Sendable {
    let id: UUID
    let topic: String
    let errorRate: Double

    init(id: UUID = UUID(), topic: String, errorRate: Double) {
        self.id = id
        self.topic = topic
        self.errorRate = errorRate
    }
}

struct GrowthMilestone: Codable, Identifiable, Sendable {
    let id: UUID
    let title: String
    let unlockedAt: Date

    init(id: UUID = UUID(), title: String, unlockedAt: Date = Date()) {
        self.id = id
        self.title = title
        self.unlockedAt = unlockedAt
    }
}

// MARK: - Atomic State

@MainActor
final class CurrentGrowthState: ObservableObject {
    @Published var readiness: ExamReadinessScore
    @Published var velocity: LearningVelocity
    @Published var weaknesses: [WeaknessPattern]
    @Published var unlockedMilestones: [GrowthMilestone]
    @Published var totalPoints: Int
    @Published var lastUpdated: Date

    init() {
        self.readiness = .empty
        self.velocity = .empty
        self.weaknesses = []
        self.unlockedMilestones = []
        self.totalPoints = 0
        self.lastUpdated = Date()
    }
}

// MARK: - Lightweight History

struct HistoricalSnapshot: Codable, Sendable {
    let id: UUID
    let timestamp: Date
    let readinessProbability: Double
    let velocityQuestionsPerDay: Double
    let weaknessCount: Int
    let milestonesUnlockedCount: Int
    let totalPointsEarned: Int
}

// MARK: - Persistence Layer

actor GrowthPersistenceService {
    private let snapshotsKey = "com.growmeldai.historical_snapshots"
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init() {
        encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
    }

    func saveHistoricalSnapshot(_ snapshot: HistoricalSnapshot) throws {
        var snapshots = (try? loadAllSnapshots()) ?? []
        snapshots.append(snapshot)
        let data = try encoder.encode(snapshots)
        UserDefaults.standard.set(data, forKey: snapshotsKey)
    }

    func loadTrendData(days: Int) throws -> [HistoricalSnapshot] {
        let cutoff = Date().addingTimeInterval(-Double(days) * 86400)
        let all = (try? loadAllSnapshots()) ?? []
        return all.filter { $0.timestamp > cutoff }
                  .sorted { $0.timestamp > $1.timestamp }
    }

    private func loadAllSnapshots() throws -> [HistoricalSnapshot] {
        guard let data = UserDefaults.standard.data(forKey: snapshotsKey) else {
            return []
        }
        return try decoder.decode([HistoricalSnapshot].self, from: data)
    }
}