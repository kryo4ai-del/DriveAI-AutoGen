struct ParentalConsentStep: View {
    @ObservedObject var viewModel: AgeVerificationViewModel
    @Environment(\.scenePhase) var scenePhase
    
    var body: some View {
        ParentalConsentContent(viewModel: viewModel)
            .onChange(of: viewModel.currentStep) { newStep in
                // ✅ If user navigated away, cancel submission
                if newStep != .parentalConsent && viewModel.isProcessing {
                    // Cancel task in ViewModel
                }
            }
            .onDisappear {
                // ✅ Clean up if swiped back
                viewModel.cancelCurrentOperation()
            }
    }
}