// ✅ GDPR COMPLIANT - Explicit biometric consent

struct BiometricConsentView: View {
    @Binding var consentGiven: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Profilfoto (optional)")
                .font(.headline)
            
            Text("""
            Ihr Profilfoto ist optional und wird dazu verwendet:
            • Zur Personalisierung Ihres Lernprofils
            • Zur Verifizierung Ihrer Identität während der Prüfung (zukünftig)
            
            Ihre Daten werden:
            • Ausschließlich lokal auf Ihrem Gerät gespeichert
            • NICHT an Server übertragen
            • Nach 2 Jahren automatisch gelöscht
            • Auf Anfrage sofort gelöscht
            """)
            .font(.body)
            .lineLimit(nil)
            
            // ✅ EXPLICIT CONSENT (GDPR Article 9)
            Toggle(isOn: $consentGiven) {
                Text("Ich akzeptiere die Verarbeitung meines Profilfotos als biometrische Daten")
                    .font(.footnote)
            }
            .padding(.vertical, 8)
            .accessibilityHint("Sie können das Foto überspringen, wenn Sie nicht zustimmen")
            
            Link(destination: URL(string: "https://yourapp.com/privacy")!) {
                Text("Datenschutzrichtlinie anzeigen")
                    .font(.footnote)
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

// Usage:
@State private var biometricConsentGiven = false

CameraScreen(
    viewModel: viewModel,
    biometricConsent: $biometricConsentGiven
)