import Foundation

final class MockLocalDataService: LocalDataServiceProtocol {
    let delayMs: UInt64
    private(set) var callCount = 0
    var shouldThrow: Error?

    init(delayMs: UInt64 = 0) {
        self.delayMs = delayMs
    }

    func fetchQuestions(category: String?) async throws -> [Question] {
        callCount += 1

        if let error = shouldThrow {
            throw error
        }

        try await Task.sleep(nanoseconds: delayMs * 1_000_000)

        if let category = category {
            return Question.mockData.filter { $0.categoryId == category }
        }
        return Question.mockData
    }

    func fetchAllCategories() async throws -> [Category] {
        try await Task.sleep(nanoseconds: delayMs * 1_000_000)
        return Category.mockData
    }

    func saveProgress(_ progress: UserProgress) async throws {
        if let error = shouldThrow {
            throw error
        }
        try await Task.sleep(nanoseconds: delayMs * 1_000_000)
    }

    func fetchProgress(categoryId: String) async throws -> UserProgress {
        try await Task.sleep(nanoseconds: delayMs * 1_000_000)
        return UserProgress(categoryId: categoryId)
    }
}