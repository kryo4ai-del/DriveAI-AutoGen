import Foundation

// MARK: - Protocol Definition (local if not importable from module)

enum MemoryFilterMode {
    case all
    case dueToday
    case learned
    case byCategory(String)
}

enum MemoryError: Error {
    case notFound
    case saveFailed
    case updateFailed
    case deleteFailed
    case fetchFailed
    case unknown(Error)
}

struct EpisodicalMemory: Identifiable, Equatable {
    let id: UUID
    var title: String
    var content: String
    var category: String
    var confidenceScore: Int
    var isLearned: Bool
    var nextReviewDate: Date
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        content: String,
        category: String = "",
        confidenceScore: Int = 0,
        isLearned: Bool = false,
        nextReviewDate: Date = Date(),
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.category = category
        self.confidenceScore = confidenceScore
        self.isLearned = isLearned
        self.nextReviewDate = nextReviewDate
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

protocol EpisodicalMemoryServiceProtocol {
    func fetchMemories(filter: MemoryFilterMode) async throws -> [EpisodicalMemory]
    func fetchMemory(id: UUID) async throws -> EpisodicalMemory
    func saveMemory(_ memory: EpisodicalMemory) async throws
    func updateMemory(_ memory: EpisodicalMemory) async throws
    func deleteMemory(id: UUID) async throws
    func reviewMemory(id: UUID, confidenceScore: Int, timestamp: Date) async throws -> EpisodicalMemory
    func markAsLearned(id: UUID) async throws
    func countDueToday() async throws -> Int
    func fetchByCategory(_ category: String) async throws -> [EpisodicalMemory]
}

// MARK: - Mock Implementation

/// Complete mock for testing ViewModels in isolation
final class MockEpisodicalMemoryService: EpisodicalMemoryServiceProtocol, @unchecked Sendable {

    // MARK: - Configuration
    var fetchMemoriesResult: Result<[EpisodicalMemory], MemoryError> = .success([])
    var fetchMemoryResult: Result<EpisodicalMemory, MemoryError> = .failure(.notFound)
    var saveMemoryResult: Result<Void, MemoryError> = .success(())
    var updateMemoryResult: Result<Void, MemoryError> = .success(())
    var deleteMemoryResult: Result<Void, MemoryError> = .success(())
    var reviewMemoryResult: Result<EpisodicalMemory, MemoryError> = .failure(.notFound)
    var markAsLearnedResult: Result<Void, MemoryError> = .success(())
    var countDueTodayResult: Result<Int, MemoryError> = .success(0)

    var delayMilliseconds: UInt64 = 0  // For testing timing issues

    // MARK: - Call Tracking
    private let lock = NSLock()
    private var _callLog: [(method: String, timestamp: Date)] = []

    var callLog: [(String, Date)] {
        lock.lock()
        defer { lock.unlock() }
        return _callLog
    }

    private func logCall(_ method: String) {
        lock.lock()
        defer { lock.unlock() }
        _callLog.append((method, Date()))
    }

    func resetCallLog() {
        lock.lock()
        defer { lock.unlock() }
        _callLog.removeAll()
    }

    // MARK: - Protocol Implementation

    func fetchMemories(filter: MemoryFilterMode) async throws -> [EpisodicalMemory] {
        logCall("fetchMemories")
        if delayMilliseconds > 0 {
            try await Task.sleep(nanoseconds: delayMilliseconds * 1_000_000)
        }
        return try fetchMemoriesResult.get()
    }

    func fetchMemory(id: UUID) async throws -> EpisodicalMemory {
        logCall("fetchMemory")
        if delayMilliseconds > 0 {
            try await Task.sleep(nanoseconds: delayMilliseconds * 1_000_000)
        }
        return try fetchMemoryResult.get()
    }

    func saveMemory(_ memory: EpisodicalMemory) async throws {
        logCall("saveMemory")
        if delayMilliseconds > 0 {
            try await Task.sleep(nanoseconds: delayMilliseconds * 1_000_000)
        }
        return try saveMemoryResult.get()
    }

    func updateMemory(_ memory: EpisodicalMemory) async throws {
        logCall("updateMemory")
        if delayMilliseconds > 0 {
            try await Task.sleep(nanoseconds: delayMilliseconds * 1_000_000)
        }
        return try updateMemoryResult.get()
    }

    func deleteMemory(id: UUID) async throws {
        logCall("deleteMemory")
        if delayMilliseconds > 0 {
            try await Task.sleep(nanoseconds: delayMilliseconds * 1_000_000)
        }
        return try deleteMemoryResult.get()
    }

    func reviewMemory(id: UUID, confidenceScore: Int, timestamp: Date) async throws -> EpisodicalMemory {
        logCall("reviewMemory")
        if delayMilliseconds > 0 {
            try await Task.sleep(nanoseconds: delayMilliseconds * 1_000_000)
        }
        return try reviewMemoryResult.get()
    }

    func markAsLearned(id: UUID) async throws {
        logCall("markAsLearned")
        if delayMilliseconds > 0 {
            try await Task.sleep(nanoseconds: delayMilliseconds * 1_000_000)
        }
        return try markAsLearnedResult.get()
    }

    func countDueToday() async throws -> Int {
        logCall("countDueToday")
        if delayMilliseconds > 0 {
            try await Task.sleep(nanoseconds: delayMilliseconds * 1_000_000)
        }
        return try countDueTodayResult.get()
    }

    func fetchByCategory(_ category: String) async throws -> [EpisodicalMemory] {
        logCall("fetchByCategory")
        return try fetchMemoriesResult.get().filter { $0.category == category }
    }

    // MARK: - Test Helpers

    func callCount(for method: String) -> Int {
        return callLog.filter { $0.0 == method }.count
    }

    func wasCalled(_ method: String) -> Bool {
        return callCount(for: method) > 0
    }
}