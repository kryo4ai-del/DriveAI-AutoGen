// Services/Persistence/ProgressPersistenceServiceImpl.swift
import Foundation
import os.log

@MainActor
final class ProgressPersistenceServiceImpl: ProgressPersistenceService {
    private let dataService: LocalDataService
    private let logger = Logger(subsystem: "com.driveai", category: "Progress")
    private var _progress: UserProgress?
    private var progressLoadTask: Task<Void, Never>?

    init(dataService: LocalDataService) {
        self.dataService = dataService
        self._progress = nil
    }

    // MARK: - Progress Management

    private var progress: UserProgress {
        get async throws {
            if let cached = _progress {
                return cached
            }

            // Cancel any ongoing load
            progressLoadTask?.cancel()

            // Load fresh progress
            progressLoadTask = Task {
                do {
                    let loadedProgress = try await dataService.fetchUserProgress() ?? UserProgress()
                    await MainActor.run {
                        self._progress = loadedProgress
                    }
                } catch {
                    logger.error("Failed to load progress: \(error.localizedDescription)")
                    throw error
                }
            }

            try Task.checkCancellation()

            // Wait for completion
            try await progressLoadTask?.value
            guard let result = _progress else {
                throw AppError.unknown("Failed to load progress")
            }
            return result
        }
    }

    func fetchProgress() async throws -> UserProgress {
        return try await progress
    }

    func saveExamDate(_ date: Date) async throws {
        let current = try await progress
        let updated = UserProgress(
            examDate: date,
            categoryProgress: current.categoryProgress,
            totalQuestions: current.totalQuestions,
            correctAnswers: current.correctAnswers
        )
        try dataService.saveUserProgress(updated)
        await MainActor.run {
            self._progress = updated
        }
    }

    func recordAnswer(questionId: String, categoryId: String, isCorrect: Bool) async throws {
        let current = try await progress
        var updatedProgress = current

        // Update category progress
        if var categoryProgress = updatedProgress.categoryProgress[categoryId] {
            categoryProgress.questionsAttempted += 1
            categoryProgress.correctAnswers += isCorrect ? 1 : 0
            updatedProgress.categoryProgress[categoryId] = categoryProgress
        } else {
            updatedProgress.categoryProgress[categoryId] = UserProgress.CategoryProgress(
                questionsAttempted: 1,
                correctAnswers: isCorrect ? 1 : 0
            )
        }

        // Update global stats
        updatedProgress.totalQuestions += 1
        updatedProgress.correctAnswers += isCorrect ? 1 : 0

        // Save
        try dataService.saveUserProgress(updatedProgress)
        await MainActor.run {
            self._progress = updatedProgress
        }
    }

    func resetProgress() throws {
        let emptyProgress = UserProgress()
        try dataService.saveUserProgress(emptyProgress)
        _progress = emptyProgress
    }

    func getWeakAreas() async throws -> [String] {
        let current = try await progress
        return current.categoryProgress.filter { categoryId, progress in
            let percentage = Double(progress.correctAnswers) / Double(progress.questionsAttempted)
            return percentage < 0.7 && progress.questionsAttempted > 5
        }.map { $0.key }
    }
}