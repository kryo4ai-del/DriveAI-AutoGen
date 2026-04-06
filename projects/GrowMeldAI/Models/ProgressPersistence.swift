// Services/Persistence/ProgressPersistence.swift
protocol ProgressPersistence: Sendable {
    func load() async throws -> UserProgress
    func save(_ progress: UserProgress) async throws
    func clear() async throws
}

// Services/Persistence/QuestionCache.swift
protocol QuestionCache: Sendable {
    func get(questionID: QuestionID) -> Question?
    func set(_ question: Question)
    func getAll() -> [Question]
    func clear()
}

// MARK: - Implementations

// Services/Persistence/UserDefaultsProgressPersistence.swift
@MainActor
final class UserDefaultsProgressPersistence: ProgressPersistence, Sendable {
    private let userDefaults: UserDefaults
    private let key = "com.driveai.user_progress"
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        self.encoder.dateEncodingStrategy = .iso8601
        self.decoder.dateDecodingStrategy = .iso8601
    }
    
    nonisolated func load() async throws -> UserProgress {
        guard let data = userDefaults.data(forKey: key) else {
            return try await _createDefault()
        }
        
        do {
            return try decoder.decode(UserProgress.self, from: data)
        } catch {
            LoggingService.shared.log(
                level: .warning,
                message: "Failed to decode progress, creating new",
                error: error
            )
            return try await _createDefault()
        }
    }
    
    nonisolated private func _createDefault() async throws -> UserProgress {
        try UserProgress(userID: UUID().uuidString)
    }
    
    nonisolated func save(_ progress: UserProgress) async throws {
        do {
            let data = try encoder.encode(progress)
            userDefaults.set(data, forKey: key)
            LoggingService.shared.log(level: .debug, message: "Progress saved")
        } catch {
            throw AppError.persistenceFailed(underlying: error as NSError)
        }
    }
    
    nonisolated func clear() async throws {
        userDefaults.removeObject(forKey: key)
    }
}

// Services/Persistence/MemoryQuestionCache.swift
final class MemoryQuestionCache: QuestionCache, Sendable {
    private var cache: [QuestionID: Question] = [:]
    
    func get(questionID: QuestionID) -> Question? {
        cache[questionID]
    }
    
    func set(_ question: Question) {
        cache[question.id] = question
    }
    
    func getAll() -> [Question] {
        Array(cache.values)
    }
    
    func clear() {
        cache.removeAll()
    }
}