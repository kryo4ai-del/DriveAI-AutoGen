import Foundation
protocol ProgressRepository {
    func loadProgress() -> Models.UserProgress
    func saveProgress(_ progress: Models.UserProgress)
    func recordAnswer(categoryId: UUID, isCorrect: Bool)
    func saveExamResult(_ result: Models.ExamResult)
}