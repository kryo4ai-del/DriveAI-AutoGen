// ViewModels/AnswerExplanationViewModel.swift
class AnswerExplanationViewModel: ObservableObject {
    @Published var isCorrect: Bool = false
    @Published var explanation: String = ""
    @Published var confidenceScore: Double = 0.0
    @Published var confidenceLabel: String = "Low"

    private var question: Question?

    func loadQuestion(_ question: Question, selectedAnswerId: UUID) {
        self.question = question
        if let question = self.question {
            self.isCorrect = selectedAnswerId == question.correctAnswerId
            self.explanation = question.explanation
        }
    }

    func applyResult(_ result: AnswerResult) {
        self.explanation = result.explanation
        self.confidenceScore = result.confidence.score
        self.confidenceLabel = result.confidence.label
    }
}
