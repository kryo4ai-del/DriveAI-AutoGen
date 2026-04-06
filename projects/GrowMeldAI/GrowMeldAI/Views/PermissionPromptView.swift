// ✅ FIX: Use SwiftUI accessibility modifiers for heading hierarchy

struct PermissionPromptView: View {
    var viewModel: PermissionFlowViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Heading
            Text("Kamera erforderlich")
                .font(.title2)
                .fontWeight(.semibold)
                .accessibilityAddTraits(.isHeader)  // ✅ Mark as heading
                .accessibilityHeading(.h1)  // iOS 17+
            
            // Description (semantic relationship)
            Text("Wir benötigen Zugriff auf die Kamera, um Ihren Führerschein zu erfassen und die Identitätsprüfung durchzuführen.")
                .font(.body)
                .lineLimit(nil)
                .accessibilityHeading(.h2)  // Subheading
            
            // Action buttons (semantic grouping)
            VStack(spacing: 12) {
                Button(action: { viewModel.grantPermission() }) {
                    Text("Zugriff erlauben")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .accessibilityLabel("Kamerazugriff erlauben")
                .accessibilityHint("Ermöglicht DriveAI, Fotos Ihres Führerscheins zu machen")
                
                Button(action: { viewModel.skipForNow() }) {
                    Text("Später"
                }
                .accessibilityLabel("Später")
                .accessibilityHint("Überspringt die Kamera-Erfassung für jetzt")
            }
            .accessibilityElement(children: .combine)  // Group buttons logically
        }
        .padding(20)
        .accessibilityElement(children: .preserve)  // Maintain internal structure for VoiceOver
    }
}