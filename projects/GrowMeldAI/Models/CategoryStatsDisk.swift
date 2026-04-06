import Foundation

struct CategoryStats {
    let categoryID: String
    let totalAttempts: Int
    let correctAttempts: Int
    let averageTimePerQuestion: TimeInterval

    var accuracy: Double {
        guard totalAttempts > 0 else { return 0 }
        return Double(correctAttempts) / Double(totalAttempts)
    }
}

struct QuestionAttempt {
    let id: String
    let categoryID: String
    let isCorrect: Bool
    let timeSpent: TimeInterval
    let attemptedAt: Date

    init(id: String = UUID().uuidString,
         categoryID: String,
         isCorrect: Bool,
         timeSpent: TimeInterval,
         attemptedAt: Date = Date()) {
        self.id = id
        self.categoryID = categoryID
        self.isCorrect = isCorrect
        self.timeSpent = timeSpent
        self.attemptedAt = attemptedAt
    }
}

actor PerformanceStore {
    private struct CategoryStatsDisk: Codable {
        let categoryID: String
        let totalAttempts: Int
        let correctAttempts: Int
        let lastUpdated: Date
        let averageTimePerQuestion: TimeInterval
    }

    private var statsCache: [String: CategoryStatsDisk] = [:]
    private let statsCacheTTL: TimeInterval = 300

    private let attemptsKey = "com.growmeldai.performancestore.attempts"
    private let statsKey = "com.growmeldai.performancestore.stats"
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init() {
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
    }

    func fetchCategoryStats(categoryID: String) async throws -> CategoryStats {
        if let cached = statsCache[categoryID],
           Date().timeIntervalSince(cached.lastUpdated) < statsCacheTTL {
            return categoryStatsFromDisk(cached)
        }

        let attempts = try await fetchAttempts(categoryID: categoryID, limit: 100)
        let stats = computeStatsFromAttempts(attempts, categoryID: categoryID)

        statsCache[categoryID] = CategoryStatsDisk(
            categoryID: categoryID,
            totalAttempts: stats.totalAttempts,
            correctAttempts: stats.correctAttempts,
            lastUpdated: Date(),
            averageTimePerQuestion: stats.averageTimePerQuestion
        )

        try await persistCategoryStats()
        return stats
    }

    func recordAttemptAndInvalidateStats(_ attempt: QuestionAttempt) async throws {
        try await saveQuestionAttempt(attempt)
        statsCache.removeValue(forKey: attempt.categoryID)
    }

    // MARK: - Private Helpers

    private func categoryStatsFromDisk(_ disk: CategoryStatsDisk) -> CategoryStats {
        return CategoryStats(
            categoryID: disk.categoryID,
            totalAttempts: disk.totalAttempts,
            correctAttempts: disk.correctAttempts,
            averageTimePerQuestion: disk.averageTimePerQuestion
        )
    }

    private func fetchAttempts(categoryID: String, limit: Int) async throws -> [QuestionAttempt] {
        let all = loadAllAttempts()
        let filtered = all.filter { $0.categoryID == categoryID }
        return Array(filtered.suffix(limit))
    }

    private func computeStatsFromAttempts(_ attempts: [QuestionAttempt], categoryID: String) -> CategoryStats {
        let total = attempts.count
        let correct = attempts.filter { $0.isCorrect }.count
        let avgTime: TimeInterval = total > 0
            ? attempts.map { $0.timeSpent }.reduce(0, +) / Double(total)
            : 0
        return CategoryStats(
            categoryID: categoryID,
            totalAttempts: total,
            correctAttempts: correct,
            averageTimePerQuestion: avgTime
        )
    }

    private func saveQuestionAttempt(_ attempt: QuestionAttempt) async throws {
        var all = loadAllAttempts()
        all.append(attempt)
        let codable = all.map { CodableAttempt(from: $0) }
        let data = try encoder.encode(codable)
        UserDefaults.standard.set(data, forKey: attemptsKey)
    }

    private func persistCategoryStats() async throws {
        var allDisk: [CategoryStatsDisk] = []
        for (_, disk) in statsCache {
            allDisk.append(disk)
        }
        let data = try encoder.encode(allDisk)
        UserDefaults.standard.set(data, forKey: statsKey)
    }

    private func loadAllAttempts() -> [QuestionAttempt] {
        guard let data = UserDefaults.standard.data(forKey: attemptsKey),
              let codable = try? decoder.decode([CodableAttempt].self, from: data) else {
            return []
        }
        return codable.map { $0.toAttempt() }
    }

    private struct CodableAttempt: Codable {
        let id: String
        let categoryID: String
        let isCorrect: Bool
        let timeSpent: TimeInterval
        let attemptedAt: Date

        init(from attempt: QuestionAttempt) {
            self.id = attempt.id
            self.categoryID = attempt.categoryID
            self.isCorrect = attempt.isCorrect
            self.timeSpent = attempt.timeSpent
            self.attemptedAt = attempt.attemptedAt
        }

        func toAttempt() -> QuestionAttempt {
            return QuestionAttempt(
                id: id,
                categoryID: categoryID,
                isCorrect: isCorrect,
                timeSpent: timeSpent,
                attemptedAt: attemptedAt
            )
        }
    }
}