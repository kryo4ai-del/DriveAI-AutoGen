protocol ExamRepository {
    func saveAttempt(_ attempt: ExamAttempt) async throws
    func fetchAttempts(userId: String) async throws -> [ExamAttempt]
  }