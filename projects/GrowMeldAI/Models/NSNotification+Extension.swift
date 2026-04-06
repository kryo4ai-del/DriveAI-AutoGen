extension NSNotification.Name {
    static let feedbackSaved = NSNotification.Name("FeedbackSaved")
    static let feedbackError = NSNotification.Name("FeedbackError")
}

// In ViewController/ViewModel:
NotificationCenter.default.addObserver(
    forName: NSNotification.Name.feedbackSaved,
    object: nil,
    queue: .main
) { _ in
    UIAccessibility.post(
        notification: .announcement,
        argument: "Feedback gespeichert"
    )
}

// In Service:
func saveFeedback(_ feedback: Feedback) async throws {
    try persistFeedback()
    NotificationCenter.default.post(
        name: NSNotification.Name.feedbackSaved,
        object: feedback
    )
}