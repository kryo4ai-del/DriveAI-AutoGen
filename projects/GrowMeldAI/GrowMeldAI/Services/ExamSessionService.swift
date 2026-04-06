// MARK: - Services/ExamSessionService.swift
import Foundation

@MainActor
final class ExamSessionService: ObservableObject {
    @Published var currentSession: ExamSession?
    @Published var error: AppError?

    private let progressRepository: ProgressRepository

    init(progressRepository: ProgressRepository) {
        self.progressRepository = progressRepository
    }

    func startExamSession(questionCount: Int = 30) {
        let session = ExamSession(
            id: UUID().uuidString,
            startTime: Date(),
            totalQuestions: questionCount,
            answers: [:]
        )
        currentSession = session
    }

    func recordAnswer(questionId: String, optionId: String, isCorrect: Bool) {
        guard var session = currentSession else { return }
        session.recordAnswer(questionId, optionId: optionId, isCorrect: isCorrect)
        currentSession = session
    }

    func endExamSession() async {
        guard var session = currentSession else { return }

        session.endTime = Date()
        currentSession = session

        do {
            var progress = try await progressRepository.loadProgress()
            progress.recordExamCompletion(session)
            try await progressRepository.saveProgress(progress)
        } catch {
            self.error = error as? AppError ?? .unknown("Failed to save progress")
        }
    }

    func cancelExamSession() {
        currentSession = nil
    }
}