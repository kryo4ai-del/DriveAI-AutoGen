// Features/Feedback/ViewModels/PreviousFeedbackViewModel.swift
@MainActor
final class PreviousFeedbackViewModel: ObservableObject {
    @Published var feedback: UserFeedback?
    @Published var isLoading: Bool = false
    
    private let feedbackService: FeedbackService
    
    init(feedbackService: FeedbackService) {
        self.feedbackService = feedbackService
    }
    
    func loadFeedback(for questionID: UUID) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            feedback = try await feedbackService.getFeedback(for: questionID)
        } catch {
            feedback = nil
        }
    }
}