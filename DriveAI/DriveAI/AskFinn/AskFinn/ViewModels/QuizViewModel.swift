import Foundation
import Combine

class QuizViewModel: ObservableObject {
    @Published var questions: [Question] = []
    @Published var currentQuestionIndex: Int = 0
    @Published var score: Int = 0
    var passed: Bool { score >= 20 } // Example passing criteria

    init() {
        self.questions = LocalDataService().loadQuestions()
    }

    var currentQuestion: Question? {
        guard currentQuestionIndex < questions.count else { return nil }
        return questions[currentQuestionIndex]
    }

    func submitAnswer(_ answerId: UUID) {
        if answerId == currentQuestion?.correctAnswerId {
            score += 1
        }
        loadNextQuestion()
    }

    private func loadNextQuestion() {
        guard currentQuestionIndex < questions.count - 1 else { return }
        currentQuestionIndex += 1
    }
}
