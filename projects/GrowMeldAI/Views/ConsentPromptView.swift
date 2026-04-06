import SwiftUI
import Foundation

struct ConsentPromptView: View {
    @State private var selectedConsent: Bool?

    var body: some View {
        VStack(spacing: 20) {
            Text("Hilf uns, DriveAI zu verbessern")
                .font(.headline)
                .accessibilityAddTraits(.isHeader)

            Text("Deine Lernaktivitäten helfen uns, die Fragen zu verbessern und dir besser zu unterstützen.")
                .font(.body)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)

            Spacer().frame(height: 20)

            Button(action: {
                selectedConsent = true
                UserDefaults.standard.set(true, forKey: "crashReportingConsent")
            }) {
                Text("Ja, hilf mir zu lernen")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .accessibilityLabel("Zustimmung geben")
            .accessibilityHint("Mit dieser Auswahl teilst du deine Lernaktivitäten mit DriveAI. Du kannst dies später in den Einstellungen ändern.")
            .accessibilityAddTraits(.isButton)
            .frame(minHeight: 44)

            Button(action: {
                selectedConsent = false
                UserDefaults.standard.set(false, forKey: "crashReportingConsent")
            }) {
                Text("Jetzt nicht")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.gray)
                    .foregroundColor(.black)
                    .cornerRadius(8)
            }
            .accessibilityLabel("Ablehnung")
            .accessibilityHint("Mit dieser Auswahl teilst du keine Lernaktivitäten mit DriveAI. Deine Datenschutzeinstellungen können später jederzeit geändert werden.")
            .accessibilityAddTraits(.isButton)
            .frame(minHeight: 44)
        }
        .padding()
        .onAppear {
            UIAccessibility.post(
                notification: .announcement,
                argument: "Datenschutz-Einstellung erforderlich. Zwei Optionen verfügbar."
            )
        }
    }
}