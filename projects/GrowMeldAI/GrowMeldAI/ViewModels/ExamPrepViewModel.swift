// File: ViewModels/ExamPrepViewModel.swift
import Foundation
import Combine

@MainActor
final class ExamPrepViewModel: ObservableObject {
    @Published private(set) var questions: [ExamQuestion] = []
    @Published private(set) var currentQuestionIndex = 0
    @Published private(set) var userAnswers: [UUID: Int] = [:]
    @Published private(set) var score = 0
    @Published private(set) var isExamCompleted = false
    @Published private(set) var timeRemaining = 1800 // 30 minutes in seconds
    @Published var isTimerRunning = false

    private var timer: Timer?
    private let questionService: QuestionServiceProtocol

    init(questionService: QuestionServiceProtocol = LocalQuestionService()) {
        self.questionService = questionService
        loadQuestions()
    }

    private func loadQuestions() {
        questions = questionService.loadQuestions()
    }

    func selectAnswer(_ answerIndex: Int) {
        guard currentQuestionIndex < questions.count else { return }
        let currentQuestion = questions[currentQuestionIndex]
        userAnswers[currentQuestion.id] = answerIndex

        if answerIndex == currentQuestion.correctAnswerIndex {
            score += 1
        }
    }

    func nextQuestion() {
        guard currentQuestionIndex + 1 < questions.count else {
            completeExam()
            return
        }
        currentQuestionIndex += 1
    }

    func previousQuestion() {
        guard currentQuestionIndex > 0 else { return }
        currentQuestionIndex -= 1
    }

    private func completeExam() {
        isExamCompleted = true
        stopTimer()
    }

    func startTimer() {
        guard !isTimerRunning else { return }
        isTimerRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.completeExam()
            }
        }
    }

    func stopTimer() {
        timer?.invalidate()
        isTimerRunning = false
    }

    func resetExam() {
        currentQuestionIndex = 0
        userAnswers.removeAll()
        score = 0
        isExamCompleted = false
        timeRemaining = 1800
        isTimerRunning = false
        stopTimer()
    }

    var currentQuestion: ExamQuestion? {
        guard currentQuestionIndex < questions.count else { return nil }
        return questions[currentQuestionIndex]
    }

    var progress: Double {
        guard !questions.isEmpty else { return 0 }
        return Double(currentQuestionIndex + 1) / Double(questions.count)
    }

    var timeString: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var isAnswerSelected: Bool {
        guard let currentQuestion = currentQuestion else { return false }
        return userAnswers[currentQuestion.id] != nil
    }

    var hasPassed: Bool {
        guard isExamCompleted else { return false }
        let passingScore = Int(Double(questions.count) * 0.9) // 90% passing threshold
        return score >= passingScore
    }
}