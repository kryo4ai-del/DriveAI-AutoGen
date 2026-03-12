import SwiftUI
import Combine

class MultipleChoiceViewModel: ObservableObject {
    @Published var question: QuestionModel?
    @Published var selectedAnswerIndex: Int?
    @Published var isAnswered: Bool = false
    @Published var feedbackMessage: String = ""

    private var cancellables = Set<AnyCancellable>()

    init() {
        loadQuestion()
    }

    // Simulated function to load a question; should be replaced by data service in production.
    func loadQuestion() {
        let correctId = UUID()
        self.question = QuestionModel(
            id: UUID(),
            question: "What does this sign mean?",
            answers: [
                AnswerModel(id: correctId, text: "Stop"),
                AnswerModel(id: UUID(), text: "Yield"),
                AnswerModel(id: UUID(), text: "No entry"),
                AnswerModel(id: UUID(), text: "Go"),
            ],
            correctAnswer: correctId
        )
    }

    // Select an answer and evaluate its correctness.
    func selectAnswer(at index: Int) {
        guard let question = question else { return }
        selectedAnswerIndex = index
        isAnswered = true
        let isCorrect = question.answers[index].id == question.correctAnswer
        feedbackMessage = isCorrect ? "Correct!" : "Incorrect. Try again."
    }

    // Reset the question and feedback for the next attempt.
    func reset() {
        selectedAnswerIndex = nil
        isAnswered = false
        feedbackMessage = ""
        loadQuestion()
    }
}
