// UserProgressService.swift
import Foundation
import Combine

protocol UserProgressServiceProtocol {
    func loadProgress() -> UserProgress
    func saveProgress(_ progress: UserProgress)
    func updateQuestionAnswered(correct: Bool, category: String)
    func updateExamSimulationResult(_ result: UserProgress.ExamSimulationResult)
    func resetProgress()
}
