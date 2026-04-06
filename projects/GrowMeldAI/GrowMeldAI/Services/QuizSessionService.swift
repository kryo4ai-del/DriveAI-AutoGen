protocol QuizSessionService: Sendable {
    func createSession(mode: QuizMode, category: QuestionCategory?) async throws -> QuizSession
    func recordAnswer(_ answer: SessionAnswer, in session: QuizSession) async throws
    func submitSession(_ session: QuizSession) async throws -> ExamResult
    func calculateScore(_ session: QuizSession) -> Int
}