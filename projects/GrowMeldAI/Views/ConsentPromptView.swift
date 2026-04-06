// Views/Onboarding/ConsentPromptView.swift

import SwiftUI

struct ConsentPromptView: View {
    @State private var privacyService: PrivacyConsentService = PrivacyConsentService.shared
    @State private var selectedConsent: Bool?
    
    var body: some View {
        VStack(spacing: 20) {
            // Heading
            Text("Hilf uns, DriveAI zu verbessern")
                .font(.headline)
                .accessibilityAddTraits(.isHeader)
            
            // Description (important for context)
            Text("Deine Lernaktivitäten helfen uns, die Fragen zu verbessern und dir besser zu unterstützen.")
                .font(.body)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer().frame(height: 20)
            
            // YES button
            Button(action: {
                selectedConsent = true
                privacyService.updateCrashReportingConsent(true)
            }) {
                Text("Ja, hilf mir zu lernen")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)  // Ensure 44pt touch target
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .accessibilityLabel("Zustimmung geben")
            .accessibilityHint("Mit dieser Auswahl teilst du deine Lernaktivitäten mit DriveAI. Du kannst dies später in den Einstellungen ändern.")
            .accessibilityAddTraits(.isButton)
            .frame(minHeight: 44)  // Minimum touch target
            
            // NO button
            Button(action: {
                selectedConsent = false
                privacyService.updateCrashReportingConsent(false)
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
            
            // Inform users of the reversible nature (accessibility hint covers this)
        }
        .padding()
        .onAppear {
            // Announce prompt to VoiceOver users
            UIAccessibility.post(
                notification: .announcement,
                argument: "Datenschutz-Einstellung erforderlich. Zwei Optionen verfügbar."
            )
        }
    }
}