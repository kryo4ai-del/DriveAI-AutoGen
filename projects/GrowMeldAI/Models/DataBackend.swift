import Foundation

struct UserStatistics: Codable {
    let totalAttempts: Int
    let correctAttempts: Int
    let categoriesProgress: [String: Double]
    let lastSyncedAt: Date?
}

struct QuestionAttempt: Codable {
    let id: String
    let questionId: Int
    let category: String
    let isCorrect: Bool
    let attemptedAt: Date

    init(id: String = UUID().uuidString,
         questionId: Int,
         category: String,
         isCorrect: Bool,
         attemptedAt: Date = Date()) {
        self.id = id
        self.questionId = questionId
        self.category = category
        self.isCorrect = isCorrect
        self.attemptedAt = attemptedAt
    }
}

enum BackendType: String, Codable {
    case local
    case firebase
    case rest
    case graphQL
}

protocol DataBackend {
    func syncProgress(category: String) async throws
    func fetchStatistics() async throws -> UserStatistics
    func uploadAttempt(_ attempt: QuestionAttempt) async throws
    func getAvailableBackends() -> [BackendType]
}

final class LocalDataService: DataBackend {
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let statisticsKey = "com.growmeldai.local.statistics"
    private let attemptsKey = "com.growmeldai.local.attempts"

    init() {
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
    }

    func syncProgress(category: String) async throws {
        // Local service: no remote sync needed
    }

    func fetchStatistics() async throws -> UserStatistics {
        guard let data = UserDefaults.standard.data(forKey: statisticsKey) else {
            return UserStatistics(
                totalAttempts: 0,
                correctAttempts: 0,
                categoriesProgress: [:],
                lastSyncedAt: nil
            )
        }
        return try decoder.decode(UserStatistics.self, from: data)
    }

    func uploadAttempt(_ attempt: QuestionAttempt) async throws {
        var attempts = loadAttempts()
        attempts.append(attempt)
        let data = try encoder.encode(attempts)
        UserDefaults.standard.set(data, forKey: attemptsKey)
        try await updateStatistics(with: attempts)
    }

    func getAvailableBackends() -> [BackendType] {
        return [.local]
    }

    private func loadAttempts() -> [QuestionAttempt] {
        guard let data = UserDefaults.standard.data(forKey: attemptsKey),
              let attempts = try? decoder.decode([QuestionAttempt].self, from: data) else {
            return []
        }
        return attempts
    }

    private func updateStatistics(with attempts: [QuestionAttempt]) async throws {
        let total = attempts.count
        let correct = attempts.filter { $0.isCorrect }.count
        var categoryProgress: [String: Double] = [:]
        let grouped = Dictionary(grouping: attempts, by: { $0.category })
        for (category, categoryAttempts) in grouped {
            let categoryCorrect = categoryAttempts.filter { $0.isCorrect }.count
            categoryProgress[category] = Double(categoryCorrect) / Double(categoryAttempts.count)
        }
        let stats = UserStatistics(
            totalAttempts: total,
            correctAttempts: correct,
            categoriesProgress: categoryProgress,
            lastSyncedAt: Date()
        )
        let data = try encoder.encode(stats)
        UserDefaults.standard.set(data, forKey: statisticsKey)
    }
}