@MainActor
final class HealthCheckService: ObservableObject {
    @Published var status: AIServiceStatus = .online {
        didSet {
            announceStatusChange()  // ← Announce to VoiceOver
        }
    }
    
    private func announceStatusChange() {
        let announcement: String
        
        switch status {
        case .online:
            announcement = "Verbindung wiederhergestellt. AI-Funktionen sind aktiv."
        case .offline:
            announcement = "Netzwerkverbindung unterbrochen. Die App funktioniert im Offline-Modus."
        case .degraded(let reason):
            announcement = "Begrenzte Funktionalität. \(reason)"
        case .error(let error):
            announcement = "Fehler aufgetreten: \(error.userFriendlyDescription)"
        }
        
        // Post announcement to accessibility system
        UIAccessibility.post(
            notification: .announcement,
            argument: announcement
        )
    }
}