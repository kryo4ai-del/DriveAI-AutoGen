import SwiftUI

struct ConsentSheet: View {
    @Environment(\.dismiss) var dismiss
    var onGranted: (Bool) -> Void

    var body: some View {
        VStack(spacing: 20) {
            // FIXED: Mark as heading
            Text("Daten & Datenschutz")
                .font(.headline)
                .accessibilityAddTraits(.isHeader)
                .accessibilityLabel("Daten & Datenschutz") // Explicit label

            // FIXED: Add accessibility container with hint
            VStack(alignment: .leading, spacing: 8) {
                Text("DriveAI nutzt anonymisierte Daten, um die App zu verbessern.")
                Text("Deine Prüfungsergebnisse werden nicht mit Meta Ads geteilt.")
            }
            .font(.body)
            .foregroundColor(.secondary)
            .accessibilityElement(children: .combine) // Group paragraphs
            .accessibilityLabel("Datenschutzerklärung")
            .accessibilityHint("DriveAI teilt nur anonymisierte Nutzungsdaten, nicht Ihre Prüfungsergebnisse")

            // FIXED: Group buttons semantically
            HStack(spacing: 12) {
                Button("Ablehnen") {
                    onGranted(false)
                    dismiss()
                }
                .buttonStyle(.bordered)
                .accessibilityLabel("Ablehnen")
                .accessibilityHint("Verhindert Datensharing mit Meta Ads")

                Button("Akzeptieren") {
                    onGranted(true)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .accessibilityLabel("Akzeptieren")
                .accessibilityHint("Erlaubt DriveAI, Daten zum Verbessern zu nutzen")
            }
            .accessibilityElement(children: .contain) // Group buttons

            Spacer()
        }
        .padding()
        .presentationDetents([.fraction(0.35)])
        // FIXED: Make entire sheet accessible
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Datenschutz-Einwilligung")
    }
}