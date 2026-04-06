struct AgeVerificationScreen: View {
    @StateObject var viewModel: AgeGatingViewModel
    
    var body: some View {
        VStack(spacing: 24) {
            // Header: "Sind du bereit für die Prüfung?"
            
            // Age Threshold Logic:
            // "Du musst mindestens 16 Jahre alt sein, um Fragen zu beantworten."
            
            Toggle("Ich bin mindestens 16 Jahre alt", isOn: $viewModel.confirmedAge16Plus)
            
            if viewModel.complianceRegime == .coppaAndGdpr || .coppaOnly {
                if !viewModel.confirmedAge16Plus && viewModel.detectedUserUnder13 {
                    // Show parental consent flow
                    ParentalConsentPrompt(email: $viewModel.parentalEmail)
                }
            }
            
            Button(action: { viewModel.proceedToApp() }) {
                Text("Weiter zur App")
            }
            .disabled(!viewModel.canProceed)
        }
    }
}