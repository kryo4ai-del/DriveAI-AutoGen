// HomeView
@State private var showErrorAlert = false
@State private var errorMessage: String?

.onAppear {
    viewModel.loadProgress { result in
        switch result {
        case .success:
            isLoading = false
        case .failure(let error):
            errorMessage = "Laden der Fortschritt fehlgeschlagen: \(error.localizedDescription)"
            showErrorAlert = true
        }
    }
}
.alert(isPresented: $showErrorAlert) {
    Alert(
        title: Text("Fehler"),
        message: Text(errorMessage ?? "Unbekannter Fehler aufgetreten."),
        dismissButton: .default(Text("OK"))
    )
}