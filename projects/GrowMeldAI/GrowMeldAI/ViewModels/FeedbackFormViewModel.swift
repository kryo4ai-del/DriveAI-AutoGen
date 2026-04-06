@MainActor
final class FeedbackFormViewModel: ObservableObject {
    // Remove ", Sendable"
    // @MainActor guarantee IS sufficient for thread safety
    @Published var feedbackText = ""
    // ... @Published properties are safe on MainActor
    
    // Safe to call actor services from main thread
    func submitFeedback() async {
        try await feedbackService.submit(feedback: feedback)
        // Isolation checked at compile time
    }
}