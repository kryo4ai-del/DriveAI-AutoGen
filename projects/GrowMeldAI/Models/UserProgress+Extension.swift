import Foundation

struct UserProgress {
    var categoryId: UUID
    var categoryName: String
    var totalQuestionsAnswered: Int = 0
    var correctAnswers: Int = 0
    var lastReviewedDate: Date = Date()

    func recordingCorrectAnswer() -> UserProgress {
        var copy = self
        copy.totalQuestionsAnswered += 1
        copy.correctAnswers += 1
        copy.lastReviewedDate = Date()
        return copy
    }

    func recordingIncorrectAnswer() -> UserProgress {
        var copy = self
        copy.totalQuestionsAnswered += 1
        copy.lastReviewedDate = Date()
        return copy
    }
}

// In ViewModel:
class ViewModel: ObservableObject {
    @Published var progress: UserProgress = .init(categoryId: UUID(), categoryName: "")

    func recordAnswer(correct: Bool) {
        progress = correct ? progress.recordingCorrectAnswer() : progress.recordingIncorrectAnswer()
    }
}