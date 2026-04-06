// ViewModels/PremiumFeatureViewModel.swift
@MainActor

// Usage in Views:
struct ExamSimulationGateView: View {
    @StateObject var premiumVM: PremiumFeatureViewModel
    @State var examAttemptsRemaining = 3
    
    var body: some View {
        if premiumVM.canAccessUnlimitedExams || examAttemptsRemaining > 0 {
            ExamSimulationView()
        } else {
            PurchasePromptView(
                title: "Unbegrenzte Prüfungssimulationen freischalten",
                subtitle: "Üben Sie so oft Sie möchten"
            )
        }
    }
}