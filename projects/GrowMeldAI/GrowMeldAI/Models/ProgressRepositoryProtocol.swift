// MARK: - Services/Data/ProgressRepository.swift

protocol ProgressRepositoryProtocol {
    var progressPublisher: AnyPublisher<Void, Never> { get }
    
    func fetchAllProgress() async throws -> ProgressSummary
    func fetchProgressByCategory(categoryId: String) async throws -> CategoryProgress
    func recordAnswer(questionId: String, isCorrect: Bool, categoryId: String) async throws
    func getStreakDays() async throws -> Int
}

struct ProgressSummary {
    let correctCount: Int
    let totalCount: Int
    let byCategory: [CategoryProgress]
}
