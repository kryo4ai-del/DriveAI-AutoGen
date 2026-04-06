// ✅ ATOMIC STATE (updated in-place, always fresh)
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

// ✅ LIGHTWEIGHT HISTORY (only aggregates, indexed efficiently)
struct HistoricalSnapshot: Codable, Sendable {
    let id: UUID
    let timestamp: Date
    let readinessProbability: Double
    let velocityQuestionsPerDay: Double
    let weaknessCount: Int
    let milestonesUnlockedCount: Int
    let totalPointsEarned: Int
}

// ✅ PERSISTENCE LAYER
actor GrowthPersistenceService {
    func saveHistoricalSnapshot(_ snapshot: HistoricalSnapshot) async throws {
        // ~200 bytes per snapshot = 180KB for 1 year
        try await database.insert(snapshot)
    }
    
    func loadTrendData(days: Int) async throws -> [HistoricalSnapshot] {
        // Query returns lightweight objects, fast even for 365 days
        return try await database.query(
            "SELECT * FROM historical_snapshots WHERE timestamp > ? ORDER BY timestamp DESC",
            cutoffDate: Date().addingTimeInterval(-Double(days) * 86400)
        )
    }
}