// ✅ CORRECT: Persistent consent with timestamp

struct PrivacyConsentScreen: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var consentGiven = false
    
    var body: some View {
        Toggle(isOn: $consentGiven) {
            Text("Ich akzeptiere die Datenschutzerklärung")
        }
        
        PrimaryButton("Weiter") {
            Task {
                do {
                    if consentGiven {
                        try await viewModel.grantConsent()
                    }
                    viewModel.moveToNext()
                } catch {
                    viewModel.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
