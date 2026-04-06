import Foundation

extension AnswerRecord {
    var accessibilityLabel: String {
        isCorrect ? "Correct answer" : "Wrong answer"
    }
}