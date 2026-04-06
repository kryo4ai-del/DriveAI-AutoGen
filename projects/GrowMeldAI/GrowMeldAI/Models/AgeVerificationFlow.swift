struct AgeVerificationFlow: View {
    @StateObject private var viewModel = AgeVerificationViewModel()
    
    // ✅ StateObject manages lifecycle
    // But if Task in viewModel never completes, it holds reference
}

// In ViewModel:
func submitParentalEmail() {
    Task {
        isProcessing = true
        try await ageVerificationService.saveParentalEmail(...)
        // If service hangs → Task never completes → viewModel held in memory
    }
}