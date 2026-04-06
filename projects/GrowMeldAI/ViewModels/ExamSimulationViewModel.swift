// DriveAI/ViewModels/Exam/ExamSimulationViewModel.swift
import Foundation
import Combine

final class ExamSimulationViewModel: ObservableObject {
    @Published var state: ExamState = .initial
    @Published var remainingSeconds: Int = 2700 // 45 min
    @Published var currentQuestionIndex: Int = 0
    @Published var selectedAnswerIndex: Int?
    @Published var score: Int = 0

    private var timer: Timer?
    private var questions: [Question] = []
    private let container: ServiceContainer
    private var cancellables = Set<AnyCancellable>()

    init(container: ServiceContainer = .shared) {
        self.container = container
    }

    deinit {
        timer?.invalidate()
    }

    @MainActor
    func startExam() async {
        state = .loadingQuestions
        do {
            questions = try await container.questionProvider.fetchExamSet()
            guard !questions.isEmpty else {
                state = .failed(score: 0)
                return
            }

            state = .inProgress(currentQuestionIndex: 0)
            remainingSeconds = 2700
            currentQuestionIndex = 0
            score = 0
            startTimer()
        } catch {
            state = .failed(score: 0)
        }
    }

    func submitAnswer(_ answerIndex: Int) {
        guard case .inProgress = state else { return }

        selectedAnswerIndex = answerIndex

        Task {
            let isCorrect = questions[currentQuestionIndex].correctAnswerIndex == answerIndex
            if isCorrect {
                score += 1
            }

            // Small delay before moving to next question
            try await Task.sleep(nanoseconds: 1_000_000_000)

            moveToNextQuestion()
        }
    }

    func pauseExam() {
        state = .paused
        timer?.invalidate()
    }

    func resumeExam() {
        state = .inProgress(currentQuestionIndex: currentQuestionIndex)
        startTimer()
    }

    func submitExam() {
        timer?.invalidate()
        state = .submitted
    }

    private func moveToNextQuestion() {
        guard currentQuestionIndex < questions.count - 1 else {
            submitExam()
            return
        }

        currentQuestionIndex += 1
        selectedAnswerIndex = nil
    }

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }

            if self.remainingSeconds > 0 {
                self.remainingSeconds -= 1
            } else {
                self.timer?.invalidate()
                self.state = .failed(score: self.score)
            }
        }
    }
}
