@MainActor
final class ReadinessViewModel: ObservableObject {
    @Published var readinessPercentage: Double = 0.0
    @Published var status: ReadinessStatus = .red
    @Published var questionsRemaining: Int = 24
    @Published var passRatePercentage: Int = 0
    @Published var motivationMessage: String = ""  // ✅ Published
    
    func updateReadiness() {
        // ... existing logic ...
        
        // ✅ Update published property
        motivationMessage = switch status {
        case .red:
            "Du schaffst das! Noch \(questionsRemaining) Fragen zum Erfolg."
        case .yellow:
            "Fast bereit! Nur noch \(questionsRemaining) \(questionsRemaining == 1 ? "Frage" : "Fragen")."
        case .green:
            "🎉 Du bist prüfungsreif! Viel Erfolg beim Test!"
        }
    }
}