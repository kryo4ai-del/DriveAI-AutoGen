// Views/QuestionFeedbackView.swift
struct QuestionFeedbackView: View {
    let result: QuestionResult // Passed in from parent
    let onDismiss: () -> Void
    
    var body: some View {
        // Pure presentation layer
        FeedbackStateDisplay(result: result)
            .onAppear {
                // Side effect happens OUTSIDE this view
                // Parent (QuestionViewModel) handles recording
            }
    }
}

// Parent responsibility: