// Services/Data/UserProgressRepository.swift
protocol UserProgressRepositoryProtocol {
    func fetchProgress() async throws -> UserProgress
    func updateProgress(_ progress: UserProgress) async throws
    func recordAttempt(_ attempt: ExamAttempt) async throws
    func deleteAllProgress() async throws  // GDPR compliance
}