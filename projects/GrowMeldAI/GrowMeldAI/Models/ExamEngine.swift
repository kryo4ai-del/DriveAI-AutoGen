// File: ExamEngine.swift
import Foundation

final class ExamEngine: ObservableObject {
    @Published var currentQuestion: Question?
    @Published var userAnswers: [UUID: Int] = [:]
    @Published var isExamCompleted = false
    @Published var score: Double = 0

    private var questions: [Question] = []
    private var currentIndex = 0

    func startExam(with questions: [Question]) {
        self.questions = questions.shuffled()
        currentIndex = 0
        currentQuestion = questions.first
        userAnswers = [:]
        isExamCompleted = false
        score = 0
    }

    func answerCurrentQuestion(with optionIndex: Int) {
        guard let question = currentQuestion else { return }

        userAnswers[question.id] = optionIndex

        if currentIndex < questions.count - 1 {
            currentIndex += 1
            currentQuestion = questions[currentIndex]
        } else {
            completeExam()
        }
    }

    private func completeExam() {
        let correctAnswers = questions.filter { question in
            userAnswers[question.id] == question.correctAnswerIndex
        }.count

        score = Double(correctAnswers) / Double(questions.count) * 100
        isExamCompleted = true

        // Update user progress
        let coordinator = AppCoordinator()
        coordinator.userProgress.totalQuestionsAnswered += questions.count
        coordinator.userProgress.correctAnswers += correctAnswers

        // Add confidence entry
        let entry = UserProgress.ConfidenceEntry(
            date: Date(),
            readinessScore: coordinator.userProgress.readinessScore,
            message: coordinator.userProgress.motivationalMessage
        )
        coordinator.userProgress.confidenceHistory.append(entry)
    }
}