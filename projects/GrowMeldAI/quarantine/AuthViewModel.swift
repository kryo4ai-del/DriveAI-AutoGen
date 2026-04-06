@MainActor
final class AuthViewModel: ObservableObject {
    @Published var authState: AuthState = .authenticating
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var errorAccessibilityId = UUID()  // Force VoiceOver update
    
    private func displayError(_ message: String) {
        self.errorMessage = message
        self.showError = true
        
        // Force VoiceOver announcement by changing ID
        self.errorAccessibilityId = UUID()
        
        // Post accessibility notification
        UIAccessibility.post(
            notification: .announcement,
            argument: message
        )
    }
}