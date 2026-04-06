// Views/Legal/AutoRenewalAcknowledgmentView.swift
import SwiftUI

struct AutoRenewalAcknowledgmentView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Automatische Verlängerung")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("""
                Dein Premium-Abo verlängert sich automatisch, es sei denn, du kündigst es mindestens 24 Stunden vor Ablauf der aktuellen Abrechnungsperiode.

                • Die Verlängerung erfolgt zum aktuellen Preis
                • Du kannst dein Abo jederzeit kündigen
                • Nach der Kündigung hast du bis zum Ende der aktuellen Abrechnungsperiode vollen Zugriff

                Du kannst dein Abo über die App Store-Einstellungen verwalten.
                """)
                .font(.body)
                .foregroundStyle(.secondary)

                Spacer()
            }
            .padding()
        }
        .presentationDetents([.medium, .large])
    }
}