// BETTER: Move to ViewModel
extension QuestionScreenViewModel {
    func getFeedbackState(
        for option: Question.Option,
        isSelected: Bool,
        isRevealed: Bool
    ) -> AnswerOptionView.FeedbackState {
        // Centralized logic
    }
}