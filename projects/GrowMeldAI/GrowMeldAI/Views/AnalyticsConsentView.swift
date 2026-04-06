struct AnalyticsConsentView: View {
    @Environment(ConsentManager.self) private var consentManager
    @State private var isConsentGiven = false
    @State private var showDetails = false
    @State private var showConfirmation = false
    
    var onDismiss: () -> Void = {}
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // ... header and toggle ...
            
            Spacer()
            
            // Action Buttons
            HStack(spacing: 12) {
                // REJECT
                Button(action: handleReject) {
                    Text("Datenerfassung ablehnen")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .accessibilityLabel("Datenerfassung ablehnen")
                
                // ACCEPT
                Button(action: handleAccept) {
                    Text("Einverstanden")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .accessibilityLabel("Datenerfassung akzeptieren")
            }
        }
        .padding()
        .alert("Bestätigung", isPresented: $showConfirmation) {
            Button("OK") { onDismiss() }
        } message: {
            Text(isConsentGiven
                ? "Danke! Wir nutzen deine Daten zur Verbesserung."
                : "Du kannst dies später in den Einstellungen ändern."
            )
        }
    }
    
    private func handleAccept() {
        isConsentGiven = true
        consentManager.setAnalyticsConsent(true)
        showConfirmation = true
    }
    
    private func handleReject() {
        isConsentGiven = false
        consentManager.setAnalyticsConsent(false)
        showConfirmation = true
    }
}