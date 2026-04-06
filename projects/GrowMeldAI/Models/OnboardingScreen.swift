struct OnboardingScreen: View {
    @State var name = ""
    @State var examDate = Date.now.addingTimeInterval(86400 * 60)
    @State var showError = false
    @State var errorMessage = ""
    @State var showHome = false
    
    var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        examDate > .now
    }
    
    private func createProfile() {
        do {
            let profile = UserProfile(
                id: UUID(),
                name: name.trimmingCharacters(in: .whitespaces),
                examDate: examDate,
                darkModeEnabled: false
            )
            try dataService.saveUserProfile(profile)  // Now throws
            showHome = true
        } catch {
            errorMessage = "Profil konnte nicht gespeichert werden: \(error.localizedDescription)"
            showError = true
        }
    }
    
    var body: some View {
        // ... existing code ...
        .alert("Fehler", isPresented: $showError) {
            Button("OK") { showError = false }
        } message: {
            Text(errorMessage)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Onboarding Formular")
    }
}