extension ProfileView {
    var body: some View {
        VStack {
            // ... existing profile content
            
            if shouldShowVariantDisclosure() {
                VStack(alignment: .leading, spacing: 8) {
                    Label("Feedback-Stil", systemImage: "info.circle")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("Wir testen zwei Arten, Fortschritt zu zeigen. Dein Feedback hilft uns.")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 12) {
                        Button(action: { showFeedbackForm() }) {
                            Text("Feedback geben")
                                .font(.caption)
                        }
                        .buttonStyle(.bordered)
                        
                        Button(action: { toggleVariantDisclosure() }) {
                            Text("Verstanden")
                                .font(.caption)
                        }
                        .buttonStyle(.borderless)
                    }
                }
                .padding(12)
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
        }
    }
    
    private func shouldShowVariantDisclosure() -> Bool {
        // Show once per session or only on first variant exposure
        !UserDefaults.standard.bool(forKey: "variantDisclosureShown")
    }
}