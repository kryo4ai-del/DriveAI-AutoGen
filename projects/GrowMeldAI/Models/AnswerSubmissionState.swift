import Foundation

enum AnswerSubmissionState {
    case unanswered
    case answered(selectedAnswerId: Int)
    case evaluated(selectedAnswerId: Int, isCorrect: Bool)
}