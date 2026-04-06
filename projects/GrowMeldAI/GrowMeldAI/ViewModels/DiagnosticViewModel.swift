// MARK: - Presentation/Diagnostic/ViewModels/DiagnosticViewModel+Accessibility.swift

@MainActor
final class DiagnosticViewModel: ObservableObject {
    @Published var diagnosticResult: DiagnosticResult?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // NEW: Track accessibility announcements
    @Published var accessibilityAnnouncement: String = ""
    
    func loadDiagnosticResult() async {
        isLoading = true
        accessibilityAnnouncement = "Diagnose wird geladen"
        UIAccessibility.post(notification: .announcement, argument: accessibilityAnnouncement)
        
        defer { isLoading = false }
        
        do {
            var result = try await diagnoseUseCase.execute()
            let recommendations = try await recommendationsUseCase.execute(for: result)
            // ... enrichment logic ...
            
            self.diagnosticResult = result
            
            // Announce completion
            let announcementText = """
            Diagnose abgeschlossen. \(result.efficacyMessage)
            Kritische Lücken: \(result.gapCount(severity: .critical)).
            Empfohlene Zeit: \(result.estimatedMinutesToMastery) Minuten.
            """
            self.accessibilityAnnouncement = announcementText
            UIAccessibility.post(notification: .announcement, argument: announcementText)
            
        } catch {
            self.diagnosticResult = nil
            let errorText = "Diagnose fehlgeschlagen: \(error.localizedDescription)"
            self.errorMessage = errorText
            self.accessibilityAnnouncement = errorText
            UIAccessibility.post(notification: .announcement, argument: errorText)
        }
    }
}