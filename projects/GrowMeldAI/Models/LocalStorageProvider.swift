protocol LocalStorageProvider {
    func saveExamDate(_ date: Date) async throws
    func fetchExamDate() async -> Date?
    func saveQuestionAttempt(_ attempt: QuestionAttempt) async throws
    func fetchUserProfile() async -> UserProfile?
}
