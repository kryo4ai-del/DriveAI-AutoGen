// Services/ProgressTrackingService.swift (CORRECTED)
import Foundation

protocol ProgressTrackingService: ObservableObject {
    func recordAnswer(categoryId: String, questionId: String, isCorrect: Bool)
    func getProgress(forCategory categoryId: String) -> UserProgress
    func getAllProgress() -> [UserProgress]
}

@MainActor
class DefaultProgressTrackingService: ProgressTrackingService {
    func recordAnswer(categoryId: String, questionId: String, isCorrect: Bool) {
    }

    func getProgress(forCategory categoryId: String) -> UserProgress {
        return UserProgress(categoryId: categoryId)
    }

    func getAllProgress() -> [UserProgress] {
        return []
    }
}