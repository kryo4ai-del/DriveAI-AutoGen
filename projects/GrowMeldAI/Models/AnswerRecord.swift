import Foundation

struct AnswerRecord: Identifiable {
    let id: UUID
    let isCorrect: Bool

    /// Accessibility label describing the result of this answer
    var accessibilityLabel: String {
        isCorrect ? "Correct answer" : "Wrong answer"
    }

    init(id: UUID = UUID(), isCorrect: Bool) {
        self.id = id
        self.isCorrect = isCorrect
    }
}