struct ConsentBannerView: View {
    @StateObject private var consentManager = ConsentManager.shared
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Deine Privatsphäre ist wichtig")
                .font(.headline)
                .accessibilityAddTraits(.isHeader)
                .accessibilityIdentifier("consent_title")
            
            Text("Wir speichern dein Prüfdatum und Fortschritt lokal auf deinem Gerät. Du kannst jederzeit einsehen oder löschen, was wir speichern.")
                .font(.body)
                .accessibilityIdentifier("consent_description")
            
            Link(destination: URL(string: "https://driveai.de/privacy")!) {
                Text("Datenschutzerklärung")
                    .underline()
            }
            .accessibilityLabel("Datenschutzerklärung öffnen")
            .accessibilityIdentifier("privacy_policy_link")
            .accessibilityHint("Öffnet die vollständige Datenschutzerklärung in Safari")
            
            HStack(spacing: 12) {
                Button("Verstanden") {
                    Task {
                        await consentManager.giveConsent(type: .dataCollection)
                        dismiss()
                    }
                }
                .accessibilityIdentifier("consent_accept_button")
                .accessibilityLabel("Zustimmung erteilen und fortfahren")
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .accessibilityElement(children: .combine)
    }
}