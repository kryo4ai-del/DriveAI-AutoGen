import Foundation

extension AnswerRecord {
    var id: UUID { UUID() }

    var accessibilityLabel: String {
        isCorrect ? "Correct answer" : "Wrong answer"
    }
}