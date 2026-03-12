import SwiftUI
import Combine

class DemoFlowViewModel: ObservableObject {
    @Published private(set) var questions: [Question] = []
    @Published private(set) var currentQuestion: Question?
    @Published private(set) var currentIndex: Int = 0
    @Published var quizResult: QuizResult?
    @Published var feedback: (message: String, isCorrect: Bool)?

    private var cancellables = Set<AnyCancellable>()

    /// Loads questions from the local data service.
    func loadQuestions() {
        questions = LocalDataService.shared.loadQuestions()
        if questions.isEmpty {
            feedback = ("No questions available.", false)
        } else {
            currentQuestion = questions.first
        }
    }

    /// Evaluates the user's answer to the current question.
    func answerQuestion(with answer: String) {
        guard let question = currentQuestion else { return }
        let correctAnswer = question.options.first(where: { $0.id == question.correctAnswerId })?.text ?? ""
        evaluateAnswer(selectedAnswer: answer, correctAnswer: correctAnswer)
        currentIndex += 1

        if currentIndex < questions.count {
            currentQuestion = questions[currentIndex]
        } else {
            quizResult = QuizResult(totalQuestions: questions.count, correctAnswers: currentIndex)
        }
    }

    /// Evaluates the selected answer against the correct answer and sets feedback accordingly.
    private func evaluateAnswer(selectedAnswer: String, correctAnswer: String) {
        if selectedAnswer == correctAnswer {
            feedback = (NSLocalizedString("Correct!", comment: ""), true)
        } else {
            feedback = (NSLocalizedString("Wrong! The correct answer is \(correctAnswer).", comment: ""), false)
        }
    }

    /// Resets the quiz to allow for a new experience.
    func resetQuiz() {
        currentIndex = 0
        feedback = nil
        loadQuestions()
    }
}
