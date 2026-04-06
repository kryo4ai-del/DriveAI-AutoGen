import Foundation

final class WeaknessPatternService: WeaknessPatternServiceProtocol {
    static let shared = WeaknessPatternService(database: LocalDatabase.shared)

    private let database: LocalDatabase

    init(database: LocalDatabase) {
        self.database = database
    }

    func fetchAllWeaknesses() async throws -> [WeaknessPattern] {
        try await database.fetchAllWeaknessPatterns()
    }

    func fetchById(_ id: String) async throws -> WeaknessPattern {
        try await database.fetchWeaknessPattern(by: id)
    }

    func fetchByFocusLevel(_ level: FocusLevel) async throws -> [WeaknessPattern] {
        try await database.fetchWeaknessPatterns(by: level)
    }

    func markWeaknessAsReviewed(_ id: String) async throws {
        try await database.markWeaknessAsReviewed(id)
    }

    func updateNextReviewDate(_ id: String, date: Date) async throws {
        try await database.updateNextReviewDate(id, date: date)
    }
}