// Move validation to ViewModel layer (enforces UI contract)
class FeedbackViewModel {
    @Published var consentCheckboxEnabled: Bool = true
    @Published var consentCheckboxTapped: Bool = false
    
    var canSubmitFeedback: Bool {
        !content.isEmpty && consentCheckboxTapped  // Must be explicitly tapped
    }
    
    func submitDetailedFeedback() async throws {
        guard consentCheckboxTapped else {
            throw FeedbackError.consentNotTapped  // Explicit error
        }
        // Safe to call service with consent=true
    }
}