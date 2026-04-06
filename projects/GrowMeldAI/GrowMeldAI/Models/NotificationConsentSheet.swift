struct NotificationConsentSheet: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            // Clear, non-manipulative heading
            Text("Lernimpulse & Motivation")
                .font(.headline)
            
            // Legal rationale (from LEGAL-002)
            Text(
                "Erhalte gezielte Erinnerungen und Motivation auf deinem Weg zum Führerschein — "
                + "wissenschaftlich optimiert für bessere Behaltensleistung."
            )
            .font(.callout)
            .foregroundColor(.secondary)
            
            // Transparency info
            VStack(alignment: .leading, spacing: 8) {
                Label(
                    "Max. 2 Benachrichtigungen pro Woche",
                    systemImage: "bell.badge"
                )
                Label(
                    "Nur Inhalte zum Führerschein",
                    systemImage: "checkmark.circle"
                )
                Label(
                    "Jederzeit abschaltbar in den Einstellungen",
                    systemImage: "gear"
                )
            }
            .font(.footnote)
            
            Spacer()
            
            // Action buttons (dismiss is explicit choice)
            HStack {
                Button("Später entscheiden") {
                    dismiss()
                }
                .buttonStyle(.bordered)
                
                Button("Ja, bitte!") {
                    Task {
                        await viewModel.requestNotificationConsent()
                        dismiss()
                    }
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
    }
}