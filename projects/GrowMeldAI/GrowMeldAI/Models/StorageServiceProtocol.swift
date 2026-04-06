import Foundation

protocol StorageServiceProtocol {
    func loadUserProfile() -> UserProfile?
    func saveUserProfile(_ profile: UserProfile) throws
    func loadQuestionStats(questionId: String) -> QuestionStats?
    func saveQuestionStats(_ stats: QuestionStats) throws
    func loadAllQuestionStats() -> [QuestionStats]
    func clearAllData() throws
}
