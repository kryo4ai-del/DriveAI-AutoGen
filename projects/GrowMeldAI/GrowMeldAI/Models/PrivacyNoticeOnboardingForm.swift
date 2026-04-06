// Privacy Notice during form completion
struct PrivacyNoticeOnboardingForm: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Wie wir Ihre Daten verwenden")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                PrivacyInfoRow(
                    title: "Prüfungsdatum",
                    description: "Verwendet für einen Countdown-Timer in Ihrem Dashboard. Lokal gespeichert, nicht mit Servern synchronisiert.",
                    dataSubject: "Sie"
                )
                
                PrivacyInfoRow(
                    title: "Führerscheinkategorie",
                    description: "Verwendet zur Filterung von Lernfragen. Lokal gespeichert, nicht mit Servern synchronisiert.",
                    dataSubject: "Sie"
                )
                
                PrivacyInfoRow(
                    title: "Profilname",
                    description: "Angezeigt in Ihrem Profil und lokalen Statistiken. Lokal gespeichert. Sie können dies jederzeit ändern oder löschen.",
                    dataSubject: "Sie"
                )
            }
            
            Divider()
            
            Text("Alle Ihre Daten sind lokal auf Ihrem Gerät. Wir synchronisieren nicht mit Servern während der Onboarding-Phase.")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

struct PrivacyInfoRow: View {
    let title: String
    let description: String
    let dataSubject: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
            
            HStack(alignment: .top, spacing: 4) {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.blue)
                    .frame(width: 16, height: 16)
                
                Text(description)
                    .font(.caption)
                    .lineLimit(nil)
            }
        }
    }
}