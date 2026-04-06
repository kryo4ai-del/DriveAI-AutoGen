import Foundation
protocol ProgressRepository {
    func loadProgress() -> UserProgress
    func saveProgress(_ progress: UserProgress)
    func recordAnswer(categoryId: UUID, isCorrect: Bool)
    func saveExamResult(_ result: ExamResult)
}
