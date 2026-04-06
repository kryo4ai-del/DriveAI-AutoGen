// ❌ BAD: Service creation baked into view
init(questionID: UUID, feedbackService: FeedbackService, onDismiss: @escaping () -> Void) {
    _viewModel = StateObject(
        wrappedValue: FeedbackCollectionViewModel(
            questionID: questionID,
            feedbackService: feedbackService  // ✅ Passed correctly
        )
    )
}

// ❌ But nowhere does FlaggedQuestionsWidgetCard define where services come from
struct FlaggedQuestionsWidgetCard: View {
    @StateObject private var viewModel: FlaggedQuestionsViewModel
    
    init(feedbackService: FeedbackService, questionsService: QuestionsService, ...) {
        // ✅ Services passed in, good
    }
}