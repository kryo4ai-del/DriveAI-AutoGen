// Services/ProgressTrackingService.swift (CORRECTED)
import Foundation

protocol ProgressTrackingService: ObservableObject {
    func recordAnswer(categoryId: String, questionId: String, isCorrect: Bool)
    func getProgress(forCategory categoryId: String) -> UserProgress
    func getAllProgress() -> [UserProgress]
}

@MainActor  // ← Enforce main thread only