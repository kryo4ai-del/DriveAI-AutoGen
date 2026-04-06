struct HighContrastBorderedButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) var isEnabled
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.primary)  // Always high contrast
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .border(Color.primary, width: 2)
            .cornerRadius(8)
            .opacity(isEnabled ? 1.0 : 0.5)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
}

// Usage:
Button(action: { viewModel.dismissConsent() }) {
    Text("Später entscheiden")
}
.buttonStyle(HighContrastBorderedButtonStyle())