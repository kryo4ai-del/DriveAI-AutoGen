// Core/Accessibility/A11yModifiers.swift

struct AccessibleTextField: View {
    let label: String
    let systemImage: String
    @Binding var text: String
    var isSecure: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(label, systemImage: systemImage)
                .font(.subheadline.weight(.semibold))
            
            TextField(label, text: $text)
                .accessibilityLabel(label)
                .accessibilityHint("Enter your \(label.lowercased())")
        }
    }
}