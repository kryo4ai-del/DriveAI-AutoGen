// Complete definition:
public protocol UserProgressRepository: Sendable {
    func fetchProgress(userId: String, category: QuestionCategory) async throws -> UserProgress?
    func fetchAllProgress(userId: String) async throws -> [UserProgress]
    func updateProgress(userId: String, progress: UserProgress) async throws
    func calculateStatistics(userId: String) async throws -> ProgressStatistics
    func recordAnswer(userId: String, category: QuestionCategory, isCorrect: Bool) async throws
}
