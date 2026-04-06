// LegalDisclaimerView.swift
import SwiftUI

struct LegalDisclaimerView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: .large) {
                Text("Rechtlicher Hinweis")
                    .font(.headline)
                    .padding(.bottom, .small)

                Text("""
                Diese App verwendet Fragen, die auf dem offiziellen TÜV/DEKRA-Katalog basieren.

                WICHTIG: Diese App ist nicht offiziell mit TÜV, DEKRA oder einer Führerscheinstelle verbunden.
                Die Fragen dienen ausschließlich als Lernhilfe und können von den offiziellen Prüfungsfragen abweichen.

                Für die offizielle Theorieprüfung wenden Sie sich bitte an eine anerkannte Fahrschule oder Prüfstelle.
                """)
                .font(.body)
                .foregroundColor(.secondary)

                Text("Copyright-Hinweis")
                    .font(.headline)
                    .padding(.top, .large)

                Text("""
                © 2024 DriveAI. Alle Rechte vorbehalten.

                Die verwendeten Fragen und Inhalte unterliegen dem Urheberrecht der jeweiligen
                Prüfungsstellen (TÜV, DEKRA, etc.). Diese App stellt keine offizielle Quelle dar.
                """)
                .font(.body)
                .foregroundColor(.secondary)

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Rechtliches")
    }
}

struct LegalDisclaimerView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            LegalDisclaimerView()
        }
    }
}