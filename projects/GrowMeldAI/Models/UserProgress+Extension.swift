extension UserProgress {
    func recordingCorrectAnswer() -> UserProgress {
        var copy = self
        copy.totalQuestionsAnswered += 1
        copy.correctAnswers += 1
        copy.lastReviewedDate = Date()
        return copy
    }
}

// In ViewModel:
@Published var progress: UserProgress = .init(categoryId: UUID(), categoryName: "")

func recordAnswer(correct: Bool) {
    progress = correct ? progress.recordingCorrectAnswer() : progress.recordingIncorrectAnswer()
}