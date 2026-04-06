struct PushConsentSheet: View {
    @ObservedObject var viewModel: PushConsentViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            VStack {
                // ...
                Button(action: {
                    Task {
                        await viewModel.acceptConsent()
                        dismiss()  // Explicit dismiss after completion
                    }
                }) {
                    Text("consent.button.accept".localized())
                }
            }
            
            // Error overlay that persists even if sheet would close
            if let errorMessage = viewModel.errorMessage {
                VStack {
                    Text(errorMessage)
                        .foregroundColor(.red)
                    Button("consent.error.openSettings".localized()) {
                        UIApplication.shared.open(
                            URL(string: UIApplication.openSettingsURLString)!
                        )
                    }
                }
                .padding()
            }
        }
    }
}