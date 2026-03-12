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
        self.question = QuestionModel(
            id: 1,
            question: "What does this sign mean?",
            answers: [
                AnswerModel(id: 0, answer: "Stop"),
                AnswerModel(id: 1, answer: "Yield"),
                AnswerModel(id: 2, answer: "No entry"),
                AnswerModel(id: 3, answer: "Go"),
            ],
            correctAnswerIndex: 0
        )
    }
    
    // Select an answer and evaluate its correctness.
    func selectAnswer(at index: Int) {
        guard let question = question else { return }
        selectedAnswerIndex = index
        isAnswered = true
        evaluateAnswer(selectedIndex: index, correctIndex: question.correctAnswerIndex)
    }
    
    // Evaluate the selected answer and set feedback message.
    private func evaluateAnswer(selectedIndex: Int, correctIndex: Int) {
        feedbackMessage = selectedIndex == correctIndex ? "Correct!" : "Incorrect. Try again."
    }
    
    // Reset the question and feedback for the next attempt.
    func reset() {
        selectedAnswerIndex = nil
        isAnswered = false
        feedbackMessage = ""
        loadQuestion()
    }
}