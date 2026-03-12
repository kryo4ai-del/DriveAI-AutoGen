import Foundation
import Combine

class DemoQuizViewModel: ObservableObject {
    @Published var questions: [QuizQuestion] = []
    @Published var currentQuestionIndex: Int = 0
    @Published var selectedAnswerIndex: Int? = nil
    @Published var results: QuizResult?
    @Published var errorMessage: String? // New property for error messages

    private var correctAnswers: Int = 0

    init() {
        loadQuestions()
    }

    private func loadQuestions() {
        do {
            self.questions = try LocalDataService.shared.loadQuizQuestions()
        } catch {
            errorMessage = "Failed to load questions. Please try again later." // Setting an error message
            print("Error loading questions: \(error.localizedDescription)")
        }
    }

    func selectAnswer(index: Int) {
        selectedAnswerIndex = index
        if index == questions[currentQuestionIndex].correctAnswerIndex {
            correctAnswers += 1
        }
    }

    func nextQuestion() {
        if currentQuestionIndex < questions.count - 1 {
            currentQuestionIndex += 1
            selectedAnswerIndex = nil
        } else {
            finalizeResults()
        }
    }

    private func finalizeResults() {
        results = QuizResult(totalQuestions: questions.count, correctAnswers: correctAnswers)
    }

    var totalCorrectAnswers: Int {
        return correctAnswers
    }
}