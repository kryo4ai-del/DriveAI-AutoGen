// DriveAI/Services/Protocols/WeaknessPatternServiceProtocol.swift
protocol WeaknessPatternServiceProtocol: AnyObject {
    func fetchAllWeaknesses() async throws -> [WeaknessPattern]
    func fetchById(_ id: String) async throws -> WeaknessPattern
    func fetchByFocusLevel(_ level: FocusLevel) async throws -> [WeaknessPattern]
    func markWeaknessAsReviewed(_ id: String) async throws -> Void
    func updateNextReviewDate(_ id: String, date: Date) async throws -> Void
}

// DriveAI/Services/Protocols/QuestionServiceProtocol.swift

// DriveAI/Services/WeaknessPatternService.swift
@MainActor
final class WeaknessPatternService: WeaknessPatternServiceProtocol {
    static let shared = WeaknessPatternService(database: LocalDatabase.shared)
    
    private let database: LocalDatabaseProtocol
    
    init(database: LocalDatabaseProtocol) {
        self.database = database
    }
    
    func fetchAllWeaknesses() async throws -> [WeaknessPattern] {
        try await database.query("SELECT * FROM weaknesses WHERE failedCount > 0")
    }
    
    // ... implement all protocol methods
}