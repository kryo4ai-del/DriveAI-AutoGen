// ✅ ACCESSIBLE ASYNC HANDLING
@MainActor
final class ExamLocationViewModel: ObservableObject {
    @Published var isGeocoding = false
    @Published var geocodingMessage: String?
    
    func saveExamLocation() async {
        isGeocoding = true
        geocodingMessage = "Adresse wird verarbeitet..."
        
        defer {
            isGeocoding = false
        }
        
        do {
            await coordinator.setExamLocation(examLocation)
            geocodingMessage = "Prüfungsort gespeichert"
            // Announce with priority
            UIAccessibility.post(
                notification: .announcement,
                argument: "Prüfungsort erfolgreich gespeichert"
            )
        } catch {
            geocodingMessage = "Fehler beim Speichern: \(error.localizedDescription)"
            UIAccessibility.post(
                notification: .announcement,
                argument: geocodingMessage
            )
        }
    }
}

// In View
if viewModel.isGeocoding {
    ProgressView()
        .accessibilityLabel("Standort wird verarbeitet")
        .accessibilityAddTraits(.updatesFrequently)
}

if let message = viewModel.geocodingMessage {
    Text(message)
        .accessibilityLabel(message)
        .accessibilityAddTraits(.updatesFrequently)
}