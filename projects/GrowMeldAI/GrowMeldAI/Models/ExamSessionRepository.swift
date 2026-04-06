import Foundation

protocol ExamSessionRepository {
    func createSession(with questions: [Question]) async throws -> ExamSession
    func saveSession(_ session: ExamSession) async throws
    func fetchSessions(limit: Int) async throws -> [ExamSession]
    func fetchLatestSession() async throws -> ExamSession?
}