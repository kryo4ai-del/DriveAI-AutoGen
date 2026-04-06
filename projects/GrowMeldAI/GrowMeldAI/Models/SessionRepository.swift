protocol SessionRepository: Sendable {
    func recordSession(_ session: LearningSessionDomain) async throws
    func getSessions(userId: String, dateRange: ClosedRange<Date>) async throws -> [LearningSessionDomain]
    func getStreak(userId: String) async throws -> StreakDomain
    func deleteSession(sessionId: String) async throws
}
